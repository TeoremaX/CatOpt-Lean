# v0.2: examples of typed synthesis

Run from the repository root:

```powershell
lake build
lake exe catopt-demo
```

The executable includes an illustration from `CatOpt/Examples/Synthesis.lean`.
It declares three possible first operators per round:

```lean
def synthesisChoices : List RoundStart :=
  [.construct 3, .shake 2, .destroyRepair 1]
```

A complete round is automatically expanded into:

```text
[construct|shake|destroyRepair] >>> localSearch >>> accept
```

Only at most two rounds are enumerated, with user-declared costs `3/2/4`
for the first action, `5` for `localSearch` and `0` for `accept`.

| Recipe | Static estimated work | Included at budget 14? |
|---|---:|---|
| empty (identity) | 0 | yes |
| construct | 8 | yes |
| shake | 7 | yes |
| destroyRepair | 9 | yes |
| shake, shake | 14 | yes |
| construct, shake | 15 | no |
| construct, construct | 16 | no |
| destroyRepair, shake | 16 | no |

Thus five recipes should be printed. These are not distinct in objective
quality on the **toy** bounded-Nat example: its fixed 20-step descent makes
all nonempty rounds reach zero. This does not rank heuristics or show that
synthesis improves optimization.

The raw checker also supports:

```lean
-- Compiles to `none`: a candidate has not yet passed local search.
#eval (CatOpt.DSL.Synthesis.compileClosed
  [.shake 2, .accept]).isSome

-- Compiles to `some` typed program.
#eval (CatOpt.DSL.Synthesis.compileClosed
  [.shake 2, .localSearch, .accept]).isSome
```

The formal versions of these checks live in `CatOpt/Tests/Synthesis.lean`.
See `docs/synthesis.md` for proofs and trust boundaries.
