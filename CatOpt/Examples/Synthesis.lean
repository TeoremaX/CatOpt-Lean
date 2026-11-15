import CatOpt.Examples.Finite
import CatOpt.DSL.Synthesis

/-! # Finite demonstration of bounded, typed round synthesis -/
namespace CatOpt.Examples
open DSL.Synthesis

/-- Arbitrary illustrative static estimates; these are not measured costs. -/
def synthesisCosts : WorkCosts where
  construct := 3
  shake := 2
  destroyRepair := 4
  localSearch := 5
  accept := 0

/-- Three permitted candidate generators. -/
def synthesisChoices : List RoundStart :=
  [.construct 3, .shake 2, .destroyRepair 1]

/-- Typed enumerator result with proof-carrying budget checks. -/
def synthesizedRecipes : List (BoundedRecipe synthesisCosts 14) :=
  enumerate synthesisChoices 2 synthesisCosts 14

end CatOpt.Examples
