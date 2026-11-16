# Changelog

This file records the main technical milestones. Older proof modules, examples and tests remain in the repository and in Git history.

## 0.10.0 — External TSP certificates

- Added a text decoder for externally generated directed-distance TSP instances and candidate routes.
- Constructed Lean permutations only after validating the finite inverse laws.
- Connected CLI acceptance to the v0.9 local-optimality theorem.
- Added accepted, nonoptimal and malformed-input integration fixtures.
- Local validation: Lean build (17,376 jobs), 24 Python tests and nine CLI cases.

## 0.9.0 — Local optimality

- Added an exhaustive checker for inclusive 2-opt segment reversals.
- Proved soundness and completeness relative to the enumerated neighborhood.
- Added an asymmetric-distance counterexample to a symmetry-dependent delta shortcut.

## 0.8.0 — Permutation tours

- Represented TSP tours as bijections.
- Formalized segment reversal and its involution property.
- Added a four-city demonstration and instrumented search round.

## 0.7.0 — Seeded neighborhood search

- Added deterministic seed evolution, shaking and nested finite VND-style search.
- Proved modeled resource bounds and elitist-incumbent properties for the restricted controller.

## 0.6.0 — Adaptive neighborhood control

- Added reset-on-improvement and advance-on-no-improvement policies.
- Proved monotonically non-worsening incumbent behavior and a fuel-based query bound.

## 0.5.0 — Finite neighborhoods

- Added objective-independent move descriptions and fueled search semantics.
- Proved exact recorded-query counts for the finite model.

## 0.4.0 — Metered local selection

- Added selection from supplied feasible neighbors with recorded objective queries.

## 0.3.0 — Explicit objective observations

- Introduced the `Metered` structure, `probe` and instrumented acceptance.

## 0.2.0 — Typed program generation

- Added checking and enumeration of phase-correct search recipes.
- Added static certificates for user-declared work estimates.

## 0.1.0 — Formal core

- Defined optimization states, feasibility-preserving composition, a typed search DSL and basic incumbent monotonicity.
