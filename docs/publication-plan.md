# Research program toward a credible CatOpt-Lean publication

**Status:** Research hypotheses; not yet an accepted scientific contribution.
Prepared 2026-11-15. Read `novelty-audit.md` before describing novelty.

## Candidate thesis

**Proof-carrying synthesis of adaptive combinatorial-search heuristics under
explicit oracle semantics**. The ambition is not to invent grammar-based
synthesis, resource types, or category-theoretic composition. Those exist.
The testable contribution would be a *specific* correct-by-construction
integration for adaptive, domain-specific metaheuristics, with a complete
comparison against established frameworks.

## Requirements for a publishable claim

1. **Formal problem and semantic scope:** finite combinatorial spaces,
   feasible typed candidate transformations, a single objective oracle,
   adaptive bounded control, explicit random seeds if sampling is added.
2. **Closed resource model:** all allowed objective queries flow through
   a syntactic `oracle` command; local search is no longer an opaque function.
3. **Machine-checked proofs:** (a) feasible incumbent, (b) elitist monotonicity,
   (c) termination under finite fuel, (d) sound dynamic budget bound for
   *all* modeled oracle calls, (e) synthesis soundness and relative completeness.
4. **Executable refinement:** tie the interpreter actually benchmarked to
   the model. If Python is retained, use a documented conformance suite and
   describe remaining trust; a direct Lean executor provides a narrower gap.
5. **Relevant adaptive algorithm:** at least one accepted-improvement-based
   GVNS with multiple neighborhoods and an explicit variable neighborhood
   schedule. The current "GVNS" fixed list is not sufficient.
6. **Baselines:** a no-proof version of the *same* DSL, naive enumeration,
   resource-guided pruning, and comparison against MORK/irace or a comparable
   established automatic-design method where feasible.
7. **Experimental validity:** held-out problem instances; paired seeds and
   equal oracle budgets; robust statistics and multiple independent problem
   families; report wall-time/overhead in addition to quality of solutions.
8. **Novelty claim:** narrowly state what exact theorem, interface, algorithm
   or measured trade-off is new *relative to each closest piece of prior art*.

## Go/no-go checkpoints

- **After v0.3:** prototype illustrates instrumentation; no total resource claim.
- **After v0.4:** closed finite-list selection and metered acceptance, with a
  supplied neighbor list; this is not yet end-to-end local-search accounting.
  Require v0.4 `lake build` before advancing.
- **After v0.5:** adaptive GVNS and controlled-loop proofs; ask an expert to
  independently audit the semantics and the literature.
- **After v0.6:** pruning proof and empirical comparison; abandon any claim
  of improvement if data or stronger published baselines contradict it.

## Reviewer objections to prepare for

- "You have only reimplemented ReSyn for a smaller language." Answer must
  give an actual metaheuristic-specific theorem or engineering result.
- "The operator makes hidden objective calls." Resolve by controlled oracle
  syntax and/or explicit refinement, not by assuming arbitrary costs.
- "The category plays no essential role." Show a theorem that is naturally
  transported through compositional interpretations or remove it from the
  title/central contribution.
- "This is toy optimization." Benchmark genuine combinatorial problems,
  and compare against nontrivial automatic design baselines.
- "The proofs are correct but the optimizer is not proved." Verify the
  executed implementation or explicitly state the remaining trusted link.

## Manuscript outline (after results exist)

1. Introduction and falsifiable research question.
2. Positioning against MORK, ReSyn, CSLib and formal SLS models.
3. Typed adaptive metaheuristic DSL and operational oracle semantics.
4. Machine-checked theorems with statement-level assumptions.
5. Certifying synthesizer and proof of pruning safety/completeness.
6. Experiments, benchmarks, ablations, and analysis.
7. Threats to validity, related work, limitations.
8. Reproducibility appendices and permanent artifact release.

## Possible targets (recheck annual calls when submitting)

- GECCO: algorithm-design contribution with strong experiments.
- CPAIOR: formal constraints and synthesis for combinatorial optimization.
- Applied Category Theory: only if genuinely new categorical mathematics is
  essential to the results, not as a label on ordinary functional composition.
- Appropriate formal-methods workshops: if verification is the central
  contribution and empirical quality is still preliminary.

Before submission: check each venue's current policy on AI-assisted research
and manuscript preparation, authorship, open artifacts and prior publication.
