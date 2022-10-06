{-# language MagicHash #-}
{-# language UnboxedTuples #-}
{-# language RankNTypes #-}
{-# language GHCForeignImportPrim #-}
{-# language UnliftedFFITypes #-}
module GHC.Dup.Prim(Box(..), dup# ) where

import GHC.Exts(Any, Word#, State#, Word(..),unsafeCoerce#,)
-- This is a datatype that has the same layout as Ptr, so that by
-- unsafeCoerce'ing, we obtain the Addr of the wrapped value

-- | The Box datatype allows you to control the time of evaluations of 'dup' or
-- 'deepDup', by pattern-matching on the result.
data Box a = Box { unbox :: a}

-- This is for turning an a to something we can pass to a primitive operation

aToWord# :: Any -> Word#
aToWord# a = case Box a of mb@(Box _) -> case unsafeCoerce# mb :: Word of W# addr -> addr

wordToA# :: Word# -> Box Any
wordToA# a = unsafeCoerce# (W# a) :: Box Any

-- This is for actually calling the primitive operation

foreign import prim "dupClosure" dupClosure# :: forall s.  Any -> State# s -> (# State# s , Any #)

{-# NOINLINE dup# #-}
-- | Dup copies a the parameter and returns it. The copy is shallow, i.e.
-- referenced thunks are still shared between the parameter and its copy.
dup# :: forall a s. a -> State# s -> (# State# s, a #)
dup# a s0 = case dupClosure# (unsafeCoerce# a) s0 of (# s1, x #) -> (# s1, unsafeCoerce# x #)
