# Verification status

**Current code version:** v0.10.0, branch `feat/external-certificates-v10` (and branches descended from it).

## Evidence available

On 16 November 2026, the following commands succeeded on a Windows installation of Lean 4.32.0:

```powershell
lake build
py scripts/check_external_cli.py
py tools/check_no_sorry.py
```

- `lake build`: **17,376 jobs**, successful.
- Python regression suite: **24 tests**, successful during installation of v0.10.
- Certificate CLI integration: **nine cases**, including accepted, locally nonoptimal, invalid and CRLF input.
- `git status`: clean working tree after the three v0.10 commits.
- `check_no_sorry.py`: no obvious unfinished proof markers or additional axioms found in the source scan.

There are still Lean lint warnings about redundant tactics in `AdaptiveVNS.lean` and `SeededGVNS.lean`. They do not constitute proof failures.

These statements are based on the recorded local command output, not an independent re-execution or an audit of every transitive axiom. The live GitHub Actions status should be checked separately.

## Scope of guarantees

- Feasible-state composition and acceptance properties apply under their stated hypotheses.
- Resource results count **explicitly instrumented objective observations**, not hidden calls, CPU time or memory use.
- TSP segment reversal preserves bijectivity.
- A positive certificate verdict entails **local** optimality relative to every inclusive segment reversal defined by the checker.
- The certificate decoder checks a route before constructing `Equiv.Perm`; the external optimizer supplies only data.

**Not established:** global TSP optimality, convergence of a randomized algorithm, equivalence of Python execution to Lean, competitive benchmark performance, or scientific novelty.

## Publication status

Source code and documentation can be published as an experimental software release. A journal article will require a precise novel claim, independently checked assumptions, serious baselines and reproducible experiments.
