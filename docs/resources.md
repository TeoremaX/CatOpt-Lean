# v0.3 — Explicit oracle-query semantics and trusted boundary

This document is a **soundness/measurement specification**, not a novelty claim.

## The measured observable

An algorithmic *objective oracle query* is represented by `probe P x`, which
returns `P.cost x` and increments `queries` by one. The result-and-count
structure `Metered α` composes sequentially with additive query accounting.
This is a restricted Writer-like model, not a new monad or new category.

### Closed example: `probeMany`

The `probeMany P xs` implementation has no route to `P.cost` except `probe`.
We prove two statements in Lean:

```text
(probeMany P xs).queries = xs.length
(probeMany P xs).value   = xs.map P.cost
```

A `ProbeBudget P b` stores a list and a proof that its length is at most `b`.
`ProbeBudget.queries_le` establishes the **observed** query budget using the
actual instrumented interpreter, rather than a manually priced operator.

## Compositional search interpreter

The existing phase-indexed search syntax is unchanged.
`runMetered` interprets it into `(SearchState, queries)`.
`acceptMetered` explicitly observes the incumbent and candidate through
`probe`, compares those observations, and chooses the feasible winner.

The formally stated relationships are:

```text
(runMetered impl p s).value = Search.run impl p s
(runMetered impl p s).queries = 2 * acceptCount p
(runMetered impl (compileRounds rs) s).queries = 2 * rs.length
P.cost (runMetered impl p s).value.incumbent ≤ P.cost s.incumbent
```

An `AcceptanceBudget` certificate additionally proves that recorded
acceptance observations stay within a specified budget. This is a theorem
about `runMetered`, rather than a check of user-supplied `WorkCosts`; it
still **does not include hidden calls** inside opaque primitives.

The first is an interpreter-refinement/erasure theorem. The second and third
count **instrumented acceptance observations**, **not all objective calls**
made anywhere in the search. The fourth reuses v0.2's verified incumbent
monotonicity, so instrumentation does not alter the optimization outcome.

## Critical limitation: opaque primitives

`Primitives.construct`, `.shake`, `.destroyRepair`, and `.localSearch` can
implement **arbitrary pure Lean operators**. They may call `P.cost` internally
without going through `probe`. In `evalMetered` these opaque primitives are
marked as *unmetered*, rather than pretending their real query count is zero.

Consequently:

- The v0.3 counter is **not** the total evaluations of an algorithm.
- No v0.3 theorem bounds TSP's actual number of evaluations.
- v0.3 does not verify actual runtime, CPU instructions, wall time, memory,
  or PRNG draws.
- No theorem identifies Python's optimizer with Lean's semantics.
- v0.2 `WorkCosts` remains a **separate, declarative** mechanism.

## Why this is still useful

It is a checked refinement scaffold. We can now identify the exact point
where the trusted boundary is too wide and replace the opaque local-search
primitive with a restricted, **oracle-driven internal DSL**. In that future
DSL *every objective request must be represented by an effect constructor*.
Only then can the resource theorem be safely interpreted as a bound on all
modeled evaluations for that algorithm.

## Lean verification

```powershell
lake build
lake exe catopt-demo
py tools/check_no_sorry.py
py -m unittest discover -s experiments -p "test_*.py" -v
```

Compiling `CatOpt` imports `CatOpt/Tests/Resources.lean` and checks all examples.
Do not claim this new v0.3 layer has been accepted until `lake build` succeeds
on Lean 4.32.0. All v0.2 imports/proofs are preserved.

## Dependencies and prior art

`TimeM` in CSLib already has a stronger, lawful general resource monad:
https://api.cslib.io/docs/Cslib/Algorithms/Lean/TimeM.html

ReSyn already combines resource-bounded program synthesis with pruning:
https://cseweb.ucsd.edu/~npolikarpova/publications/pldi19.pdf

We use a small self-contained `Metered` to expose the trust boundary. A later
version should consider reusing CSLib where maintenance or lawful monad
abstractions justify an extra dependency.
