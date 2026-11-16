import CatOpt.TSP.TwoOpt

/-!
# v0.8 — Four-city square crossing removed by a two-opt reversal

The square uses unit Manhattan perimeter edges and length-two diagonals.
The route 0 → 2 → 1 → 3 → 0 has cost 6; reversing positions 1..2 gives
0 → 1 → 2 → 3 → 0, whose cost is 4. The example is intentionally tiny:
it tests execution and arithmetic, not TSP solver competitiveness.
-/

namespace CatOpt.Examples
open CatOpt.TSP

/-- The four-city square in cyclic index order, with Manhattan distances. -/
def squareDistance (a b : Fin 4) : Nat :=
  if a = b then 0
  else if (a.val + 1) % 4 = b.val ∨ (b.val + 1) % 4 = a.val then 1
  else 2

def squareInstance : Instance 3 where
  distance := squareDistance

/-- Position order is 0,2,1,3; the two diagonals cross. -/
def crossingTour : Tour 3 := Equiv.swap (1 : Fin 4) 2

/-- Reverse the two middle positions (inclusive). -/
def middleSegment : Segment 3 where
  lo := 1
  hi := 2
  ordered := by decide

def squareInitial : SearchState (problem squareInstance) :=
  SearchState.init crossingTour (by trivial)

def squareRound := round squareInstance [middleSegment] squareInitial

def squareRun := run squareInstance [middleSegment] 2 squareInitial

def squareBudget : Option (RunBudget 3 8) :=
  certifyRun 3 8 2 [middleSegment]

end CatOpt.Examples
