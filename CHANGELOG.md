# Changelog

## 0.8.0 — 2026-11-15 (new Lean proofs pending compilation)

- Introduce permutation-valued TSP tours as `Equiv.Perm (Fin (n+1))`.
- Define inclusive segment reversal, its index involution, bijectivity and reversibility of `twoOpt`.
- Implement cyclic weighted tour cost, objective-independent candidate generation and instrumented elitist search.
- State exact semantic query counts and incumbent non-worsening for complete fuel-bounded runs.
- Include four-city crossing demonstration and independently tested Python 2-opt reference (no refinement claim).
- Add three-stage validation-gated local Git commits.
- **Verification:** user-confirmed v0.7 `lake build` (6043 jobs); new v0.8 Lean proof compilation pending.


## 0.7.0 — 2026-11-15 (user-confirmed Lean build: 6043 jobs)

- Add objective-free seed-indexed first-order shaking and deterministic seed update.
- Compose bounded inner adaptive VND-style descent with two-probe outer elitist acceptance.
- Specify outer reset/advance, global incumbent monotonicity, and the uniform instrumented-query bound `f * (t * (2*m+4)+2)`.
- Add fuel/budget certificates, seed-choice and rejection/acceptance examples, and Git verification-gated commits.
- **Not proven probabilistic:** no stochastic distribution, random-convergence theorem, external benchmark refinement, or production full-GVNS guarantee.
- **Verification:** v0.7 user-confirmed (`lake build`: 6043 jobs), demo, three commits and clean worktree; linter style warnings remain.


## 0.6.0 — 2026-11-15 (user-confirmed Lean build)

- Added a finite **adaptive VNS-style controller** with an indexed catalog of first-order neighborhoods.
- Improvement tests are instrumented with two additional `probe` calls.
- Added proofs of policy reset/advance, incumbent monotonicity and modeled query upper bound `fuel * (2*cap+4)`.
- Added static `RunBudget`, four-step example, compile-time proof regressions and staged Git commits.
- **Not full GVNS:** randomized shaking, VND and external benchmarks are not covered.
- **Verification:** user confirmed v0.6 `lake build` (6037 jobs), demo and three commits; warnings are style-related.


## 0.5.0 — 2026-11-15 (user-confirmed Lean build)

- Added `FiniteNeighborhood.lean`, a first-order move language on `Fin (n + 1)` with objective-independent neighbor generation.
- Added a fuel-bounded instrumented runner with exact semantic counts `fuel × (2 × move_count + 2)` and incumbent non-worsening.
- Added `FuelBudget`, a certificate connecting an execution to a proved bound on registered objective probes.
- Added one finite executable example, proof regressions, publication-scope notes and three-stage Git update script.
- **Not adaptive GVNS:** the neighborhood grammar is fixed; total *real* cost and external code remain outside the proof.
- **Verified by user:** v0.5 `lake build` succeeded (6031 jobs), the executable demo ran, and three commits were created with a clean Git tree.

## 0.4.0 — 2026-11-15 (user-confirmed Lean build)

- Added a finite, typed feasible-neighborhood selector with explicit `probe` calls.
- Added exact oracle-count and value-erasure theorems for selection, plus a non-worsening proof.
- Added local-search/acceptance round, exact count `2 × candidates + 2`, and a proof-carrying `RoundBudget`.
- Added examples, compile-time proof regressions, and executable demonstration.
- Added staged Git patch/commit workflow to validate each change before committing.
- **Trust boundary:** neighbor generation and existing opaque primitives remain unmetered.
- **Verified by user:** v0.4 `lake build` succeeded (6025 jobs), demo executed, no-obvious-sorry check passed and all five Python tests passed; three local commits created.

## 0.3.0 — 2026-11-15 (user-confirmed Lean build)

- Added scoping originality audit with comparisons to MORK, ReSyn, CSLib
  TimeM and mechanized complexity formalisms; no claim of global novelty.
- Added `CatOpt/DSL/Resources.lean`: explicit objective-query probe and
  closed list client, theorem of exact recorded count, proof-carrying list
  budget, instrumented acceptance and interpreter erasure theorems.
- Added Lean examples/tests, research publication plan, resource-specification
  document, and refreshed verification-status evidence.
- **Limit:** instrumented search counts acceptance probes only. The existing
  opaque `Primitives` may make additional unrecorded objective calls.
- **Verified by user:** `lake build` 6019 jobs; demo and both checks completed successfully.

## 0.2.0 — 2026-11-15 (user-confirmed Lean build)

- Added compiler from raw actions to phase-indexed programs and finite
  generation of valid closed rounds.
- Added `BoundedRecipe` proofs of budget compliance for **user-declared**
  estimated static costs; no real evaluation-count claim.
- Added formal synthesis theorems, checks and demo output.
- **Verified by user:** `lake build` 6013 jobs; demo 5 recipes; no-obvious-sorry
  checker passed; all five Python regression tests passed.

## 0.1.0 — 2026-11-15 (user-confirmed Lean build)

- Introduced category of feasibility-preserving transformations, phase-typed
  search language, separate candidate/incumbent and general monotonicity proof.
- Added GRASP-like, fixed-schedule VNS and Iterated Greedy schemes, independent
  Python TSP experiment, CI, README and draft research manuscript.
- Fixed `import` order, qualified `Nat.le_refl`/`Nat.le_trans` and reduced
  arithmetic transparency issues in the finite example.
- **Verified by user:** `lake build` 6007 jobs and initial demo output.
