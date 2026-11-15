# v0.5 — Closed finite moves and fuel-bounded oracle accounting

**Status:** prepared in source; compile with Lean 4.32.0 on the target machine or GitHub CI before marking it verified. The user has already compiled and executed v0.4 successfully (6025 jobs).

## Precise scope

`CatOpt/DSL/FiniteNeighborhood.lean` defines a deliberately **restricted, first-order** neighborhood language:

- State space: `Fin (n + 1)`; all states are feasible (`True`).
- Moves: `hold`, `forward k` (addition modulo `n + 1`), `backward k` (saturating subtraction).
- Neighborhood generation: `generate n moves x`, which receives neither the objective nor the general `Problem` record.
- The cost function enters only when `OracleLocalSearch.selectMetered` and `Resources.acceptMetered` call `probe`.
- A complete round generates a fixed list, selects the best strict improvement, then applies elitist acceptance.
- `run ... fuel s` repeats this closed round a fixed number of times using structural recursion.

The move language is not a generic operator API. This restriction is **intentional**: a user-defined callback `P.State → List Candidate` might access the objective without using `probe`, making a total-count theorem invalid. The finite move constructors cannot embed such callbacks.

## Main claims

Write \(M\) for the list of move tokens, \(r\) for the fuel (number of rounds), and \(s\) for a certified state. The new theorems aim to establish:

\[
Q(\operatorname{round}(M,s))=2|M|+2,
\qquad
Q(\operatorname{run}(r,M,s))=r\,(2|M|+2).
\]

The selector performs **two `probe` calls per neighbor**, including ties and a `hold` move. Acceptance adds exactly two more queries. The move interpreter performs no `probe`. The count is deliberately not an optimized number of distinct objective values (values can be queried more than once). The theorem is about **the number of explicit instrumented calls** made by this interpreter.

The incumbent is non-worsening:

\[
f(I(\operatorname{run}(r,M,s)))\le f(I(s)).
\]

A `FuelBudget B` carries `fuel`, `moves`, and a proof of `fuel * (2 * moves.length + 2) ≤ B`. `FuelBudget.queries_le` connects the certificate to the execution theorem. This is stronger than v0.2's user-declared estimated work table; it is still a statement about a particular **Lean semantics** and this restricted language, not the machine cost of any external algorithm.

## Examples

The executable starts with 15 in `Fin 21`, objective `Fin.val`, moves `[backward 1, backward 2]`, fuel 3. Round results are 13, 11, and 9. There are two neighbors per round, so `3 × (2 × 2 + 2) = 18` semantic queries. `certifyFuel 18` succeeds; `certifyFuel 17` rejects the same program.

Lean regression tests check this calculation, the accepted result, generic bound theorems, the zero-fuel case, and objective-independent move generation.

## What this does *not* establish

1. There is **no guarantee about CPU time, allocations, Lean kernel reductions, or real-world runtime cost**. Move construction uses CPU without invoking the cost oracle.
2. The bound is **not** a total count of evaluations inside the old opaque `Primitives`, Python TSP implementations, or any foreign program.
3. The finite moves do **not** implement TSP 2-opt, permutation feasibility, or a competitive VND.
4. Fixed moves repeated for `fuel` rounds are **not adaptive GVNS**. The next phase should introduce a finite radius/controller state that responds to objective improvements, and prove budget bounds for its paths.
5. The semantic counting pattern, Writer-like composition, and resource certificates have significant prior art (CSLib `TimeM`, ReSyn, resource analysis). The project's scientific novelty must be argued at the level of meaningful domain-specific guarantees and measurements, not these components alone.

## Reproduction

```powershell
lake build
lake exe catopt-demo
py tools/check_no_sorry.py
py -m unittest discover -s experiments -p "test_*.py" -v
```

If all checks succeed, record the Lean 4 toolchain (`lean --version`), commit SHA, and CI run. Git commits are created by `apply_v05.ps1` **only after** the corresponding checks succeed. Do not claim an uncompiled theorem is kernel-verified.
