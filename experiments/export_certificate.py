"""Export third-party TSP distance matrices and route data for the Lean verifier.

This tool is a *format converter*, not part of the trusted verifier. The Lean
executable performs its own parsing, tour validation and local-optimality test.

Example:
    python3 experiments/export_certificate.py \
      --matrix experiments/fixtures/square-matrix.csv \
      --tour experiments/fixtures/square-perimeter-tour.csv \
      --out /tmp/square.cert
    lake exe catopt-certify /tmp/square.cert
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path

MAX_CITIES = 32


def read_csv_naturals(path: Path) -> list[list[int]]:
    with path.open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.reader(stream, strict=True)
        rows = []
        for row in reader:
            if not row:
                raise ValueError("empty CSV row")
            values = []
            for cell in row:
                token = cell.strip()
                if not token or not token.isascii() or not token.isdecimal():
                    raise ValueError(f"not a natural-number field: {cell!r}")
                values.append(int(token))
            rows.append(values)
    return rows


def encode_certificate(matrix: list[list[int]], tour: list[int]) -> str:
    n = len(matrix)
    if not 1 <= n <= MAX_CITIES:
        raise ValueError(f"number of cities must be in [1, {MAX_CITIES}]")
    if any(len(row) != n for row in matrix):
        raise ValueError("distance matrix must be square")
    if any(not isinstance(value, int) or value < 0 for row in matrix for value in row):
        raise ValueError("distance entries must be natural numbers")
    if len(tour) != n or set(tour) != set(range(n)):
        raise ValueError("tour is not a permutation of 0 .. N-1")
    lines = [str(n)]
    lines.extend(" ".join(map(str, row)) for row in matrix)
    lines.append(" ".join(map(str, tour)))
    return "\n".join(lines) + "\n"


def export(matrix_path: Path, tour_path: Path, out_path: Path) -> None:
    matrix = read_csv_naturals(matrix_path)
    route_rows = read_csv_naturals(tour_path)
    if len(route_rows) != 1:
        raise ValueError("tour CSV must contain exactly one row")
    output = encode_certificate(matrix, route_rows[0])
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(output, encoding="utf-8", newline="\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument("--tour", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    export(args.matrix, args.tour, args.out)
    print(f"Wrote certificate: {args.out}")


if __name__ == "__main__":
    main()
