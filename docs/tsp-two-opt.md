# v0.8 — Permutation-valued TSP and a certified 2-opt segment reversal

**Status:** Source-level candidate as of 15 November 2026; the user's **v0.7**
compiled with 6,043 Lake jobs and had a clean local Git tree. The new **v0.8**
proofs require their own `lake build` and CI confirmation before they can be
claimed as Lean-verified.

## Why the representation matters

In earlier versions, the state type was `Fin (n+1)`: a single integer. That
cannot represent a TSP tour. Here `Tour n := Equiv.Perm (Fin (n+1))` is a
bijection from **tour positions** to **city identifiers**. A bijection is a
much stronger invariant than an arbitrary list: every city appears exactly
once. Its proof fields are part of the type, rather than runtime assertions.

We use `n+1` cities to avoid a degenerate empty cycle and make the cyclic
successor `(k + 1) % (n+1)` total. For example, `Tour 3` describes four cities.
Tours are **not quotiented by rotations or reversals**, so different
permutations can represent the same undirected cycle. This is intentional
for the first implementation, and can create redundant synthesis candidates.

## Mathematically specified 2-opt-style reversal

A `Segment n` contains inclusive endpoints `lo ≤ hi`. For a position `k`,
its mirrored position is

\[
R_{lo,hi}(k)=\begin{cases}
lo+hi-k & lo\le k\le hi,\\
k & \text{otherwise}.
\end{cases}
\]

The Lean definitions `reverseIndex`, `reversePositions`, and `twoOpt`
construct the reversal as an **involutive permutation** acting on tour
positions. The crucial obligations are:

- `reverseIndex_involutive`: `R(R(k)) = k`;
- `twoOpt_injective` and `twoOpt_surjective`: no city duplicated or omitted;
- `twoOpt_involutive`: applying the same reversal twice restores the tour;
- `twoOpt_at`: every output city has the position-reversal interpretation.

The name *2-opt-style* is deliberate: segments of length zero or one are
allowed and correspond to degenerate (identity) moves. Classical nondegenerate
2-opt typically specifies two distinct broken edges and reconnects the
tour; a contiguous segment reversal is its standard symmetric-TSP
realization, but this module does not formalize a two-edge exchange or its
constant-time delta formula. Nor is every reversal guaranteed to improve.

## Cyclic weighted objective

`Instance n` has an arbitrary `distance : Fin (n+1) → Fin (n+1) → Nat`.
The cost is the sum of distances between consecutive positions, including
last-to-first. **Symmetry and the triangle inequality are not assumed.**
The tiny square example uses symmetric unit perimeter edges and length-two
diagonals (the Manhattan metric on a unit square). It deliberately contains
a crossing: `[0,2,1,3]` has cost 6, while reversing positions `[1,2]`
yields `[0,1,2,3]` of cost 4.

## Instrumentation and proof boundary

`neighbors` constructs the candidate list from a **first-order segment
palette** that receives no objective function; its output length equals
`segments.length`. Every comparison is routed through the existing
`OracleLocalSearch` selector and acceptance semantics.

For one complete round with `m` supplied segments, the **recorded objective
calls** are exactly `2*m + 2`. With `fuel = f`, the runner records exactly
`f*(2*m+2)` calls. `run_incumbent_le` establishes elitist non-worsening
of the incumbent's cyclic tour cost for any `Nat`-valued distance matrix.
The `RunBudget` certificate is an *exact semantic query-count bound*.

The module **does not** prove a bound on wall-clock time, on the number of
edge-distance evaluations inside `tourCost`, on allocation, or on the
independent Python TSP engine. We explicitly treat one call to `tourCost`
as one oracle query, even though its body loops over `n+1` edges. Python's
`two_opt_reference.py` is an independently tested reference and is **not**
proved to implement the Lean semantics.

## Scope and planned development

v0.8 intentionally does not implement a complete TSP GVNS. It establishes a
sound permutation state representation and an executable 2-opt-style move.
The next specific obligations would be (i) a verified 2-opt edge-delta
formula for symmetric instances, (ii) a full neighborhood enumerator with
symmetry-redundancy control, and (iii) a test harness comparing Lean and
Python on **the same input records** with a separately established
refinement relation. Later evaluate on standard TSP instances.

## How to verify

```powershell
lake build
lake exe catopt-demo
py tools/check_no_sorry.py
py -m unittest discover -s experiments -p "test_*.py" -v
```

Only a successful Lean compilation at the exact revision establishes the
machine-checked status of its stated theorems. Python tests cannot replace it.
