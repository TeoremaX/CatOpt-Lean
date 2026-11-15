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

## v0.5 staged patch

From a clean **v0.4** branch, run the patch's `apply_v05.ps1`. It creates `feat/finite-neighborhood-v05` and attempts three commits: semantics; executable tests; documentation. The script compiles the Lean file and then the full project **before** committing. It never performs `git push`, `git reset`, or `git add -A`. If a stage fails, it leaves only that stage's files for inspection; after downloading a fixed patch, rerun with `-Resume` to explicitly allow replacing those files. Once verified, push with `git push -u origin feat/finite-neighborhood-v05` and open a PR.


## v0.6 staged commits

Starting from a **clean and committed v0.5** on
`feat/finite-neighborhood-v05`, extract the v0.6 patch *outside* the repo and
run `apply_v06.ps1 -RepoPath <your repo>`. It creates
`feat/adaptive-vns-v06`, then performs three verification-gated commits:

1. `feat(lean): add resource-bounded adaptive VNS controller` — new semantics.
2. `test(lean): check adaptive neighborhood policy and query bounds` — examples,
   tests, public imports and demo.
3. `docs: document adaptive controller scope and research limits` — release
   documentation.

After a failed stage, inspect Git status and download a corrected patch if
necessary. `-Resume` permits overwriting only that stage's files; it never
resets history. This script does **not** push to GitHub automatically.
