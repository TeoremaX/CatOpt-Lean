# v0.4 — A closed, oracle-instrumented finite-neighborhood selector

**Scope:** exact guarantees for finite-list *selection and elitist acceptance* in the Lean semantics, not for neighborhood generation, arbitrary local-search loops, TSP execution, or wall-clock cost.

## Why a new module?

`CatOpt/DSL/Resources.lean` (v0.3) proved two `probe` calls per acceptance action. But the old `Primitives.localSearch : Operator P` is opaque: the instrumented interpreter cannot see how often its implementation evaluates `P.cost`. Assigning it a price would be an *assumption*, not verification.

`CatOpt/DSL/OracleLocalSearch.lean` adds a smaller, closed computation whose comparisons really do call `probe`. It accepts `Candidate P = {x : P.State // P.feasible x}`. A caller must supply both a candidate and a proof of its feasibility; the selector does not invent or silently assume feasibility.

## Algorithm: compare and keep best

For `current : Candidate P` and a supplied finite list `candidates`:

1. For each `fresh`, call `probe P current.val` and `probe P fresh.val`.
2. Keep `fresh` if its observed objective is **strictly smaller**; otherwise keep `current`. Ties preserve the current candidate.
3. Recurse over the remaining list.
4. Optionally apply the pre-existing `acceptMetered` to the selected candidate and incumbent.

No random generator, search move construction or hidden API is used in the selector's executable definition. This baseline deliberately re-evaluates the current candidate at every comparison; it is **not a cache-optimized best-of-list**. That redundancy makes the accounting simple and explicit, but is not an efficiency result.

## Machine-checkable proof obligations

For every `P`, feasible start `x` and list `xs` of feasible candidates:

```lean
(selectMetered P x xs).value = select P x xs
(selectMetered P x xs).queries = 2 * xs.length
P.cost (selectMetered P x xs).value.val ≤ P.cost x.val
```

Feasibility is enforced by the result type `Metered (Candidate P)`. The metered local-search transition leaves the incumbent unchanged. A closed local-search-and-acceptance round additionally satisfies:

```lean
(roundMetered P neighbors s).queries = 2 * (neighbors s.candidate).length + 2
P.cost (roundMetered P neighbors s).value.incumbent ≤ P.cost s.incumbent
```

The `RoundBudget` type carries the proof `2 * candidates.length + 2 ≤ budget`. `certifyRound` constructs it only when this decidable inequality holds; `RoundBudget.queries_le` relates the certificate to the actual instrumented round.

### Example

Given feasible starting incumbent and candidate `15`, and externally supplied candidates `[14, 13]` under `cost = id`, the metered selector returns `13` with `4` probes. Elitist acceptance returns incumbent `13` with **6 total registered probes**. `CatOpt/Tests/OracleLocalSearch.lean` contains compile-time tests and the generic quantified theorems.

## Trust boundary: what this does *not* count

The `neighbors : P.State → List (Candidate P)` argument is an *external list producer* and **could evaluate `P.cost` itself**. The theorem counts all objective observations **inside the selector and acceptance semantics** but does not count or constrain work done to produce that list. Equally, the original `Search.Primitives` (GRASP-style construction, perturbations, old local search) are still opaque. The Python benchmarks have no formal refinement theorem to this Lean selector.

A strict end-to-end oracle budget for adaptive metaheuristics needs a restricted **neighborhood-construction language** with no direct `P.cost` access (or a formally proved oracle-effect interface) and then a bounded interpreter that instruments all its effects. This is proposed for v0.5.

No claim of global novelty is made: Writer-like instrumentation, program refinements and resource-certified synthesis are established ideas; see `docs/novelty-audit.md`.

## Reproduction

From a clean v0.3 checkout with Lean 4.32.0 and Mathlib already cached:

```powershell
lake build
lake exe catopt-demo
py tools/check_no_sorry.py
py -m unittest discover -s experiments -p "test_*.py" -v
```

The new code is **source-reviewed only in the authoring environment**; users must run `lake build` to confirm that the Lean kernel accepts the new theorem statements and proofs. Prior v0.3 was compiled successfully on Windows by the user.
