import CatOpt.Examples.AdaptiveVNS

/-! v0.6 compile-time regression tests for adaptive finite-neighborhood search. -/
namespace CatOpt.Tests.AdaptiveVNS
open CatOpt.DSL.AdaptiveVNS

/-- The controller never worsens the incumbent, for arbitrary cost functions. -/
example {n cap : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (fuel : Nat) (s : State n objective) :
    objective (run objective catalog fuel s).value.search.incumbent ≤
      objective s.search.incumbent :=
  run_incumbent_le objective catalog fuel s

/-- A genuine semantic upper bound, not a user-declared operation price. -/
example {n cap : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (fuel : Nat) (s : State n objective) :
    (run objective catalog fuel s).queries ≤ fuel * (2 * cap + 4) :=
  run_queries_le objective catalog fuel s

example {n cap budget : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective)
    (cert : RunBudget cap budget) :
    (run objective catalog cert.fuel s).queries ≤ budget :=
  cert.queries_le objective catalog s

/-- Policy proof applies to any objective, not only the example trace. -/
example {n cap : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective)
    (moves : List CatOpt.DSL.FiniteNeighborhood.Move)
    (h : catalog.neighborhoods[s.index]? = some moves)
    (improves : objective
      (CatOpt.DSL.FiniteNeighborhood.round n objective moves s.search).value.incumbent <
      objective s.search.incumbent) :
    (step objective catalog s).value.index = 0 :=
  step_reset objective catalog s moves h improves

/-- A no-change neighborhood makes the controller advance. -/
example : (step Examples.finiteLineObjective Examples.adaptiveCatalog
    Examples.adaptiveInitial).value.index = 1 := by decide

/-- The second neighborhood genuinely improves, resetting the controller. -/
example : (run Examples.finiteLineObjective Examples.adaptiveCatalog 2
    Examples.adaptiveInitial).value.index = 0 := by decide

/-- Four adaptive steps produce the trace 15 → 15 → 13 → 13 → 11. -/
example : Examples.adaptiveResult.value.search.incumbent.val = 11 := by decide
example : Examples.adaptiveResult.value.index = 0 := by decide
example : Examples.adaptiveResult.queries = 24 := by decide

example : (certifyRun 1 24 4).isSome = true := by decide
example : (certifyRun 1 23 4).isNone = true := by decide

/-- An exhausted catalog has no further objective queries. -/
def exhausted : State 20 Examples.finiteLineObjective :=
  ⟨Examples.finiteLineInitial, 2⟩

example : (step Examples.finiteLineObjective Examples.adaptiveCatalog
    exhausted).queries = 0 := by decide

/-- No fuel leaves the state unchanged and makes no observations. -/
example : (run Examples.finiteLineObjective Examples.adaptiveCatalog 0
    Examples.adaptiveInitial).queries = 0 := rfl
example : (run Examples.finiteLineObjective Examples.adaptiveCatalog 0
    Examples.adaptiveInitial).value.search.incumbent.val = 15 := by decide

end CatOpt.Tests.AdaptiveVNS
