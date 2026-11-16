import CatOpt.DSL.AdaptiveVNS

/-!
# v0.7 — Seeded shaking with a nested, fuel-bounded VND controller

This is a *deterministic seeded* (not probability-distribution-valued) GVNS
fragment. The first-order shake interpreter has no objective argument. A
fresh local run starts from the shaken solution and uses the v0.6 adaptive
controller as a finite VND-style descent. The outer acceptance compares its
best local incumbent to the original global incumbent via TWO `probe`s.

All objective observations inside this fragment go through the finite-move
selector, VND controller, or explicit outer `probe`. The proved bound concerns
those modeled observations, not hardware runtime, distributional convergence,
or any external Python implementation.
-/

namespace CatOpt.DSL.SeededGVNS
open CatOpt
open CatOpt.DSL.Resources
open CatOpt.DSL.FiniteNeighborhood

/-- Deterministic seed evolution, *not* a formal uniform RNG. -/
def nextSeed (seed : Nat) : Nat :=
  (1664525 * seed + 1013904223) % 4294967296

/-- Select a first-order move without consulting the objective. If a list is
    empty, the specified perturbation is the identity move. -/
def seededMove (moves : List Move) (seed : Nat) : Move :=
  (moves[seed % moves.length]?).getD .hold

/-- Deterministic shake interpreter, independent of the objective. -/
def shake (n : Nat) (moves : List Move) (seed : Nat)
    (x : Fin (n + 1)) : Fin (n + 1) :=
  interpret n (seededMove moves seed) x

/-- Outer shaking neighborhoods and the verified inner VND-style schedule. -/
structure Config (cap : Nat) where
  shaking : List (List Move)
  vnd : CatOpt.DSL.AdaptiveVNS.Catalog cap
  vndFuel : Nat

/-- Incumbent, current outer shaking-neighborhood index and explicit seed. -/
structure State (n : Nat) (objective : Fin (n + 1) → Nat) where
  search : SearchState (finiteProblem n objective)
  index : Nat
  seed : Nat

/-- Begin the nested VND search from the perturbed solution. -/
def localStart {n : Nat} (objective : Fin (n + 1) → Nat)
    (x : Fin (n + 1)) : CatOpt.DSL.AdaptiveVNS.State n objective :=
  ⟨SearchState.init x (by trivial), 0⟩

/-- Inner VND result, where every cost observation is metered. -/
def localRun {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (moves : List Move) (seed : Nat)
    (x : Fin (n + 1)) :
    Metered (CatOpt.DSL.AdaptiveVNS.State n objective) :=
  CatOpt.DSL.AdaptiveVNS.run objective config.vnd config.vndFuel
    (localStart objective (shake n moves seed x))

/-- One outer step: seed-controlled shake, nested local VND and elitist
    acceptance. Improvement resets the outer index; otherwise it advances. -/
def step {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) : Metered (State n objective) :=
  match config.shaking[s.index]? with
  | none => Metered.pure s
  | some moves =>
      let localResult := localRun objective config moves s.seed s.search.incumbent
      let old := probe (finiteProblem n objective) s.search.incumbent
      let fresh := probe (finiteProblem n objective) localResult.value.search.incumbent
      let improves := fresh.value < old.value
      let chosen := if improves then localResult.value.search.incumbent
                    else s.search.incumbent
      let accepted : SearchState (finiteProblem n objective) :=
        SearchState.init chosen (by trivial)
      ⟨⟨accepted, if improves then 0 else s.index + 1, nextSeed s.seed⟩,
        localResult.queries + old.queries + fresh.queries⟩

/-- Exact metered count for a single outer step, in terms of the inner run.
    Empty/exhausted neighborhoods incur zero observations. -/
theorem step_queries {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) :
    (step objective config s).queries =
      match config.shaking[s.index]? with
      | none => 0
      | some moves =>
          (localRun objective config moves s.seed s.search.incumbent).queries + 2 := by
  cases h : config.shaking[s.index]? with
  | none => simp [step, h, Metered.pure]
  | some moves => simp [step, h, probe] <;> omega

/-- An accepted local improvement resets the outer VNS neighborhood. -/
theorem step_reset {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) (moves : List Move)
    (h : config.shaking[s.index]? = some moves)
    (hi : objective (localRun objective config moves s.seed s.search.incumbent).value.search.incumbent <
      objective s.search.incumbent) :
    (step objective config s).value.index = 0 := by
  simp [step, h, probe, hi]

/-- Failure to improve advances to the next outer perturbation. -/
theorem step_advance {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) (moves : List Move)
    (h : config.shaking[s.index]? = some moves)
    (hi : ¬ objective (localRun objective config moves s.seed s.search.incumbent).value.search.incumbent <
      objective s.search.incumbent) :
    (step objective config s).value.index = s.index + 1 := by
  simp [step, h, probe, hi]

/-- Elitist outer acceptance protects the global incumbent even if shaking
    and the subsequent local descent finish at a worse feasible solution. -/
theorem step_incumbent_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) :
    objective (step objective config s).value.search.incumbent ≤
      objective s.search.incumbent := by
  cases h : config.shaking[s.index]? with
  | none => simp [step, h, Metered.pure]
  | some moves =>
      by_cases hi :
        objective (localRun objective config moves s.seed s.search.incumbent).value.search.incumbent <
          objective s.search.incumbent
      · simpa [step, h, probe, hi] using (Nat.le_of_lt hi)
      · simp [step, h, probe, hi]

/-- The nested VND budget plus two outer acceptance observations bounds each
    active outer step; the same bound is valid for exhausted neighborhoods. -/
theorem step_queries_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective) :
    (step objective config s).queries ≤
      config.vndFuel * (2 * cap + 4) + 2 := by
  rw [step_queries]
  cases h : config.shaking[s.index]? with
  | none => simp [h]
  | some moves =>
      simp only [h]
      exact Nat.add_le_add_right
        (CatOpt.DSL.AdaptiveVNS.run_queries_le objective config.vnd config.vndFuel
          (localStart objective (shake n moves s.seed s.search.incumbent))) 2

/-- Outer structural fuel bounds the number of *attempted* GVNS steps. -/
def run {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) : Nat → State n objective → Metered (State n objective)
  | 0, s => Metered.pure s
  | fuel + 1, s =>
      (step objective config s).bind (run objective config fuel)

/-- End-to-end elitist monotonicity for every seed and arbitrary objective. -/
theorem run_incumbent_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (fuel : Nat) (s : State n objective) :
    objective (run objective config fuel s).value.search.incumbent ≤
      objective s.search.incumbent := by
  induction fuel generalizing s with
  | zero => exact Nat.le_refl _
  | succ k ih =>
      change objective
        (run objective config k (step objective config s).value).value.search.incumbent ≤
          objective s.search.incumbent
      exact Nat.le_trans (ih (step objective config s).value)
        (step_incumbent_le objective config s)

/-- The bound covers any sequence of resets/advances and any seed. -/
theorem run_queries_le {cap n : Nat} (objective : Fin (n + 1) → Nat)
    (config : Config cap) (fuel : Nat) (s : State n objective) :
    (run objective config fuel s).queries ≤
      fuel * (config.vndFuel * (2 * cap + 4) + 2) := by
  induction fuel generalizing s with
  | zero => simp [run, Metered.pure]
  | succ k ih =>
      change (step objective config s).queries +
        (run objective config k (step objective config s).value).queries ≤
        (k + 1) * (config.vndFuel * (2 * cap + 4) + 2)
      calc
        (step objective config s).queries +
            (run objective config k (step objective config s).value).queries ≤
            (config.vndFuel * (2 * cap + 4) + 2) +
              k * (config.vndFuel * (2 * cap + 4) + 2) :=
                Nat.add_le_add (step_queries_le objective config s)
                  (ih (step objective config s).value)
        _ = (k + 1) * (config.vndFuel * (2 * cap + 4) + 2) := by
              simp only [Nat.add_mul, Nat.one_mul]
              exact Nat.add_comm _ _

/-- Proof-bearing upper bound on all modeled oracle observations in the
    nested, seeded finite DSL. No external runtime guarantee is implied. -/
structure RunBudget (cap innerFuel budget : Nat) where
  outerFuel : Nat
  fits : outerFuel * (innerFuel * (2 * cap + 4) + 2) ≤ budget

/-- Check a numeric budget without executing an optimization routine. -/
def certifyRun (cap innerFuel budget outerFuel : Nat) :
    Option (RunBudget cap innerFuel budget) :=
  if h : outerFuel * (innerFuel * (2 * cap + 4) + 2) ≤ budget then
    some ⟨outerFuel, h⟩
  else none

/-- A successful certificate is valid for any seed and any objective. -/
theorem RunBudget.queries_le {cap innerFuel budget n : Nat}
    (b : RunBudget cap innerFuel budget) (objective : Fin (n + 1) → Nat)
    (config : Config cap) (s : State n objective)
    (h : config.vndFuel = innerFuel) :
    (run objective config b.outerFuel s).queries ≤ budget := by
  have hb := run_queries_le objective config b.outerFuel s
  rw [h] at hb
  exact Nat.le_trans hb b.fits

end CatOpt.DSL.SeededGVNS
