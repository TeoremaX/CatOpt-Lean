import CatOpt.Examples.FiniteNeighborhood
import CatOpt.DSL.AdaptiveVNS

/-!
# v0.6 deterministic adaptive VNS-style demonstration

The first neighborhood holds the incumbent and therefore cannot improve it.
The second moves backward by two. Over four steps the policy advances,
improves, resets and advances/improves again: 15 → 15 → 13 → 13 → 11.
Each active neighborhood contains one move: two selection probes, two
acceptance probes, and two policy probes = six modeled observations per step.
-/
namespace CatOpt.Examples
open CatOpt.DSL.AdaptiveVNS

/-- A deliberately small closed catalog; its length certificate is structural. -/
def adaptiveCatalog : Catalog 1 where
  neighborhoods := [[.hold], [.backward 2]]
  bounded := by
    intro i moves h
    cases i with
    | zero =>
        simp at h
        subst moves
        decide
    | succ i =>
        cases i with
        | zero =>
            simp at h
            subst moves
            decide
        | succ i =>
            simp at h

def adaptiveInitial : State 20 finiteLineObjective :=
  ⟨finiteLineInitial, 0⟩

def adaptiveResult :=
  run finiteLineObjective adaptiveCatalog 4 adaptiveInitial

/-- Four active steps, at most 4 × (2 × 1 + 4) = 24 observations. -/
def adaptiveBudget : Option (RunBudget 1 24) :=
  certifyRun 1 24 4

end CatOpt.Examples
