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
