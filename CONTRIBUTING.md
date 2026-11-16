# Contributing

CatOpt-Lean is experimental research software. Corrections to proofs, counterexamples, reproducible performance measurements and proposals that clarify the trusted boundary are welcome.

For a code change:

1. Explain the result or bug being addressed and state any assumptions.
2. Keep Lean source free of `sorry` and additional unsupported axioms.
3. Run `lake build` and the applicable regression checks.
4. If experiments are involved, include the instance, command line, seed, budget and results, including unsuccessful runs.
5. Distinguish properties proved in Lean from observations made by a separate Python program.

For larger changes, an issue with a focused example is helpful before writing a substantial implementation. A clean commit history and a reproducible test are more useful than a broad claim about formal verification or algorithmic performance.
