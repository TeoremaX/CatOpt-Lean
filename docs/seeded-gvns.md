# v0.7 — Seed-controlled shaking and nested VND-style descent

## Status and scope

This release adds `CatOpt.DSL.SeededGVNS` to the **first-order finite-move**
fragment. It is a bounded *seeded GVNS-style* model, not a proof about a
uniformly random algorithm, not a fully specified reference GVNS from the
literature, and not a verified TSP implementation.

**Review gate:** all theorems are candidates until the exact revision passes
`lake build` with the pinned Lean 4.32.0 toolchain. The last known verified
baseline is v0.6: user-confirmed successful `lake build` with 6037 jobs.

## Precise semantics

For a fixed `objective : Fin (n+1) → Nat`, the outer state consists of:

- `search`: a certified feasible `SearchState` (global incumbent and candidate),
- `index`: the outer shaking-neighborhood to try,
- `seed`: an explicit, reproducible natural-number seed.

The configuration contains (1) a finite list of shaking move lists,
(2) a **certified** inner adaptive neighborhood catalog with maximum length
`cap`, and (3) `vndFuel`, the maximum attempted inner steps.

On each active outer step:

1. Choose a **first-order** move from the current list using `seed % length`
   (identity move if the list is empty).
2. Apply the move to the old global incumbent without an objective-function
   argument, obtaining a feasible `Fin (n+1)` candidate.
3. Start a fresh inner VND-style run at the shaken solution. The internal
   `AdaptiveVNS.run` resets to the first local neighborhood after strict
   improvement and advances otherwise, for at most `vndFuel` steps.
4. `probe` the **old global incumbent** and the **inner local result**.
   Accept the local result only on **strict improvement**; otherwise preserve
   the global incumbent.
5. Reset/advance the outer neighborhood accordingly and update the seed with
   a deterministic arithmetic recurrence.

An exhausted outer catalog is inert (no probe, no seed advancement). `run`
repeats at most `outerFuel` attempts regardless of improvements.

### Metered upper bound

If `m = cap`, `t = vndFuel`, and `f = outerFuel`, then

```
Q_inner_per_attempt ≤ t * (2*m + 4)
Q_outer_per_active_attempt ≤ t * (2*m + 4) + 2
Q_total ≤ f * (t * (2*m + 4) + 2)
```

The extra **two** probes are the outer strict acceptance test. The bound is
uniform over objectives, seeds, and adaptive branches. Inert outer steps and
exhausted inner catalogs can result in fewer queries. This counts **only**
explicit `Resources.probe` effects inside the closed Lean fragment, not
processor time, arbitrary external objective callbacks, or Python benchmarks.

`RunBudget` and `certifyRun` provide a static certificate for that uniform
upper bound, with a proof requiring `config.vndFuel = innerFuel`.

### Mathematical guarantees

The new proofs establish:

- `step_queries`: the exact outer-step charge in terms of actual nested probes;
- `step_reset` and `step_advance`: improvement-driven outer changes;
- `step_incumbent_le`: preservation of the global elitist incumbent;
- `step_queries_le`: worst-case single-step query bound;
- `run_incumbent_le`: non-worsening for all seeds and outer fuels;
- `run_queries_le`: worst-case end-to-end semantic query bound;
- `RunBudget.queries_le`: bound delivered by a checked certificate.

Feasibility follows from the finite `Fin (n+1)` domain and typed
`SearchState`; both the shaking interpreter and nested move DSL produce
states within that domain.

## Reproducible example

State domain: `Fin 21`. Objective: `Fin.val` (minimization). Initial global
incumbent: 15. The two outer perturbation lists contain one move each:
`forward 4` and `backward 1`. The inner VND schedule uses the neighborhood
`[backward 1]` for up to two steps.

| Attempt | Perturbation | Inner result | Accepted global incumbent | Next outer index | Count |
| --- | --- | ---: | ---: | ---: | ---: |
| 1 | 15 → 19 | 17 | 15 | 1 | 14 |
| 2 | 15 → 14 | 12 | 12 | 0 | 14 |

Total: 28 modeled probes; static budget 28 succeeds and 27 fails. Additional
compile-time tests cover distinct seed selection, an empty move list, fuel
zero, an exhausted outer catalog, and generic proof statements.

## What is still missing for publication

The seed recurrence is deterministic. The current code does **not** show
that seeds are uniformly distributed or that the process converges in
probability. There is no stochastic-kernel or Markov-chain semantics yet.
Likewise the nested search is a **fuel-bounded VND-style policy**, not a proof
of terminating precisely at a local optimum.

Before presenting the project as a verified, general-purpose GVNS framework:

1. Formalize the intended *reference* algorithm and relate the implemented
   scheduler to it, rather than merely relying on a name.
2. Represent permutations or other nontrivial feasible structures; verify
   relevant moves (e.g., 2-opt) and complete objective-accounting effects.
3. Establish a refinement or conformance relation to an external benchmark
   executable if external performance results are to inherit formal claims.
4. Compare against published grammar-based configurators and proof-guided
   synthesis methods; these components are not claimed as novel by themselves.

The current release is a rigor-oriented engineering milestone, not evidence
of computational superiority or global originality.
