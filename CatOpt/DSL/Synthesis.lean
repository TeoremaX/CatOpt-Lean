import CatOpt.DSL.Search

/-!
# Typed synthesis of elitist local-search programs

This module has two distinct interfaces:

1. `compileClosed` checks a *raw* list of actions against the phase protocol.
2. `enumerate` generates *already well-typed* completed rounds and rejects
   recipes exceeding an explicitly declared static work estimate.

A work estimate is not a verified bound on wall-clock time or actual objective
function evaluations. Synthesis does not assert that a discovered pipeline is
optimal, useful, or genuinely novel.
-/
namespace CatOpt.DSL.Synthesis
open CatOpt.DSL.Search

/-- Untyped external representation. Invalid sequences can be expressed here,
    but not in `SearchProgram` after elaboration. -/
inductive RawAction where
  | construct (seed : Nat)
  | shake (radius : Nat)
  | destroyRepair (strength : Nat)
  | localSearch
  | accept
  deriving Repr, DecidableEq

/-- A checked sequence starting at phase `s`, together with its resulting phase. -/
abbrev SomeProgram (s : Stage) :=
  Sigma (fun t : Stage => SearchProgram s t)

/-- Compile one raw action, failing if its input stage is incorrect. -/
def compileStep (s : Stage) (a : RawAction) : Option (SomeProgram s) :=
  match s, a with
  | .ready, .construct seed => some ⟨.candidate, .atom (.construct seed)⟩
  | .ready, .shake radius => some ⟨.candidate, .atom (.shake radius)⟩
  | .ready, .destroyRepair strength =>
      some ⟨.candidate, .atom (.destroyRepair strength)⟩
  | .candidate, .localSearch => some ⟨.improved, .atom .localSearch⟩
  | .improved, .accept => some ⟨.ready, .atom .accept⟩
  | _, _ => none

/-- Reject at the *first* invalid transition; successful results are typed ASTs. -/
def compileRaw : (s : Stage) → List RawAction → Option (SomeProgram s)
  | s, [] => some ⟨s, .skip⟩
  | s, a :: rest =>
      match compileStep s a with
      | none => none
      | some ⟨middle, first⟩ =>
          match compileRaw middle rest with
          | none => none
          | some ⟨last, tail⟩ => some ⟨last, .seq first tail⟩

/-- Only complete programs from `ready` back to `ready` are executable rounds. -/
def compileClosed (tokens : List RawAction) :
    Option (SearchProgram .ready .ready) :=
  match compileRaw .ready tokens with
  | some ⟨.ready, p⟩ => some p
  | _ => none

/-- Any successfully checked closed raw program inherits the verified
    phase-typed interpreter's incumbent-monotonicity contract. -/
theorem compileClosed_monotone {P : Problem} (impl : Primitives P)
    (tokens : List RawAction) (p : SearchProgram .ready .ready)
    (_h : compileClosed tokens = some p) :
    IncumbentMonotone P (run impl p) :=
  program_monotone impl p

/-- Synthesis grammar: each complete round starts with a feasible candidate
    generator, proceeds through local search, and finishes with acceptance. -/
inductive RoundStart where
  | construct (seed : Nat)
  | shake (radius : Nat)
  | destroyRepair (strength : Nat)
  deriving Repr, DecidableEq

/-- The first primitive of a completed search round. -/
def RoundStart.asAction : RoundStart → Action .ready .candidate
  | .construct seed => .construct seed
  | .shake radius => .shake radius
  | .destroyRepair strength => .destroyRepair strength

/-- A complete, well-typed, elitist search round. -/
def round (r : RoundStart) : SearchProgram .ready .ready :=
  .seq (.atom r.asAction) (.seq (.atom .localSearch) (.atom .accept))

/-- Concatenate a finite list of complete rounds. -/
def compileRounds : List RoundStart → SearchProgram .ready .ready
  | [] => .skip
  | r :: rs => .seq (round r) (compileRounds rs)

/-- Count primitives in the syntax tree, including acceptance. -/
def atomCount {a b : Stage} : SearchProgram a b → Nat
  | .skip => 0
  | .atom _ => 1
  | .seq p q => atomCount p + atomCount q

/-- Each complete round uses precisely three primitive actions. -/
theorem round_atomCount (r : RoundStart) : atomCount (round r) = 3 := by
  cases r <;> rfl

/-- The generated syntax has exactly three primitives per round. -/
theorem compileRounds_atomCount (rs : List RoundStart) :
    atomCount (compileRounds rs) = 3 * rs.length := by
  induction rs with
  | nil => rfl
  | cons r rs ih =>
      change atomCount (round r) + atomCount (compileRounds rs) =
        3 * (rs.length + 1)
      rw [round_atomCount, ih]
      omega

/-- A completed round always re-synchronizes the candidate with the incumbent. -/
theorem round_synced {P : Problem} (impl : Primitives P)
    (r : RoundStart) (s : SearchState P) :
    (run impl (round r) s).candidate = (run impl (round r) s).incumbent := by
  cases r <;> rfl

/-- Completed round lists preserve synchronization, provided the initial
    state is synchronized; the empty list is the identity. -/
theorem compileRounds_synced {P : Problem} (impl : Primitives P)
    (rs : List RoundStart) (s : SearchState P)
    (h : s.candidate = s.incumbent) :
    (run impl (compileRounds rs) s).candidate =
      (run impl (compileRounds rs) s).incumbent := by
  induction rs generalizing s with
  | nil => exact h
  | cons r rs ih =>
      change (run impl (compileRounds rs) (run impl (round r) s)).candidate =
        (run impl (compileRounds rs) (run impl (round r) s)).incumbent
      exact ih (run impl (round r) s) (round_synced impl r s)

/-- Parametric monotonicity for any synthesized round sequence. -/
theorem compileRounds_monotone {P : Problem} (impl : Primitives P)
    (rs : List RoundStart) :
    IncumbentMonotone P (run impl (compileRounds rs)) :=
  program_monotone impl (compileRounds rs)

/-- User-declared static work estimates for *individual* operations.
    These are neither proven upper bounds nor measured evaluation counts. -/
structure WorkCosts where
  construct : Nat
  shake : Nat
  destroyRepair : Nat
  localSearch : Nat
  accept : Nat
  deriving Repr

/-- Static estimated work of one complete round. -/
def roundCost (C : WorkCosts) (r : RoundStart) : Nat :=
  (match r with
   | .construct _ => C.construct
   | .shake _ => C.shake
   | .destroyRepair _ => C.destroyRepair) + C.localSearch + C.accept

/-- Static additive estimate; no runtime resource claim is implied. -/
def estimatedCost (C : WorkCosts) : List RoundStart → Nat
  | [] => 0
  | r :: rs => roundCost C r + estimatedCost C rs

/-- A recipe with an actual Lean proof that its *declared estimate* is
    within a budget. The proof is stored, not merely tested and discarded. -/
structure BoundedRecipe (C : WorkCosts) (budget : Nat) where
  rounds : List RoundStart
  withinBudget : estimatedCost C rounds ≤ budget

/-- The checker either produces a budget certificate or rejects the recipe. -/
def certify (C : WorkCosts) (budget : Nat) (rs : List RoundStart) :
    Option (BoundedRecipe C budget) :=
  if h : estimatedCost C rs ≤ budget then some ⟨rs, h⟩ else none

/-- Enumerate recipes of exactly `n` rounds using only allowed starts. -/
def recipes (choices : List RoundStart) : Nat → List (List RoundStart)
  | 0 => [[]]
  | n + 1 =>
      choices.flatMap (fun r => (recipes choices n).map (fun rest => r :: rest))

/-- All budget-admissible recipes of at most `maxRounds` rounds.
    `maxRounds` bounds the finite enumeration; `budget` uses `WorkCosts`. -/
def enumerate (choices : List RoundStart) (maxRounds : Nat)
    (C : WorkCosts) (budget : Nat) : List (BoundedRecipe C budget) :=
  ((List.range (maxRounds + 1)).flatMap (recipes choices)).filterMap (certify C budget)

/-- Interpret a certified, typed recipe using any feasibility-preserving
    implementation of the primitive operations. -/
def BoundedRecipe.execute {P : Problem} {C : WorkCosts} {budget : Nat}
    (r : BoundedRecipe C budget) (impl : Primitives P)
    (s : SearchState P) : SearchState P :=
  run impl (compileRounds r.rounds) s

/-- The incumbent never deteriorates for *any* certified recipe. -/
theorem BoundedRecipe.incumbent_le {P : Problem} {C : WorkCosts}
    {budget : Nat} (r : BoundedRecipe C budget) (impl : Primitives P)
    (s : SearchState P) :
    P.cost (r.execute impl s).incumbent ≤ P.cost s.incumbent :=
  compileRounds_monotone impl r.rounds s

/-- The certificate is a formal bound on the declared estimate, not an
    assertion about actual evaluation counts. -/
theorem BoundedRecipe.estimate_le {C : WorkCosts} {budget : Nat}
    (r : BoundedRecipe C budget) : estimatedCost C r.rounds ≤ budget :=
  r.withinBudget

end CatOpt.DSL.Synthesis
