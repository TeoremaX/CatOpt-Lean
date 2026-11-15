import CatOpt.Category

/-!
# Primitive optimization operators and cost-based certificates

Non-worsening is a *property*, not part of the morphism type: Shake, mutation
and destruction are permitted to increase objective value.
-/
namespace CatOpt
open CategoryTheory

/-- A total operator on a fixed optimization problem that preserves feasibility. -/
abbrev Operator (P : Problem) := SafeHom P.toSpace P.toSpace

/-- An operator never increases objective value on feasible inputs. -/
def NonWorsening (P : Problem) (f : Operator P) : Prop :=
  ∀ x, P.feasible x → P.cost (f.run x) ≤ P.cost x

/-- Every identity operator is non-worsening. -/
theorem nonWorsening_identity (P : Problem) :
    NonWorsening P (SafeHom.identity P.toSpace) := by
  intro x hx
  exact Nat.le_refl _

/-- Improvement certificates compose. -/
theorem nonWorsening_comp (P : Problem)
    (f g : Operator P) (hf : NonWorsening P f)
    (hg : NonWorsening P g) :
    NonWorsening P (SafeHom.compose f g) := by
  intro x hx
  exact Nat.le_trans (hg (f.run x) (f.preserves x hx)) (hf x hx)

/-- Execute a feasible transformation a fixed number of times. -/
def runN (P : Problem) (f : Operator P) : Nat → P.State → P.State
  | 0, x => x
  | n + 1, x => runN P f n (f.run x)

/-- Iteration preserves feasibility. -/
theorem runN_feasible (P : Problem) (f : Operator P)
    (n : Nat) (x : P.State) (hx : P.feasible x) :
    P.feasible (runN P f n x) := by
  induction n generalizing x with
  | zero => exact hx
  | succ n ih =>
      exact ih (f.run x) (f.preserves x hx)

/-- Any finite repetition of a certified non-worsening operator is non-worsening. -/
theorem runN_nonWorsening (P : Problem) (f : Operator P)
    (hf : NonWorsening P f) (n : Nat) (x : P.State)
    (hx : P.feasible x) :
    P.cost (runN P f n x) ≤ P.cost x := by
  induction n generalizing x with
  | zero => exact Nat.le_refl _
  | succ n ih =>
      exact Nat.le_trans (ih (f.run x) (f.preserves x hx)) (hf x hx)

end CatOpt
