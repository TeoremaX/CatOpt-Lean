# Verification status (2026-11-15)

- **v0.6 user-verified:** `lake build` completed (6037 jobs);
  `lake exe catopt-demo` produced the expected adaptive trace and 24 probes.
  Git recorded commits `4d9fbf8`, `3df1dbd`, `d40127a` on
  `feat/adaptive-vns-v06`; worktree was clean.
- **v0.5 user-verified:** `lake build` completed (6031 jobs), with 18 probes.
- **v0.4 user-verified:** `lake build` completed (6025 jobs), and Python tests passed.
- **v0.7 has not yet passed Lean.** The proofs are source-level candidates
  pending `lake build` on the same revision and CI.
- The `check_no_sorry.py` scanner is only a textual sanity check. It is **not**
  an alternative to Lean kernel verification or a proof of no hidden axioms.
- All query counts refer to the **closed finite DSL**, not CPU time, independent
  Python TSP code, or older opaque primitives.
- The seeded recurrence is deterministic: no formal random-distribution or
  convergence claim is justified.

## Release checklist

Record the exact commit, `lean --version`, `lake build`, full executable trace,
`py tools/check_no_sorry.py`, Python tests, and CI status. Push only after
inspection and passing verification on the committed revision.
