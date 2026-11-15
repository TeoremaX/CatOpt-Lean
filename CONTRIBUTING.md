# Contributing

We welcome precise mathematical counterexamples, Lean compilation fixes,
algorithmic correctness improvements, and reproducible benchmark studies.

- Please open an issue describing the theorem, experiment, or documentation
  gap before proposing a major change.
- A new theorem must state its hypotheses explicitly. Prefer direct,
  explanatory proofs; do not introduce `sorry` or extra axioms.
- A new algorithm must specify its acceptance policy, search state and
  random-state semantics; do not silently assume monotonicity.
- Keep Lean formal guarantees and Python experiment claims distinct.
- Run `lake build`, `lake exe catopt-demo` and
  `python3 -m unittest discover -s experiments` before opening a PR.
- Report random seeds, instance names, evaluation budgets and exact command
  lines for every empirical result.
