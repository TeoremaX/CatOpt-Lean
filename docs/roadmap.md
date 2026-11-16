# Research roadmap

CatOpt-Lean v0.10 is a working formal prototype. The immediate objective is to turn its individual checked components into a coherent, measurable result that can be evaluated against existing approaches.

## Current baseline

- [x] Feasibility-preserving categorical core and phase-typed programs.
- [x] Checked enumeration of small search recipes.
- [x] Explicit oracle-query instrumentation for restricted search fragments.
- [x] Finite adaptive search and deterministic seeded shaking with nested VND-style control.
- [x] TSP routes as permutations; segment reversal and local-optimality checking.
- [x] External text certificates, decoded and checked in Lean.
- [x] Local Lean build and integration tests for v0.10.

## Next steps

1. **Improve certificate scalability.** Specify and prove the incremental 2-opt cost difference for symmetric TSP. Handle asymmetric distances separately; the four-edge shortcut is not generally sound for directed instances.
2. **Close the execution boundary.** Connect external optimizers to the certificate format on larger, documented instances. Measure verification time and report the cost of the current exhaustive checker.
3. **Connect synthesis and certification.** Investigate a syntax and semantics in which generated metaheuristics carry explicit contracts for feasibility, acceptance and modeled objective queries.
4. **Evaluate comparative value.** Establish baselines for synthesis without formal contracts, verify cost overhead, and report solution quality under matched objective-evaluation budgets.
5. **External review.** Ask researchers in combinatorial optimization and formal methods to inspect the novelty claim and proof assumptions before selecting a venue.

## Research questions

- Does a typed search representation prevent implementation mistakes that occur in comparable untyped descriptions?
- Can certificate checking be inexpensive enough to be useful on nontrivial instances?
- Which resource contracts can be proved for an actual closed interpreter, rather than postulated for arbitrary primitives?
- Does a compositional formalization lead to theorems or analyses that are difficult to obtain otherwise?

A journal submission is not the next automatic version milestone. It depends on a specific contribution that remains meaningful after comparison with related work, evidence on representative instances and an accurate account of the remaining trust boundary.
