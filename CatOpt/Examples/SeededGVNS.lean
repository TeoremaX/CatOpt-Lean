import CatOpt.Examples.FiniteNeighborhood
import CatOpt.DSL.SeededGVNS

/-!
# v0.7 — Reproducible seeded shaking and a nested VND-style descent

In Fin 21 with cost = identity, the first outer shake (+4) is not recovered by
2 inner backward-one steps, so the global incumbent remains 15. The second
outer shake (-1) is followed by 2 inner improvements and reaches 12. Both
outer steps are metered: 2 inner steps × 6 probes + 2 outer probes = 14.
-/
namespace CatOpt.Examples
open CatOpt.DSL.SeededGVNS

/-- A one-neighborhood inner VND schedule, with a checked cap of one move. -/
def innerCatalogV07 : CatOpt.DSL.AdaptiveVNS.Catalog 1 where
  neighborhoods := [[.backward 1]]
  bounded := by
    intro i moves h
    cases i with
    | zero =>
        simp at h
        subst moves
        decide
    | succ i =>
        simp at h

/-- First shake is deliberately worse; the next permits improvement. -/
def seededConfig : Config 1 where
  shaking := [[.forward 4], [.backward 1]]
  vnd := innerCatalogV07
  vndFuel := 2

def seededInitial : State 20 finiteLineObjective :=
  ⟨finiteLineInitial, 0, 0⟩

def seededFirst :=
  step finiteLineObjective seededConfig seededInitial

def seededResult :=
  run finiteLineObjective seededConfig 2 seededInitial

/-- Two attempts require at most 2 × (2 × (2 × 1 + 4) + 2) = 28 probes. -/
def seededBudget : Option (RunBudget 1 2 28) :=
  certifyRun 1 2 28 2

end CatOpt.Examples
