import CatOpt.Basic
import Mathlib.CategoryTheory.Category.Basic

/-!
# Category of feasibility-preserving state transformations

Objects are states equipped with predicates. A morphism is a total function
preserving the specified predicate. No objective-decrease assumption is made:
perturbations should be legal morphisms even when they worsen the cost.
-/
namespace CatOpt
open CategoryTheory

universe u

/-- An object of the category: a type equipped with a feasible-state predicate. -/
structure Space where
  Carrier : Type u
  feasible : Carrier → Prop

/-- A feasibility-preserving map. -/
structure SafeHom (X Y : Space.{u}) where
  run : X.Carrier → Y.Carrier
  preserves : ∀ x, X.feasible x → Y.feasible (run x)

namespace SafeHom

@[ext] theorem ext {X Y : Space.{u}} {f g : SafeHom X Y}
    (h : f.run = g.run) : f = g := by
  cases f with
  | mk fr fp =>
    cases g with
    | mk gr gp =>
      cases h
      rfl

/-- Identity preserves feasibility. -/
def identity (X : Space.{u}) : SafeHom X X where
  run := id
  preserves := by
    intro x hx
    exact hx

/-- Sequential execution: first `f`, then `g`. -/
def compose {X Y Z : Space.{u}} (f : SafeHom X Y)
    (g : SafeHom Y Z) : SafeHom X Z where
  run := fun x => g.run (f.run x)
  preserves := by
    intro x hx
    exact g.preserves (f.run x) (f.preserves x hx)

theorem identity_comp {X Y : Space.{u}} (f : SafeHom X Y) :
    compose (identity X) f = f := by
  apply ext
  rfl

theorem comp_identity {X Y : Space.{u}} (f : SafeHom X Y) :
    compose f (identity Y) = f := by
  apply ext
  rfl

theorem compose_assoc {W X Y Z : Space.{u}}
    (f : SafeHom W X) (g : SafeHom X Y) (h : SafeHom Y Z) :
    compose (compose f g) h = compose f (compose g h) := by
  apply ext
  rfl

end SafeHom

/-- Genuine Mathlib `Category` instance, not only an analogy with composition. -/
instance : CategoryTheory.Category.{u} Space.{u} where
  Hom := SafeHom
  id := SafeHom.identity
  comp := SafeHom.compose
  id_comp := SafeHom.identity_comp
  comp_id := SafeHom.comp_identity
  assoc := SafeHom.compose_assoc

/-- Every optimization problem determines an object of this category.
    A transparent abbreviation allows typeclass inference to recognize the
    underlying carrier (e.g. `Nat`) in concrete examples. -/
abbrev Problem.toSpace (P : Problem) : Space :=
  ⟨P.State, P.feasible⟩

end CatOpt
