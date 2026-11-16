# Literature and originality audit — CatOpt-Lean (2026-11-15)

**Scope:** scoping review, not a systematic review or a proof of priority.
We searched for automatic metaheuristic design, typed/grammar-based component
systems, resource-guided program synthesis, resource semantics, mechanized
complexity, proof-carrying algorithms, and formal stochastic local search.
Searches covered accessible publisher pages, bibliographies, research-group
repositories and public Lean documentation. No exhaustive Scopus/Web of Science
citation graph or private-unpublished-work search was performed.

**Conclusion:** No current CatOpt-Lean feature should be marketed as a
previously undiscovered mathematical construction. The possible contribution
is a domain-specific, end-to-end combination with NEW proven properties and
carefully measured engineering advantages. The novelty of that combination
has not been demonstrated. A reviewer or domain expert may know closer work.

## Priority comparison: nearest relevant work

| Aspect | Prior work | Consequence for our claim |
|---|---|---|
| Automatic design of metaheuristics from components | Martín-Santamaría, López-Ibáñez, Stützle, Colmenar (2024), EJOR, DOI 10.1016/j.ejor.2024.06.001 | Already done, including implicit grammar from requirements and tuning |
| Earlier grammar-based automatic design | Mascia et al. (2014), Computers & Operations Research, DOI 10.1016/j.cor.2014.05.020 | Pipelines/grammar search are not novel |
| Resource-guided synthesis and pruning | Knoth et al. (2019), PLDI, *Resource-Guided Program Synthesis* | Directly anticipates composition of synthesis with resource bounds and pruning |
| Liquid resource types | Knoth et al. (2020), ICFP | Quantitative specifications and cost reasoning are established |
| Costed Writer-like semantics in Lean | CSLib `Cslib.Algorithms.Lean.TimeM`, https://api.cslib.io/docs/Cslib/Algorithms/Lean/TimeM.html | Result-and-cost pair, bind/addition, resource proofs are already available |
| Explicit cost models and composed complexity in Lean | `complexity-lean`, https://github.com/alonamaloh/complexity-lean | Mechanized cost and halting bounds are not new |
| Resource reasoning via proof-carrying artifacts | Certifying combinatorial optimization and related certificate-verification literature | A certificate is meaningful only relative to checked premises |
| Predicate-preserving category | Elementary mathematical construction; Mathlib Category | Category correctness alone is not publishable novelty |
| Formal general model of stochastic local search | *Generalization and completeness of stochastic local search algorithms* (2021), DOI 10.1016/j.swevo.2021.100982 | Generic SLS formal modeling is established; Turing completeness limits generic semantic decidability |
| Lean-assisted genetic optimization empirical work | *A Hybrid Genetic Algorithm with Wisdom of Artificial Crowds for the Boolean Satisfiability Problem* (2026), SCIRP | The combination "Lean theorem + heuristic benchmark" alone is insufficient novelty |

## Four distinctions that must be preserved

1. `BoundedRecipe` in v0.2 verifies only `estimatedCost ≤ budget` for user-declared
   estimates. It does not verify any number of objective calls.
2. In v0.3 `probeMany` is **closed** and performs every objective observation
   through `probe`; its query count therefore corresponds to the observations
   in its own interpreter. `acceptMetered` also performs two `probe` calls.
3. `runMetered` intentionally treats the original arbitrary `Primitives`
   operators as opaque, assigning them **zero *recorded* queries**. It cannot
   claim that their implementations perform no objective evaluations. The
   `runMetered_queries` theorem is an exact count of **instrumented acceptance
   probes**, not a total algorithmic complexity theorem.
4. No Lean theorem currently states that the external Python TSP optimizer
   refines the Lean model or that the generated algorithms improve quality.

## Research gap / candidate hypotheses to test

The following is a **research question**, not a novelty claim:

> Does a fully oracle-controlled, phase-typed semantics for **adaptive**
> combinatorial metaheuristics enable useful, machine-checked resource and
> invariant certificates that improve automatic algorithm design over a
> competitive component-grammar baseline?

Test separately:

- **H1:** An executable, oracle-controlled adaptive VNS/GVNS semantics can
  produce sound counts and meaningful dynamic budget bounds without treating
  operator costs as arbitrary inputs.
- **H2:** A certified incremental synthesizer can prune branches without
  losing any admissible program *relative to the finite grammar and budget*.
  This is a correctness theorem, **not** an originality claim.
- **H3:** Formal contracts or verified pruning improve robustness, efficiency
  or interpretability when compared with a matched version without them.
  This requires experimental baselines, not simply source proofs.
- **H4:** All reported objective evaluations in the evaluated optimizer can be
  related to the formal oracle semantics through a concrete refinement proof
  or a separately audited, restricted compiled implementation.

**Falsification criteria:** if prior work already realizes H1–H4 together,
if the trusted boundary hides most objective calls, or if verification overhead
outweighs benefits in the target domain, narrow or revise the claim.

## Why v0.3 comes before pruning

Sound pruning requires a cost predicate that tracks a meaningful operational
resource. v0.2's declared weights are not such a predicate. v0.3 proves an
instrumented oracle model in a **restricted fragment**, keeps erasure to the
established DSL, and explicitly exposes the remaining unmetered primitive
boundary. The research milestone is to close that boundary in the next phase.

## Key links

- Martín-Santamaría et al. (2024): https://doi.org/10.1016/j.ejor.2024.06.001
- ReSyn (2019): https://cseweb.ucsd.edu/~npolikarpova/publications/pldi19.pdf
- ReSyn repository: https://github.com/tjknoth/resyn
- Liquid Resource Types: https://www.cs.cmu.edu/~janh/projects/04_synthesis/
- CSLib TimeM: https://api.cslib.io/docs/Cslib/Algorithms/Lean/TimeM.html
- Lean complexity models: https://github.com/alonamaloh/complexity-lean
- Generalization of stochastic local search (2021):
  https://doi.org/10.1016/j.swevo.2021.100982
- Lean checked SAT/GA case study (2026):
  https://www.scirp.org/journal/paperinformation?paperid=155298
- Survey on methodological novelty in metaheuristics (Nov 2026):
  https://doi.org/10.3390/math14214112

## Publication gate

A proper submission must include (a) precise novelty-relative-to-baselines
statement, (b) formal semantics and checked proof sources, (c) proof of an
implementation/refinement or narrowly scoped oracle-accounting claim,
(d) comparative multi-instance empirical study with held-out instances,
(e) threat-to-validity discussion, and (f) explicitly declared AI assistance
where required by the venue.
