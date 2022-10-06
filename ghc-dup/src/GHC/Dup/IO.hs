{-# language MagicHash #-}
{-# language UnboxedTuples #-}
{-# language ScopedTypeVariables #-}
module GHC.Dup.IO(dupIO, unsafeDup) where

import GHC.IO(IO(..), unsafePerformIO)

import GHC.Dup.Prim

dupIO :: forall a. a -> IO (Box a)
dupIO a = IO $ \s -> case dup# a s of
  (# s1, b #) -> (# s1, Box b #)

{-# noinline unsafeDup #-}
unsafeDup :: a -> Box a
unsafeDup a = unsafePerformIO (dupIO a)
