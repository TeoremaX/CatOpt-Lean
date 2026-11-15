"""Correctness, determinism and boundedness regression tests."""
from __future__ import annotations

import unittest
from random import Random

from tsp import (INSTANCES, destroy_repair, grasp_construct, held_karp,
                 random_tour, shake, solve, validate_result)

ALGORITHMS = ("grasp-vnd", "gvns", "iterated-greedy")


class TSPTests(unittest.TestCase):
    def test_instance_distances(self) -> None:
        for instance in INSTANCES.values():
            for i in range(instance.n):
                self.assertEqual(instance.distance(i, i), 0)
                for j in range(instance.n):
                    self.assertEqual(instance.distance(i, j), instance.distance(j, i))

    def test_construct_and_perturb_remain_permutations(self) -> None:
        for instance in INSTANCES.values():
            rng = Random(1234)
            route = grasp_construct(instance, rng)
            self.assertEqual(set(route), set(range(instance.n)))
            self.assertEqual(route[0], 0)
            for new in (shake(route, 3, rng),
                        destroy_repair(route, 3, instance, rng)):
                self.assertEqual(new[0], 0)
                self.assertEqual(set(new), set(range(instance.n)))

    def test_exact_solver_small_square(self) -> None:
        from tsp import TSP
        square = TSP("square", ((0, 0), (0, 10), (10, 10), (10, 0)))
        self.assertEqual(held_karp(square), 40)

    def test_budget_seed_and_validity(self) -> None:
        instance = INSTANCES["grid12"]
        optimum = held_karp(instance)
        for method in ALGORITHMS:
            first = solve(instance, method, 42, 350)
            second = solve(instance, method, 42, 350)
            self.assertEqual(first, second)
            validate_result(instance, first)
            self.assertGreaterEqual(first.best_cost, optimum)
            self.assertLessEqual(first.best_cost, instance.cost(random_tour(instance, Random(42))))

    def test_invalid_parameters(self) -> None:
        with self.assertRaises(ValueError):
            solve(INSTANCES["grid12"], "grasp-vnd", 0, 1)
        with self.assertRaises(ValueError):
            solve(INSTANCES["grid12"], "unknown", 0, 100)


if __name__ == "__main__":
    unittest.main()
