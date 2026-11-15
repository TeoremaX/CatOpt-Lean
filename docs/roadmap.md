# Roadmap: research milestones and acceptance criteria

## M0 — Scientific framing (current draft)

- [x] Distinguish representation from novel mathematics.
- [x] Evaluate the endomorphism-only, invariant-preserving and stochastic options.
- [x] Choose an invariant-preserving categorical core with typed phase protocol.
- [x] Identify relevant categorical and optimization literature.
- [ ] Complete a systematic survey of grammar-based hyper-heuristics / algorithm synthesis.

**Success criterion:** reviewers can state exactly what is assumed and proved,
what is conventional and what remains conjectural.

## M1 — Trusted formal foundation (highest priority)

- [x] Write Lean category, semantics, certificates and proof tests.
- [x] User confirmed successful Windows `lake build` for the corrected v0.1 core (6007 jobs).
- [x] User-confirmed green `lake build` through v0.4 (6025 jobs); v0.5 compilation and GitHub CI remain pending.
- [ ] Commit and pin `lake-manifest.json` after reconciling with the current Mathlib release.
- [ ] Audit `#print axioms` of major theorems after compilation.
- [ ] Add `lake test` target if separate tests become necessary.
- [x] Add a counterexample test showing raw `Shake` need not be non-worsening.

**Success criterion:** GitHub CI shows a green Lean build with zero sorry/admit.

## M2 — Verified compositional laws

- [ ] Quotient typed syntax by identity/associativity to form the path category.
- [ ] Construct actual `CategoryTheory.Functor` from the quotient to `Space`.
- [ ] Prove observational equivalences beyond reassociation and identities.
- [ ] Prove graded resource contracts, e.g. additive evaluation cost.
- [ ] Decide whether parametric deterministic state and nondeterminism suffice,
  or whether distribution-valued operators genuinely require a Kleisli model.

**Success criterion:** at least one theorem gains content from morphisms
between **different** state types and is not a restatement of function
composition.

## M3 — Faithful algorithm models

- [ ] Define a certified finite-state TSP tour type (permutation + city set).
- [ ] Formalize 2-opt and insertion as feasibility-preserving endomorphisms.
- [ ] Implement VND using **multiple** neighborhoods and fixed-point/descent
  stopping criteria, with a well-founded termination argument when finite.
- [ ] Implement genuine adaptive GVNS; model its neighborhood radius and
  acceptance decisions in a richer search state.
- [ ] Implement GRASP construction with explicit deterministic PRNG state.
- [ ] Prove a relation between verified Lean executables and the benchmark
  rather than asserting agreement between independent implementations.

**Success criterion:** tests compare Lean-executed tours to Python counterparts
for the same seed/instance and a formal refinement proof covers core operators.

## M4 — Serious empirical evaluation

- [ ] Run at least 30 seeds on a publicly specified set of varied instances.
- [ ] Add exact optima or best-known baselines from clearly cited instances.
- [ ] Report wall-clock and full-objective-evaluation budgets, variance and
  statistical uncertainty.
- [ ] Compare nontrivial established baselines with preregistered parameters.

**Success criterion:** independent readers can reproduce results, including
negative and null results, and the chosen performance comparisons are fair.

## M5 — Potential research contribution

- [x] Prototype typed candidate generation and a proof-carrying *static estimated-work* filter.
- [ ] Prove contracts on *actual* evaluations and generalized operator effects (not just declared estimates).
- [ ] Search the synthesis space, avoiding duplicate semantic programs using
  sound rewrites.
- [ ] Demonstrate at least one empirically useful new combination or
  simplification versus ordinary untyped grammar synthesis.
- [ ] Present limitations and external review from researchers in category
  theory, formal methods and combinatorial optimization.

**Success criterion:** a specific theorem or experimental insight remains
valuable even if the category-theory terminology is removed.


## Revised research milestones after the 2026-11-15 originality audit

- v0.2: typed finite grammar + **declared** static work estimates. Verified
  by user in Lean (6013 jobs).
- v0.3: `probe`-instrumented acceptance and list-scoring semantics (user-verified).
- v0.4: a metered best-of-feasible-list selector, with neighbor generation
  still external (user-verified, 6025 jobs).
- v0.5 (compilation pending): first-order finite moves plus a fuel-bounded
  run; exact query counts for the restricted fragment.
- v0.6 (research goal): adaptive GVNS in the same restricted oracle semantics.
- v0.7+ (research goal): incremental synthesis and sound, finite-grammar-
  relative budget pruning, then held-out combinatorial evaluations.

No theorem proves a performance advantage, and no contribution should be
claimed as novel before dedicated expert assessment.

## v0.5 onwards — refined controlled semantics roadmap

- [x] **v0.4:** supply feasible neighbors and count all selector/acceptance `probe` effects (user-verified).
- [ ] **v0.5:** first-order finite move grammar and fuel-bounded loop; source written; await kernel compilation before checking this item.
- [ ] **v0.6:** explicit adaptive controller (radius, accept/restart decision, fuel), with a proof of path-sensitive query bounds and tests showing that the controller actually changes neighborhoods.
- [ ] **v0.7:** connect a nontrivial permutation problem, verified move feasibility and meaningful baselines; avoid equating the independent Python benchmark with the Lean executable.
- [ ] **v0.8:** synthesis-space pruning with soundness and relative completeness, and experiments against naive enumeration.

The fixed finite move language in v0.5 is intentionally limited. It is not a claim of state-of-the-art search quality or novel Writer semantics.
