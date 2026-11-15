# Verification status (2026-11-15)

- **v0.8: user-confirmed** `lake build` succeeded (17,365 jobs), `catopt-demo`
  ran including TSP example, three commits (`8f964be`, `eb27b1c`, `cbca166`)
  and clean Git status.
- **v0.9: NOT YET Lean-compiled**. `LocalOptimality.lean` and its Lean tests
  must be accepted by the pinned Lean 4.32.0 + Mathlib on the user's computer.
- Python reference regression tests are independent of Lean. Passing Python
  tests does not formally verify the Python implementation.
- `checkLocalOptimum = true` can establish 2-opt **local** optimality only in
  the modeled finite neighborhood. It is not a global optimum certificate.
- No statement on native runtime, external solver refinement, expected cost,
  probability of convergence, or actual Python evaluation-call bounds.
