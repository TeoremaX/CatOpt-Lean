# v0.9 — Research positioning and evidence gate (2026-11-15)

## What the v0.8 user build establishes

`lake build` completed successfully (17,365 jobs) on the user's Windows machine.
The permutation-valued tour, segment reversal, bijection/involution, metered
selector, and the small TSP example are accepted by Lean. This is **not** an
external solver refinement proof or a globally optimal tour certificate.

## Closest prior work / priority assessment

| Source | Established | Implication for CatOpt-Lean |
|---|---|---|
| Martín-Santamaría et al., *EJOR* (2024), DOI 10.1016/j.ejor.2024.06.001 | Automatic composition of component-annotated metaheuristics, experimental competitiveness | Algorithm assembly alone is not original |
| Knoth et al., *PLDI* (2019), DOI 10.1145/3314221.3314602 | Resource-guided synthesis with refinement types and pruning | Resource-aware synthesis is not original |
| CSLib (2026), arXiv:2602.04846 and TimeM docs | Lean cost-analysis infrastructure; trusted annotations | Do not claim to have invented a cost monad |
| leanprover/lp (current repository) | Externally generated optimization certificates checked by Lean | The architecture of an untrusted solver + verified checker already exists |
| HardnessReductionsLean and CLRS-Lean | Lean formalizations of TSP representations / NP-hardness / approximation | TSP formalization is not novel by itself |
| Lancia and Vidoni, *INFORMS J. Comput.* (2024), DOI 10.1287/ijoc.2023.0169 | Advanced best 2-opt move algorithms | A fast delta implementation is not a standalone novelty |
| Furini, *Evaluating a move incrementally* | Classical symmetric-TSP four-edge 2-opt delta | Delta algebra is known; proof must require symmetry |
| Mehlhorn & Näher et al., *Certifying algorithms* (2011) | Algorithm produces witnesses verified by separate checkers | Certifying computation is an established paradigm |

**Novelty conclusion:** no global novelty certificate exists. The narrow
possible contribution is an end-to-end proof-carrying *metaheuristic design*
pipeline: (i) typed synthesis, (ii) objective-call accounting, (iii) a
machine-checkable local-optimality/feasibility verifier for proposals from
untrusted optimizers, and (iv) measured reductions in verification/design
cost. Whether this integration is original or publishable remains open.

## v0.9 precise scope

`CatOpt/TSP/LocalOptimality.lean` defines a total exhaustive Boolean checker
for every inclusive segment reversal of a permutation tour, for arbitrary
natural-valued **directed** distances. The soundness theorem says `true` means
no tested reversal improves cyclic cost. The converse holds by construction.

This is a **2-opt local optimum**, not a global TSP optimum, an approximation
ratio, or a certificate for an unverified external Python program. Checking
is exhaustive: it is not an O(1) incremental delta checker and can be slow.

## Symmetry trap

The classical four-edge delta formula is valid for appropriate non-wrapping
segment reversals when distances are symmetric. It can fail for asymmetric
TSP because internal edges reverse direction. The Python test includes a
counterexample with actual delta +99 and a four-edge prediction of 0. The
formal Lean checker deliberately recomputes full cyclic costs, so its
soundness does not assume symmetry. Next phase: a separate symmetric-TSP
structure with a formal O(1) delta identity and an explicit bridge to
`tourCost`.

## What would constitute a plausible paper

Research question: **Can proof-carrying composition and independently checked
local-optimality certificates make automated heuristic design more reliable
without prohibitive overhead?**

Required: (A) a verifiable import format for external TSP tours; (B) a Lean
checker whose soundness applies to those imported values; (C) proof of a
symmetric O(1) delta bridge or other efficient verification strategy;
(D) candidate synthesis/correctness and pruning theorems; (E) ablations and
benchmarks vs basic enumeration and MORK-like configuration, including
held-out TSPLIB problem instances; (F) explicit verifier CPU-time overhead;
(G) complete reproduction scripts, raw results and confidence intervals.

**Decision gate:** if there is no measurable gain, stronger independently
checked guarantee, or clearer compositional theorem beyond prior work, do
not market this as a new algorithms paper. Consider a technical note, software
artifact, undergraduate research poster or collaboration with GRAFO instead.

## Main paper hypothesis and its potential falsification

*Research hypothesis H1:* a contract-checked neighborhood DSL can generate
and verify feasible/local-optimum candidates with fewer invalid candidates
and lower design-space exploration cost than an untyped grammar with
post-hoc tests, holding candidate quality and computation budgets fixed.

*Research hypothesis H2:* a small Lean kernel-checked result certificate
can validate the local-optimality claim of an untrusted optimizer without
trusting that optimizer's source code, using a documented input encoding.

H1 must be tested with matching operator catalogs and budgets; not against
a weaker baseline. H2 is already common as a *certifying algorithm* paradigm,
so publishability depends on the specialized optimizer design workflow,
verified checker coverage, and practical overhead, not the idea of external
certificates. It is quite possible that experiments reject one or both
hypotheses. That outcome should be reported, not suppressed.

## Required mathematical milestones after v0.9

**M1: A sound imported-tour checker.** Parse an external tour as data with
explicit length, city-range and no-duplicates validation, prove successful
parsing constructs an `Equiv.Perm`, and connect it to `checkLocalOptimum`.
The current API only accepts a `Tour` *already constructed inside Lean*;
this is a significant unresolved trust boundary.

**M2: Symmetric-TSP delta refinement.** Introduce `SymmetricInstance`, prove
that incremental cost difference equals full recomputation for every
allowed 2-opt move, including boundary cases, with correct arithmetic over
`Int` rather than subtraction of natural numbers. This is a classical
identity to formalize, NOT a new formula. Compare the trusted checker time
with and without the delta optimization.

**M3: Exhaustive-neighborhood soundness and completeness.** Prove the move
iterator enumerates all (and only) allowed segments; prove `true` corresponds
to no strict improving move in that neighborhood, then quantify its query
and distance-lookup costs. A local-optimum certificate does not certify
TSP global optimality or bounded approximation ratio.

**M4: Synthesis bridge.** Prove that outputs of the CatOpt DSL can be
translated to the checked tour/certificate model. If an algorithm uses
unverified native code or Python, trust only its *proposals* and re-check
inside Lean.

**M5: Comparative evaluation.** Separate three measurable dimensions:
algorithm-design time, deployment solution quality, verification overhead.
Use at least three test conditions: (i) no constraints, (ii) post-hoc
rejection, (iii) incremental formal pruning. Report false-rejection rate
(should be zero with respect to the specified finite grammar), accepted
candidate counts, performance, and verifier build/checking time.

## Experimental protocol before any serious submission

1. Use named instances and original TSPLIB edge-weight conventions.
   Do not mix exact `EUC_2D` rounded integer distances with arbitrary
   floating-point Euclidean distances; this changes what is proved.
2. Separate problem instances into tuning, selection and held-out test
   groups, without exposing held-out instances to the synthesizer.
3. For each algorithm, use the same *actual* objective/distance budget,
   not merely the metered upper bound from a different cost model.
4. Run independent seeds, archive the seed list, and use confidence
   intervals / per-instance paired comparisons. Report all failures and
   compiler warnings rather than only successful examples.
5. Compare against reliable basic 2-opt/VND implementations, an untyped
   generator, and where feasible MORK/irace; measure verifier overhead.
6. Include a machine-readable `claim -> file -> theorem -> assumption ->
   build version` mapping. Publish tagged source and dependency lockfile.

## Reasonable dissemination strategy

- **Now:** public GitHub software and a technical report explicitly marked
  *work in progress*, with the v0.8 user build as reproducibility evidence.
- **After M1–M3:** workshop poster or formal-methods software demonstration;
  ideally obtain feedback from mathematical optimization and Lean experts.
- **After M4–M5:** consider a research paper in a relevant optimization,
  automated program synthesis, or formal verification venue. A journal or
  premier-conference acceptance is not assured; the hypothesis and novelty
  must survive expert review.

A strong title *after the required evidence* might be:
`Proof-Carrying Metaheuristic Design: Verified Local-Search Certificates
and Resource-Aware Composition`. Do not publish this as an achieved claim
before completing its end-to-end evidence.

## Sources

1. https://doi.org/10.1016/j.ejor.2024.06.001
2. https://doi.org/10.1145/3314221.3314602
3. https://arxiv.org/abs/2602.04846
4. https://api.cslib.io/docs/Cslib/Algorithms/Lean/TimeM.html
5. https://github.com/leanprover/lp
6. https://github.com/DominikPeters/HardnessReductionsLean
7. https://tanktechnology.github.io/CLRS-Lean/CLRSLean/FourthEdition/Chapter_34/
8. https://doi.org/10.1287/ijoc.2023.0169
9. https://fabiofurini.github.io/combinatorial-optimization/heuristic-algorithms/local-search/evaluating-a-move-incrementally/
10. https://doi.org/10.1016/J.COSREV.2010.09.009
