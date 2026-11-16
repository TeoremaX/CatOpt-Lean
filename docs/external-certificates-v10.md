# v0.10 — Untrusted external TSP input, checked by Lean

## Goal and precise claim

The external solver is **not** in the trusted computation path. It may supply
any UTF-8 text file. The Lean CLI parses the count, the entire directed
nonnegative integer distance matrix, and a sequence of city identifiers.
It rejects malformed files, oversize cases, non-square matrices, repeated
cities, missing cities, and out-of-range identifiers. It builds a `Tour`
(`Equiv.Perm`) **only after checking an explicit computable inverse and both
inverse laws**. A noninvalid candidate is evaluated by v0.9's
`checkLocalOptimum` against **every** inclusive segment reversal.

The theorem `verifyText_accepted_sound` says: if the parsed case is `c` and
the text verifier returns `.ok true`, every segment reversal of `c.tour` has
cost greater than or equal to that original tour. The distances may be
asymmetric and need not satisfy the triangle inequality. All checks cover
the complete cyclic return edge. This is **local**, not global optimality.

## File format (no Lean code is supplied by the optimizer)

```
4
0 1 2 1
1 0 1 2
2 1 0 1
1 2 1 0
0 1 2 3
```

The first row is the **number of cities N**, strictly positive and currently
bounded by 32 to avoid accidentally running the deliberately exhaustive
checker on very large inputs. The next N rows contain exactly N natural
numbers each. The final row contains exactly N natural identifiers in tour
position order, a permutation of the integers 0 to N−1. Values are separated
by **spaces**; CRLF and empty lines are accepted. CSV commas, tabs, scientific
notation, signed integers and floating-point values are not part of this
format. A separate, untrusted Python exporter translates CSV to this format.

## Commands

```powershell
# Valid perimeter tour: cost 4, no improving reversal, exit code 0.
lake exe catopt-certify experiments/fixtures/square-accepted.cert

# Crossing tour: cost 6, strictly improving reversal exists, exit code 1.
lake exe catopt-certify experiments/fixtures/square-rejected.cert

# Export data produced by *any* external solver to a canonical text file.
py experiments/export_certificate.py `
  --matrix experiments/fixtures/square-matrix.csv `
  --tour experiments/fixtures/square-perimeter-tour.csv `
  --out exported.cert
lake exe catopt-certify exported.cert

# The Lean integration tests include malformed input and CRLF examples.
py scripts/check_external_cli.py
```

Exit statuses: `0` accepted; `1` valid input but not 2-opt locally minimal;
`2` malformed certificate or command-line usage. An I/O error can also cause
an uncaught operating-system exception; this is not modeled in the theorem.

## Trust boundary, limitations, novelty

* This is a **closed Lean checker** for natural-valued directed distance
  matrices. There are no verified accuracy claims about an external optimizer.
* The Python exporter and independent Python reference tests are not part of
  the checker; tampering there cannot force Lean to accept a malformed route.
* The distance function uses bounded array reads after runtime dimension
  checks. We do not yet prove a separate refinement theorem connecting each
  source byte to a matrix entry; parsing code is evaluated under Lean's
  runtime and the theorem concerns the parsed `Case`.
* The local-optimality test is exhaustive and uses full tour-cost recomputation
  for each candidate, not the O(1) symmetric-TSP 2-opt delta. Asymmetry is
  supported; no shortcut identity is assumed.
* A locally optimal route is **not** a globally optimal route. This is
  especially important on real benchmark instances.
* The checker is intentionally demonstration-scale (`N ≤ 32`) and is not yet
  benchmarked against dedicated certifier software. No statement about
  worst-case wall-clock time is proved, and no uniqueness or scientific
  novelty is claimed for this straightforward use of proof-carrying data.
* A robust research paper would require a separate proof of input refinement,
  scalable verification with formally justified deltas, independent large
  benchmarks, comparative evidence, and a distinct contribution in
  compositional synthesis rather than only an external-file parser.

## Release gate

The user must run `lake build`, the positive and negative Lean CLI cases,
`py tools/check_no_sorry.py`, and all Python tests. Only after these pass and
`git status` is clean may this branch be called a **verified experimental
software release** and pushed to GitHub. It is **not yet** a peer-reviewed
paper or a demonstrated new metaheuristic.
