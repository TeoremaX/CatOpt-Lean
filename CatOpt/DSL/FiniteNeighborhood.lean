import CatOpt.DSL.OracleLocalSearch

/-!
# v0.5 — First-order finite moves with an oracle-controlled local-search loop

This fragment deliberately restricts search states to `Fin (n + 1)`, so every
state is feasible. Neighborhood generation is an interpreter for a *data-only*
move language and receives no objective function. Objective comparisons in the
selector and acceptance action go through `Resources.probe`.

The query theorems count exactly these semantic probe effects, not CPU time,
Lean reduction steps, external Python calls or the cost of constructing moves.
They do not apply to the opaque `Search.Primitives` from the earlier examples.
-/

namespace CatOpt.DSL.FiniteNeighborhood
open CatOpt
open CatOpt.DSL.Resources
open CatOpt.DSL.OracleLocalSearch

/-- A finite optimization problem with no infeasible states. -/
abbrev finiteProblem (n : Nat) (objective : Fin (n + 1) → Nat) : Problem :=
  { State := Fin (n + 1)
    feasible := fun _ => True
    cost := objective }

/-- First-order moves. None contains a callback or objective function. -/
inductive Move where
  | hold
  | forward (steps : Nat)
  | backward (steps : Nat)
  deriving Repr, DecidableEq

/-- A move interpreter that does not receive the objective function.
    Forward motion wraps around; backward motion saturates at zero. -/
def interpret (n : Nat) (m : Move) (x : Fin (n + 1)) : Fin (n + 1) :=
  match m with
  | .hold => x
  | .forward k =>
      ⟨(x.val + k) % (n + 1), Nat.mod_lt _ (Nat.succ_pos n)⟩
  | .backward k =>
      ⟨x.val - k, Nat.lt_of_le_of_lt (Nat.sub_le x.val k) x.isLt⟩

/-- Generate all neighbors using arithmetic on finite indices only. -/
def generate (n : Nat) (moves : List Move) (x : Fin (n + 1)) :
    List (Fin (n + 1)) :=
  moves.map (fun m => interpret n m x)

/-- Package the objective-independent move results as feasible candidates. -/
def certifiedNeighbors (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (x : Fin (n + 1)) :
    List (Candidate (finiteProblem n objective)) :=
  (generate n moves x).map
    (fun y => (⟨y, True.intro⟩ : Candidate (finiteProblem n objective)))

/-- The number of generated candidates is independent of the current state. -/
@[simp] theorem certifiedNeighbors_length (n : Nat)
    (objective : Fin (n + 1) → Nat)
    (moves : List Move) (x : Fin (n + 1)) :
    (certifiedNeighbors n objective moves x).length = moves.length := by
  simp [certifiedNeighbors, generate]

/-- Erasing feasibility certificates recovers the objective-free move list. -/
theorem certifiedNeighbors_values (n : Nat)
    (objective : Fin (n + 1) → Nat)
    (moves : List Move) (x : Fin (n + 1)) :
    (certifiedNeighbors n objective moves x).map Subtype.val = generate n moves x := by
  simp [certifiedNeighbors, List.map_map, Function.comp_def]

/-- A complete finite-neighborhood round: objective-free generation,
    instrumented best-of-list selection, then instrumented elitist acceptance. -/
def round (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (s : SearchState (finiteProblem n objective)) :
    Metered (SearchState (finiteProblem n objective)) :=
  roundMetered (finiteProblem n objective)
    (fun x => certifiedNeighbors n objective moves x) s

/-- Exact count across generation, selection and acceptance *in this DSL*. -/
theorem round_queries (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (s : SearchState (finiteProblem n objective)) :
    (round n objective moves s).queries = 2 * moves.length + 2 := by
  unfold round
  rw [roundMetered_queries]
  rw [certifiedNeighbors_length]

/-- A completed round cannot worsen the previous incumbent. -/
theorem round_incumbent_le (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (s : SearchState (finiteProblem n objective)) :
    objective (round n objective moves s).value.incumbent ≤
      objective s.incumbent := by
  exact roundMetered_incumbent_le (finiteProblem n objective)
    (fun x => certifiedNeighbors n objective moves x) s

/-- Iterate complete rounds, structurally bounded by explicit fuel. -/
def run (n : Nat) (objective : Fin (n + 1) → Nat) (moves : List Move) :
    Nat → SearchState (finiteProblem n objective) →
      Metered (SearchState (finiteProblem n objective))
  | 0, s => Metered.pure s
  | fuel + 1, s =>
      (round n objective moves s).bind (run n objective moves fuel)

/-- Every repetition has the same finite number of explicit oracle probes. -/
theorem run_queries (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (fuel : Nat)
    (s : SearchState (finiteProblem n objective)) :
    (run n objective moves fuel s).queries =
      fuel * (2 * moves.length + 2) := by
  induction fuel generalizing s with
  | zero => simp [run, Metered.pure]
  | succ k ih =>
      calc
        (run n objective moves (k + 1) s).queries =
            (round n objective moves s).queries +
              (run n objective moves k (round n objective moves s).value).queries := rfl
        _ = (2 * moves.length + 2) + k * (2 * moves.length + 2) := by
              rw [round_queries, ih]
        _ = (k + 1) * (2 * moves.length + 2) := by
              simp only [Nat.add_mul, Nat.one_mul]
              exact Nat.add_comm _ _

/-- Non-worsening extends from one complete round to every fuel-bounded run. -/
theorem run_incumbent_le (n : Nat) (objective : Fin (n + 1) → Nat)
    (moves : List Move) (fuel : Nat)
    (s : SearchState (finiteProblem n objective)) :
    objective (run n objective moves fuel s).value.incumbent ≤
      objective s.incumbent := by
  induction fuel generalizing s with
  | zero => exact Nat.le_refl _
  | succ k ih =>
      change objective
        (run n objective moves k (round n objective moves s).value).value.incumbent ≤
          objective s.incumbent
      exact Nat.le_trans (ih (round n objective moves s).value)
        (round_incumbent_le n objective moves s)

/-- Proof-carrying budget for the exact probe semantics of this finite DSL. -/
structure FuelBudget (budget : Nat) where
  moves : List Move
  fuel : Nat
  fits : fuel * (2 * moves.length + 2) ≤ budget

/-- Construct a certificate only if the exact semantic query count fits. -/
def certifyFuel (budget fuel : Nat) (moves : List Move) :
    Option (FuelBudget budget) :=
  if h : fuel * (2 * moves.length + 2) ≤ budget then
    some ⟨moves, fuel, h⟩
  else none

/-- A successful certificate bounds the modeled execution for every input. -/
theorem FuelBudget.queries_le {budget n : Nat} (c : FuelBudget budget)
    (objective : Fin (n + 1) → Nat)
    (s : SearchState (finiteProblem n objective)) :
    (run n objective c.moves c.fuel s).queries ≤ budget := by
  rw [run_queries]
  exact c.fits

/-- The same certificate does not depend on the objective to hold. -/
theorem FuelBudget.incumbent_le {budget n : Nat} (c : FuelBudget budget)
    (objective : Fin (n + 1) → Nat)
    (s : SearchState (finiteProblem n objective)) :
    objective (run n objective c.moves c.fuel s).value.incumbent ≤
      objective s.incumbent := by
  exact run_incumbent_le n objective c.moves c.fuel s

end CatOpt.DSL.FiniteNeighborhood
