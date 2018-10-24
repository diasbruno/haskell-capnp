{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE OverloadedStrings     #-}
module Tests.Module.Capnp.Rpc (rpcTests) where

import Control.Concurrent.STM
import Data.Word
import Test.Hspec

import Control.Concurrent       (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Concurrent.Async (race_)
import Control.Monad.IO.Class   (MonadIO, liftIO)
import Data.Function            ((&))

import Capnp (ConstMsg, def)

import Capnp.Gen.Aircraft.Pure
import Capnp.Rpc

import qualified Capnp.Gen.Echo.Pure as E

rpcTests :: Spec
rpcTests = do
    echoTests
    aircraftTests

-------------------------------------------------------------------------------
-- Tests using echo.capnp. This is the schema used by the example.
-------------------------------------------------------------------------------

echoTests :: Spec
echoTests = describe "Echo server & client" $
    it "Should echo back the same message." $ do
        -- XXX: this is copypasta from the examples dir. We should find
        -- a way to share more of the code, while keeping the example
        -- useful as documentation.
        (clientTrans, serverTrans) <- transportPair
        let runClient = runVat $ (vatConfig $ const clientTrans)
                { debugMode = True
                , withBootstrap = Just $ \client -> do
                    let echoSrv = E.Echo client
                    let msgs =
                            [ def { E.query = "Hello #1" }
                            , def { E.query = "Hello #2" }
                            ]
                    rets <- traverse (\msg -> echoSrv & E.echo'echo msg) msgs
                    liftIO $ rets `shouldBe`
                        [ def { E.reply = "Hello #1" }
                        , def { E.reply = "Hello #2" }
                        ]
                    stopVat
                }
            runServer = runVat $ (vatConfig $ const serverTrans)
                { debugMode = True
                , offerBootstrap = Just $ do
                    E.Echo client <- E.export_Echo TestEchoServer
                    pure client
                }
        race_ runServer runClient

data TestEchoServer = TestEchoServer

instance E.Echo'server_ TestEchoServer where
    echo'echo params TestEchoServer = pure def { E.reply = E.query params }

-------------------------------------------------------------------------------
-- Tests using aircraft.capnp.
-------------------------------------------------------------------------------

aircraftTests :: Spec
aircraftTests = describe "aircraft.capnp rpc tests" $ do
    it "A counter should maintain state" $ do
        (ct, st) <- transportPair
        let runClient = runVat $ (vatConfig $ const ct)
                { debugMode = True
                , withBootstrap = Just $ \client -> do
                    let ctr = CallSequence client
                    results <- sequence $ replicate 4 $
                        ctr & callSequence'getNumber def
                    liftIO $ results `shouldBe`
                        [ def { n = 1 }
                        , def { n = 2 }
                        , def { n = 3 }
                        , def { n = 4 }
                        ]
                    stopVat
                }
            runServer = runVat $ (vatConfig $ const st)
                { debugMode = True
                , offerBootstrap = Just $ do
                    CallSequence client <- newTestCtr >>= export_CallSequence
                    pure client
                }
        race_ runServer runClient
    xit "A counter factory returns a new counter each time." $ do
        (ct, st) <- transportPair
        let runClient = runVat $ (vatConfig $ const ct)
                { debugMode = True
                , withBootstrap = Just $ \client -> do
                    let factory = CounterFactory client
                    let newCounter start = do
                            CounterFactory'newCounter'results{counter} <-
                                factory & counterFactory'newCounter def { start }
                            pure counter

                    ctrA <- newCounter 2
                    ctrB <- newCounter 0

                    let bumpN ctr n = sequence $ replicate n $
                            ctr & callSequence'getNumber def

                    r <- bumpN ctrA 4
                    liftIO $ r `shouldBe`
                        [ def { n = 3 }
                        , def { n = 4 }
                        , def { n = 5 }
                        , def { n = 6 }
                        ]

                    r <- bumpN ctrB 2
                    liftIO $ r `shouldBe`
                        [ def { n = 1 }
                        , def { n = 2 }
                        ]

                    ctrC <- newCounter 30

                    r <- bumpN ctrA 3
                    liftIO $ r `shouldBe`
                        [ def { n = 7 }
                        , def { n = 8 }
                        , def { n = 9 }
                        ]

                    r <- bumpN ctrC 1
                    liftIO $ r `shouldBe` [ def { n = 31 } ]

                    stopVat
                }
            runServer = runVat $ (vatConfig $ const st)
                { debugMode = True
                , offerBootstrap = Just $ do
                    CounterFactory client <- export_CounterFactory TestCtrFactory
                    pure client
                }
        race_ runServer runClient

data TestCtrFactory = TestCtrFactory

instance CounterFactory'server_ TestCtrFactory where
    counterFactory'newCounter _ TestCtrFactory = do
        ctr <- newTestCtr >>= export_CallSequence
        pure CounterFactory'newCounter'results { counter = ctr }

newTestCtr :: MonadIO m => m TestCtrServer
newTestCtr = liftIO $ TestCtrServer <$> newTVarIO 0

newtype TestCtrServer = TestCtrServer (TVar Word32)

instance CallSequence'server_ TestCtrServer  where
    callSequence'getNumber _ (TestCtrServer tvar) = do
        ret <- liftIO $ atomically $ do
            modifyTVar' tvar (+1)
            readTVar tvar
        pure def { n = ret }

-------------------------------------------------------------------------------
-- Utilties used by the tests.
-------------------------------------------------------------------------------

-- | Make a pair of in-memory transports that are connected to one another. i.e,
-- messages sent on one are received on the other.
transportPair :: MonadIO m => m (Transport m, Transport m)
transportPair = liftIO $ do
    varA <- newEmptyMVar
    varB <- newEmptyMVar
    pure
        ( mVarTransport varA varB
        , mVarTransport varB varA
        )

-- | @'mVarTransport' sendVar recvVar@ is a 'Transport' which sends messages by
-- putting them into @sendVar@, and receives messages by taking them from
-- @recvVar@.
mVarTransport :: MonadIO m => MVar ConstMsg -> MVar ConstMsg -> Transport m
mVarTransport sendVar recvVar = Transport
    { sendMsg = liftIO . putMVar sendVar
    , recvMsg = liftIO (takeMVar recvVar)
    }