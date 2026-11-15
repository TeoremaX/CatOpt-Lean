# CatOpt-Lean

**Typed compositional search pipelines with feasibility and incumbent-monotonicity certificates**

> Research-oriented Lean 4 + Mathlib prototype · numerical TSP case studies in Python · v0.4.0
>
> **Verification status:** The user confirmed the full **v0.3** project built successfully on Windows using Lean 4.32.0 (`6019 jobs`), including v0.3 instrumentation, `check_no_sorry.py`, and 5/5 Python tests. **New v0.4 code has not been Lean-compiled in the authoring environment**; run `lake build` before claiming it is formally verified.

## Research question

Can we describe a useful family of local-search metaheuristics by a typed algebra of operators, give that syntax a compositional interpretation in an actual category, and derive guarantees about the search state *independently of the choice of perturbation and local-search heuristics*?

The modest but mathematically precise answer explored here is **yes for the particular feasibility-preserving, elitist-acceptance fragment**. This repository does **not** claim a general theory of every optimization algorithm, equivalence of GVNS/GRASP/IG, automated discovery of novel heuristics, or new convergence theorems.

## Why the naïve pipeline model is insufficient

Writing `VNS = Accept ∘ LocalSearch ∘ Shake` with each operation of type `S → S` erases which solution is the incumbent. A perturbation may worsen the candidate. An acceptance operator must compare the new candidate *to the previous incumbent* rather than acting only on the candidate.

Our state explicitly stores `incumbent` and `candidate`, with proofs that both satisfy the problem feasibility predicate. `shake`, `construct` and `destroyRepair` reset the candidate but preserve the incumbent. `localSearch` changes the candidate. `accept` chooses a lower-cost feasible solution and synchronizes both tracks.

## Main mathematical structures

**Feasibility-preserving category.** Objects are pairs `(α, feasible : α → Prop)`. A morphism `X ⟶ Y` consists of a function `X.Carrier → Y.Carrier` and a proof that it maps feasible inputs to feasible outputs. Identity and composition satisfy the actual `CategoryTheory.Category` interface from Mathlib (`CatOpt/Category.lean`).

**Search DSL.** The phase transitions are statically indexed:

```text
ready ──construct(seed)──────> candidate ──localSearch──> improved ──accept──> ready
ready ──shake(radius)───────> candidate ──localSearch──> improved ──accept──> ready
ready ──destroyRepair(k)────> candidate ──localSearch──> improved ──accept──> ready
```

Programs are typed syntax trees, interpreted by a semantics into the category. An interpretation is defined on atomic arrows and extends by identity/composition. Associativity and both unit laws hold **semantically**, but not definitionally for unquotiented syntax. The latter distinction matters: the DSL is *not* claimed to be a strict free category in its raw AST representation.

**Structural monotonicity.** Let `I(s)` denote the incumbent and `f` the objective. For any certified feasible primitive implementations and any well-typed program `p`, the intended central theorem establishes:

\[
 f\bigl(I(\llbracket p\rrbracket(s))\bigr) \le f(I(s)).
\]

This is a theorem about the *incumbent*, not about the candidate or the best possible global objective. It follows from construction/perturbation leaving the incumbent unchanged, elitist acceptance, and closure under sequential composition. The proof carries no stochastic convergence or performance guarantee.

## Repository map

```text
CatOpt-Lean/
├── CatOpt.lean                         public library imports
├── CatOpt/
│   ├── Basic.lean                      objective, feasibility, search state
│   ├── Category.lean                   category of feasibility-preserving maps
│   ├── Operators.lean                  composition, non-worsening, iteration
│   ├── Properties.lean                 acceptance, incumbent invariants
│   ├── DSL/
│   │   ├── Syntax.lean                 generic typed syntax
│   │   ├── Semantics.lean              categorical interpretation and laws
│   │   ├── Search.lean                 phase-typed search DSL and soundness
│   │   ├── Synthesis.lean              raw checker, round generator, budget certificates
│   │   ├── Resources.lean              counted acceptance probes and erasure theorem
│   │   └── OracleLocalSearch.lean      metered feasible-list selection
│   ├── Algorithms/
│   │   ├── GRASP.lean                   seeded GRASP-style rounds
│   │   ├── GVNS.lean                    fixed-neighbourhood VNS schedule
│   │   └── IteratedGreedy.lean         destroy/repair rounds
│   ├── Examples/
│   │   ├── Finite.lean               executable finite-state semantics
│   │   ├── Synthesis.lean            shared synthesis demo parameters
│   │   ├── Resources.lean            instrumented examples
│   │   └── OracleLocalSearch.lean    finite-neighborhood example
│   └── Tests/
│       ├── Proofs.lean                 existing proof checks
│       ├── Synthesis.lean              synthesis/compiler regression tests
│       ├── Resources.lean              instrumented-query theorem checks
│       └── OracleLocalSearch.lean      v0.4 proof regression checks
├── Main.lean                           Lean demo
├── experiments/
│   ├── tsp.py                           independent TSP benchmark engine
│   ├── run_benchmark.py                 reproducible multi-run comparisons
│   └── test_tsp.py                      Python regression tests
├── docs/                                scientific notes and limitations
├── paper/main.tex                      working technical manuscript
├── paper/references.bib                references
├── examples/                            typed pipeline gallery
├── scripts/                             local setup and checking
└── .github/workflows/                  Lean and Python CI
```

## Install and reproduce

Requires Lean 4, Lake, Mathlib and Python 3.11+. Install Lean with [elan](https://lean-lang.org/install/) and then:

```bash
cd CatOpt-Lean
lake update
lake exe cache get
lake build
lake exe catopt-demo
python3 -m unittest discover -s experiments -p 'test_*.py' -v
python3 experiments/run_benchmark.py --runs 15 --budget 5000
```

Mathlib and Lean are both pinned to `v4.32.0` in `lakefile.toml` and `lean-toolchain`; `lake update` will produce `lake-manifest.json`. **Commit that manifest after the first successful bootstrap** for exact dependency reproducibility. If the upstream tag/toolchain has changed, refer to [Mathlib's installation guide](https://lean-lang.org/install/manual/).

For a faster smoke test:

```bash
python3 experiments/run_benchmark.py --runs 2 --budget 1500 --instances grid12
```

The benchmark requires no third-party Python packages. Results are emitted to `experiments/results.csv` (ignored by Git). Executed smoke and reference batches (with a 135-row result CSV) are described in `docs/experiments.md` but are not evidence of algorithmic superiority.

## v0.2: generator and static budget certificates

The new `CatOpt/DSL/Synthesis.lean` provides two approaches. `compileClosed`
checks an untyped list of actions, rejecting invalid stage transitions
(`shake → accept` is rejected). `enumerate` constructs complete, phase-typed
rounds directly, filtered by an additive **user-declared static work estimate**.
`BoundedRecipe` includes a proof that the declared estimate fits the chosen
budget. This is **not** a runtime, evaluation-count or quality guarantee.

The generator has structural theorems for program size, incumbent
non-deterioration and candidate/incumbent synchronization. The demo now prints
five candidate recipes for a small fixed palette/budget. See
[`docs/synthesis.md`](docs/synthesis.md) for precise definitions, proofs,
limitations and related work. Generated algorithms are neither ranked by
fitness nor claimed to be new.

## v0.3: explicit instrumented oracle observations

`CatOpt/DSL/Resources.lean` adds a small Writer-like structure `Metered`,
`probe` as the *explicit* objective-query effect, and two checked clients:

- A **closed list scorer** `probeMany`: precisely one `probe` per entry; Lean
  proves its return values and the exact number of instrumented observations.
  `ProbeBudget.queries_le` proves a genuine bound for this restricted client.
  `AcceptanceBudget.queries_le` separately bounds *recorded acceptance probes*
  for generated rounds (not total algorithmic evaluations).
- A **search-state instrumentation** `runMetered`: acceptance uses two `probe`
  calls. An erasure theorem proves that `.value` agrees with existing `Search.run`,
  and a theorem counts exactly `2 × acceptCount` instrumented acceptance probes.

**Fundamental limitation:** old `Primitives` (including `localSearch`) remain
opaque and may perform **unrecorded** objective calls. The second theorem is
*not* a bound on total algorithm evaluations, and must never be described as one.
See [`docs/resources.md`](docs/resources.md) and the
[`novelty audit`](docs/novelty-audit.md), including the existing CSLib `TimeM`.
For scientific milestones and publication criteria see
[`docs/publication-plan.md`](docs/publication-plan.md).

## v0.4: metered finite-neighborhood selection

`CatOpt/DSL/OracleLocalSearch.lean` introduces a closed best-of-list *selector* for
supplied **feasible** candidates. Each comparison uses two explicit `probe`
calls, and Lean is asked to establish **exact** observed query counts,
value-preserving erasure to a pure reference selector, and non-worsening of the
selected objective. A selector-plus-acceptance round accounts for
`2 × candidate_count + 2` instrumented observations and supports a
proof-bearing `RoundBudget` certificate.

The **neighbor-list producer is still external** and may contain uninstrumented
computation or oracle calls; existing GRASP/GVNS/IG operators are not reverified
by this new module. This is not a complete evaluation bound for any of those
algorithms. See [`docs/oracle-local-search.md`](docs/oracle-local-search.md).

For incremental Git commits, see [`docs/git-workflow.md`](docs/git-workflow.md)
and the separate v0.4 patch ZIP with `apply_v04.ps1`.

## What is formally stated, and what is not?

| Component | Mathematical claim | Current evidence |
|---|---|---|
| Category | Identity, associativity, proof-preserving composition | Confirmed by user in v0.1 Windows build |
| Operator | Non-worsening closed under composition and finite iteration | Confirmed by user in v0.1 Windows build |
| DSL | Well-typed phases and interpretation preserving categorical laws | Confirmed by user in v0.1 Windows build |
| Search | Incumbent cost does not increase under any well-typed program | Confirmed by user in v0.1 Windows build |
| GRASP/GVNS/IG | Finite sequences with well-typed operators and generic proof | Confirmed by user in v0.1 Windows build |
| v0.2 synthesis | Typed action checker, round generation, syntactic size, budget certificate and incumbent guarantee | User-confirmed successful 6013-job Lean build |
| v0.3 instrumented oracle | Closed list-scoring query count, acceptance-probe count, interpreter erasure and incumbent monotonicity | User-confirmed 6019-job Lean build |
| v0.4 local selector | Exact selection/acceptance query count and non-worsening for a supplied feasible neighbor list | Pending v0.4 `lake build` |
| TSP | Feasible benchmark implementations, repeatable seeds, exact small-instance optima | Executed Python tests; **not Lean verified** |
| General convergence | No claim | Not implemented |
| Experimental superiority | No claim | Requires independent evaluation |

## Model comparisons and limitations

We deliberately chose a **predicate-preserving category + phase-indexed syntax** rather than a Kleisli category or a monoidal category as the initial formal core. The trade-offs and alternatives are discussed in `docs/formulation.md`; source-aware comparison with categorical learning and automated metaheuristic design appears in `docs/related-work.md`.

**Important distinctions:**

- A probability kernel is *not* simply a deterministic `S → S`. Randomness is explicit only through seed parameters in the current Lean prototype, and a compositional stochastic semantics remains future work.
- The Lean GVNS example is a **fixed-radius schedule**, not full adaptive GVNS. The Python benchmark uses acceptance-driven radius changes and is **not proven equivalent** to the Lean program.
- The term `VND` in the Lean example denotes a finite sequence of descent steps, not the fully general multi-neighborhood VND. The Python benchmark implements actual 2-opt and insertion VND.
- Only an **elitist acceptance policy** is modeled. Simulated annealing, Metropolis acceptance, multiobjective dominance and nonelitist population updates do not satisfy the stated generic monotonicity theorem without modifying the property.
- The category is meaningful because feasibility is a property of arrows, but this alone is not a novel category-theoretic construction. Novelty would require a compelling, nontrivial abstraction or new derivations.

## Papers and provenance

1. Brendan Fong, David I. Spivak, Rémy Tuyéras (2019), [*Backprop as Functor*](https://arxiv.org/abs/1711.10455).
2. Bruno Gavranović (2024), [*Fundamental Components of Deep Learning*](https://arxiv.org/abs/2403.13001).
3. Bruno Gavranović et al. (2024), [*Categorical Deep Learning is an Algebraic Theory of All Architectures*](https://proceedings.mlr.press/v235/gavranovic24a.html).
4. Dan Shiebler (2021), [*Generalized Optimization*](https://arxiv.org/abs/2109.10262).
5. [Lean 4](https://lean-lang.org/), [Mathlib](https://github.com/leanprover-community/mathlib4), and the [Lean category theory documentation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/CategoryTheory/Category/Basic.html).

These papers motivate compositional mathematics but **do not certify that CatOpt-Lean is new**. It needs a proper literature review of combinatorial optimization, typed heuristics and algorithm configuration as well as categorical ML.

## Project status

**0.4.0 — finite-neighborhood selector / Lean verification pending.** The user verified the entire v0.3 project with Lean 4.32.0 on 2026-11-15 (6019 jobs) and Python tests (5/5). The newly added v0.4 modules are source-reviewed, but their compilation still needs to be confirmed. Neither v0.3 nor v0.4 counts calls hidden in opaque generators or primitives. See `docs/verification-status.md`.

Contributions, counterexamples and critical mathematical review are welcome. Licensed under MIT.
