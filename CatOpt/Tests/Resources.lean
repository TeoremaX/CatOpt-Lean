import CatOpt.Examples.Resources

/-! Regression checks compile as Lean theorems with no runtime test runner. -/
namespace CatOpt.Tests.Resources
open CatOpt.DSL.Resources
open CatOpt.DSL.Synthesis

example : Examples.probeExample.queries = 4 := rfl
example : Examples.probeExample.value = [15, 7, 0, 20] := rfl

example : (certifyProbes Examples.bounded 2 [15, 7, 0]).isNone = true := rfl
example : (certifyProbes Examples.bounded 3 [15, 7, 0]).isSome = true := rfl

/-- This result is a theorem about actual `probeMany`, not a declared price. -/
example (c : ProbeBudget Examples.bounded 3) :
    (probeMany Examples.bounded c.inputs).queries ≤ 3 := c.queries_le

/-- The new interpreter returns the same state as the older interpreter. -/
example : Examples.meteredRoundExample.value =
    DSL.Search.run Examples.implementation (compileRounds [.shake 2]) Examples.initial := by
  exact runMetered_value Examples.implementation (compileRounds [.shake 2]) Examples.initial

example : Examples.meteredRoundExample.queries = 2 := by
  exact compileRounds_queries Examples.implementation [.shake 2] Examples.initial

/-- For any number of synthesized rounds, exactly two observations per
    acceptance are visible, not all calls hidden in primitive implementations. -/
example (rs : List RoundStart) :
    (runMetered Examples.implementation (compileRounds rs) Examples.initial).queries =
      2 * rs.length :=
  compileRounds_queries Examples.implementation rs Examples.initial

/-- The instrumented run retains the original monotonicity theorem. -/
example (rs : List RoundStart) :
    Examples.bounded.cost
        (runMetered Examples.implementation (compileRounds rs) Examples.initial).value.incumbent
      ≤ Examples.bounded.cost Examples.initial.incumbent :=
  runMetered_incumbent_le Examples.implementation (compileRounds rs) Examples.initial


example : (certifyAcceptance 3 [.shake 2, .shake 4]).isNone = true := rfl
example : (certifyAcceptance 4 [.shake 2, .shake 4]).isSome = true := rfl

example (c : AcceptanceBudget 4) :
    (runMetered Examples.implementation (compileRounds c.rounds)
      Examples.initial).queries ≤ 4 :=
  c.queries_le Examples.implementation Examples.initial

end CatOpt.Tests.Resources
