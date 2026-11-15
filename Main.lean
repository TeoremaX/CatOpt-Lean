import CatOpt

open CatOpt
open CatOpt.DSL.Synthesis

def main : IO Unit := do
  IO.println "CatOpt-Lean — finite-state semantics and typed synthesis demonstration"
  IO.println s!"Initial incumbent objective: {Examples.initial.incumbent}"
  IO.println s!"GRASP-style result:          {Examples.graspResult.incumbent}"
  IO.println s!"GVNS fixed-schedule result:  {Examples.gvnsResult.incumbent}"
  IO.println s!"Iterated Greedy result:      {Examples.igResult.incumbent}"
  IO.println "The Lean search semantics has an abstract monotonic-incumbent proof."
  IO.println ""

  let candidates := Examples.synthesizedRecipes
  IO.println s!"Synthesized budget-certified recipes: {candidates.length}"
  for recipe in candidates do
    let result := recipe.execute Examples.implementation Examples.initial
    IO.println s!"  rounds={recipe.rounds.length}, estimated work={estimatedCost Examples.synthesisCosts recipe.rounds}, incumbent={result.incumbent}"
  IO.println "Budget units are user-declared estimates, not verified runtime costs."

  IO.println ""
  IO.println "v0.3 — Explicit instrumented-oracle observations"
  IO.println s!"  Explicit list probes: {Examples.probeExample.queries}"
  IO.println s!"  One round (acceptance) probes: {Examples.meteredRoundExample.queries}"
  IO.println "  The opaque local-search operator is NOT instrumented here."
  IO.println "  Counters do not bound its hidden evaluations, CPU time, or real costs."

  IO.println ""
  IO.println "v0.4 — Verified finite-neighborhood selection (explicit observations)"
  IO.println s!"  Supplied feasible neighbors: {Examples.v04Candidates.length}"
  IO.println s!"  Selection observations:     {Examples.v04Selection.queries}"
  IO.println s!"  Round observations:         {Examples.v04Round.queries}"
  IO.println s!"  Accepted incumbent:        {Examples.v04Round.value.incumbent}"
  IO.println "  Counts cover selector + acceptance, NOT neighbor generation or other opaque operators."

  IO.println ""
  IO.println "v0.5 — First-order finite moves + fuel-bounded oracle semantics"
  IO.println s!"  Move tokens per round:      {Examples.finiteLineMoves.length}"
  IO.println "  Fuel (complete rounds):    3"
  IO.println s!"  Exact modeled probes:       {Examples.finiteLineResult.queries}"
  IO.println s!"  Final accepted incumbent:  {Examples.finiteLineResult.value.incumbent.val}"
  IO.println "  Generators use only finite arithmetic. Counts exclude CPU/Lean reduction work."
  IO.println "  This is not yet adaptive GVNS or a formally verified TSP solver."
