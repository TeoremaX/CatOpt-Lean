import CatOpt.TSP.LocalOptimality
import CatOpt.Examples.TSP

/-! Regression checks for complete finite 2-opt local minimality.
    These are executable small fixtures, not general optimality theorems. -/

namespace CatOpt.Tests.LocalOptimality
open CatOpt.TSP

-- The crossed tour has a strictly improving reversal.
example : checkLocalOptimum Examples.squareInstance Examples.crossingTour = false := by
  decide

-- The uncrossed perimeter has no improving contiguous reversal.
example : checkLocalOptimum Examples.squareInstance
    (twoOpt Examples.crossingTour Examples.middleSegment) = true := by
  decide

example {n : Nat} (inst : Instance n) (tour : Tour n)
    (hc : checkLocalOptimum inst tour = true)
    (lo hi : Fin (n + 1)) (h : lo.val ≤ hi.val) :
    tourCost inst tour ≤ tourCost inst (twoOpt tour ⟨lo, hi, h⟩) :=
  checkLocalOptimum_sound inst tour hc lo hi h

end CatOpt.Tests.LocalOptimality
