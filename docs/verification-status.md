# Verification status — 2026-11-15

## User-confirmed v0.2 build (Lean 4.32.0 / Mathlib 4.32.0)

The user ran these commands in PowerShell on Windows:

```text
lake build                         # Build completed successfully (6013 jobs)
lake exe catopt-demo              # 5 synthesized budget-certified recipes
py tools/check_no_sorry.py        # No obvious unfinished proofs / extra axioms
py -m unittest discover ...       # 5/5 tests passed
```

This evidence validates the **v0.2** repository and is not extrapolated to
newly authored v0.3 files. The simple lexical no-sorry scan is weaker than
Lean compilation; built Lean theorems must be inspected for their premises.

## v0.3 state

- Source files have been written and reviewed manually.
- The authoring environment lacks `lake`/`lean` and has no DNS for Lean download.
- Thus the new modules `CatOpt/DSL/Resources.lean`, `CatOpt/Examples/Resources.lean`
  and `CatOpt/Tests/Resources.lean` **have not been typechecked** here.
- Python regression tests from `experiments/` can be run independently and do
  not imply Lean correctness.
- The new query counter intentionally covers only *explicit* `probe` actions.
  Opaque primitives can perform hidden objective computations; no theorem
  bounds full metaheuristic evaluation counts. See `docs/resources.md`.

## Commands to complete verification

```powershell
lake build
lake exe catopt-demo
py tools/check_no_sorry.py
py -m unittest discover -s experiments -p "test_*.py" -v
```

Preserve the existing `.lake` directory and `lake-manifest.json` when using
the incremental patch. Do not run `lake update` if v0.2 is already configured.

## Further trusted-boundary analysis

Search operators are `SafeHom` functions certified for feasibility. They are
not formal programs with controlled oracle access; they may query `P.cost`
internally. The new model is a verifiable *instrumentation fragment*, not a
fully instrumented GVNS, GRASP or Iterated Greedy implementation. Python TSP
implementations remain separate and without a Lean refinement theorem.
