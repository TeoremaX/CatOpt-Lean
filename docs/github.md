# Publish CatOpt-Lean to GitHub

## In Git Bash or a terminal (from the extracted project directory)

```bash
cd CatOpt-Lean
# Recommended: run local tests before first push.
python3 -m unittest discover -s experiments -p 'test_*.py' -v
# After installing Lean and Mathlib:
lake update
lake exe cache get
lake build
# Review the generated lake-manifest.json; commit it for reproducibility.

git init
git branch -M main
git add .
git commit -m "Initial typed compositional optimization framework"
```

Create a **new empty** GitHub repository named `CatOpt-Lean` (without selecting
an auto-generated README or `.gitignore`). Copy its Git remote URL, then:

```bash
git remote add origin https://github.com/YOUR_USER/CatOpt-Lean.git
git push -u origin main
```

Or with authenticated GitHub CLI:

```bash
gh auth login
gh repo create CatOpt-Lean --public --source=. --remote=origin --push
```

The Actions tab should show **Lean proofs** and **Python benchmark tests**.
If the Lean workflow is red, fix the compiler errors before adding an
"all proofs verified" badge or claiming formal verification on a CV.

Recommended GitHub repository description:

> Research prototype: category-theoretic semantics and phase-typed
> optimization pipelines in Lean 4; TSP benchmarks in Python.

Suggested topics: `lean4`, `mathlib`, `category-theory`, `formal-methods`,
`optimization`, `metaheuristics`, `domain-specific-language`,
`combinatorial-optimization`, `automated-algorithm-design`.

Be careful with wording: no stronger verification claim than the actual
status shown by the first green workflow and checked theorems.
