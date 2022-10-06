{-# language MagicHash #-}
{-# language UnboxedTuples #-}

module GHC.Dup.ST(dup) where

import GHC.ST
import GHC.Dup.Prim

dup :: a -> ST s (Box a)
dup a = ST $ \s -> case dup# a s of
  (# s1, b #) -> (# s1, Box b #)
