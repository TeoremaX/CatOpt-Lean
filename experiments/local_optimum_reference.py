"""Independent Python reference for exhaustive 2-opt local-minimum checking.

NO formal refinement connection with Lean. This implementation is for
regression tests and counterexamples, not a proof-producing solver.
"""
from __future__ import annotations
from typing import Sequence


def cost(tour: Sequence[int], matrix: Sequence[Sequence[int]]) -> int:
    n = len(tour)
    if n == 0:
        raise ValueError("A tour cannot be empty")
    if sorted(tour) != list(range(n)) or len(matrix) != n or any(len(row) != n for row in matrix):
        raise ValueError("Expected a permutation and a square distance matrix")
    return sum(matrix[tour[k]][tour[(k + 1) % n]] for k in range(n))


def reverse_segment(tour: Sequence[int], lo: int, hi: int) -> list[int]:
    if not (0 <= lo <= hi < len(tour)):
        raise ValueError("Invalid inclusive segment")
    return list(tour[:lo]) + list(reversed(tour[lo:hi + 1])) + list(tour[hi + 1:])


def check_local_optimum(tour: Sequence[int], matrix: Sequence[Sequence[int]]) -> bool:
    initial = cost(tour, matrix)
    for lo in range(len(tour)):
        for hi in range(lo, len(tour)):
            if cost(reverse_segment(tour, lo, hi), matrix) < initial:
                return False
    return True


def four_edge_delta(tour: Sequence[int], matrix: Sequence[Sequence[int]], lo: int, hi: int) -> int:
    """Only for symmetric TSP and 0 < lo <= hi < n (no wraparound)."""
    n = len(tour)
    if not (0 < lo <= hi < n):
        raise ValueError("4-edge delta requires an interior, nonwrapping segment")
    a, b = tour[lo - 1], tour[lo]
    c, d = tour[hi], tour[(hi + 1) % n]
    return matrix[a][c] + matrix[b][d] - matrix[a][b] - matrix[c][d]
