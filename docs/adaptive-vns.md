# v0.6 — Finite adaptive VNS-style control with measured objective observations

## Why this module exists

The v0.5 `FiniteNeighborhood.run` executes the *same move list* for each round.
A core VNS design feature is **neighborhood change**: when an iteration
improves the incumbent, restart from the first neighborhood; otherwise try
another neighborhood. This release adds that behavior while keeping every
objective comparison inside the metered finite-state fragment.

**It is not a full GVNS implementation.** In particular, the new module has
no randomized `shake`, inner VND controller, variable neighborhood ordering
strategy, or proof of any heuristic reaching a local/global optimum.
It is a minimal deterministic adaptive VNS-style *controller* with an honest
formal contract, not a validated production optimizer.

## Mathematical semantics

Let `n : Nat` and `objective : Fin (n+1) → Nat`. Each state contains:

- `search`, the existing certified feasible incumbent/candidate state;
- `index : Nat`, the next finite neighborhood to attempt.

`Catalog cap` is a finite list of move lists, equipped with a *proof* that
every valid neighborhood lookup returns at most `cap` move tokens. The moves
are v0.5's first-order `hold`, `forward k`, and `backward k` constructors;
they have no embedded objective-function callbacks.

An active step:

1. interprets the selected move list without the objective;
2. performs `FiniteNeighborhood.round` (two metered probes per move, plus two
   for acceptance);
3. calls `probe` twice more, to compare the old incumbent with the accepted
   incumbent;
4. resets `index` to zero upon *strict* improvement, else increments it.

An out-of-range index yields an inert step with **zero** probes. A fuel
parameter bounds the number of attempted steps. This means the implementation
also covers an exhausted catalog without accessing an invalid position.

### Contracts

For the active move list `moves`:

```text
step.queries = 2 * moves.length + 4
```

For a missing neighborhood:

```text
step.queries = 0
```

For `fuel = f`, a catalog certified with `cap = m`, and an arbitrary
objective/adaptive path:

```text
run.queries ≤ f * (2*m + 4)
objective(final.incumbent) ≤ objective(initial.incumbent)
```

The first bound is a **worst-case upper bound**, not an exact path-independent
count. Inactive steps and shorter neighborhoods can make the actual counter
smaller. `RunBudget` carries a proof that the upper bound fits a requested
budget, and `certifyRun` returns `none` when it cannot certify that bound.

### Why the policy comparison is explicitly metered

If the controller compared old/new objective values directly, a budget of
`2*|moves| + 2` would overlook the policy test. The extra **two** semantic
`probe` effects are intentionally counted. We do not assume caching or reuse
of previous comparisons.

## Regression example

`adaptiveCatalog` has two neighborhoods: `[hold]` and `[backward 2]`. With the
objective `Fin.val`, starting at state 15 and four fuel steps:

| Attempt | Neighborhood | Accepted incumbent | Next index | Queries |
| --- | --- | ---: | ---: | ---: |
| 1 | hold | 15 | 1 | 6 |
| 2 | backward 2 | 13 | 0 | 6 |
| 3 | hold | 13 | 1 | 6 |
| 4 | backward 2 | 11 | 0 | 6 |

So the concrete example has 24 recorded queries. Tests also reject a static
budget of 23 and accept 24.

## What this does and does not verify

**Inside Lean's model:** the finite move generator has no objective argument;
all selection, acceptance, and policy comparisons are performed using
explicit `probe` effects. The code formalizes the update policy, feasibility
(by the `Fin (n + 1)` domain and `SearchState` certificates), incumbent
monotonicity, totality under fuel, and a uniform semantic query bound.

**Outside this scope:** cost of building move lists, number of machine
instructions, memory, wall-clock time, allocations, hidden objective calls in
older opaque primitives, randomness, external Python TSP, real-world GVNS
performance, and optimum attainment. `probe` counts modeled interactions,
not the time/physical cost of evaluating the objective.

## Publication discipline

Neighborhood changes and resource-bounded execution are established
techniques. This is an engineering/formal-method milestone, **not a claim of
novel mathematical priority**. A future submission needs comparisons to
MORK/ReSyn/CSLib, a meaningful refinement theorem to an executable algorithm,
comparative experiments, and a documented scientific contribution that goes
beyond simple composition and fuel-bounded recursion.
