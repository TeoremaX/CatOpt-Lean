# Publication criteria

CatOpt-Lean is not yet a journal manuscript. This note records the requirements for a defensible paper, rather than a planned submission date.

## Possible contribution

A compositional search language in which optimization procedures can be assembled under formally checked feasibility and resource contracts, with independently checkable certificates for the solutions produced.

Parts of this idea already exist in program synthesis, verified resource accounting, certifying algorithms and automatic metaheuristic design. A publication must identify an additional result that is specific and demonstrably new.

## Minimum evidence

1. **A clear statement of novelty:** a theorem, a verified compiler or a measured design benefit not already established by the nearest systems.
2. **A documented trust boundary:** which code runs inside Lean, which data arrive externally, which proof assumptions are used and which operations are counted.
3. **Useful problem instances:** public TSP benchmarks or other appropriate combinatorial instances, not just the four-city demonstration.
4. **Fair baselines:** equivalent unverified implementations, relevant synthesis frameworks and standard local-search alternatives.
5. **Comparable resources:** paired seeds where relevant, comparable evaluation budgets, verification runtime, CPU time, variance and instance size.
6. **Reproducibility:** source revision, toolchains, instance provenance, scripts and both positive and negative results.
7. **Independent review:** feedback from researchers who work on formal verification and algorithm configuration.

## What v0.10 currently proves

The external certificate path decodes a candidate tour into an actual permutation and, when the checker accepts, establishes local optimality relative to the finite family of inclusive segment reversals. It does not verify an external search program, prove global optimality, or provide evidence that verified synthesis outperforms alternative approaches.

## Recommended research sequence

First make the TSP checker efficient under explicitly stated symmetry assumptions and benchmark it. Then connect it to the synthesized search programs, establish resource properties for the closed execution semantics, and compare results with suitable literature baselines. Only then determine the paper's contribution and venue.

See [related work](related-work.md), [current roadmap](roadmap.md) and [research positioning](research-positioning-v09.md). Earlier exploratory notes remain useful background but should not be presented as peer-reviewed conclusions.
