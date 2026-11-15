import CatOpt.Properties
import CatOpt.DSL.Semantics

/-!
# A phase-typed DSL for local-search metaheuristics

The phase index rejects malformed pipelines such as `accept` before descent,
or a second `construct` when the first candidate has not been accepted.
The stages are a useful *syntactic protocol*; they are not three different
runtime data types. This model intentionally uses elitist acceptance.
-/
namespace CatOpt.DSL.Search
open CatOpt

/-- Phases through which each candidate must pass. -/
inductive Stage where
  | ready
  | candidate
  | improved
  deriving DecidableEq, Repr

/-- Primitive operators with valid input/output phases. -/
inductive Action : Stage → Stage → Type where
  | construct (seed : Nat) : Action .ready .candidate
  | shake (radius : Nat) : Action .ready .candidate
  | destroyRepair (strength : Nat) : Action .ready .candidate
  | localSearch : Action .candidate .improved
  | accept : Action .improved .ready

/-- Search syntax: the only expressible pipelines have matching stages. -/
def searchSignature : Signature Stage where
  Edge := Action

abbrev SearchProgram (a b : Stage) := Program searchSignature a b

/-- A concrete family of feasible operators implementing the primitives.
    This is the trusted algorithm-specific implementation boundary. -/
structure Primitives (P : Problem) where
  construct : Nat → Operator P
  shake : Nat → Operator P
  destroyRepair : Nat → Operator P
  localSearch : Operator P

/-- Interpret one action on the certified two-track state. -/
def evalAction {P : Problem} (impl : Primitives P)
    {a b : Stage} : Action a b → SearchOp P
  | .construct seed => resetCandidate P (impl.construct seed)
  | .shake radius => resetCandidate P (impl.shake radius)
  | .destroyRepair strength => resetCandidate P (impl.destroyRepair strength)
  | .localSearch => transformCandidate P impl.localSearch
  | .accept => acceptBetter P

/-- Interpret a well-typed program by sequencing its effects. -/
def run {P : Problem} (impl : Primitives P)
    {a b : Stage} : SearchProgram a b → SearchOp P
  | .skip => id
  | .atom action => evalAction impl action
  | .seq p q => fun s => run impl q (run impl p s)

/-- Every primitive action preserves or improves incumbent quality. -/
theorem action_monotone {P : Problem} (impl : Primitives P)
    {a b : Stage} (action : Action a b) :
    IncumbentMonotone P (evalAction impl action) := by
  cases action with
  | construct seed => exact resetCandidate_monotone P (impl.construct seed)
  | shake radius => exact resetCandidate_monotone P (impl.shake radius)
  | destroyRepair strength => exact resetCandidate_monotone P (impl.destroyRepair strength)
  | localSearch => exact transformCandidate_monotone P impl.localSearch
  | accept => exact acceptBetter_monotone P

/-- Main DSL soundness theorem: no well-typed program can worsen its
    incumbent, regardless of how its primitive heuristics choose candidates. -/
theorem program_monotone {P : Problem} (impl : Primitives P)
    {a b : Stage} (program : SearchProgram a b) :
    IncumbentMonotone P (run impl program) := by
  induction program with
  | skip =>
      intro s
      exact Nat.le_refl _
  | atom action =>
      exact action_monotone impl action
  | seq p q hp hq =>
      intro s
      exact Nat.le_trans (hq (run impl p s)) (hp s)

/-- Completed search rounds leave the runtime ready to start another round. -/
def execute {P : Problem} (impl : Primitives P)
    (program : SearchProgram .ready .ready)
    (s : SearchState P) : SearchState P :=
  run impl program s

end CatOpt.DSL.Search

namespace CatOpt.DSL.Search
open CatOpt CategoryTheory

/-- Stage-tagged objects in the feasibility-preserving category. The proof of
    feasibility is already carried in `SearchState`; the outer predicate is True. -/
def stageSpace (P : Problem) (_ : Stage) : Space where
  Carrier := SearchState P
  feasible := fun _ => True

/-- Every phase-typed primitive has a genuine categorical interpretation. -/
def asCategory {P : Problem} (impl : Primitives P) :
    Interpretation searchSignature Space where
  object := stageSpace P
  arrow := fun action =>
    { run := evalAction impl action
      preserves := by
        intro s hs
        trivial }

/-- The generic categorical interpretation agrees with executable semantics. -/
theorem denote_run {P : Problem} (impl : Primitives P)
    {a b : Stage} (program : SearchProgram a b) :
    (denote (asCategory impl) program).run = run impl program := by
  induction program with
  | skip => rfl
  | atom action => rfl
  | seq p q hp hq =>
      funext s
      change (denote (asCategory impl) q).run
          ((denote (asCategory impl) p).run s) =
          run impl q (run impl p s)
      rw [hp, hq]

end CatOpt.DSL.Search
