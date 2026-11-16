"""Integration checks that run the Lean executable, including negative cases.

Run *after* `lake build` (requires Lean 4.32.0 and Mathlib).
This is an executable regression test, not a formal theorem of CSV parsing.
"""
from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "experiments" / "fixtures"


def run(input_path: Path, expected_status: int, marker: str) -> None:
    process = subprocess.run(
        ["lake", "exe", "catopt-certify", str(input_path)],
        cwd=ROOT, capture_output=True, text=True, check=False,
    )
    combined = process.stdout + process.stderr
    if process.returncode != expected_status or marker not in combined:
        raise AssertionError(
            f"input={input_path.name}: expected exit {expected_status}, {marker!r}; "
            f"got exit {process.returncode}, output={combined!r}"
        )
    print(f"PASS {input_path.name}: exit={expected_status}, verdict={marker}")


def main() -> None:
    run(FIXTURES / "square-accepted.cert", 0, "ACCEPTED:")
    run(FIXTURES / "square-rejected.cert", 1, "REJECTED:")
    original = (FIXTURES / "square-accepted.cert").read_text()
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        cases = {
            "duplicate.cert": (original.replace("0 1 2 3\n", "0 1 1 3\n"), 2),
            "out-of-range.cert": (original.replace("0 1 2 3\n", "0 1 2 4\n"), 2),
            "matrix-too-short.cert": (original.replace("0 1 2 1\n", "0 1 2\n"), 2),
            "negative.cert": (original.replace("0 1 2 1\n", "0 -1 2 1\n"), 2),
            "extra-row.cert": (original + "0 0 0 0\n", 2),
            "empty.cert": ("", 2),
        }
        for name, (text, status) in cases.items():
            path = root / name
            path.write_text(text, encoding="utf-8")
            run(path, status, "INVALID:")
        crlf = root / "windows.cert"
        crlf.write_bytes(original.replace("\n", "\r\n").encode("utf-8"))
        run(crlf, 0, "ACCEPTED:")


if __name__ == "__main__":
    main()
