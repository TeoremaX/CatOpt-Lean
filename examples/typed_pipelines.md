# Phase-typed pipelines (schematic)

All chains below have type `SearchProgram .ready .ready`.

```lean
Algorithms.graspVND 17
Algorithms.gvnsSchedule [1, 2, 3, 4]
Algorithms.iteratedGreedy [2, 3, 2]
```

Each round follows one of three legal phase transitions:

```text
ready ──construct(seed)──────> candidate ──localSearch──> improved ──accept──> ready
ready ──shake(radius)───────> candidate ──localSearch──> improved ──accept──> ready
ready ──destroyRepair(k)────> candidate ──localSearch──> improved ──accept──> ready
```

A direct `accept` from `ready` is rejected by the indexed type.

**Important:** this is an intentionally restricted DSL. It does not yet
represent reactive schedules, non-elitist acceptance (e.g. standard simulated
annealing), or heterogeneous population states. The `run` interpreter does
model the incumbent and candidate separately.
