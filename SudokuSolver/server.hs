{-# LANGUAGE OverloadedStrings #-}
 
import Network.Wai
import Network.Wai.Application.Static
import Network.Wai.Handler.Warp (run)
import Network.Wai.Parse (parseRequestBody, lbsBackEnd)
import Network.HTTP.Types (status200, methodGet, methodPost)
import Network.HTTP.Types.Header (hContentType)
import Blaze.ByteString.Builder (copyByteString)
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.UTF8 as BU
import qualified Data.ByteString.Char8 as C
import Data.Monoid
import Sudoku
 
main = do
    let port = 3000
    putStrLn $ "Listening on port " ++ show port
    run port app -- (staticApp (defaultFileServerSettings "./views"))

app req respond 
    | requestMethod req == methodPost
        = do
            (params, _) <- parseRequestBody lbsBackEnd req
            let board = C.concat $ map (\(x,y) -> C.concat [x,y]) params
            let string_board = C.unpack board
            putStrLn $ show string_board
            let result = solve $readSudoku string_board
            respond $
                case pathInfo req of
                    ["solved"] -> responseBuilder status200 [ ("Content-Type", "text/plain") ] $ mconcat $ map copyByteString
                                    [BU.fromString $ show result]
                    x -> index x
    | otherwise
        =   do
                respond $
                    case pathInfo req of            
                        ["yay"] -> yay
                        x -> index x

yay = responseBuilder status200 [ ("Content-Type", "text/html") ] $ mconcat $ map copyByteString
    [ "yay" ]

index x = responseFile status200 [("Content-Type", "text/html")] "views/index.html" Nothing


