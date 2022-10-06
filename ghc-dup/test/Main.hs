{-# LANGUAGE LambdaCase, PatternSynonyms #-}

module Main where

import Control.Exception
import System.Environment
import System.IO
import System.IO.Error

-- import GHC.Debug.Stub

retry :: IO a -> IO a
retry io = do
    ma <- try io
    -- putStrLn "Inserting artificial pause for ghc-debug. Press enter to continue"
    -- _ <- getLine
    case ma of
      Right a -> return a
      Left (_ :: SomeException) -> retry io

{-------------------------------------------------------------------------------
  Source
-------------------------------------------------------------------------------}

data Source = SourceOutput_ {-# UNPACK #-} !Int Source | SourceDone_

pattern SourceOutput i s <- SourceOutput_ i s
pattern SourceDone  <- SourceDone_

bigSource :: IO Source
bigSource = go 10_000_000
  where
    go :: Int -> IO Source
    go 0 = mkSourceDone
    go n = mkSourceOuptut n =<< (go (pred n))

runSourcePrintAll :: Source -> IO ()
runSourcePrintAll =
   \s -> withFile "log" WriteMode $ \h -> go h s
  where
    go :: Handle -> Source -> IO ()
    go _  SourceDone         = return ()
    go h (SourceOutput n k) = hPrint h n >> go h k

-- This variant is less interesting: the only thing that is "retained" is the
-- final print
runSourcePrintResult :: Source -> IO ()
runSourcePrintResult =
    go 0
  where
    go :: Int -> Source -> IO ()
    go !acc  SourceDone        = print acc
    go !acc (SourceOutput n k) = go (acc + n) k

{-------------------------------------------------------------------------------
  Sink
-------------------------------------------------------------------------------}

data Sink = SinkInput (Maybe Int -> Sink) | SinkDone Int

sinkCountEven :: Sink
sinkCountEven = go 0
  where
    go :: Int -> Sink
    go !acc = SinkInput $ \case
                Nothing            -> SinkDone acc
                Just i | even i    -> go (acc + 1)
                       | otherwise -> go  acc

-- This one is ok: nothing can be floated out
sinkSum :: Sink
sinkSum = go 0
  where
    go :: Int -> Sink
    go !acc = SinkInput $ \case
                Nothing -> SinkDone acc
                Just i  -> go (acc + i)

runSinkFromFile :: Sink -> IO ()
runSinkFromFile =
    \s -> withFile "lotsanumbers" ReadMode $ go s
  where
    go :: Sink -> Handle -> IO ()
    go (SinkDone n)  _ = print n
    go (SinkInput k) h = do
        mLine <- try $ hGetLine h
        case mLine of
          Left e | isEOFError e -> go (k Nothing) h
          Left e                -> throw e
          Right line            -> go (k (Just (read line))) h

{-------------------------------------------------------------------------------
  Application driver
-------------------------------------------------------------------------------}

main :: IO ()
main = -- withGhcDebug $
  do
    -- putStrLn "Debuggee is starting"
    [arg] <- getArgs
    print arg
    case arg of
      "0" ->         runSourcePrintAll    bigSource     -- O(1)
      "1" -> retry $ runSourcePrintAll    bigSource     -- O(n)
      "2" ->         runSourcePrintResult bigSource     -- O(1)
      "3" -> retry $ runSourcePrintResult bigSource     -- O(1)
      "4" ->         runSinkFromFile      sinkCountEven -- O(1)
      "5" -> retry $ runSinkFromFile      sinkCountEven -- O(n)
      "6" ->         runSinkFromFile      sinkSum       -- O(1)
      "7" -> retry $ runSinkFromFile      sinkSum       -- O(1)
      _   -> error "invalid argument"
