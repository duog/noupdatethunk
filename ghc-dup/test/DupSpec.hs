{-# language ScopedTypeVariables #-}
{-# language BangPatterns #-}
{-# OPTIONS_GHC -O2 #-}
module DupSpec where

import Data.IORef
import Control.Monad

import Data.Time

import Test.Tasty
import Test.Tasty.Hspec
import Test.Hspec
import GHC.IO.Unsafe
import Control.Exception

import GHC.Dup

fibRef :: IORef Int
fibRef = unsafePerformIO $ newIORef 0
{-# noinline fibRef #-}

incFibRef :: IO ()
incFibRef = modifyIORef' fibRef (+1)

-- getFib :: Int -> Int
-- getFib  =

-- fib_ :: [Int]
-- fib_ = let
--   getInt x = unsafePerformIO $ incFibRef $> x
--   {$}
--   ints = [0..]
--   in coerce $ liftA2 (+) (Ziplist ints) (ZipList $ tail ints)


spec_enum :: Spec
spec_enum = describe "grandfathered enum" $ do
    statically_unknown :: Int <- length . show <$> runIO getCurrentTime
    r <- runIO $ newIORef 0
    let
      {-# noinline mk_elem #-}
      mk_elem i = unsafePerformIO $ do
        modifyIORef' r (+i)
        pure i
    let long_list = [mk_elem i | i <- [statically_unknown..10000]]
        sum_long_list = runIO $ do
          Box x <- dupIO long_list
          evaluate (sum x)

    x1 <- sum_long_list
    acc1 <- runIO $ readIORef r
    it "foo" $ acc1 `shouldNotBe` 0
    x2 <- sum_long_list
    acc2 <- runIO $ readIORef r
    it "bar" $ (acc1 * 2) `shouldBe` acc2
