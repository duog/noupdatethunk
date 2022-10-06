{-|
Module      :  GHC.dup
Copyright   :  (c) 2012 Joachim Breitner
License     :  BSD3
Maintainer  :  Joachim Breitner <mail@joachim-breitner.de>
Stability   :  experimental
Portability :  not at all

This module provides two new operations, 'GHC.Dup.dup' and 'GHC.Dup.deepDup',
that allow you to prevent the result of two evaluations of the same
expression to be shared.
-}

{-# LANGUAGE GHCForeignImportPrim, MagicHash, UnboxedTuples, UnliftedFFITypes, RankNTypes #-}

{-# OPTIONS_HADDOCK prune #-}

module GHC.Dup (Box(..), dupIO, unsafeDup) where

import GHC.Dup.Prim(Box(..))
import GHC.Dup.IO





-- foreign import prim "deepDupClosure" deepDupClosure :: Word# -> Word#

-- -- This is like 'deepDup', but with a different type, and should not be used by
-- -- the programmer.
-- deepDupFun :: a -> a
-- deepDupFun a =
--     case deepDupClosure (aToWord# (unsafeCoerce# a)) of { x ->
--     case wordToA# x of { Box x' ->
--         unsafeCoerce# x'
--     }}
-- {-# NOINLINE deepDupFun #-}

-- -- | This copies the parameter and changes all references therein so that when
-- -- they are evaluated, they are copied again. This ensures that everything put on the heap by a function that wraps all is parameters in 'deepDup' can be freed after the evaluation.
-- deepDup :: a -> Box a
-- deepDup a =
--     case deepDupClosure (aToWord# (unsafeCoerce# a)) of { x ->
--     case wordToA# x of { Box x' ->
--         Box (unsafeCoerce# x')
--     }}
-- {-# NOINLINE deepDup #-}
