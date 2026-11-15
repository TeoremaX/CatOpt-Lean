import CatOpt

open CatOpt

def main : IO Unit := do
  IO.println "CatOpt-Lean — executable finite-state semantics example"
  IO.println s!"Initial incumbent objective: {Examples.initial.incumbent}"
  IO.println s!"GRASP-style result:          {Examples.graspResult.incumbent}"
  IO.println s!"GVNS fixed-schedule result:  {Examples.gvnsResult.incumbent}"
  IO.println s!"Iterated Greedy result:      {Examples.igResult.incumbent}"
  IO.println "Each program has an abstract monotonic-incumbent proof in Lean."
