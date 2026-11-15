# Verification status (updated 2026-11-15)

- **v0.3 confirmed:** user ran `lake build` successfully (6019 jobs), `lake exe catopt-demo`, `py tools/check_no_sorry.py` and all five Python tests.
- **v0.4 pending:** new `OracleLocalSearch.lean` and regression proofs have been source-reviewed, but this authoring environment has **no Lean/Lake compiler** and cannot download one. Execute the staged patch script or run the verification commands on Lean 4.32.0.
- The `check_no_sorry.py` scanner checks for common unfinished-proof markers, **not** soundness; successful `lake build` is the relevant kernel-validation evidence.
- This repository does not verify calls inside external neighborhood generators, original opaque heuristics, or independent Python TSP implementations.

## After a successful v0.4 build

Record the exact Git commit SHA, toolchain, `lake build` output, and CI run URL here before citing verification in a publication.
