import CatOpt.TSP.TwoOpt

/-!
# v0.9 — A finite, exhaustive 2-opt local-optimality checker

`checkLocalOptimum` checks *all* contiguous position intervals of a tour.
The interval reversal is the move defined in `TwoOpt.lean`, including
singletons and the full tour (which can matter for directed distances).

Soundness: returning `true` implies no tested reversal has strictly lower
cyclic tour cost. Completeness: if every tested reversal is nonimproving,
then the checker returns `true`. This is local, NOT global, optimality.

The external optimizer, importing/encoding its tour as an `Equiv.Perm`,
complexity of the evaluator, and external Python execution are not verified.
This checker uses the *full* cost, not an O(1) 4-edge delta formula.
-/

namespace CatOpt.TSP

/-- Check one inclusive contiguous interval. For `lo > hi`, no segment
exists, so that pair imposes no obligation. -/
def checkPair {n : Nat} (inst : Instance n) (tour : Tour n)
    (lo hi : Fin (n + 1)) : Bool :=
  if h : lo.val ≤ hi.val then
    decide (tourCost inst tour ≤ tourCost inst (twoOpt tour ⟨lo, hi, h⟩))
  else true

/-- Exhaustively check every *ordered* pair of endpoints.
Quantifiers range over a finite type, so this is executable. -/
def checkLocalOptimum {n : Nat} (inst : Instance n)
    (tour : Tour n) : Bool :=
  decide (∀ lo hi : Fin (n + 1), checkPair inst tour lo hi = true)

/-- Soundness of an individual accepted check. -/
theorem checkPair_sound {n : Nat} (inst : Instance n) (tour : Tour n)
    (lo hi : Fin (n + 1)) (h : lo.val ≤ hi.val)
    (hc : checkPair inst tour lo hi = true) :
    tourCost inst tour ≤ tourCost inst (twoOpt tour ⟨lo, hi, h⟩) := by
  simp only [checkPair, dif_pos h] at hc
  exact of_decide_eq_true hc

/-- If the checker returns true, *every* segment reversal is nonimproving.
This theorem does not require metricity or distance symmetry. -/
theorem checkLocalOptimum_sound {n : Nat} (inst : Instance n)
    (tour : Tour n) (hc : checkLocalOptimum inst tour = true)
    (lo hi : Fin (n + 1)) (h : lo.val ≤ hi.val) :
    tourCost inst tour ≤ tourCost inst (twoOpt tour ⟨lo, hi, h⟩) := by
  have hall : ∀ lo hi : Fin (n + 1), checkPair inst tour lo hi = true := by
    exact of_decide_eq_true hc
  exact checkPair_sound inst tour lo hi h (hall lo hi)

/-- Completeness relative to the FULL finite segment-reversal neighborhood.
The checker never rejects a tour that satisfies all of these inequalities. -/
theorem checkLocalOptimum_complete {n : Nat} (inst : Instance n)
    (tour : Tour n)
    (hmin : ∀ (lo hi : Fin (n + 1)) (h : lo.val ≤ hi.val),
      tourCost inst tour ≤ tourCost inst (twoOpt tour ⟨lo, hi, h⟩)) :
    checkLocalOptimum inst tour = true := by
  apply decide_eq_true
  intro lo hi
  by_cases h : lo.val ≤ hi.val
  · simpa [checkPair, h] using decide_eq_true (hmin lo hi h)
  · simp [checkPair, h]

/-- A result checked by Lean can be packaged with a proof of local minimality.
It remains a proof of 2-opt local minimality, not a TSP optimality witness. -/
structure CheckedLocalMinimum (n : Nat) where
  instanceData : Instance n
  tour : Tour n
  checked : checkLocalOptimum instanceData tour = true

/-- Any such certificate implies all segment-reversal inequalities. -/
theorem CheckedLocalMinimum.noImprovingSegment {n : Nat}
    (c : CheckedLocalMinimum n) (lo hi : Fin (n + 1))
    (h : lo.val ≤ hi.val) :
    tourCost c.instanceData c.tour ≤
      tourCost c.instanceData (twoOpt c.tour ⟨lo, hi, h⟩) := by
  exact checkLocalOptimum_sound c.instanceData c.tour c.checked lo hi h

end CatOpt.TSP
