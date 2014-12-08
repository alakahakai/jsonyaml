import           Control.Applicative        ((<$>))
import           Control.Monad              (forM_)
import           Data.Aeson                 (eitherDecode)
import qualified Data.ByteString            as B
import qualified Data.ByteString.Lazy.Char8 as BLC
import qualified Data.Yaml                  as Y
import           System.Environment         (getArgs)
import           System.Exit                (exitFailure)

helpMessage :: IO ()
helpMessage = putStrLn "Usage: json2yaml <FILE> [<FILE> ..]\nFor stdin input, use - as FILE" >> exitFailure

printYAML :: Show a => Either a Y.Value -> IO B.ByteString
printYAML x = case x of
  Left err -> print err >> exitFailure
  Right v -> return $ Y.encode (v :: Y.Value)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> helpMessage
    _ ->
      forM_ args $ \arg ->
        case arg of
          "-" -> B.getContents >>= printYAML . Y.decodeEither' >>= B.putStr
          _ -> eitherDecode <$> BLC.readFile arg >>= printYAML >>= B.writeFile (arg ++ ".yaml")
