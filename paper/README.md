# Early manuscript draft

`main.tex` and `references.bib` are retained as research notes. The manuscript was written for the **initial formal core** and does not reflect the current v0.10 implementation, its external TSP certificate checker, or the subsequent verification results.

It is **not** a submitted or accepted paper and should not be cited as describing the current software. The old compiled PDF has been removed to avoid presenting an outdated draft as a current result.

The source can still be rebuilt locally with a standard LaTeX installation:

```bash
cd paper
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

Before reuse in any submission, the manuscript needs to be substantially rewritten, the literature checked, and claims matched to the current Lean theorems and experimental evidence. The up-to-date technical entry points are the repository [README](../README.md), [verification status](../docs/verification-status.md) and [publication criteria](../docs/publication-plan.md).
