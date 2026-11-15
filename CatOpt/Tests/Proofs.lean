import CatOpt.Examples.Finite

/-!
# Compile-time regression checks

Each `example` is checked by Lean. They don't run merely as scripts.
No `sorry`, `admit` or additional axioms are used in the package code.
-/
namespace CatOpt.Tests
open CatOpt DSL.Search

example : NonWorsening Examples.bounded Examples.descentOp :=
  Examples.descent_nonWorsening

example : NonWorsening Examples.bounded Examples.vndOp :=
  Examples.vnd_nonWorsening

example : IncumbentMonotone Examples.bounded
    (DSL.Search.run Examples.implementation (Algorithms.graspVND 7)) :=
  DSL.Search.program_monotone Examples.implementation (Algorithms.graspVND 7)

example : IncumbentMonotone Examples.bounded
    (DSL.Search.run Examples.implementation (Algorithms.gvnsSchedule [1, 2, 3])) :=
  DSL.Search.program_monotone Examples.implementation (Algorithms.gvnsSchedule [1, 2, 3])

example : IncumbentMonotone Examples.bounded
    (DSL.Search.run Examples.implementation (Algorithms.iteratedGreedy [1, 3])) :=
  DSL.Search.program_monotone Examples.implementation (Algorithms.iteratedGreedy [1, 3])

/-- All concrete programs have an incumbent no worse than the initial 15. -/
example : Examples.bounded.cost Examples.graspResult.incumbent ≤ 15 := by
  exact DSL.Search.program_monotone Examples.implementation
    (Algorithms.graspVND 12) Examples.initial

example : Examples.bounded.cost Examples.gvnsResult.incumbent ≤ 15 := by
  exact DSL.Search.program_monotone Examples.implementation
    (Algorithms.gvnsSchedule [2, 5, 1]) Examples.initial

example : Examples.bounded.cost Examples.igResult.incumbent ≤ 15 := by
  exact DSL.Search.program_monotone Examples.implementation
    (Algorithms.iteratedGreedy [3, 2, 1]) Examples.initial

end CatOpt.Tests

namespace CatOpt.Tests
open CatOpt DSL.Search

/-- A concrete sanity counterexample: a feasible shake can worsen the objective.
    This is why monotonicity is proved for the incumbent, not the candidate. -/
example : ¬ NonWorsening Examples.bounded (Examples.shakeOp 1) := by
  intro h
  have bad := h 0 (by decide : Examples.bounded.feasible 0)
  norm_num [Examples.bounded, Examples.shakeOp] at bad

end CatOpt.Tests
