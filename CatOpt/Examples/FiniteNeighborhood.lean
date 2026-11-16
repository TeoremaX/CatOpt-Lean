import CatOpt.DSL.FiniteNeighborhood

/-!
# v0.5 — Fully specified, finite-move search demonstration

Starting from 15 in `Fin 21`, each of the three rounds considers `x - 1` and
`x - 2` (saturating subtraction). The objective is `Fin.val`.
Expected accepted incumbents are 13, 11 and 9, with six probes per round.
-/
namespace CatOpt.Examples
open CatOpt.DSL.FiniteNeighborhood

/-- A minimal example objective; not an optimization benchmark. -/
def finiteLineObjective (x : Fin 21) : Nat := x.val

/-- Two first-order, oracle-independent moves. -/
def finiteLineMoves : List Move := [.backward 1, .backward 2]

def finiteLineInitial : SearchState (finiteProblem 20 finiteLineObjective) :=
  SearchState.init (15 : Fin 21) (by trivial)

/-- Three complete instrumented rounds on a bounded finite state domain. -/
def finiteLineResult :=
  run 20 finiteLineObjective finiteLineMoves 3 finiteLineInitial

/-- The budget is about modeled objective observations, not CPU or Python. -/
def finiteLineBudget : Option (FuelBudget 18) :=
  certifyFuel 18 3 finiteLineMoves

end CatOpt.Examples
