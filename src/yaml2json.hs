import           Data.Aeson (Value)
import           Data.Aeson.Encode.Pretty (encodePretty)
import           System.Environment (getArgs)
import           Control.Monad (forM_)
import           System.Exit (exitFailure)
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy.Char8 as BLC
import qualified Data.Yaml as Y

helpMessage :: IO ()
helpMessage = putStrLn "Usage: yaml2json <FILE> [<FILE> ..]\nFor stdin input, use - as FILE" >> exitFailure

printJSON :: Show a => Either a Value -> IO BLC.ByteString
printJSON x = case x of
  Left err -> print err >> exitFailure
  Right v -> return $ encodePretty (v :: Value)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> helpMessage
    _ ->
      forM_ args $ \arg ->
        case arg of
          "-" -> B.getContents >>= printJSON . Y.decodeEither' >>= BLC.putStr
          _ -> Y.decodeFileEither arg >>= printJSON >>= BLC.writeFile (arg ++ ".json")
