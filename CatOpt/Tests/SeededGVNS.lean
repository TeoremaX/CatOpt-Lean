import CatOpt.Examples.SeededGVNS

/-! v0.7 regression checks of seeded shaking, nested VND and modeled costs. -/
namespace CatOpt.Tests.SeededGVNS
open CatOpt.DSL.SeededGVNS
open CatOpt.DSL.FiniteNeighborhood

/-- Shake is deterministic for a given seed and move list. -/
example : (shake 20 [.forward 4, .backward 1] 0 (15 : Fin 21)).val = 19 := by decide
example : (shake 20 [.forward 4, .backward 1] 1 (15 : Fin 21)).val = 14 := by decide
example : (shake 20 [] 10 (15 : Fin 21)).val = 15 := by decide

/-- An outer step is non-worsening for any objective and any seed. -/
example {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) :
    objective (step objective config s).value.search.incumbent ≤
      objective s.search.incumbent :=
  step_incumbent_le objective config s

/-- The outer query count is the nested count plus two probes when active. -/
example {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) :
    (step objective config s).queries =
      match config.shaking[s.index]? with
      | none => 0
      | some moves =>
          (localRun objective config moves s.seed s.search.incumbent).queries + 2 :=
  step_queries objective config s

/-- Both policy branches are covered by proofs, not only sample traces. -/
example {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) (moves : List Move)
    (h : config.shaking[s.index]? = some moves)
    (hi : objective (localRun objective config moves s.seed s.search.incumbent).value.search.incumbent <
      objective s.search.incumbent) :
    (step objective config s).value.index = 0 :=
  step_reset objective config s moves h hi

example {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) (moves : List Move)
    (h : config.shaking[s.index]? = some moves)
    (hi : ¬ objective (localRun objective config moves s.seed s.search.incumbent).value.search.incumbent <
      objective s.search.incumbent) :
    (step objective config s).value.index = s.index + 1 :=
  step_advance objective config s moves h hi

/-- The proof is about the entire nested execution, not only one selector. -/
example {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (fuel : Nat) (s : State n objective) :
    (run objective config fuel s).queries ≤
      fuel * (config.vndFuel * (2 * cap + 4) + 2) :=
  run_queries_le objective config fuel s

example {cap innerFuel budget n : Nat}
    (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective)
    (cert : RunBudget cap innerFuel budget)
    (h : config.vndFuel = innerFuel) :
    (run objective config cert.outerFuel s).queries ≤ budget :=
  cert.queries_le objective config s h

/-- The first shake cannot win against the incumbent after only two descents. -/
example : Examples.seededFirst.value.search.incumbent.val = 15 := by decide
example : Examples.seededFirst.value.index = 1 := by decide
example : Examples.seededFirst.queries = 14 := by decide

/-- The next shake produces an accepted strictly better result. -/
example : Examples.seededResult.value.search.incumbent.val = 12 := by decide
example : Examples.seededResult.value.index = 0 := by decide
example : Examples.seededResult.queries = 28 := by decide

/-- Pre-execution budget admits 28 registered probes but rejects 27. -/
example : (certifyRun 1 2 28 2).isSome = true := by decide
example : (certifyRun 1 2 27 2).isNone = true := by decide

/-- Structural fuel zero or an exhausted outer catalog incurs no queries. -/
example : (run Examples.finiteLineObjective Examples.seededConfig 0
    Examples.seededInitial).queries = 0 := rfl

def exhausted : State 20 Examples.finiteLineObjective :=
  ⟨Examples.finiteLineInitial, 5, 0⟩
example : (step Examples.finiteLineObjective Examples.seededConfig exhausted).queries = 0 := by decide

end CatOpt.Tests.SeededGVNS
