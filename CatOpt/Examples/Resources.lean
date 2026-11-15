import CatOpt.Examples.Synthesis
import CatOpt.DSL.Resources

/-! Small executable checks of the instrumented objective-query semantics. -/
namespace CatOpt.Examples
open CatOpt.DSL.Resources
open CatOpt.DSL.Synthesis

/-- This particular client explicitly asks the objective four times. -/
def probeExample : Metered (List Nat) :=
  probeMany bounded [15, 7, 0, 20]

/-- Only one `accept` occurs: this records two oracle observations.
    The opaque `vndOp` computation is NOT measured by this counter. -/
def meteredRoundExample : Metered (SearchState bounded) :=
  runMetered implementation (compileRounds [.shake 2]) initial

/-- Three probes fit into a budget of three instrumented objective calls. -/
def probedBudgetExample : Option (ProbeBudget bounded 3) :=
  certifyProbes bounded 3 [15, 7, 0]

end CatOpt.Examples
