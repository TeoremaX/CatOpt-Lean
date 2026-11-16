# v0.2 — Typed enumeration and formally checked static budgets

The code is in `CatOpt/DSL/Synthesis.lean`. Compile-time regression checks
are in `CatOpt/Tests/Synthesis.lean`, imported by `CatOpt.lean` so `lake build`
includes them. This is **bounded candidate generation**, not a claim to have
invented, evaluated or automatically selected better optimization algorithms.

## 1. Why add a synthesis layer?

There are two distinct problems:

1. An external user may submit an **untyped sequence** of primitive actions.
   Its transitions must be checked before producing any executable DSL program.
2. A synthesizer may create pipelines **directly in typed form**, so illegal
   sequences never exist in its search space. This can be more efficient than
   generating invalid sequences and throwing them away.

The v0.2 API supports both. Neither requires changing the previously checked
`Category`, `Properties` or `DSL.Search` layers.

## 2. Raw list checker

`RawAction` is a non-indexed type with five constructors: `construct`, `shake`,
`destroyRepair`, `localSearch`, `accept`. A transition is valid only when its
input phase matches one of the declared stage edges:

```text
ready -- construct/shake/destroyRepair --> candidate
candidate -- localSearch -------------> improved
improved -- accept --------------------> ready
```

`compileStep` has dependent type:

```lean
Stage → RawAction → Option (Σ t : Stage, SearchProgram start t)
```

More precisely, its implementation takes a fixed `start : Stage` and returns
`Option (SomeProgram start)`. `compileRaw` uses these proof-relevant intermediate
stages to accumulate a typed syntax tree, or stops with `none` on the first
bad transition. `compileClosed` additionally requires `ready` at the end.

Examples checked by Lean:

```lean
compileClosed [.accept]                           = none
compileClosed [.shake 2, .accept]                 = none
compileClosed [.construct 3, .construct 5]       = none
compileClosed [.construct 3, .localSearch]        = none
(compileClosed [.construct 3, .localSearch, .accept]).isSome = true
```

These are protocol checks, *not* feasibility checks. Concrete feasibility is
guaranteed by each operator's `SafeHom.preserves` field when implementing the
`Primitives` interface.

## 3. Typed round grammar

A `RoundStart` is one of three parameterized generators. `round` always emits
exactly the three-arrow sequence:

```text
start candidate generator → localSearch → accept
```

`compileRounds` composes such rounds into a `ready → ready` program. By
construction, every generated program is type-correct. Moreover:

- `compileRounds_atomCount`: **exactly 3 × number of rounds** atoms;
- `compileRounds_monotone`: for any feasible primitive implementation,
  accepted-incumbent cost does not increase;
- `compileRounds_synced`: once incumbent/candidate tracks are synchronized,
  executing any number of complete rounds preserves synchronization.

**These are structural claims.** They do not imply that a candidate improves,
that the local search reaches a local/global optimum, or that GRASP/GVNS/IG
have been modeled in their full adaptive/stochastic form.

## 4. Static work estimate (important limitation)

`WorkCosts` is a record of nonnegative **natural-number estimates** supplied
by the user for each primitive. `estimatedCost` is additive across rounds.

`certify costs budget recipe` returns `none` or a `BoundedRecipe` containing
an actual proof of `estimatedCost costs recipe ≤ budget`. Filtering by an
unchecked Boolean alone would not give this proof object.

This says **nothing about real CPU time, memory, or objective evaluations**
unless additional verified contracts connect the estimates to the concrete
implementations. A fixed cost per `localSearch` is especially unrealistic for
an unbounded local search; thus the current estimate must be treated as an
engineering planning variable rather than a performance guarantee.

`enumerate choices maxRounds costs budget` enumerates lists of up to
`maxRounds` round starts from `choices`, then passes each to `certify`. The
empty recipe (identity program) is included. Enumeration is exhaustive **only
within that finite, explicitly supplied grammar**, not among all possible
algorithms. **Importantly, the current code generates all candidate recipes
before filtering by budget:** it does not yet prune partial branches early, and
its time/memory grow exponentially with `maxRounds` and the alphabet size.
No semantic deduplication or objective-based ranking is applied.

For `choices = [construct(3), shake(2), destroyRepair(1)]` and static costs
`3, 2, 4` plus `localSearch=5`, `accept=0`, with `maxRounds=2` and `budget=14`,
there are **5** accepted recipes: one identity, three single rounds, and one
two-round `shake/shake`. The exact cardinality is a compile-time Lean test.

## 5. Separating three levels of trust

| Layer | What it guarantees | What it does not guarantee |
|---|---|---|
| Typing | Valid action-stage transitions | Optimality and termination of arbitrary external code |
| SafeHom/Primitives | Feasibility of returned states | That a mutation improves the objective |
| Monotonic incumbent | Accepted incumbent never gets worse | Better candidate or global optimum |
| BoundedRecipe | Declared static estimate ≤ budget | Real running-time/evaluation-count bound |
| Python TSP | Independent executable benchmark tests | Lean refinement/equivalence |

There is no `sorry`, `admit`, user axiom or appeal to external solvers in the
new proof code. However, **new v0.2 sources have to pass `lake build`** before
they may be described as compiler-verified. The successful Windows build of
v0.1 does not automatically verify newly authored v0.2 files.

## 6. Science and originality

Grammar-based automatic design and component annotations are established
research areas. In particular:

- Mascia et al., *Grammar-based generation of stochastic local search
  heuristics through automatic algorithm configuration tools*,
  Computers & Operations Research 51 (2014), 190–199,
  https://doi.org/10.1016/j.cor.2014.05.020
- Pagnozzi and Stützle, *Evaluating the impact of grammar complexity in
  automatic algorithm design*, International Transactions in Operational
  Research (2020), https://doi.org/10.1111/itor.12902
- *On the automatic generation of metaheuristic algorithms for combinatorial
  optimization problems*, European Journal of Operational Research 318(3)
  (2024), https://doi.org/10.1016/j.ejor.2024.06.001

The 2024 paper already uses requirements/contract annotations to organize an
implicit grammar. Therefore neither "generating algorithms from components"
nor "contracts/primitives permit only valid compositions" alone is novel.
A future contribution must isolate something *stronger and testable*: for
example formal refinement of generated implementations, certified bounds on
real evaluations, or a sound pruning technique with demonstrable savings
compared to competitive grammar-based baselines.

## 7. What we should investigate next

1. Prove that the parser and direct generator coincide on a chosen canonical
   encoding of complete rounds.
2. Introduce actual **measured** evaluation counts into Lean semantics (not a
   free `WorkCosts` assumption), then derive verified resource contracts.
3. Add incremental budget-aware search and sound pruning, distinguishing provably semantics-preserving
   rewrites from unsafe heuristics.
4. Move beyond one local-search primitive; add typed neighbourhoods, rich
   control states and adaptive GVNS transitions.
5. Check the finite Lean execution against a faithful Python reference,
   before claiming correspondence with the TSP benchmark.
