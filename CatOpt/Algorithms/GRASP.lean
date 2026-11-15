import CatOpt.DSL.Search

namespace CatOpt.Algorithms
open DSL DSL.Search

/-- One GRASP-style construction → local search → elitist acceptance round.
    Deterministic seeds are explicit; randomness must be supplied by the
    concrete `Primitives` implementation. -/
def graspVND (seed : Nat) : SearchProgram .ready .ready :=
  .seq (.atom (.construct seed))
    (.seq (.atom .localSearch) (.atom .accept))

/-- Repeated independently seeded construction phases. -/
def graspMultiStart (seeds : List Nat) : SearchProgram .ready .ready :=
  seeds.foldl (fun acc seed => .seq acc (graspVND seed)) .skip

end CatOpt.Algorithms
