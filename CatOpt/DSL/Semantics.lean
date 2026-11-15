import CatOpt.DSL.Syntax
import Mathlib.CategoryTheory.Category.Basic

/-!
# Interpretation into a semantic category

Interpretation maps syntax objects to category objects, and each generator
to an arrow. The interpretation extends to the entire program by identity
and composition. Its coherence equations are proved explicitly below.
-/
namespace CatOpt.DSL
open CategoryTheory

universe u v w

/-- Interpretation of each primitive edge as a morphism. -/
structure Interpretation {Obj : Type u} (σ : Signature.{u,v} Obj)
    (C : Type w) [CategoryTheory.Category C] where
  object : Obj → C
  arrow : ∀ {a b}, σ.Edge a b → (object a ⟶ object b)

/-- A semantics defined recursively on the syntax tree. -/
def denote {Obj : Type u} {σ : Signature.{u,v} Obj}
    {C : Type w} [CategoryTheory.Category C]
    (I : Interpretation σ C) {a b : Obj} :
    Program σ a b → (I.object a ⟶ I.object b)
  | .skip => 𝟙 _
  | .atom x => I.arrow x
  | .seq p q => denote I p ≫ denote I q

/-- Syntax sequencing is interpreted as category composition. -/
theorem denote_seq {Obj : Type u} {σ : Signature.{u,v} Obj}
    {C : Type w} [CategoryTheory.Category C]
    (I : Interpretation σ C) {a b c : Obj}
    (p : Program σ a b) (q : Program σ b c) :
    denote I (.seq p q) = denote I p ≫ denote I q := rfl

/-- Semantics respects associativity even if syntax trees differ. -/
theorem denote_assoc {Obj : Type u} {σ : Signature.{u,v} Obj}
    {C : Type w} [CategoryTheory.Category C]
    (I : Interpretation σ C) {a b c d : Obj}
    (p : Program σ a b) (q : Program σ b c) (r : Program σ c d) :
    denote I (.seq (.seq p q) r) = denote I (.seq p (.seq q r)) := by
  change (denote I p ≫ denote I q) ≫ denote I r =
    denote I p ≫ (denote I q ≫ denote I r)
  exact Category.assoc _ _ _

/-- Left units are sound in the denotational semantics. -/
theorem denote_left_unit {Obj : Type u} {σ : Signature.{u,v} Obj}
    {C : Type w} [CategoryTheory.Category C]
    (I : Interpretation σ C) {a b : Obj}
    (p : Program σ a b) :
    denote I (.seq .skip p) = denote I p := by
  change (𝟙 (I.object a)) ≫ denote I p = denote I p
  exact Category.id_comp _

/-- Right units are sound in the denotational semantics. -/
theorem denote_right_unit {Obj : Type u} {σ : Signature.{u,v} Obj}
    {C : Type w} [CategoryTheory.Category C]
    (I : Interpretation σ C) {a b : Obj}
    (p : Program σ a b) :
    denote I (.seq p .skip) = denote I p := by
  change denote I p ≫ (𝟙 (I.object b)) = denote I p
  exact Category.comp_id _

end CatOpt.DSL
