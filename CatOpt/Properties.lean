import CatOpt.Operators
import Mathlib.Tactic

/-!
# Incumbent/candidate separation and accepted-cost guarantees

The essential distinction is between a candidate (which may deteriorate under
perturbation) and an incumbent (which is changed only by acceptance).
-/
namespace CatOpt

namespace Problem

/-- Select a candidate precisely when it is no worse; ties choose the candidate. -/
def chooseBetter (P : Problem) (old candidate : P.State) : P.State :=
  if P.cost candidate ≤ P.cost old then candidate else old

/-- Selection preserves feasibility, assuming both arguments are feasible. -/
theorem chooseBetter_feasible (P : Problem) {old candidate : P.State}
    (ho : P.feasible old) (hc : P.feasible candidate) :
    P.feasible (P.chooseBetter old candidate) := by
  unfold chooseBetter
  split
  · exact hc
  · exact ho

/-- Acceptance never worsens the incumbent. -/
theorem chooseBetter_le_old (P : Problem) (old candidate : P.State) :
    P.cost (P.chooseBetter old candidate) ≤ P.cost old := by
  unfold chooseBetter
  split
  · assumption
  · exact Nat.le_refl _

/-- Acceptance also selects an objective no worse than the candidate. -/
theorem chooseBetter_le_candidate (P : Problem) (old candidate : P.State) :
    P.cost (P.chooseBetter old candidate) ≤ P.cost candidate := by
  unfold chooseBetter
  split_ifs with h
  · exact Nat.le_refl _
  · omega

end Problem

/-- An operation on certified two-track search states. -/
abbrev SearchOp (P : Problem) := SearchState P → SearchState P

/-- Changes only the candidate, keeping the incumbent untouched. -/
def transformCandidate (P : Problem) (f : Operator P) : SearchOp P :=
  fun s =>
    { incumbent := s.incumbent
      candidate := f.run s.candidate
      incumbent_ok := s.incumbent_ok
      candidate_ok := f.preserves s.candidate s.candidate_ok }

/-- Generates a candidate from the incumbent, not from an obsolete candidate. -/
def resetCandidate (P : Problem) (f : Operator P) : SearchOp P :=
  fun s =>
    { incumbent := s.incumbent
      candidate := f.run s.incumbent
      incumbent_ok := s.incumbent_ok
      candidate_ok := f.preserves s.incumbent s.incumbent_ok }

/-- Update the incumbent using elitist acceptance; synchronize the candidate. -/
def acceptBetter (P : Problem) : SearchOp P :=
  fun s =>
    { incumbent := P.chooseBetter s.incumbent s.candidate
      candidate := P.chooseBetter s.incumbent s.candidate
      incumbent_ok := P.chooseBetter_feasible s.incumbent_ok s.candidate_ok
      candidate_ok := P.chooseBetter_feasible s.incumbent_ok s.candidate_ok }

/-- This property tracks incumbent quality rather than candidate quality. -/
def IncumbentMonotone (P : Problem) (f : SearchOp P) : Prop :=
  ∀ s, P.cost (f s).incumbent ≤ P.cost s.incumbent

theorem transformCandidate_monotone (P : Problem) (f : Operator P) :
    IncumbentMonotone P (transformCandidate P f) := by
  intro s
  exact Nat.le_refl _

theorem resetCandidate_monotone (P : Problem) (f : Operator P) :
    IncumbentMonotone P (resetCandidate P f) := by
  intro s
  exact Nat.le_refl _

theorem acceptBetter_monotone (P : Problem) :
    IncumbentMonotone P (acceptBetter P) := by
  intro s
  exact P.chooseBetter_le_old s.incumbent s.candidate

/-- A composition of incumbent-monotone transformations remains monotone. -/
theorem incumbentMonotone_comp (P : Problem) (f g : SearchOp P)
    (hf : IncumbentMonotone P f) (hg : IncumbentMonotone P g) :
    IncumbentMonotone P (fun s => g (f s)) := by
  intro s
  exact Nat.le_trans (hg (f s)) (hf s)

/-- Main structural property: after arbitrary feasible perturbation and local
    search, elitist acceptance does not worsen the incumbent. -/
theorem perturb_descent_accept_monotone (P : Problem)
    (perturb descent : Operator P) :
    IncumbentMonotone P
      (fun s => acceptBetter P (transformCandidate P descent (resetCandidate P perturb s))) := by
  apply incumbentMonotone_comp P
    (resetCandidate P perturb)
    (fun s => acceptBetter P (transformCandidate P descent s))
  · exact resetCandidate_monotone P perturb
  · apply incumbentMonotone_comp P (transformCandidate P descent) (acceptBetter P)
    · exact transformCandidate_monotone P descent
    · exact acceptBetter_monotone P

end CatOpt
