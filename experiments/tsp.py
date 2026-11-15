"""Reproducible, *unverified* TSP case studies for CatOpt-Lean.

All solvers use the same objective-evaluation limit. Internal distance
lookups for greedy construction are NOT counted as full evaluations, so the
budget is useful for comparisons but is not an equal wall-clock budget.

The Python code is an empirical implementation, not generated or verified by
Lean. In particular, `gvns` includes adaptive neighbourhood changes, whereas
the Lean DSL model currently encodes fixed schedules only.
"""
from __future__ import annotations

from dataclasses import dataclass
from math import hypot
from random import Random
from typing import Iterator, Sequence

Point = tuple[int, int]
Tour = tuple[int, ...]


@dataclass(frozen=True)
class TSP:
    name: str
    points: tuple[Point, ...]

    @property
    def n(self) -> int:
        return len(self.points)

    def distance(self, i: int, j: int) -> int:
        a, b = self.points[i], self.points[j]
        return round(hypot(a[0] - b[0], a[1] - b[1]))

    def cost(self, route: Sequence[int]) -> int:
        if len(route) != self.n or set(route) != set(range(self.n)):
            raise ValueError("A tour must visit each vertex exactly once")
        return sum(self.distance(route[i], route[(i + 1) % self.n])
                   for i in range(self.n))


class BudgetExhausted(Exception):
    """No additional full objective evaluation is allowed."""


@dataclass
class Evaluator:
    instance: TSP
    limit: int
    calls: int = 0

    def score(self, route: Tour) -> int:
        if self.calls >= self.limit:
            raise BudgetExhausted
        self.calls += 1
        return self.instance.cost(route)


@dataclass(frozen=True)
class Result:
    algorithm: str
    instance: str
    seed: int
    budget: int
    evaluations: int
    best_cost: int
    best_tour: Tour


# Three original, deterministic small datasets. Deliberately non-TSPLIB.
INSTANCES: dict[str, TSP] = {
    "grid12": TSP("grid12", tuple(
        (8 + 17 * (i % 4), 9 + 19 * (i // 4) + ((i * 7) % 9))
        for i in range(12)
    )),
    "ring14": TSP("ring14", (
        (5, 38), (10, 23), (20, 13), (35, 7), (49, 10), (60, 20),
        (65, 36), (60, 53), (46, 65), (31, 67), (15, 60), (7, 49),
        (28, 41), (39, 32),
    )),
    "cluster16": TSP("cluster16", (
        (3, 7), (8, 10), (14, 6), (12, 14),
        (62, 5), (66, 11), (73, 4), (69, 16),
        (7, 70), (13, 75), (15, 67), (4, 79),
        (65, 68), (73, 73), (76, 63), (59, 78),
    )),
}


def held_karp(instance: TSP) -> int:
    """Exact optimum via Held-Karp dynamic programming, for small n only."""
    n = instance.n
    if n > 18:
        raise ValueError("Exact solver intentionally limited to 18 vertices")
    # Keys = (visited bitmask, last city); initial city fixed at 0.
    dp: dict[tuple[int, int], int] = {(1, 0): 0}
    for _ in range(1, n):
        nxt: dict[tuple[int, int], int] = {}
        for (mask, last), value in dp.items():
            for city in range(1, n):
                if mask & (1 << city):
                    continue
                key = (mask | (1 << city), city)
                new_cost = value + instance.distance(last, city)
                if new_cost < nxt.get(key, 10**30):
                    nxt[key] = new_cost
        dp = nxt
    all_mask = (1 << n) - 1
    return min(value + instance.distance(last, 0)
               for (mask, last), value in dp.items() if mask == all_mask)


def random_tour(instance: TSP, rng: Random) -> Tour:
    rest = list(range(1, instance.n))
    rng.shuffle(rest)
    return tuple([0, *rest])


def grasp_construct(instance: TSP, rng: Random, alpha: float = 0.25) -> Tour:
    """Randomized restricted candidate list based on nearest-edge distances."""
    route = [0]
    remaining = set(range(1, instance.n))
    while remaining:
        options = sorted((instance.distance(route[-1], city), city)
                         for city in remaining)
        minimum, maximum = options[0][0], options[-1][0]
        threshold = minimum + alpha * (maximum - minimum)
        candidates = [city for distance, city in options if distance <= threshold]
        chosen = rng.choice(candidates)
        route.append(chosen)
        remaining.remove(chosen)
    return tuple(route)


def two_opt_neighbors(route: Tour) -> Iterator[Tour]:
    n = len(route)
    for i in range(1, n - 1):
        for j in range(i + 1, n):
            yield route[:i] + tuple(reversed(route[i:j + 1])) + route[j + 1:]


def insertion_neighbors(route: Tour) -> Iterator[Tour]:
    n = len(route)
    for i in range(1, n):
        for j in range(1, n):
            if i != j:
                candidate = list(route)
                city = candidate.pop(i)
                candidate.insert(j, city)
                yield tuple(candidate)


def vnd(route: Tour, cost: int, ev: Evaluator) -> tuple[Tour, int]:
    """VND with two neighbourhoods and first improvement; restart at k=0."""
    neighborhoods = (two_opt_neighbors, insertion_neighbors)
    k = 0
    while k < len(neighborhoods):
        improved = False
        for candidate in neighborhoods[k](route):
            value = ev.score(candidate)
            if value < cost:
                route, cost = candidate, value
                improved = True
                break
        k = 0 if improved else k + 1
    return route, cost


def shake(route: Tour, strength: int, rng: Random) -> Tour:
    """Random swaps, keeping city 0 fixed; allows objective deterioration."""
    current = list(route)
    for _ in range(strength):
        i, j = rng.sample(range(1, len(current)), 2)
        current[i], current[j] = current[j], current[i]
    return tuple(current)


def destroy_repair(route: Tour, d: int, instance: TSP, rng: Random) -> Tour:
    """Remove d cities and reinsert them at minimum additional edge cost."""
    d = min(max(d, 1), len(route) - 2)
    deleted = rng.sample(list(route[1:]), d)
    remaining = [city for city in route if city not in deleted]
    rng.shuffle(deleted)
    for city in deleted:
        best_delta = None
        best_position = None
        for position in range(1, len(remaining) + 1):
            before = remaining[position - 1]
            after = remaining[position % len(remaining)]
            delta = (instance.distance(before, city)
                     + instance.distance(city, after)
                     - instance.distance(before, after))
            if best_delta is None or delta < best_delta:
                best_delta, best_position = delta, position
        assert best_position is not None
        remaining.insert(best_position, city)
    return tuple(remaining)


def solve(instance: TSP, algorithm: str, seed: int, budget: int) -> Result:
    if budget < 2:
        raise ValueError("budget must be at least 2 full objective evaluations")
    if instance.n < 4:
        raise ValueError("at least 4 vertices required")
    rng = Random(seed)
    ev = Evaluator(instance, budget)
    best: Tour = random_tour(instance, rng)
    best_cost = ev.score(best)

    try:
        if algorithm == "grasp-vnd":
            while True:
                candidate = grasp_construct(instance, rng)
                value = ev.score(candidate)
                candidate, value = vnd(candidate, value, ev)
                if value < best_cost:
                    best, best_cost = candidate, value
        elif algorithm == "gvns":
            # An initial feasible incumbent, then adaptive radius progression.
            best, best_cost = vnd(best, best_cost, ev)
            radius = 1
            while True:
                candidate = shake(best, radius, rng)
                value = ev.score(candidate)
                candidate, value = vnd(candidate, value, ev)
                if value < best_cost:
                    best, best_cost, radius = candidate, value, 1
                else:
                    radius = radius + 1 if radius < 4 else 1
        elif algorithm == "iterated-greedy":
            best, best_cost = vnd(best, best_cost, ev)
            while True:
                candidate = destroy_repair(best, 3, instance, rng)
                value = ev.score(candidate)
                candidate, value = vnd(candidate, value, ev)
                if value < best_cost:
                    best, best_cost = candidate, value
        else:
            raise ValueError(f"Unknown algorithm: {algorithm}")
    except BudgetExhausted:
        pass

    return Result(algorithm, instance.name, seed, budget, ev.calls, best_cost, best)


def validate_result(instance: TSP, result: Result) -> None:
    assert len(result.best_tour) == instance.n
    assert result.best_tour[0] == 0
    assert set(result.best_tour) == set(range(instance.n))
    assert instance.cost(result.best_tour) == result.best_cost
    assert 1 <= result.evaluations <= result.budget
