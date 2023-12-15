{-# LANGUAGE DeriveFoldable      #-}
{-# LANGUAGE DeriveFunctor       #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE DeriveTraversable   #-}
{-# LANGUAGE DerivingStrategies  #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module IORefs (prop_IORefs_sequential) where

import           Control.Concurrent
import           Data.Coerce
                   (coerce)
import           Data.Foldable
                   (toList)
import           Data.IORef
import           Data.Map.Strict
                   (Map)
import           GHC.Generics
                   (Generic)
import           Prelude
import           Test.QuickCheck
import           Test.StateMachine

import qualified Data.Map.Strict                   as Map

import           Test.StateMachine.Lockstep.Simple
import           Test.StateMachine.TreeDiff

{-------------------------------------------------------------------------------
  Instantiate the simple API
-------------------------------------------------------------------------------}

data T a

data instance Cmd (T _) h = New | Read h | Update h
  deriving stock (Show, Functor, Foldable, Traversable)

data instance Resp (T a) h = Var h | Val a | Unit ()
  deriving stock (Show, Eq, Functor, Foldable, Traversable)

data instance MockHandle (T _) = MV Int
  deriving stock (Show, Eq, Ord, Generic)

newtype instance RealHandle (T a) = RealVar (Opaque (IORef a))
  deriving stock (Eq, Show, Generic)

type instance MockState (T a) = Map (MockHandle (T a)) a

instance ToExpr (MockHandle (T a))
instance ToExpr (RealHandle (T a))

type instance Tag (T _) = TagCmd

{-------------------------------------------------------------------------------
  Interpreters
-------------------------------------------------------------------------------}

runMock :: a
        -> (a -> a)
        -> Cmd (T a) (MockHandle (T a))
        -> MockState (T a) -> (Resp (T a) (MockHandle (T a)), MockState (T a))
runMock e f cmd m =
    case cmd of
      New      -> let v = MV (Map.size m) in (Var v, Map.insert v e m)
      Read   v -> (Val (m Map.! v), m)
      Update v -> (Unit (), Map.adjust f v m)

runReal :: a
        -> (a -> a)
        -> Cmd (T a) (RealHandle (T a))
        -> IO (Resp (T a) (RealHandle (T a)))
runReal e f cmd =
    case cmd of
      New      -> Var  <$> coerce <$> newIORef e
      Read   r -> Val  <$> readIORef  (coerce r)
      Update r -> Unit <$> slowModify (coerce r) f

slowModify :: IORef a -> (a -> a) -> IO ()
slowModify r f = readIORef r >>= \a -> threadDelay 1000 >> writeIORef r (f a)

{-------------------------------------------------------------------------------
  Generator
-------------------------------------------------------------------------------}

generator :: forall a.
             Model (T a) Symbolic
          -> Maybe (Gen (Cmd (T a) :@ Symbolic))
generator (Model _ hs) = Just $ oneof $ concat [
      withoutHandle
    , if null hs then [] else withHandle
    ]
  where
    withoutHandle :: [Gen (Cmd (T a) :@ Symbolic)]
    withoutHandle = [return $ At New]

    withHandle :: [Gen (Cmd (T a) :@ Symbolic)]
    withHandle = [
        fmap At $ Update <$> genHandle
      , fmap At $ Read   <$> genHandle
      ]

    genHandle :: Gen (Reference (RealHandle (T a)) Symbolic)
    genHandle = elements (map fst hs)

{-------------------------------------------------------------------------------
  Tagging

  We just label with the name of the command, for now.
-------------------------------------------------------------------------------}

data TagCmd = TagNew | TagRead | TagUpdate
  deriving stock (Show)

tagCmds :: [Event (T Int) Symbolic] -> [TagCmd]
tagCmds = map (aux . unAt . cmd)
  where
    aux :: Cmd (T Int) h -> TagCmd
    aux New        = TagNew
    aux (Read   _) = TagRead
    aux (Update _) = TagUpdate

{-------------------------------------------------------------------------------
  Wrapping it all up

  NOTE: The parallel property will fail (intentional race condition).
-------------------------------------------------------------------------------}

ioRefTest :: StateMachineTest (T Int)
ioRefTest = StateMachineTest {
      initMock   = Map.empty
    , generator  = IORefs.generator
    , shrinker   = \_ _ -> []
    , newHandles = toList
    , runMock    = IORefs.runMock 0 (+1)
    , runReal    = IORefs.runReal 0 (+1)
    , cleanup    = \_ -> return ()
    , tag        = tagCmds
    }

prop_IORefs_sequential :: Property
prop_IORefs_sequential = prop_sequential ioRefTest Nothing
