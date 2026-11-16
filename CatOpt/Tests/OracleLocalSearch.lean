import CatOpt.Examples.OracleLocalSearch

/-! v0.4 compile-time regression theorems, including polymorphic guarantees. -/
namespace CatOpt.Tests.OracleLocalSearch
open CatOpt.DSL.OracleLocalSearch

/-- Results are unchanged when the explicitly counted effects are erased. -/
example (P : Problem) (start : Candidate P) (xs : List (Candidate P)) :
    (selectMetered P start xs).value = select P start xs :=
  selectMetered_value P start xs

/-- Exactly two observations per neighbor. -/
example (P : Problem) (start : Candidate P) (xs : List (Candidate P)) :
    (selectMetered P start xs).queries = 2 * xs.length :=
  selectMetered_queries P start xs

/-- Selected candidates remain feasible by their dependent subtype. -/
example (P : Problem) (start : Candidate P) (xs : List (Candidate P)) :
    P.feasible (selectMetered P start xs).value.val :=
  (selectMetered P start xs).value.property

/-- Selection cannot worsen the objective function. -/
example (P : Problem) (start : Candidate P) (xs : List (Candidate P)) :
    P.cost (selectMetered P start xs).value.val ≤ P.cost start.val :=
  selectMetered_le P start xs

/-- Both selection and acceptance are included in this exact query count. -/
example (P : Problem) (neighbors : P.State → List (Candidate P))
    (s : SearchState P) :
    (roundMetered P neighbors s).queries =
      2 * (neighbors s.candidate).length + 2 :=
  roundMetered_queries P neighbors s

example (P : Problem) (neighbors : P.State → List (Candidate P))
    (s : SearchState P) :
    P.cost (roundMetered P neighbors s).value.incumbent ≤ P.cost s.incumbent :=
  roundMetered_incumbent_le P neighbors s

/-- A budget smaller than the six modeled observations is rejected. -/
example : (certifyRound Examples.bounded 5 Examples.initial
    Examples.v04Candidates).isNone = true := rfl

example : (certifyRound Examples.bounded 6 Examples.initial
    Examples.v04Candidates).isSome = true := rfl

example : Examples.v04Selection.queries = 4 := by
  unfold Examples.v04Selection
  rw [selectMetered_queries]
  rfl

example : Examples.v04Round.queries = 6 := by
  unfold Examples.v04Round
  rw [roundMetered_queries]
  rfl

/-- Check the executable result, not only the generic bound. -/
example : Examples.v04Round.value.incumbent = 13 := by decide

example (c : RoundBudget Examples.bounded 6) :
    (roundMetered Examples.bounded (fun _ => c.candidates) c.state).queries ≤ 6 :=
  c.queries_le

end CatOpt.Tests.OracleLocalSearch
