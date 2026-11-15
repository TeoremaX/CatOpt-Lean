# Verification status (updated 2026-11-15)

- **v0.4 confirmed:** user ran Lean 4.32.0 `lake build` successfully (6025 jobs), `lake exe catopt-demo`, `py tools/check_no_sorry.py`, and all five Python tests. Three incremental v0.4 Git commits were made locally on `feat/oracle-local-search` and the working tree was clean.
- **v0.5 pending:** `FiniteNeighborhood.lean` plus new examples/regressions have been source-reviewed, but the authoring environment lacks a working Lean/Lake compiler. Run the v0.5 staged script and require `lake build` before asserting that these new theorems are kernel-checked.
- The `check_no_sorry.py` scanner is only a syntax/text check, **not** a substitute for kernel verification.
- Exact query counts apply to the **new closed finite move interpreter** only. They do not count CPU time, Lean reduction steps, Python code or oracle calls in previous opaque primitives.
- The v0.5 finite runner has fixed moves and a fixed number of rounds. It is **not adaptive GVNS**.

## Evidence checklist after a successful v0.5 build

Record `lean --version`, `git rev-parse HEAD`, successful `lake build`, demo output, test results and GitHub CI status. Compare against the baseline from v0.4 rather than the old 6019-job v0.3 figure.
