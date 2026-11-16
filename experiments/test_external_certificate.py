"""Independent Python tests for the v0.10 file interchange protocol.

These tests are NOT proof that the Python and Lean interpreters are equivalent.
Lean is the only authority for acceptance; testing does not replace its build.
"""
from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from export_certificate import MAX_CITIES, encode_certificate, export, read_csv_naturals

FIXTURES = Path(__file__).resolve().parent / "fixtures"
SQUARE = [[0, 1, 2, 1], [1, 0, 1, 2], [2, 1, 0, 1], [1, 2, 1, 0]]


def reference_cost(matrix: list[list[int]], tour: list[int]) -> int:
    return sum(matrix[tour[i]][tour[(i + 1) % len(tour)]] for i in range(len(tour)))


def reference_is_locally_optimal(matrix: list[list[int]], tour: list[int]) -> bool:
    original = reference_cost(matrix, tour)
    return all(original <= reference_cost(
        matrix, tour[:i] + list(reversed(tour[i:j + 1])) + tour[j + 1:]
    ) for i in range(len(tour)) for j in range(i, len(tour)))


def parse_reference(data: str) -> tuple[list[list[int]], list[int]]:
    rows = [[int(part) for part in line.split()] for line in data.strip().splitlines()]
    size = rows[0][0]
    assert len(rows) == size + 2
    assert len(rows[-1]) == size
    assert len(rows[1:-1]) == size
    return rows[1:-1], rows[-1]


class ExternalCertificateTests(unittest.TestCase):
    def test_export_square(self) -> None:
        with tempfile.TemporaryDirectory() as d:
            target = Path(d) / "square.cert"
            export(FIXTURES / "square-matrix.csv", FIXTURES / "square-perimeter-tour.csv", target)
            self.assertEqual(target.read_text(), (FIXTURES / "square-accepted.cert").read_text())

    def test_export_crossing(self) -> None:
        with tempfile.TemporaryDirectory() as d:
            target = Path(d) / "crossing.cert"
            export(FIXTURES / "square-matrix.csv", FIXTURES / "square-crossing-tour.csv", target)
            self.assertEqual(target.read_text(), (FIXTURES / "square-rejected.cert").read_text())

    def test_accepted_fixture(self) -> None:
        matrix, tour = parse_reference((FIXTURES / "square-accepted.cert").read_text())
        self.assertEqual(reference_cost(matrix, tour), 4)
        self.assertTrue(reference_is_locally_optimal(matrix, tour))

    def test_rejected_fixture(self) -> None:
        matrix, tour = parse_reference((FIXTURES / "square-rejected.cert").read_text())
        self.assertEqual(reference_cost(matrix, tour), 6)
        self.assertFalse(reference_is_locally_optimal(matrix, tour))

    def test_duplicate_tour_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "permutation"):
            encode_certificate(SQUARE, [0, 1, 1, 3])

    def test_negative_matrix_rejected(self) -> None:
        bad = [row[:] for row in SQUARE]
        bad[1][2] = -2
        with self.assertRaisesRegex(ValueError, "natural"):
            encode_certificate(bad, [0, 1, 2, 3])

    def test_non_square_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "square"):
            encode_certificate([[0, 1], [1]], [0, 1])

    def test_too_large_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "number of cities"):
            encode_certificate([[0] * (MAX_CITIES + 1)] * (MAX_CITIES + 1), list(range(MAX_CITIES + 1)))

    def test_csv_rejects_non_natural(self) -> None:
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "bad.csv"
            path.write_text("1,foo,3\n")
            with self.assertRaisesRegex(ValueError, "natural"):
                read_csv_naturals(path)

    def test_directed_works(self) -> None:
        directed = [[0, 1, 20], [9, 0, 1], [1, 20, 0]]
        tour = [0, 1, 2]
        self.assertEqual(reference_cost(directed, tour), 3)
        self.assertTrue(reference_is_locally_optimal(directed, tour))
        result = encode_certificate(directed, tour)
        self.assertEqual(parse_reference(result), (directed, tour))


if __name__ == "__main__":
    unittest.main()
