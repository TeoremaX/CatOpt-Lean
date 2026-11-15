# Empirical TSP study: protocol and initial smoke measurements

## What is being tested?

Three *Python* heuristics are compared on symmetric metric TSP instances:

- `grasp-vnd`: nearest-edge restricted candidate list (`alpha = 0.25`),
  then a two-neighborhood VND;
- `gvns`: randomized incumbent, VND, random-swap shaking (radius 1–4) with
  radius reset on strictly improved incumbent;
- `iterated-greedy`: randomized incumbent, VND, removal of three cities,
  cheapest reinsertion, VND, strict elitist acceptance.

The VND contains 2-opt and insertion neighborhoods, using first improvement
and reset to the first neighborhood after an accepted improvement. All
operators maintain permutations and city 0 remains fixed. The implementations
use deterministic `random.Random(seed)` and an objective-evaluation budget.

**The Lean `GVNS` is a fixed schedule, not the adaptive Python GVNS. The
Lean finite-state `VND` is repeated descent, not Python's 2-opt/insertion
VND. No equivalence or simulation relation has been proved.**

## Benchmark instances

Generated/original coordinate sets are shipped in `experiments/tsp.py`:
`grid12`, `ring14`, `cluster16`. Their small sizes permit Held-Karp exact
optimal-cost computation and provide an independent reference for gaps.
A minimum-cost tour may have many equivalent permutations.

## Fully specified quick smoke experiment (executed)

Run:

```bash
python3 experiments/run_benchmark.py --runs 3 --budget 1500 \
  --instances grid12 ring14 --out experiments/quickcheck.csv
```

| Instance | Exact optimum | Algorithm | Best | Mean | Population SD | Optimal / 3 |
|---|---:|---|---:|---:|---:|---:|
| grid12 | 214 | grasp-vnd | 214 | 214.00 | 0.00 | 3 |
| grid12 | 214 | gvns | 214 | 216.33 | 3.30 | 2 |
| grid12 | 214 | iterated-greedy | 214 | 219.67 | 4.19 | 1 |
| ring14 | 236 | grasp-vnd | 236 | 236.00 | 0.00 | 3 |
| ring14 | 236 | gvns | 236 | 236.33 | 0.47 | 2 |
| ring14 | 236 | iterated-greedy | 236 | 236.33 | 0.47 | 2 |

These are **smoke tests, not evidence of superiority**: three seeds, small
instances, and very simple solvers do not support statistically robust
claims. We include them only to show the experiment runner actually executes
and that computed costs are no better than exact optima.

## Stronger preregistered evaluation (not yet executed)

1. Run at least 30 independent seeds per algorithm and instance.
2. Add larger heterogeneous instances (asymmetric, Euclidean, structured)
   and publicly identify their provenance and the known best values.
3. Fix equal *full objective evaluation budgets* and separately report
   wall-clock time, number of distance accesses, and memory usage.
4. Report best, median, mean, SD, success frequency, and gap to known optimum
   with paired uncertainty intervals; consider nonparametric paired tests.
5. Include ablations (VND versus one neighborhood, fixed versus adaptive k,
   removal strength, restricted candidate-list alpha).
6. Compare robust baselines beyond the three variants; report limitations,
   not only winning cases.
7. Before making claims about guaranteed TSP-tour validity in Python,
   provide a machine-checked refinement to Lean's feasible-state model.

## Reproducibility caveats

The evaluation limit counts complete calls to `TSP.cost`, **not** internal
edge-distance calls during greedy construction/destruction. Equal counts do
not mean identical computational work. The `budget` policy may interrupt
VND before the algorithm finishes a candidate's improvement phase, so the
previous incumbent is returned. The next version should instrument all
primitive costs and report runtime distributions.

## Reference batch executed (15 seeds × 3 algorithms × 3 instances)

Command:

```bash
python3 experiments/run_benchmark.py --runs 15 --budget 5000 \
  --out experiments/reference_results.csv
```

The complete 135-row CSV is included. Summary:

| Instance | Exact optimum | Algorithm | Mean | Population SD | Optimal / 15 |
|---|---:|---|---:|---:|---:|
| grid12 | 214 | grasp-vnd | 214.00 | 0.00 | 15 |
| grid12 | 214 | gvns | 214.47 | 1.75 | 14 |
| grid12 | 214 | iterated-greedy | 216.93 | 4.23 | 10 |
| ring14 | 236 | grasp-vnd | 236.00 | 0.00 | 15 |
| ring14 | 236 | gvns | 236.00 | 0.00 | 15 |
| ring14 | 236 | iterated-greedy | 237.00 | 2.00 | 12 |
| cluster16 | 304 | grasp-vnd | 304.00 | 0.00 | 15 |
| cluster16 | 304 | gvns | 304.00 | 0.00 | 15 |
| cluster16 | 304 | iterated-greedy | 304.00 | 0.00 | 15 |

These tiny synthetic instances are easy for several methods. Saturation at
exact optima means the experiment is **not discriminative** enough for a
paper claiming an advantage. They do establish that the benchmark runs,
seeds are reproducible, and small-instance reference optima are available.
