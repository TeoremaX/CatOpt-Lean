import CatOpt.Examples.FiniteNeighborhood

/-! v0.5 compile-time regression tests for the finite move interpreter. -/
namespace CatOpt.Tests.FiniteNeighborhood
open CatOpt.DSL.FiniteNeighborhood

/-- No objective value is required to construct a feasible neighbor list. -/
example (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (x : Fin (n + 1)) :
    (certifiedNeighbors n objective moves x).map Subtype.val =
      generate n moves x :=
  certifiedNeighbors_values n objective moves x

/-- The metered costs are independent of current state and objective. -/
example (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (fuel : Nat)
    (s : SearchState (finiteProblem n objective)) :
    (run n objective moves fuel s).queries =
      fuel * (2 * moves.length + 2) :=
  run_queries n objective moves fuel s

/-- Explicit fuel bounds the whole modeled local-search loop. -/
example (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (fuel : Nat)
    (s : SearchState (finiteProblem n objective)) :
    objective (run n objective moves fuel s).value.incumbent ≤
      objective s.incumbent :=
  run_incumbent_le n objective moves fuel s

/-- Successful certificates hold for every objective on the finite domain. -/
example (n budget : Nat) (certificate : FuelBudget budget)
    (objective : Fin (n + 1) → Nat)
    (s : SearchState (finiteProblem n objective)) :
    (run n objective certificate.moves certificate.fuel s).queries ≤ budget :=
  certificate.queries_le objective s

/-- Three rounds, two neighbors each: 3 × (2 × 2 + 2) = 18 queries. -/
example : Examples.finiteLineResult.queries = 18 := by
  unfold Examples.finiteLineResult
  rw [run_queries]
  decide

/-- The concrete execution really accepts 13, then 11, then 9. -/
example : Examples.finiteLineResult.value.incumbent.val = 9 := by decide

example : (certifyFuel 17 3 Examples.finiteLineMoves).isNone = true := by decide
example : (certifyFuel 18 3 Examples.finiteLineMoves).isSome = true := by decide

/-- A zero-fuel run has no probes, and returns the input state. -/
example : (run 20 Examples.finiteLineObjective
    Examples.finiteLineMoves 0 Examples.finiteLineInitial).queries = 0 := rfl
example : (run 20 Examples.finiteLineObjective
    Examples.finiteLineMoves 0 Examples.finiteLineInitial).value.incumbent.val = 15 := by decide

end CatOpt.Tests.FiniteNeighborhood
