/-!
# Basic optimization problem and search state

An objective is minimized. The feasibility predicate is part of the problem,
not silently assumed. Natural-number-valued objectives keep the executable
example small; the abstract categorical layer does not depend on this choice.
-/
namespace CatOpt

/-- A minimization problem with explicit admissibility. -/
structure Problem where
  State : Type
  feasible : State → Prop
  cost : State → Nat

/-- The current incumbent and a possibly worse candidate coexist.
    Both are certified feasible by their constructor. -/
structure SearchState (P : Problem) where
  incumbent : P.State
  candidate : P.State
  incumbent_ok : P.feasible incumbent
  candidate_ok : P.feasible candidate

namespace SearchState

/-- Initialize a run from a feasible solution. -/
def init {P : Problem} (x : P.State) (hx : P.feasible x) : SearchState P :=
  ⟨x, x, hx, hx⟩

@[simp] theorem init_incumbent {P : Problem} (x : P.State)
    (hx : P.feasible x) :
    (init x hx).incumbent = x := rfl

@[simp] theorem init_candidate {P : Problem} (x : P.State)
    (hx : P.feasible x) :
    (init x hx).candidate = x := rfl

end SearchState
end CatOpt
