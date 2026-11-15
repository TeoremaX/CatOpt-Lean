# Git workflow for CatOpt-Lean

## Principles

- Commit a scientific change in small, independently understandable units.
- Never commit `.lake/`, build artifacts, secrets, benchmark scratch files or unrelated edits.
- Do not publish a verification claim until `lake build` passes for the precise commit that will be published.
- If a Lean proof fails, fix it **before committing the corresponding unit**; do not insert `sorry` to obtain a passing build.
- Commit `lake-manifest.json` when generated and stable. If it is untracked when starting the v0.4 patch, commit it first as a separate reproducibility change.

## v0.4 three commits

The patch ZIP contains three changesets and `apply_v04.ps1`, which applies each changeset and invokes the test relevant to it **before committing**:

1. `feat(lean): instrument finite feasible-neighborhood selection` — `CatOpt/DSL/OracleLocalSearch.lean` (checks with `lake env lean CatOpt/DSL/OracleLocalSearch.lean`).
2. `test(lean): prove and exercise metered local-search rounds` — adds examples, tests, imports, executable demo, version bump (checks `lake build`, demo, no-sorry checker and Python regression tests).
3. `docs: specify oracle accounting limits and v0.4 release` — documents scope and remaining trust boundary.

The script invokes `git` using the user's configured name and email. It does **not** set its own authorship, overwrite `.git`, call `git init`, or push automatically. It refuses a dirty working tree, a missing Git repository and an unexpected version. The user can inspect every change before pushing.

Recommended execution from outside the repository:

```powershell
Expand-Archive .\CatOpt-Lean-v0.4-parche-commits.zip -DestinationPath .\CatOpt-v04-patch
& .\CatOpt-v04-patch\apply_v04.ps1 -RepoPath 'C:\Users\User\Documents\CatOpt-Lean'
```

If you have uncommitted v0.3 edits, review them and create an initial baseline commit first:

```powershell
cd C:\Users\User\Documents\CatOpt-Lean
git status
git add -A
git diff --cached --stat
git commit -m "chore: checkpoint validated CatOpt-Lean v0.3"
```

Only run `git add -A` after inspecting the staged changes and confirming no sensitive data or untracked artifacts are included. If `git status` shows a different branch from the intended one, create a feature branch before applying the patch, e.g. `git switch -c feat/oracle-local-search`.

When all checks have passed:

```powershell
git log --oneline -4
git status
git push -u origin feat/oracle-local-search
```

If you are not using a feature branch, substitute your actual branch name. Pull requests and branch-protection checks are recommended for the repository's main branch.

## On errors

The script stops at the first failed Lean command and leaves the relevant files in your worktree **uncommitted**, allowing you to inspect the error. Do not rerun it blindly after partially applying commits; inspect `git log` and `git status`. The script never resets or deletes existing Git history.
