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
- [ ] Obtain **green `lake build`** for the new v0.2 synthesis modules and GitHub CI; commit generated manifest.
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
- v0.3: `probe`-instrumented semantics with a closed counted scoring client
  and acceptance erasure proof (compiler check pending).
- v0.4 (hypothesis): replace the opaque local-search interface with an
  oracle-controlled DSL; ensure **all modeled objective observations** flow
  through that effect and prove relevant dynamic upper bounds.
- v0.5 (hypothesis): an adaptive GVNS in the same controlled semantics.
- v0.6 (hypothesis): incremental synthesis and *sound, finite-grammar relative*
  budget pruning; comparisons with naive enumeration and MORK/ReSyn-inspired
  baselines, followed by held-out combinatorial problems.

No theorem proves a performance advantage, and no contribution should be
claimed as novel before dedicated expert assessment.
