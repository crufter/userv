{-# LANGUAGE OverloadedStrings #-}
 
-- An extremely simple API for our specific usecase (JSON over HTTP).

import qualified Network.Wai                    as W
import qualified Network.Wai.Handler.Warp       as Warp
import qualified Data.Aeson                     as A
import qualified Data.ByteString                as B
import qualified Network.HTTP.Types             as T
import qualified Network.HTTP.Client.Internal   as C
import qualified Data.ByteString.Char8          as C8
import qualified Data.ByteString.Lazy           as BL

-- Starts an HTTP server which expects JSON in the request body,
-- and responds with a JSON in the response body.
--
-- The only data the actual handler receives is the path part of the request URL
-- and the JSON from the request.
serve :: Int -> (B.ByteString -> A.Value -> IO A.Value) -> IO ()
serve portNum handler = Warp.run portNum app
    where
        app :: W.Application
        app req respond = do
            input <- W.lazyRequestBody req
            let path = W.rawPathInfo req
                inpVal' = A.decode input :: Maybe A.Value
            case inpVal' of
                Just inpVal     -> do
                    rsp <- handler path inpVal
                    respond $ W.responseLBS T.status200 [] $ A.encode rsp
                Nothing         -> respond $ W.responseLBS T.status400 [] "{}"

-- Makes a post request to URL with A.Value sent in the request body.
-- The JSON in the response body will be returned.
req :: B.ByteString -> A.Value -> IO (Maybe A.Value)
req url value = do
    -- Getting a new manager here every time is not a good idea
    man <- C.newManager C.defaultManagerSettings
    initReq <- C.parseUrl $ C8.unpack url
    let reqBody = C.RequestBodyBS . B.concat . BL.toChunks $ A.encode value
    rsp <- C.httpLbs initReq{C.requestBody=reqBody} man
    return . A.decode $ C.responseBody rsp
