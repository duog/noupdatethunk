{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Control.Exception
import Data.Foldable
import Options.Applicative

import qualified GHC.Dup as Dup
import Data.Functor

{-------------------------------------------------------------------------------
  Infrastructure
-------------------------------------------------------------------------------}

data UseDup = UseDup | NoDup

-- | Thin wrapper around dup to allow to toggle easily between using it and not
mdup :: UseDup -> a -> a
mdup NoDup  x = x
mdup UseDup x = case Dup.dup x of Dup.Box x' -> x'

-- |  Exception handler
--
-- We don't expect any exceptions, but the mere presence of the exception
-- handler will cause stuff to be retained in memory if we're not careful. This
-- is explained in detail in
-- <https://well-typed.com/blog/2016/09/sharing-conduit/#motivation>.
retry :: IO a -> IO a
retry io = do
    ma <- try io
    case ma of
      Right a -> return a
      Left (_ :: SomeException) -> retry io

{-------------------------------------------------------------------------------
  Sources

  <https://well-typed.com/blog/2016/09/sharing-conduit/#sources>
-------------------------------------------------------------------------------}

-- | Simplest form of a conduit: yield only
--
-- This is isomorphic to a list, of course, but by defining it manually, we
-- avoid any kind of rules or other optimizations that ghc may or may not do.
data Source o =
    SourceDone
  | SourceYield o (Source o)

yieldFrom :: Int -> Source Int
yieldFrom 0 = SourceDone
yieldFrom n = SourceYield n $ yieldFrom (n - 1)

printYields :: forall o. Show o => UseDup -> Source o -> IO ()
printYields useDup = go
  where
    go :: Source o -> IO ()
    go = mdup useDup <&> \case
        SourceDone      -> return ()
        SourceYield o k -> print o >> go k

testSource :: UseDup -> IO ()
testSource useDup = retry $ printYields useDup (yieldFrom 1000000)

{-------------------------------------------------------------------------------
  Command line options
-------------------------------------------------------------------------------}

data Options = Options {
      optionsUseDup   :: UseDup
    , optionsTestCase :: TestCase
    }

data TestCase =
    TestSource

getOptions :: IO Options
getOptions = execParser opts
  where
    opts = info (parseOptions <**> helper) $ mconcat [
          fullDesc
        , progDesc "Test the use of dup# to solve sharing problems"
        ]

parseOptions :: Parser Options
parseOptions = Options
    <$> parseUseDup
    <*> parseTestCase

parseUseDup :: Parser UseDup
parseUseDup = asum [
      flag' UseDup $ mconcat [
          long "use-dup"
        , help "Use dup#"
        ]
    , flag' NoDup $ mconcat [
          long "no-dup"
        , help "Do not use dup#"
        ]
    ]

parseTestCase :: Parser TestCase
parseTestCase = subparser $ mconcat [
      cmd "source" (pure TestSource) "Source"
    ]
  where
    cmd :: String -> Parser a -> String -> Mod CommandFields a
    cmd l p d = command l $ info p (progDesc d)

{-------------------------------------------------------------------------------
  Main
-------------------------------------------------------------------------------}

main :: IO ()
main = do
    Options{..} <- getOptions
    case optionsTestCase of
      TestSource -> testSource optionsUseDup