# Changelog

## 0.3.0 — 2026-11-15 (new Lean validation pending)

- Added scoping originality audit with comparisons to MORK, ReSyn, CSLib
  TimeM and mechanized complexity formalisms; no claim of global novelty.
- Added `CatOpt/DSL/Resources.lean`: explicit objective-query probe and
  closed list client, theorem of exact recorded count, proof-carrying list
  budget, instrumented acceptance and interpreter erasure theorems.
- Added Lean examples/tests, research publication plan, resource-specification
  document, and refreshed verification-status evidence.
- **Limit:** instrumented search counts acceptance probes only. The existing
  opaque `Primitives` may make additional unrecorded objective calls.
- **Status:** v0.3 Lean build has not yet run in authoring environment.

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
