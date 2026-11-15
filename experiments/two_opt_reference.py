"""Independent Python 2-opt reference, NOT formally linked to the Lean model.

This small finite model is useful for exhaustive regression and cross-language
comparison in future work. It is not evidence of refinement by itself.
"""

from __future__ import annotations

from typing import Callable, Sequence, TypeVar

City = TypeVar("City")


def reverse_segment(tour: Sequence[City], lo: int, hi: int) -> tuple[City, ...]:
    """Reverse the inclusive segment [lo, hi], leaving other positions intact."""
    n = len(tour)
    if not 0 <= lo <= hi < n:
        raise ValueError("expected 0 <= lo <= hi < len(tour)")
    result = tuple(tour)
    return result[:lo] + tuple(reversed(result[lo : hi + 1])) + result[hi + 1 :]


def cyclic_cost(tour: Sequence[City], distance: Callable[[City, City], int]) -> int:
    """Sum all directed cycle arcs, including last -> first."""
    if not tour:
        raise ValueError("tour must be nonempty")
    return sum(distance(city, tour[(i + 1) % len(tour)]) for i, city in enumerate(tour))


def square_distance(a: int, b: int) -> int:
    if a == b:
        return 0
    if (a + 1) % 4 == b or (b + 1) % 4 == a:
        return 1
    return 2


def metered_elitist_round(
    initial: Sequence[int],
    segments: Sequence[tuple[int, int]],
    distance: Callable[[int, int], int],
) -> tuple[tuple[int, ...], int]:
    """Mirror current Lean selector: 2 comparisons per candidate + acceptance.

    This is an independent reference implementation and DOES NOT provide a
    formal proof that Python refines Lean.
    """
    current = tuple(initial)
    candidate = current
    queries = 0
    for lo, hi in segments:
        fresh = reverse_segment(current, lo, hi)
        # Local search compares each neighbor with the current best candidate.
        old_cost = cyclic_cost(candidate, distance)
        new_cost = cyclic_cost(fresh, distance)
        queries += 2
        if new_cost < old_cost:
            candidate = fresh
    original_cost = cyclic_cost(current, distance)
    improved_cost = cyclic_cost(candidate, distance)
    queries += 2
    return (candidate if improved_cost < original_cost else current), queries
