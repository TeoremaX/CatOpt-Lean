import CatOpt.DSL.Synthesis

/-!
# Instrumented objective-query semantics (v0.3)

`Metered` counts *explicit calls to `probe` in this model*. It is NOT a bound
on machine instructions, wall-clock time, or calls hidden inside opaque
`Primitives` implementations. The existing `Search.run` interpreter is kept
unchanged and a value-preservation theorem connects the new interpreter to it.

This deliberate separation prevents an invalid claim that the arbitrary
`localSearch : Operator P` has zero real objective evaluations. The reported
counter measures only the observation effect handled by this layer.
-/

namespace CatOpt.DSL.Resources
open CatOpt.DSL.Search
open CatOpt.DSL.Synthesis

/-- An answer paired with the number of instrumented objective observations. -/
structure Metered (α : Type) where
  value : α
  queries : Nat
  deriving Repr

/-- Pure operations generate no recorded oracle interactions. -/
def Metered.pure {α : Type} (a : α) : Metered α := ⟨a, 0⟩

/-- Composition accumulates exactly the observations recorded by its parts. -/
def Metered.bind {α β : Type} (m : Metered α)
    (f : α → Metered β) : Metered β :=
  ⟨(f m.value).value, m.queries + (f m.value).queries⟩

@[simp] theorem Metered.bind_value {α β : Type}
    (m : Metered α) (f : α → Metered β) :
    (m.bind f).value = (f m.value).value := rfl

@[simp] theorem Metered.bind_queries {α β : Type}
    (m : Metered α) (f : α → Metered β) :
    (m.bind f).queries = m.queries + (f m.value).queries := rfl

/-- Writer associativity: the recorded counts are independent of grouping. -/
theorem Metered.bind_assoc {α β γ : Type} (m : Metered α)
    (f : α → Metered β) (g : β → Metered γ) :
    (m.bind f).bind g = m.bind (fun a => (f a).bind g) := by
  cases m with
  | mk a n =>
      change
        (⟨(g (f a).value).value,
           (n + (f a).queries) + (g (f a).value).queries⟩ : Metered γ) =
        ⟨(g (f a).value).value,
          n + ((f a).queries + (g (f a).value).queries)⟩
      rw [Nat.add_assoc]

/-- The only explicitly instrumented objective operation in this module. -/
def probe (P : Problem) (x : P.State) : Metered Nat :=
  ⟨P.cost x, 1⟩

@[simp] theorem probe_value (P : Problem) (x : P.State) :
    (probe P x).value = P.cost x := rfl

@[simp] theorem probe_queries (P : Problem) (x : P.State) :
    (probe P x).queries = 1 := rfl

/-- A small *closed* client of the oracle, which never calls `P.cost`
    except through `probe`. Its recorded count therefore covers every
    objective observation requested by this client. -/
def probeMany (P : Problem) : List P.State → Metered (List Nat)
  | [] => Metered.pure []
  | x :: xs =>
      let head := probe P x
      let tail := probeMany P xs
      ⟨head.value :: tail.value, head.queries + tail.queries⟩

/-- Fully instrumented list scoring uses exactly one observation per item. -/
theorem probeMany_queries (P : Problem) (xs : List P.State) :
    (probeMany P xs).queries = xs.length := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
      simp [probeMany, ih, probe, Nat.add_comm]

/-- The instrumented client agrees with the pure list of objective values. -/
theorem probeMany_value (P : Problem) (xs : List P.State) :
    (probeMany P xs).value = xs.map P.cost := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
      simp [probeMany, probe, ih]

/-- A budget certificate for the closed list-scoring client. -/
structure ProbeBudget (P : Problem) (budget : Nat) where
  inputs : List P.State
  fits : inputs.length ≤ budget

/-- Produce a checkable certificate; no user-supplied per-operation weights. -/
def certifyProbes (P : Problem) (budget : Nat) (inputs : List P.State) :
    Option (ProbeBudget P budget) :=
  if h : inputs.length ≤ budget then some ⟨inputs, h⟩ else none

/-- Certified inputs never exceed their instrumented query budget. -/
theorem ProbeBudget.queries_le {P : Problem} {budget : Nat}
    (c : ProbeBudget P budget) :
    (probeMany P c.inputs).queries ≤ budget := by
  rw [probeMany_queries]
  exact c.fits

/-- Elitist acceptance with two explicitly observed objective values.
    No unrecorded call to `P.cost` is made in this definition. -/
def acceptMetered (P : Problem) (s : SearchState P) :
    Metered (SearchState P) :=
  let old := probe P s.incumbent
  let next := probe P s.candidate
  if next.value ≤ old.value then
    ⟨{ incumbent := s.candidate
       candidate := s.candidate
       incumbent_ok := s.candidate_ok
       candidate_ok := s.candidate_ok }, old.queries + next.queries⟩
  else
    ⟨{ incumbent := s.incumbent
       candidate := s.incumbent
       incumbent_ok := s.incumbent_ok
       candidate_ok := s.incumbent_ok }, old.queries + next.queries⟩

/-- Two instrumented observations, independently of the acceptance result. -/
theorem acceptMetered_queries (P : Problem) (s : SearchState P) :
    (acceptMetered P s).queries = 2 := by
  by_cases h : P.cost s.candidate ≤ P.cost s.incumbent
  · simp [acceptMetered, probe, h]
  · simp [acceptMetered, probe, h]

/-- The new implementation returns precisely the old elitist-search state. -/
theorem acceptMetered_value (P : Problem) (s : SearchState P) :
    (acceptMetered P s).value = acceptBetter P s := by
  by_cases h : P.cost s.candidate ≤ P.cost s.incumbent
  · simp [acceptMetered, probe, acceptBetter, Problem.chooseBetter, h]
  · simp [acceptMetered, probe, acceptBetter, Problem.chooseBetter, h]

/-- Instrument only acceptance; opaque primitives remain unmetered here.
    This design intentionally does NOT claim to count their internal work. -/
def evalMetered {P : Problem} (impl : Primitives P)
    {a b : Stage} : Action a b → SearchState P → Metered (SearchState P)
  | .construct seed => fun s => Metered.pure (resetCandidate P (impl.construct seed) s)
  | .shake radius => fun s => Metered.pure (resetCandidate P (impl.shake radius) s)
  | .destroyRepair strength => fun s =>
      Metered.pure (resetCandidate P (impl.destroyRepair strength) s)
  | .localSearch => fun s => Metered.pure (transformCandidate P impl.localSearch s)
  | .accept => acceptMetered P

/-- Erasing observations agrees with the established interpreter on atoms. -/
theorem evalMetered_value {P : Problem} (impl : Primitives P)
    {a b : Stage} (act : Action a b) (s : SearchState P) :
    (evalMetered impl act s).value = evalAction impl act s := by
  cases act with
  | construct seed => rfl
  | shake radius => rfl
  | destroyRepair strength => rfl
  | localSearch => rfl
  | accept => exact acceptMetered_value P s

/-- Query-bearing atoms are precisely the two-observation accept actions. -/
def acceptCount {a b : Stage} : SearchProgram a b → Nat
  | .skip => 0
  | .atom (.accept) => 1
  | .atom _ => 0
  | .seq p q => acceptCount p + acceptCount q

/-- Compositional interpreter with a Writer-like observation count. -/
def runMetered {P : Problem} (impl : Primitives P)
    {a b : Stage} : SearchProgram a b → SearchState P → Metered (SearchState P)
  | .skip => fun s => Metered.pure s
  | .atom act => evalMetered impl act
  | .seq p q => fun s =>
      (runMetered impl p s).bind (runMetered impl q)

/-- Sound erasure: instrumentation does not change the returned search state. -/
theorem runMetered_value {P : Problem} (impl : Primitives P)
    {a b : Stage} (p : SearchProgram a b) (s : SearchState P) :
    (runMetered impl p s).value = Search.run impl p s := by
  induction p generalizing s with
  | skip => rfl
  | atom act => exact evalMetered_value impl act s
  | seq p q ihp ihq =>
      change (runMetered impl q (runMetered impl p s).value).value =
        Search.run impl q (Search.run impl p s)
      rw [ihq, ihp]

/-- Exactly two instrumented objective observations per accept action,
    irrespective of the actual candidate or the accepted result. -/
theorem runMetered_queries {P : Problem} (impl : Primitives P)
    {a b : Stage} (p : SearchProgram a b) (s : SearchState P) :
    (runMetered impl p s).queries = 2 * acceptCount p := by
  induction p generalizing s with
  | skip => rfl
  | atom act =>
      cases act with
      | construct seed => rfl
      | shake radius => rfl
      | destroyRepair strength => rfl
      | localSearch => rfl
      | accept =>
          simpa [runMetered, acceptCount, evalMetered] using
            acceptMetered_queries P s
  | seq p q ihp ihq =>
      change (runMetered impl p s).queries +
        (runMetered impl q (runMetered impl p s).value).queries =
        2 * (acceptCount p + acceptCount q)
      rw [ihp, ihq]
      omega

/-- Every generated complete round contributes precisely one acceptance. -/
theorem round_acceptCount (r : RoundStart) :
    acceptCount (round r) = 1 := by
  cases r <;> rfl

/-- A generated sequence of rounds contains exactly one accept per round. -/
theorem compileRounds_acceptCount (rs : List RoundStart) :
    acceptCount (compileRounds rs) = rs.length := by
  induction rs with
  | nil => rfl
  | cons r rs ih =>
      change acceptCount (round r) + acceptCount (compileRounds rs) =
        rs.length + 1
      rw [round_acceptCount, ih]
      omega

/-- Resource theorem for the *instrumented acceptance effect only*. -/
theorem compileRounds_queries {P : Problem} (impl : Primitives P)
    (rs : List RoundStart) (s : SearchState P) :
    (runMetered impl (compileRounds rs) s).queries = 2 * rs.length := by
  rw [runMetered_queries, compileRounds_acceptCount]

/-- The newly instrumented interpreter also inherits incumbent monotonicity. -/
theorem runMetered_incumbent_le {P : Problem} (impl : Primitives P)
    {a b : Stage} (p : SearchProgram a b) (s : SearchState P) :
    P.cost (runMetered impl p s).value.incumbent ≤ P.cost s.incumbent := by
  rw [runMetered_value]
  exact program_monotone impl p s


/-- A certificate for the *instrumented acceptance-probe* budget of a
    synthesized program. This explicitly does not bound hidden objective
    calls inside the old `Primitives`. -/
structure AcceptanceBudget (budget : Nat) where
  rounds : List RoundStart
  fits : 2 * rounds.length ≤ budget

/-- Certified synthesis-level query budget for acceptance effects only. -/
def certifyAcceptance (budget : Nat) (rs : List RoundStart) :
    Option (AcceptanceBudget budget) :=
  if h : 2 * rs.length ≤ budget then some ⟨rs, h⟩ else none

/-- Unlike `WorkCosts`, this budget matches a theorem about the interpreter's
    explicitly recorded acceptance probes. It is not a total-cost theorem. -/
theorem AcceptanceBudget.queries_le {P : Problem} {budget : Nat}
    (c : AcceptanceBudget budget) (impl : Primitives P) (s : SearchState P) :
    (runMetered impl (compileRounds c.rounds) s).queries ≤ budget := by
  rw [compileRounds_queries]
  exact c.fits

end CatOpt.DSL.Resources
