import CatOpt.Examples.TSP

/-!
# v0.8 — Mechanically checkable permutation and objective-oracle tests

Quantified lemmas below compile only when Lean accepts the corresponding
proofs for *every* finite city count, tour and legal segment.
-/
namespace CatOpt.Tests.TSP
open CatOpt.TSP

/-- Every reversal is a bijection, not just a list with the same length. -/
example {n : Nat} (tour : Tour n) (segment : Segment n) :
    Function.Injective (twoOpt tour segment) :=
  twoOpt_injective tour segment

example {n : Nat} (tour : Tour n) (segment : Segment n) :
    Function.Surjective (twoOpt tour segment) :=
  twoOpt_surjective tour segment

/-- Repeating a segment reversal is observationally the identity on tours. -/
example {n : Nat} (tour : Tour n) (segment : Segment n) :
    twoOpt (twoOpt tour segment) segment = tour :=
  twoOpt_involutive tour segment

/-- These tests cover a crossing and a strict improvement in a real cycle. -/
example : tourCost Examples.squareInstance Examples.crossingTour = 6 := by decide
example : tourCost Examples.squareInstance
    (twoOpt Examples.crossingTour Examples.middleSegment) = 4 := by decide
example : Examples.squareRound.value.incumbent =
    twoOpt Examples.crossingTour Examples.middleSegment := by
  apply Equiv.ext
  intro k
  fin_cases k <;> decide
example : Examples.squareRound.queries = 4 := by decide
example : tourCost Examples.squareInstance Examples.squareRound.value.incumbent = 4 := by decide
example : Examples.squareRun.queries = 8 := by decide
example : tourCost Examples.squareInstance Examples.squareRun.value.incumbent = 4 := by decide

/-- Exact query cost and non-worsening for arbitrary integer distance data. -/
example {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (fuel : Nat) (s : SearchState (problem inst)) :
    (run inst segments fuel s).queries = fuel * (2 * segments.length + 2) :=
  run_queries inst segments fuel s

example {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (fuel : Nat) (s : SearchState (problem inst)) :
    tourCost inst (run inst segments fuel s).value.incumbent ≤ tourCost inst s.incumbent :=
  run_incumbent_le inst segments fuel s

/-- The budget certificate accepts exactly eight metered calls, not seven. -/
example : (certifyRun 3 7 2 [Examples.middleSegment]).isNone = true := by decide
example : (certifyRun 3 8 2 [Examples.middleSegment]).isSome = true := by decide

end CatOpt.Tests.TSP
