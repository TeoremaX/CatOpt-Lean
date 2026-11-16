import CatOpt.DSL.OracleLocalSearch
import Mathlib

/-!
# v0.8 — Certified permutation tours and contiguous-segment reversal

This module introduces a *closed* representation of an (n+1)-city TSP tour as
an equivalence of finite sets. Every inhabitant is a bijection from tour
positions to city identifiers; malformed tours cannot be constructed.

`reverseIndex` reverses positions inside a certified contiguous segment and
leaves all others unchanged. Its involution proof yields an index equivalence;
composition of equivalences makes `twoOpt` preserve the permutation invariant.

`Instance.distance` is an arbitrary natural-valued directed edge weight. The
cyclic objective sums exactly (n+1) edges, including the return edge. We do
NOT assume the triangle inequality or symmetry, nor assert that a reversal
must improve the objective. Elitist selection protects the incumbent.

A round counts exactly two recorded `probe` effects per candidate plus two
for acceptance. Segment construction and pure distance arithmetic are not
charged in this cost model. This is not a CPU-time bound and is not a proof
about the independent Python TSP benchmark.
-/

namespace CatOpt.TSP
open CatOpt
open CatOpt.DSL.Resources
open CatOpt.DSL.OracleLocalSearch

/-- A tour of (n+1) cities, numbered `Fin (n+1)`, is a bijection from
    positions to cities. The positive cardinality avoids empty-cycle cases. -/
abbrev Tour (n : Nat) := Equiv.Perm (Fin (n + 1))

/-- Inclusive bounds of the segment being reversed. -/
structure Segment (n : Nat) where
  lo : Fin (n + 1)
  hi : Fin (n + 1)
  ordered : lo.val ≤ hi.val

/-- Objective-independent mirror of one tour position inside the segment.
    The index stays within `Fin (n+1)` by arithmetic. -/
def reverseIndex {n : Nat} (s : Segment n) (k : Fin (n + 1)) : Fin (n + 1) :=
  if h : s.lo.val ≤ k.val ∧ k.val ≤ s.hi.val then
    ⟨s.lo.val + s.hi.val - k.val, by
      have hj := s.hi.isLt
      omega⟩
  else k

/-- Positions outside the segment do not move. -/
theorem reverseIndex_outside {n : Nat} (s : Segment n) (k : Fin (n + 1))
    (h : ¬ (s.lo.val ≤ k.val ∧ k.val ≤ s.hi.val)) :
    reverseIndex s k = k := by
  unfold reverseIndex
  exact dif_neg h

/-- Inside the segment, position k is reflected to lo+hi-k. -/
theorem reverseIndex_inside {n : Nat} (s : Segment n) (k : Fin (n + 1))
    (h : s.lo.val ≤ k.val ∧ k.val ≤ s.hi.val) :
    (reverseIndex s k).val = s.lo.val + s.hi.val - k.val := by
  simp [reverseIndex, h]

/-- Mirroring the same segment twice restores every original position. -/
theorem reverseIndex_involutive {n : Nat} (s : Segment n) :
    Function.Involutive (reverseIndex s) := by
  intro k
  by_cases hk : s.lo.val ≤ k.val ∧ k.val ≤ s.hi.val
  · have hm : s.lo.val ≤ (reverseIndex s k).val ∧
        (reverseIndex s k).val ≤ s.hi.val := by
      rw [reverseIndex_inside s k hk]
      omega
    apply Fin.ext
    rw [reverseIndex_inside s (reverseIndex s k) hm]
    rw [reverseIndex_inside s k hk]
    omega
  · rw [reverseIndex_outside s k hk]
    exact reverseIndex_outside s k hk

/-- A segment reversal is a genuine permutation of tour positions. -/
def reversePositions {n : Nat} (s : Segment n) : Equiv.Perm (Fin (n + 1)) where
  toFun := reverseIndex s
  invFun := reverseIndex s
  left_inv := reverseIndex_involutive s
  right_inv := reverseIndex_involutive s

/-- Two-opt-style move: reverse an inclusive contiguous segment of a tour.
    Endpoints and degenerate segments are allowed; all moves remain valid. -/
def twoOpt {n : Nat} (tour : Tour n) (s : Segment n) : Tour n :=
  (reversePositions s).trans tour

/-- The new city at position k was formerly at the reflected position. -/
theorem twoOpt_at {n : Nat} (tour : Tour n) (s : Segment n)
    (k : Fin (n + 1)) :
    twoOpt tour s k = tour (reverseIndex s k) := by
  rfl

/-- Every two-opt-style result is injective: a city cannot occur twice. -/
theorem twoOpt_injective {n : Nat} (tour : Tour n) (s : Segment n) :
    Function.Injective (twoOpt tour s) :=
  (twoOpt tour s).injective

/-- Every city is still visited: no city disappears from the route. -/
theorem twoOpt_surjective {n : Nat} (tour : Tour n) (s : Segment n) :
    Function.Surjective (twoOpt tour s) :=
  (twoOpt tour s).surjective

/-- Applying the same reversal twice recovers the original tour. -/
theorem twoOpt_involutive {n : Nat} (tour : Tour n) (s : Segment n) :
    twoOpt (twoOpt tour s) s = tour := by
  apply Equiv.ext
  intro k
  change tour (reverseIndex s (reverseIndex s k)) = tour k
  rw [reverseIndex_involutive s]

/-- A city-to-city weighted instance; symmetry is NOT imposed. -/
structure Instance (n : Nat) where
  distance : Fin (n + 1) → Fin (n + 1) → Nat

/-- The cyclic successor index, including the last-to-first return. -/
def nextPosition {n : Nat} (k : Fin (n + 1)) : Fin (n + 1) :=
  ⟨(k.val + 1) % (n + 1), Nat.mod_lt _ (Nat.succ_pos n)⟩

/-- Explicit cyclic tour cost, computed from the instance's distance oracle.
    The metered interface counts *calls to this objective*, not its inner
    per-edge arithmetic; this distinction must remain visible to readers. -/
def tourCost {n : Nat} (inst : Instance n) (tour : Tour n) : Nat :=
  ∑ k : Fin (n + 1), inst.distance (tour k) (tour (nextPosition k))

/-- TSP as a CatOpt minimization problem, with feasible tours by construction. -/
abbrev problem {n : Nat} (inst : Instance n) : Problem :=
  { State := Tour n
    feasible := fun _ => True
    cost := tourCost inst }

/-- Produce feasible candidates solely from first-order segment data. -/
def neighbors {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (tour : Tour n) : List (Candidate (problem inst)) :=
  segments.map (fun s => (⟨twoOpt tour s, trivial⟩ : Candidate (problem inst)))

@[simp] theorem neighbors_length {n : Nat} (inst : Instance n)
    (segments : List (Segment n)) (tour : Tour n) :
    (neighbors inst segments tour).length = segments.length := by
  simp [neighbors]

/-- One fully instrumented selection+acceptance round using 2-opt candidates. -/
def round {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (state : SearchState (problem inst)) : Metered (SearchState (problem inst)) :=
  roundMetered (problem inst) (fun t => neighbors inst segments t) state

/-- Exact number of objective calls registered by this round. -/
theorem round_queries {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (state : SearchState (problem inst)) :
    (round inst segments state).queries = 2 * segments.length + 2 := by
  unfold round
  rw [roundMetered_queries]
  rw [neighbors_length]

/-- Elitist acceptance prevents the incumbent's cyclic cost from increasing. -/
theorem round_incumbent_le {n : Nat} (inst : Instance n)
    (segments : List (Segment n)) (state : SearchState (problem inst)) :
    tourCost inst (round inst segments state).value.incumbent ≤
      tourCost inst state.incumbent := by
  exact roundMetered_incumbent_le (problem inst)
    (fun t => neighbors inst segments t) state

/-- Repeat complete 2-opt rounds for an explicit number of iterations. -/
def run {n : Nat} (inst : Instance n) (segments : List (Segment n)) :
    Nat → SearchState (problem inst) → Metered (SearchState (problem inst))
  | 0, s => Metered.pure s
  | fuel + 1, s => (round inst segments s).bind (run inst segments fuel)

/-- An exact semantic call count, independent of the tour and distances. -/
theorem run_queries {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (fuel : Nat) (s : SearchState (problem inst)) :
    (run inst segments fuel s).queries = fuel * (2 * segments.length + 2) := by
  induction fuel generalizing s with
  | zero => simp [run, Metered.pure]
  | succ k ih =>
      calc
        (run inst segments (k + 1) s).queries =
            (round inst segments s).queries +
              (run inst segments k (round inst segments s).value).queries := rfl
        _ = (2 * segments.length + 2) + k * (2 * segments.length + 2) := by
          rw [round_queries, ih]
        _ = (k + 1) * (2 * segments.length + 2) := by
          simp only [Nat.add_mul, Nat.one_mul]
          exact Nat.add_comm _ _

/-- Monotonicity is preserved over any fuel-bounded run. -/
theorem run_incumbent_le {n : Nat} (inst : Instance n) (segments : List (Segment n))
    (fuel : Nat) (s : SearchState (problem inst)) :
    tourCost inst (run inst segments fuel s).value.incumbent ≤
      tourCost inst s.incumbent := by
  induction fuel generalizing s with
  | zero => exact Nat.le_refl _
  | succ k ih =>
      change tourCost inst
        (run inst segments k (round inst segments s).value).value.incumbent ≤
          tourCost inst s.incumbent
      exact Nat.le_trans (ih (round inst segments s).value)
        (round_incumbent_le inst segments s)

/-- Check the closed DSL's registered query budget statically. -/
structure RunBudget (n budget : Nat) where
  segments : List (Segment n)
  fuel : Nat
  fits : fuel * (2 * segments.length + 2) ≤ budget

def certifyRun (n budget fuel : Nat) (segments : List (Segment n)) :
    Option (RunBudget n budget) :=
  if h : fuel * (2 * segments.length + 2) ≤ budget then
    some ⟨segments, fuel, h⟩
  else none

/-- The certificate bounds the same instrumented execution that is run. -/
theorem RunBudget.queries_le {n budget : Nat} (c : RunBudget n budget)
    (inst : Instance n) (s : SearchState (problem inst)) :
    (run inst c.segments c.fuel s).queries ≤ budget := by
  rw [run_queries]
  exact c.fits

end CatOpt.TSP
