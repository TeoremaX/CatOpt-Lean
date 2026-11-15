import CatOpt.DSL.Synthesis
import CatOpt.Examples.Synthesis

/-!
# Compile-time tests for typed synthesis and budget certificates

These are Lean checks, *not* performance benchmarks. Invalid raw programs
must be rejected; successful synthesis is certified by general theorems.
-/
namespace CatOpt.Tests.Synthesis
open CatOpt.DSL.Synthesis
open CatOpt.DSL.Search

/-- Acceptance is illegal before generating and improving a candidate. -/
example : compileClosed [.accept] = none := rfl

/-- A raw shake cannot be accepted without the required local-search phase. -/
example : compileClosed [.shake 2, .accept] = none := rfl

/-- A second construction is illegal while a candidate is pending. -/
example : compileClosed [.construct 3, .construct 5] = none := rfl

/-- A complete construction / descent / acceptance round is accepted. -/
example : (compileClosed [.construct 3, .localSearch, .accept]).isSome = true := rfl

/-- A dangling candidate is rejected because the terminal phase is not ready. -/
example : compileClosed [.construct 3, .localSearch] = none := rfl

/-- An empty program is the identity and is well typed. -/
example : (compileClosed []).isSome = true := rfl

/-- Five admissible recipes: identity, three single rounds, and the
    two-round shake/shake combination at estimated cost 7 + 7 = 14. -/
example : Examples.synthesizedRecipes.length = 5 := by decide

/-- At budget six only the empty/identity program is admitted. -/
example :
    (enumerate Examples.synthesisChoices 2 Examples.synthesisCosts 6).length = 1 := by
  decide

/-- Budget rejection and acceptance are computed without an outside oracle. -/
example :
    (certify Examples.synthesisCosts 6 [.shake 2]).isSome = false := rfl
example :
    (certify Examples.synthesisCosts 14 [.shake 2, .shake 2]).isSome = true := rfl

/-- Successful raw compilation also inherits the monotone-incumbent theorem. -/
example (p : SearchProgram .ready .ready)
    (h : compileClosed [.shake 2, .localSearch, .accept] = some p) :
    IncumbentMonotone Examples.bounded (run Examples.implementation p) := by
  exact compileClosed_monotone Examples.implementation
    [.shake 2, .localSearch, .accept] p h

/-- A specific recipe has exactly six actions across two rounds. -/
example : atomCount (compileRounds [.construct 1, .shake 2]) = 6 := by
  exact compileRounds_atomCount [.construct 1, .shake 2]

/-- Actual theorem applies to the existing Lean search semantics. -/
example (r : BoundedRecipe Examples.synthesisCosts 14) :
    Examples.bounded.cost
      (r.execute Examples.implementation Examples.initial).incumbent ≤ 15 := by
  exact r.incumbent_le Examples.implementation Examples.initial

/-- Every generated round list preserves candidate/incumbent synchronization
    from the synchronized `initial` state of the finite example. -/
example (r : BoundedRecipe Examples.synthesisCosts 14) :
    (r.execute Examples.implementation Examples.initial).candidate =
      (r.execute Examples.implementation Examples.initial).incumbent := by
  exact compileRounds_synced Examples.implementation r.rounds Examples.initial rfl

end CatOpt.Tests.Synthesis
