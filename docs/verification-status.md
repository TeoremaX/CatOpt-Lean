# Verification status (updated 2026-11-15)

- **v0.4 confirmed:** user ran Lean 4.32.0 `lake build` successfully (6025 jobs), `lake exe catopt-demo`, `py tools/check_no_sorry.py`, and all five Python tests. Three incremental v0.4 Git commits were made locally on `feat/oracle-local-search` and the working tree was clean.
- **v0.5 confirmed:** the user ran Lean 4.32.0 `lake build` successfully (6031 jobs), and demonstrated 18 probes and final incumbent 9.
- The `check_no_sorry.py` scanner is only a syntax/text check, **not** a substitute for kernel verification.
- Exact query counts apply to the **new closed finite move interpreter** only. They do not count CPU time, Lean reduction steps, Python code or oracle calls in previous opaque primitives.
- The v0.5 runner has fixed moves and a fixed number of rounds; v0.6 introduces only a deterministic adaptive VNS-style policy, **not** full randomized GVNS.

## Evidence checklist for each subsequent release

Record `lean --version`, `git rev-parse HEAD`, successful `lake build`, demo output, test results and GitHub CI status. Compare against the baseline from v0.4 rather than the old 6019-job v0.3 figure.


## v0.5 — verified on the user’s Windows machine

On 2026-11-15 the user reported `Build completed successfully (6031 jobs)`;
`lake exe catopt-demo` displayed v0.5's three-round example with 18 probes
and final incumbent 9. Git showed commits `a03a986`, `95998f5` and `691f28a`,
and `git status` was clean. This documents *reported* Lean validation for v0.5.

## v0.6 — pending Lean compilation

The new `CatOpt/DSL/AdaptiveVNS.lean`, Lean examples and tests have been
written but **not kernel-checked in the authoring environment**. No claim of a
verified v0.6 build should be made until the exact revision passes `lake build`
and tests. Python unit tests are separate from Lean soundness.
