{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE ScopedTypeVariables    #-}
{-# LANGUAGE TypeApplications       #-}
{-# LANGUAGE TypeFamilyDependencies #-}
{-# LANGUAGE UndecidableInstances   #-}

-- | Class that will be used when diffing values. It ought to be instantiated
-- with our vendored @tree-diff@ (see "Test.StateMachine.Diffing.TreeDiff"), or
-- other akin implementations.

module Test.StateMachine.Diffing (CanDiff(..), ediff) where

import           Data.Proxy
                   (Proxy(..))
import qualified Prettyprinter                 as PP
import qualified Prettyprinter.Render.Terminal as PP

class CanDiff x where
  -- | Expressions that will be diffed
  type AnExpr x
  -- | What will the diff of two @AnExpr@s result in
  type ADiff x

  -- | Extract the expression from the data
  toDiff :: x -> AnExpr x

  -- | Diff two expressions
  exprDiff :: Proxy x -> AnExpr x -> AnExpr x -> ADiff x

  -- | Output a diff in compact form
  diffToDocCompact :: Proxy x -> ADiff x -> PP.Doc PP.AnsiStyle

  -- | Output a diff
  diffToDoc :: Proxy x -> ADiff x -> PP.Doc PP.AnsiStyle

  -- | Output an expression
  exprToDoc :: Proxy x -> AnExpr x -> PP.Doc PP.AnsiStyle

ediff :: forall x. CanDiff x => x -> x -> ADiff x
ediff x y = exprDiff (Proxy @x) (toDiff x) (toDiff y)
