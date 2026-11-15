import CatOpt.Examples.Resources
import CatOpt.DSL.OracleLocalSearch

/-!
# v0.4 finite selector example

This is a tiny *closed selector*: its supplied candidates are explicitly
feasible, and all comparisons inside the selector and acceptance use `probe`.
The list is fixed and has no hidden objective computation. This is not a
claim about the opaque GRASP/GVNS/IG implementations.
-/
namespace CatOpt.Examples
open CatOpt.DSL.OracleLocalSearch

/-- Two feasible neighbors, with visible costs 14 and 13. -/
def v04Candidates : List (Candidate bounded) :=
  [⟨14, by decide⟩, ⟨13, by decide⟩]

/-- Select the best of 15, 14, 13 using four oracle observations. -/
def v04Selection :=
  selectMetered bounded (⟨15, by decide⟩ : Candidate bounded) v04Candidates

/-- Selection (4 probes) followed by elitist acceptance (2 probes). -/
def v04Round :=
  roundMetered bounded (fun _ => v04Candidates) initial

/-- The budget check is about the actual explicit interpreter trace. -/
def v04Budget : Option (RoundBudget bounded 6) :=
  certifyRound bounded 6 initial v04Candidates

end CatOpt.Examples
