import CatOpt.DSL.FiniteNeighborhood

/-!
# v0.6 — Fuel-bounded adaptive VNS controller over first-order finite moves

The controller explores a finite list of neighborhoods. After a completed
instrumented round it resets to neighborhood zero exactly when the accepted
incumbent strictly improves; otherwise it advances to the next neighborhood.

Crucial scope: this is a deterministic, finite *VNS-style adaptive controller*,
not yet the full randomized GVNS + nested VND algorithm. Selection and
acceptance reuse the v0.5 first-order finite-move semantics. Two additional
`probe` operations explicitly measure the controller's improvement test.
The model counts semantic oracle observations, not CPU time or external calls.
-/

namespace CatOpt.DSL.AdaptiveVNS
open CatOpt
open CatOpt.DSL.Resources
open CatOpt.DSL.FiniteNeighborhood

/-- A finite schedule with a certified upper bound on the size of every
    neighborhood. The certificate is checked at the *actual lookup* boundary. -/
structure Catalog (cap : Nat) where
  neighborhoods : List (List Move)
  bounded : ∀ (i : Nat) (moves : List Move),
    neighborhoods[i]? = some moves → moves.length ≤ cap

/-- The controller's index refers to the next neighborhood to attempt.
    An index beyond the catalog is an exhausted (inert) state. -/
structure State (n : Nat) (objective : Fin (n + 1) → Nat) where
  search : SearchState (finiteProblem n objective)
  index : Nat

/-- Exact query charge of a single adaptive step, independent of the cost
    values themselves. A missing neighborhood incurs zero observations. -/
def stepCost {cap : Nat} (catalog : Catalog cap) (index : Nat) : Nat :=
  match catalog.neighborhoods[index]? with
  | none => 0
  | some moves => 2 * moves.length + 4

/-- Execute one neighborhood. A strict improvement resets to index zero;
    otherwise increment the index. The test itself uses TWO oracle probes. -/
def step {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective) : Metered (State n objective) :=
  match catalog.neighborhoods[s.index]? with
  | none => Metered.pure s
  | some moves =>
      let result := round n objective moves s.search
      let old := probe (finiteProblem n objective) s.search.incumbent
      let fresh := probe (finiteProblem n objective) result.value.incumbent
      let nextIndex := if fresh.value < old.value then 0 else s.index + 1
      ⟨⟨result.value, nextIndex⟩, result.queries + old.queries + fresh.queries⟩

/-- The improvement test is metered and every candidate selection/acceptance
    is metered: exactly two probes per move, plus four per active step. -/
theorem step_queries {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective) :
    (step objective catalog s).queries = stepCost catalog s.index := by
  cases h : catalog.neighborhoods[s.index]? with
  | none => simp [step, stepCost, h, Metered.pure]
  | some moves =>
      simp [step, stepCost, h, probe, round_queries] <;> omega

/-- Strictly improving incumbents restart at the first neighborhood. -/
theorem step_reset {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective) (moves : List Move)
    (h : catalog.neighborhoods[s.index]? = some moves)
    (hi : objective (round n objective moves s.search).value.incumbent <
      objective s.search.incumbent) :
    (step objective catalog s).value.index = 0 := by
  simp [step, h, probe, hi]

/-- On failure to improve, try the subsequent neighborhood. -/
theorem step_advance {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective) (moves : List Move)
    (h : catalog.neighborhoods[s.index]? = some moves)
    (hi : ¬ objective (round n objective moves s.search).value.incumbent <
      objective s.search.incumbent) :
    (step objective catalog s).value.index = s.index + 1 := by
  simp [step, h, probe, hi]

/-- A step never worsens the incumbent. -/
theorem step_incumbent_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective) :
    objective (step objective catalog s).value.search.incumbent ≤
      objective s.search.incumbent := by
  cases h : catalog.neighborhoods[s.index]? with
  | none => simp [step, h, Metered.pure]
  | some moves =>
      simpa [step, h] using round_incumbent_le n objective moves s.search

/-- The finite catalog certificate gives a uniform per-step query bound. -/
theorem step_queries_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (s : State n objective) :
    (step objective catalog s).queries ≤ 2 * cap + 4 := by
  rw [step_queries]
  cases h : catalog.neighborhoods[s.index]? with
  | none => simp [stepCost, h]
  | some moves =>
      have hcap := catalog.bounded s.index moves h
      simp [stepCost, h] <;> omega

/-- Structurally recursive execution. Fuel limits *attempted* steps, even
    if an improving neighborhood repeatedly resets the index. -/
def run {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) : Nat → State n objective → Metered (State n objective)
  | 0, s => Metered.pure s
  | fuel + 1, s =>
      (step objective catalog s).bind (run objective catalog fuel)

/-- Monotonicity holds for the entire adaptive execution, irrespective of
    which improvement/advance choices the objective induces. -/
theorem run_incumbent_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (fuel : Nat) (s : State n objective) :
    objective (run objective catalog fuel s).value.search.incumbent ≤
      objective s.search.incumbent := by
  induction fuel generalizing s with
  | zero => exact Nat.le_refl _
  | succ k ih =>
      change objective (run objective catalog k (step objective catalog s).value).value.search.incumbent ≤
        objective s.search.incumbent
      exact Nat.le_trans (ih (step objective catalog s).value)
        (step_incumbent_le objective catalog s)

/-- A uniform upper bound valid for *every possible adaptive path*.
    The exact count may be lower if neighborhoods have different lengths
    or the catalog is exhausted before fuel runs out. -/
theorem run_queries_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (catalog : Catalog cap) (fuel : Nat) (s : State n objective) :
    (run objective catalog fuel s).queries ≤ fuel * (2 * cap + 4) := by
  induction fuel generalizing s with
  | zero => simp [run, Metered.pure]
  | succ k ih =>
      change (step objective catalog s).queries +
        (run objective catalog k (step objective catalog s).value).queries ≤
        (k + 1) * (2 * cap + 4)
      calc
        (step objective catalog s).queries +
            (run objective catalog k (step objective catalog s).value).queries ≤
            (2 * cap + 4) + k * (2 * cap + 4) :=
              Nat.add_le_add (step_queries_le objective catalog s)
                (ih (step objective catalog s).value)
        _ = (k + 1) * (2 * cap + 4) := by
              simp only [Nat.add_mul, Nat.one_mul]
              exact Nat.add_comm _ _

/-- The catalog and the fuel carry a *static* certificate for the worst-case
    modeled oracle budget. It is not a bound on external running time. -/
structure RunBudget (cap budget : Nat) where
  fuel : Nat
  fits : fuel * (2 * cap + 4) ≤ budget

/-- Decide a proposed fuel budget before executing the adaptive controller. -/
def certifyRun (cap budget fuel : Nat) : Option (RunBudget cap budget) :=
  if h : fuel * (2 * cap + 4) ≤ budget then some ⟨fuel, h⟩ else none

/-- Proof-bearing budget certificates apply to any catalog of this cap. -/
theorem RunBudget.queries_le {cap budget n : Nat} (b : RunBudget cap budget)
    (objective : Fin (n + 1) → Nat) (catalog : Catalog cap) (s : State n objective) :
    (run objective catalog b.fuel s).queries ≤ budget := by
  exact Nat.le_trans (run_queries_le objective catalog b.fuel s) b.fits

end CatOpt.DSL.AdaptiveVNS
