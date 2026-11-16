# Technical manuscript

`main.tex` contains the editable nine-page draft; `main.pdf` is a
successfully compiled preview, checked by PDF rendering and text extraction.
The paper uses standard LaTeX packages and inline bibliography entries,
so BibTeX is not required for the preview. `references.bib` is retained for
future journal/Overleaf styles.

Compile locally:

```bash
cd paper
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

This is **not a peer-reviewed paper**. The Lean proofs are written but not
compiler-verified in the project authoring environment. That caveat is
printed in the manuscript itself.


**Version scope:** this manuscript describes the earlier v0.1 formal core.
The v0.2 typed synthesizer is documented separately in `docs/synthesis.md`
and was subsequently compiled successfully by the user. It is **not covered**
by this older paper/PDF.


**Update 2026-11-15 (v0.3):** `paper/main.pdf` is the earlier technical
prototype paper; it is **not** updated to cover resource instrumentation or
the novelty audit. Consult `docs/novelty-audit.md` and `docs/resources.md`
before citing the new claims. No publication readiness is claimed.
