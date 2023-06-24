{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module CalculatorExample (tests) where

import Capnp.Rpc (ConnConfig (..), handleConn, requestBootstrap, withConn)
import Capnp.Rpc.Transport (socketTransport)
import Capnp.TraversalLimit (defaultLimit)
import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (race_)
import Control.Exception.Safe (throwIO, try)
import Data.Default (def)
import Data.Foldable (for_)
import Data.String (fromString)
import Data.Word
import qualified Examples.Rpc.CalculatorClient
import qualified Examples.Rpc.CalculatorServer
import Network.Simple.TCP (connect, serve)
import System.Environment (getEnv)
import System.Exit (ExitCode (ExitSuccess))
import System.IO.Error (isDoesNotExistError)
import System.Process (callProcess, readProcessWithExitCode)
import Test.Hspec

getExe :: String -> IO (Maybe FilePath)
getExe varName =
  try (getEnv varName) >>= \case
    Left e
      | isDoesNotExistError e -> do
          putStrLn $ varName ++ " not set; skipping."
          pure Nothing
      | otherwise ->
          throwIO e
    Right path ->
      pure (Just path)

tests :: Spec
tests = describe "Check our example against the C++ implementation" $ do
  clientPath <- runIO $ getExe "CXX_CALCULATOR_CLIENT"
  serverPath <- runIO $ getExe "CXX_CALCULATOR_SERVER"
  for_ clientPath $ \clientPath ->
    it "Should pass when run against our server" $
      Examples.Rpc.CalculatorServer.main
        `race_` (waitForServer >> cxxClient clientPath 4000)
  for_ serverPath $ \serverPath ->
    it "Should pass when run against our client" $
      cxxServer serverPath 4000
        `race_` (waitForServer >> Examples.Rpc.CalculatorClient.main)
  for_ ((,) <$> clientPath <*> serverPath) $ \(clientPath, serverPath) ->
    it "Should pass when run aginst the C++ server, proxied through us." $
      cxxServer serverPath 4000
        `race_` (waitForServer >> runProxy 4000 6000)
        -- we wait twice, so that the proxy also has time to start:
        `race_` (waitForServer >> waitForServer >> cxxClient clientPath 6000)
  where
    -- \| Give the server a bit of time to start up.
    waitForServer :: IO ()
    waitForServer = threadDelay 100000

    cxxServer :: FilePath -> Word16 -> IO ()
    cxxServer path port =
      callProcess path ["localhost:" ++ show port]
    cxxClient :: FilePath -> Word16 -> IO ()
    cxxClient path port = do
      (eStatus, out, err) <- readProcessWithExitCode path ["localhost:" ++ show port] ""
      (eStatus, out, err)
        `shouldBe` ( ExitSuccess,
                     unlines
                       [ "Evaluating a literal... PASS",
                         "Using add and subtract... PASS",
                         "Pipelining eval() calls... PASS",
                         "Defining functions... PASS",
                         "Using a callback... PASS"
                       ],
                     ""
                   )

-- | @'runProxy' serverPort clientPort@ connects to the server listening at
-- localhost:serverPort, requests its bootstrap interface, and then listens
-- on clientPort, offering a proxy of the server's bootstrap interface as our
-- own.
runProxy :: Word16 -> Word16 -> IO ()
runProxy serverPort clientPort =
  connect "localhost" (fromString $ show serverPort) $ \(serverSock, _addr) ->
    withConn (socketTransport serverSock defaultLimit) def {debugMode = True} $ \conn -> do
      client <- requestBootstrap conn
      serve "localhost" (fromString $ show clientPort) $ \(clientSock, _addr) ->
        handleConn
          (socketTransport clientSock defaultLimit)
          def
            { bootstrap = Just client,
              debugMode = True
            }
