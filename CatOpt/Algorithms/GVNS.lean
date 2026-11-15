import CatOpt.Algorithms.GRASP

namespace CatOpt.Algorithms
open DSL DSL.Search

/-- One VNS-style perturbation → descent → acceptance round. -/
def vnsRound (radius : Nat) : SearchProgram .ready .ready :=
  .seq (.atom (.shake radius))
    (.seq (.atom .localSearch) (.atom .accept))

/-- A finite, fixed radius schedule resembling GVNS. Unlike adaptive GVNS,
    this prototype does not yet change k based on acceptance outcomes. -/
def gvnsSchedule (radii : List Nat) : SearchProgram .ready .ready :=
  radii.foldl (fun acc radius => .seq acc (vnsRound radius)) .skip

end CatOpt.Algorithms
