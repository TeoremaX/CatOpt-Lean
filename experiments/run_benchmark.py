"""Run reproducible comparative TSP experiments (Python 3.11+; stdlib only)."""
from __future__ import annotations

import argparse
import csv
import statistics
from pathlib import Path

from tsp import INSTANCES, held_karp, solve, validate_result

ALGORITHMS = ("grasp-vnd", "gvns", "iterated-greedy")


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=int, default=15)
    parser.add_argument("--budget", type=int, default=5000)
    parser.add_argument("--instances", nargs="+", default=list(INSTANCES),
                        choices=sorted(INSTANCES))
    parser.add_argument("--out", type=Path, default=Path("experiments/results.csv"))
    args = parser.parse_args(argv)
    if args.runs < 1 or args.budget < 2:
        parser.error("--runs >= 1 and --budget >= 2 are required")

    rows: list[dict[str, str | int | float]] = []
    for name in args.instances:
        instance = INSTANCES[name]
        optimum = held_karp(instance)
        print(f"\n{name}: optimum = {optimum} (exact Held-Karp)")
        for algorithm in ALGORITHMS:
            costs = []
            for seed in range(args.runs):
                outcome = solve(instance, algorithm, seed, args.budget)
                validate_result(instance, outcome)
                assert outcome.best_cost >= optimum
                costs.append(outcome.best_cost)
                rows.append({
                    "instance": name, "algorithm": algorithm, "seed": seed,
                    "budget": args.budget, "evaluations": outcome.evaluations,
                    "cost": outcome.best_cost, "optimum": optimum,
                    "gap_pct": round(100 * (outcome.best_cost - optimum) / optimum, 5),
                })
            print(f"  {algorithm:17s} best={min(costs):4d} "
                  f"mean={statistics.mean(costs):7.2f} "
                  f"std={statistics.pstdev(costs):6.2f} "
                  f"opt_hits={sum(x == optimum for x in costs)}/{args.runs}")

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"\nSaved {len(rows)} rows to {args.out}")


if __name__ == "__main__":
    main()
