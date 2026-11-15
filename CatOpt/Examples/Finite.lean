import CatOpt.Algorithms.IteratedGreedy
import Mathlib.Tactic

/-!
# Executable finite-domain demonstration

This is deliberately a tiny, transparent *semantics demonstration*, not a
claim that a 21-state toy is a competitive TSP optimizer. See `experiments/`
for genuine TSP implementations and measurements (not formally verified).
-/
namespace CatOpt.Examples
open DSL.Search

/-- A toy minimization problem on integers 0,...,20, objective f(x)=x. -/
abbrev bounded : Problem where
  State := Nat
  feasible := fun x => x ≤ 20
  cost := id

/-- Explicitly seeded construction; every result remains feasible. -/
def constructOp (seed : Nat) : Operator bounded where
  run := fun (_ : Nat) => seed % 21
  preserves := by
    intro x hx
    change seed % 21 ≤ 20
    exact Nat.le_of_lt_succ (Nat.mod_lt seed (by decide))

/-- A possibly worsening modular perturbation. -/
def shakeOp (radius : Nat) : Operator bounded where
  run := fun (x : Nat) => (x + radius) % 21
  preserves := by
    intro x hx
    change (x + radius) % 21 ≤ 20
    exact Nat.le_of_lt_succ (Nat.mod_lt (x + radius) (by decide))

/-- An illustrative destruction-and-repair transformation. -/
def destroyRepairOp (strength : Nat) : Operator bounded where
  run := fun (x : Nat) => (x + 2 * strength) % 21
  preserves := by
    intro x hx
    change (x + 2 * strength) % 21 ≤ 20
    exact Nat.le_of_lt_succ (Nat.mod_lt (x + 2 * strength) (by decide))

/-- One exact descent step. Natural subtraction saturates at zero. -/
def descentOp : Operator bounded where
  run := fun (x : Nat) => x - 1
  preserves := by
    intro x hx
    change x - 1 ≤ 20
    exact Nat.le_trans (Nat.sub_le x 1) hx

/-- For this particular example descent is certified non-worsening. -/
theorem descent_nonWorsening : NonWorsening bounded descentOp := by
  intro x hx
  change x - 1 ≤ x
  exact Nat.sub_le x 1

/-- A 20-step simple descent is a legitimate (if elementary) local search. -/
def vndOp : Operator bounded where
  run := runN bounded descentOp 20
  preserves := by
    intro x hx
    exact runN_feasible bounded descentOp 20 x hx

/-- Certificate is inherited from the single-step operator. -/
theorem vnd_nonWorsening : NonWorsening bounded vndOp := by
  intro x hx
  exact runN_nonWorsening bounded descentOp
    descent_nonWorsening 20 x hx

/-- Implementations for the three compositional algorithms. -/
def implementation : Primitives bounded where
  construct := constructOp
  shake := shakeOp
  destroyRepair := destroyRepairOp
  localSearch := vndOp

/-- Every example begins from the feasible incumbent 15. -/
def initial : SearchState bounded :=
  SearchState.init (15 : Nat) (by decide)

/-- A concrete result, evaluated by `lake exe catopt-demo`. -/
def graspResult : SearchState bounded :=
  DSL.Search.execute implementation (Algorithms.graspVND 12) initial

def gvnsResult : SearchState bounded :=
  DSL.Search.execute implementation (Algorithms.gvnsSchedule [2, 5, 1]) initial

def igResult : SearchState bounded :=
  DSL.Search.execute implementation (Algorithms.iteratedGreedy [3, 2, 1]) initial

end CatOpt.Examples
