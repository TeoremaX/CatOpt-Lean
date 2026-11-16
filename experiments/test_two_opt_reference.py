import itertools
import unittest

from two_opt_reference import (
    cyclic_cost,
    metered_elitist_round,
    reverse_segment,
    square_distance,
)


class TwoOptReferenceTests(unittest.TestCase):
    def test_all_small_permutations_remain_permutations(self):
        for n in range(1, 7):
            for tour in itertools.permutations(range(n)):
                for lo in range(n):
                    for hi in range(lo, n):
                        candidate = reverse_segment(tour, lo, hi)
                        self.assertEqual(set(candidate), set(tour))
                        self.assertEqual(len(candidate), n)
                        self.assertEqual(reverse_segment(candidate, lo, hi), tour)

    def test_segment_matches_hand_calculation(self):
        self.assertEqual(reverse_segment((0, 2, 1, 3), 1, 2), (0, 1, 2, 3))
        self.assertEqual(reverse_segment((0, 1, 2, 3, 4), 1, 3), (0, 3, 2, 1, 4))

    def test_square_crossing_and_elitist_round(self):
        tour = (0, 2, 1, 3)
        self.assertEqual(cyclic_cost(tour, square_distance), 6)
        self.assertEqual(cyclic_cost(reverse_segment(tour, 1, 2), square_distance), 4)
        improved, queries = metered_elitist_round(tour, [(1, 2)], square_distance)
        self.assertEqual((improved, queries), ((0, 1, 2, 3), 4))

    def test_rejected_worsening_and_empty_palette(self):
        tour = (0, 1, 2, 3)
        rejected, queries = metered_elitist_round(tour, [(1, 2)], square_distance)
        self.assertEqual((rejected, queries), (tour, 4))
        unchanged, queries = metered_elitist_round(tour, [], square_distance)
        self.assertEqual((unchanged, queries), (tour, 2))

    def test_bad_bounds_and_empty_cycle(self):
        for lo, hi in [(-1, 2), (2, 1), (0, 4)]:
            with self.assertRaises(ValueError):
                reverse_segment((0, 1, 2, 3), lo, hi)
        with self.assertRaises(ValueError):
            cyclic_cost((), square_distance)


if __name__ == "__main__":
    unittest.main()
