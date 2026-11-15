import CatOpt.Algorithms.GVNS

namespace CatOpt.Algorithms
open DSL DSL.Search

/-- One destroy-repair → descent → elitist acceptance round. -/
def iteratedGreedyRound (strength : Nat) : SearchProgram .ready .ready :=
  .seq (.atom (.destroyRepair strength))
    (.seq (.atom .localSearch) (.atom .accept))

/-- Finite schedule of Iterated Greedy rounds. -/
def iteratedGreedy (strengths : List Nat) : SearchProgram .ready .ready :=
  strengths.foldl (fun acc strength => .seq acc (iteratedGreedyRound strength)) .skip

end CatOpt.Algorithms
