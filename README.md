# CatOpt-Lean

CatOpt-Lean is a research prototype for specifying and checking small compositional optimization algorithms in **Lean 4 and Mathlib**. It combines a typed language for search operators, proofs about feasible solutions and incumbents, and a TSP example with an independent certificate checker.

The project is at **v0.10.0 (experimental)**. It is usable as a formal-methods demonstrator, not a production TSP solver or a completed research publication.

## What is implemented

- **Feasibility-preserving transformations.** `CatOpt/Category.lean` defines a category whose morphisms preserve a feasibility predicate.
- **Typed search programs.** `CatOpt/DSL/Search.lean` distinguishes construction or perturbation, local search, and acceptance. The types prevent invalid phase transitions. Under the stated assumptions on primitive operators, an elitist search program cannot worsen its incumbent.
- **Small program generator.** `CatOpt/DSL/Synthesis.lean` checks and enumerates typed search recipes. Its initial budget is a declared estimate, **not** a measurement of execution time.
- **Instrumented search semantics.** The resource modules count explicit objective-query operations. Finite neighborhoods, an adaptive VNS-style policy, and seeded, deterministic shaking with a nested VND-style search have proofs about the modeled state and query counts.
- **Permutation-valued TSP tours.** `CatOpt/TSP/TwoOpt.lean` represents a route as a bijection and implements contiguous segment reversal. Validity and reversal properties are proved in Lean.
- **Local-optimality checker.** `CatOpt/TSP/LocalOptimality.lean` checks every inclusive segment reversal. A positive result proves that none of those moves has lower cyclic tour cost.
- **External certificate input.** `CatOpt/TSP/ExternalCertificate.lean` reads a simple text format through the `catopt-certify` executable. The Lean decoder validates the city sequence before constructing a permutation and running the local checker.

GRASP, GVNS and Iterated Greedy appear in the project as small examples or restricted models; this is **not** a complete verification of arbitrary implementations of those algorithms.

## Build and run

The repository pins **Lean 4.32.0** and the corresponding Mathlib version in `lean-toolchain` and `lakefile.toml`. Install [elan](https://lean-lang.org/install/) and Python 3.11 or later.

```bash
lake exe cache get
lake build
lake exe catopt-demo
python3 -m unittest discover -s experiments -p 'test_*.py' -v
python3 scripts/check_external_cli.py
```

A valid certificate can be checked directly:

```bash
lake exe catopt-certify experiments/fixtures/square-accepted.cert
```

The command returns exit code **0** for an accepted local minimum, **1** for a valid route with an improving 2-opt move, and **2** for malformed input or invalid command usage. The fixture `square-rejected.cert` is an example of exit code 1.

### Certificate format

A certificate is plain text: the number of cities, a square matrix of nonnegative integer distances, and a permutation of city IDs from 0 to N−1.

```text
4
0 1 2 1
1 0 1 2
2 1 0 1
1 2 1 0
0 1 2 3
```

Distances may be directed or asymmetric. The current exhaustive checker limits inputs to **32 cities** as a practical safeguard. Space-separated natural numbers are expected; CSV can be exported with `experiments/export_certificate.py`.

## What the proof means

For an accepted tour T and every eligible inclusive interval [i, j], the checked statement is:

```text
cost(T) <= cost(reverse_segment(T, i, j))
```

This is **2-opt local optimality for the neighborhood implemented here**, not global TSP optimality. The checker recalculates entire tour costs; it does not yet implement a formally proved incremental 2-opt delta.

The Lean proofs also do **not** establish that a Python optimizer is correct, that the Lean and Python implementations are equivalent, that all CPU operations are accounted for, or that an algorithm converges probabilistically. The seeded controller is deterministic, not a formal probability model.

## Reproducibility and repository structure

- `CatOpt/Basic.lean`, `CatOpt/Category.lean`, `CatOpt/Operators.lean`: optimization states and compositional foundations.
- `CatOpt/DSL/`: typed programs, synthesis, resource instrumentation, finite-neighborhood search and seeded control.
- `CatOpt/TSP/`: tours, segment reversal, local-optimality verification and external input.
- `CatOpt/Tests/` and `CatOpt/Examples/`: Lean proof checks and examples.
- `experiments/`: independent Python TSP experiments, exporter, fixtures and regression tests.
- `docs/`: mathematical explanations and research notes.
- `paper/`: an **early manuscript draft** describing an older core; it is not current evidence of publication.

The v0.10 code was built locally with `lake build` (17,376 jobs); 24 Python tests and the nine certificate CLI integration cases passed. See [verification status](docs/verification-status.md) for the scope of that evidence. CI results should be checked separately on GitHub Actions.

## Further reading

- [Mathematical formulation](docs/formulation.md)
- [Typed synthesis](docs/synthesis.md)
- [Seeded search and resource semantics](docs/seeded-gvns.md)
- [TSP segment reversal](docs/tsp-two-opt.md)
- [External certificates and trust boundary](docs/external-certificates-v10.md)
- [Current research roadmap](docs/roadmap.md)
- [Related work](docs/related-work.md)

The long-term aim is to connect synthesis of search procedures with checkable correctness and resource contracts. Establishing a publishable scientific contribution will require new results, comparison with existing systems and a reproducible experimental study.

**License:** MIT.
