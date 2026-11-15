"""Conservative unfinished-proof scan. `lake build` is the real proof check."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
pattern = re.compile(r"\b(sorry|admit|axiom)\b")
bad = []
for file in [root / "CatOpt.lean", root / "Main.lean", *sorted((root / "CatOpt").rglob("*.lean"))]:
    source = file.read_text(encoding="utf-8")
    source = re.sub(r"/-.*?-/", "", source, flags=re.S)
    for number, line in enumerate(source.splitlines(), 1):
        code = line.split("--", 1)[0]
        if pattern.search(code):
            bad.append(f"{file.relative_to(root)}:{number}: {code.strip()}")
if bad:
    raise SystemExit("Forbidden token(s):\n" + "\n".join(bad))
print("No obvious unfinished proofs/extra axioms in Lean source files.")
