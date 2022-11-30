#### 0.7.2 (???)

  * Fix compatibility with GHC 9.0 and 9.2 (PR #7, thanks @edsko).
  
  * Introduce new `runXCommandsXWithSetup` which allow for monadic
    initialization of the state machine for each test case execution.

#### 0.7.1 (2021-8-17)

  * Update links and references from the old archived repo at the
    `advancedtelematic` Github organisation to the active fork of the repo at
    the Github user `stevana`.

#### 0.7.0 (2020-3-17)

  * Add Stack resolver lts-15 and drop lts-11;

  * High-level interface to the state machine API (PR #355) -- this
    captures the patterns described in
    http://www.well-typed.com/blog/2019/01/qsm-in-depth/ as a proper
    Haskell abstraction;

  * Experimental support for Markov chain-base command generation and
    reliability calculations;

  * forAllParallelCommands now gets another argument with type Maybe
    Int, indicating the minimum number of commands we want a test case
    to have. `Nothing` provides old functionality;

  * Fixed a bug in the parallel case for the mock function (PR #348) and
    other bugs related to references in the parallel case;

  * Add a new field in the StateMachine called cleanup. This function
    can be used to ensure resources are cleaned between tests.
    `noCleanup` can be used to achieve the older functionality;

  * Improved labelling;

  * Generalize parallelism, so that more than two threads can be used
    (PR #324);

  * Option to print dot visualisation of failed examples;

  * Handle exceptions better and provide better output.

#### 0.6.0 (2019-1-15)

  This is a breaking release. See mentioned PRs for how to upgrade your code,
  and feel free to open an issue if anything isn't clear.

  * Generalise shrinking so that it might depend on the model (PR #263);

  * Drop support for GHC 8.0.* or older, by requiring base >= 4.10 (PR #267). If
    you need support for older GHC versions, open a ticket;

  * Use Stack resolver lts-13 as default (PR #261);

  * Generalise the `GConName` type class to make it possible to use it for
    commands that cannot have `Generic1` instances. Also rename the type class
    to `CommandNames` (PR #259).

#### 0.5.0 (2019-1-4)

  The first and third item in the below list might break things, have a look at
  the diffs of the PRs on how to fix your code (feel free to open an issue if it
  isn't clear).

  * Allow the user to explicitly stop the generation of commands (PR #256);
  * Fix shrinking bug (PR #255);
  * Replace MonadBaseControl IO with MonadUnliftIO (PR #252);
  * Check if the pre-condition holds before executing an action (PR #251).

#### 0.4.3 (2018-12-7)

  * Support QuickCheck-2.12.*;
  * Use new compact diffing of records from tree-diff library when displaying
    counterexamples;
  * Explain mock better in the README;
  * Handle exceptions more gracefully;
  * Show, possibly multiple, counterexample when parallel property fails.

#### 0.4.2 (2018-9-3)

  * Fix bug that made tests fail on systems without docker;
  * Remove some unused dependencies found by the weeder tool.

#### 0.4.1 (2018-8-31)

  * Minor fixes release:

    - Fix broken link and code in README;
    - Disable web server tests when docker isn't available (issue #222).

#### 0.4.0 (2018-8-21)

  * Major rewrite, addressing many issues:

    - The output of sequential runs now shows a diff of how the model changed in
      each step (related to issue #77);

    - The datatype of actions was renamed to commands and no longer is a GADT
      (discussed in issue #170, also makes issue #196 obsolete);

    - Commands can now return multiple references (issue #197);

    - Global invariants can now more easily be expressed (issue #200);

    - Counterexamples are now printed when post-conditions fail (issue #172).

#### 0.3.1 (2018-1-15)

  * Remove upper bounds for dependencies, to easier keep up with
    Stackage nightly.

#### 0.3.0 (2017-12-15)

  * A propositional logic module was added to help provide better
    counterexamples when pre- and post-conditions don't hold;

  * Generation of parallel programs was improved (base on
    a [comment](https://github.com/Quviq/QuickCheckExamples/issues/2) by
    Hans Svensson about how Erlang QuickCheck does it);

  * Support for semantics that might fail was added;

  * Pretty printing of counterexamples was improved.

#### 0.2.0

  * Z-inspired definition of relations and associated operations were
    added to help defining concise and showable models;

  * Template Haskell derivation of `shrink` and type classes: `Show`,
    `Constructors`, `HFunctor`, `HFoldable`, `HTraversable`;

  * New and more flexible combinators for building sequential and
    parallel properties replaced the old clunky ones;

  * Circular buffer example was added;

  * Two examples of how to test CRUD web applications were added.

#### 0.1.0

  * The API was simplified, thanks to ideas stolen from
    [Hedgehog](https://github.com/hedgehogqa/haskell-hedgehog/commit/385c92f9dd0aa7e748fc677b2eeead5e3572685f).

#### 0.0.0

  * Initial release.
