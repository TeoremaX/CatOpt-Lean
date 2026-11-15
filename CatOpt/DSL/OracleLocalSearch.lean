import CatOpt.DSL.Resources

/-!
# v0.4 — Closed, instrumented finite-neighborhood selection

Every objective comparison made by `selectMetered` passes through `probe`.
The selector consumes a supplied list of *certified feasible* neighbors.
Its candidate generation is outside this module and is not counted.

The main guarantees are:
* exactly `2 * candidates.length` registered queries (two per comparison);
* the selected solution is feasible;
* the selected objective is no worse than the starting candidate;
* the metered and pure selectors return the same candidate;
* an elitist round adds precisely two acceptance queries.

These are counts of explicit objective-oracle effects in the Lean semantics,
not CPU time and not hidden evaluations in the producer of the neighbor list.
-/

namespace CatOpt.DSL.OracleLocalSearch
open CatOpt.DSL.Resources

/-- Every candidate comes with a feasibility certificate. -/
abbrev Candidate (P : Problem) := {x : P.State // P.feasible x}

/-- Deterministic, strict-improvement selection; ties retain the incumbent. -/
def choose (P : Problem) (old fresh : Candidate P) : Candidate P :=
  if P.cost fresh.val < P.cost old.val then fresh else old

/-- The same comparison, with both evaluations explicitly counted. -/
def chooseMetered (P : Problem) (old fresh : Candidate P) :
    Metered (Candidate P) :=
  let a := probe P old.val
  let b := probe P fresh.val
  if b.value < a.value then
    ⟨fresh, a.queries + b.queries⟩
  else
    ⟨old, a.queries + b.queries⟩

@[simp] theorem chooseMetered_value (P : Problem) (old fresh : Candidate P) :
    (chooseMetered P old fresh).value = choose P old fresh := by
  by_cases h : P.cost fresh.val < P.cost old.val
  · simp [chooseMetered, choose, probe, h]
  · simp [chooseMetered, choose, probe, h]

@[simp] theorem chooseMetered_queries (P : Problem) (old fresh : Candidate P) :
    (chooseMetered P old fresh).queries = 2 := by
  by_cases h : P.cost fresh.val < P.cost old.val
  · simp [chooseMetered, probe, h]
  · simp [chooseMetered, probe, h]

/-- Choosing the better candidate cannot increase the objective. -/
theorem choose_le (P : Problem) (old fresh : Candidate P) :
    P.cost (choose P old fresh).val ≤ P.cost old.val := by
  by_cases h : P.cost fresh.val < P.cost old.val
  · simpa [choose, h] using (Nat.le_of_lt h)
  · simp [choose, h]

/-- A pure reference implementation used to state the erasure theorem. -/
def select (P : Problem) : Candidate P → List (Candidate P) → Candidate P
  | current, [] => current
  | current, fresh :: rest => select P (choose P current fresh) rest

/-- All comparisons go through the metered oracle; no direct objective call. -/
def selectMetered (P : Problem) :
    Candidate P → List (Candidate P) → Metered (Candidate P)
  | current, [] => Metered.pure current
  | current, fresh :: rest =>
      (chooseMetered P current fresh).bind (fun next => selectMetered P next rest)

/-- Instrumentation changes neither the selected candidate nor tie behavior. -/
theorem selectMetered_value (P : Problem) (current : Candidate P)
    (candidates : List (Candidate P)) :
    (selectMetered P current candidates).value = select P current candidates := by
  induction candidates generalizing current with
  | nil => rfl
  | cons fresh rest ih =>
      change (selectMetered P (chooseMetered P current fresh).value rest).value =
        select P (choose P current fresh) rest
      rw [chooseMetered_value]
      exact ih (choose P current fresh)

/-- The measured number of comparisons is exact, for every input list. -/
theorem selectMetered_queries (P : Problem) (current : Candidate P)
    (candidates : List (Candidate P)) :
    (selectMetered P current candidates).queries = 2 * candidates.length := by
  induction candidates generalizing current with
  | nil => rfl
  | cons fresh rest ih =>
      change (chooseMetered P current fresh).queries +
        (selectMetered P (chooseMetered P current fresh).value rest).queries =
        2 * (rest.length + 1)
      rw [chooseMetered_queries, ih]
      omega

/-- The pure reference selection never worsens its initial feasible solution. -/
theorem select_le (P : Problem) (current : Candidate P)
    (candidates : List (Candidate P)) :
    P.cost (select P current candidates).val ≤ P.cost current.val := by
  induction candidates generalizing current with
  | nil => exact Nat.le_refl _
  | cons fresh rest ih =>
      change P.cost (select P (choose P current fresh) rest).val ≤
        P.cost current.val
      exact Nat.le_trans (ih (choose P current fresh)) (choose_le P current fresh)

/-- Metered selection is non-worsening; this is not only a counter theorem. -/
theorem selectMetered_le (P : Problem) (current : Candidate P)
    (candidates : List (Candidate P)) :
    P.cost (selectMetered P current candidates).value.val ≤ P.cost current.val := by
  rw [selectMetered_value]
  exact select_le P current candidates

/-- Transform just the candidate track. The neighbor supplier is not charged. -/
def localSearchMetered (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    Metered (SearchState P) :=
  let found := selectMetered P ⟨s.candidate, s.candidate_ok⟩ (neighbors s.candidate)
  ⟨{ incumbent := s.incumbent
     candidate := found.value.val
     incumbent_ok := s.incumbent_ok
     candidate_ok := found.value.property }, found.queries⟩

/-- The number of oracle observations made by the finite selector. -/
theorem localSearchMetered_queries (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    (localSearchMetered P neighbors s).queries =
      2 * (neighbors s.candidate).length := by
  change (selectMetered P ⟨s.candidate, s.candidate_ok⟩
    (neighbors s.candidate)).queries = 2 * (neighbors s.candidate).length
  exact selectMetered_queries P _ _

/-- Local search cannot change the incumbent until the acceptance action. -/
theorem localSearchMetered_incumbent (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    (localSearchMetered P neighbors s).value.incumbent = s.incumbent := rfl

/-- The candidate chosen by the fully instrumented selector does not worsen. -/
theorem localSearchMetered_candidate_le (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    P.cost (localSearchMetered P neighbors s).value.candidate ≤ P.cost s.candidate := by
  change P.cost (selectMetered P ⟨s.candidate, s.candidate_ok⟩
    (neighbors s.candidate)).value.val ≤ P.cost s.candidate
  exact selectMetered_le P _ _

/-- Compose a measured local search with v0.3's measured elitist acceptance. -/
def roundMetered (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    Metered (SearchState P) :=
  (localSearchMetered P neighbors s).bind (acceptMetered P)

/-- This round has no opaque local-search work: all selection and acceptance
    comparisons are registered through `probe`. Neighbor generation is external. -/
theorem roundMetered_queries (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    (roundMetered P neighbors s).queries =
      2 * (neighbors s.candidate).length + 2 := by
  change (localSearchMetered P neighbors s).queries +
    (acceptMetered P (localSearchMetered P neighbors s).value).queries = _
  rw [localSearchMetered_queries, acceptMetered_queries]

/-- As in the established search semantics, the accepted incumbent is elitist. -/
theorem roundMetered_incumbent_le (P : Problem)
    (neighbors : P.State → List (Candidate P)) (s : SearchState P) :
    P.cost (roundMetered P neighbors s).value.incumbent ≤ P.cost s.incumbent := by
  have hacc := acceptBetter_monotone P (localSearchMetered P neighbors s).value
  have hround : (roundMetered P neighbors s).value =
      acceptBetter P (localSearchMetered P neighbors s).value := by
    change (acceptMetered P (localSearchMetered P neighbors s).value).value = _
    exact acceptMetered_value P _
  rw [hround]
  calc
    P.cost (acceptBetter P (localSearchMetered P neighbors s).value).incumbent ≤
        P.cost (localSearchMetered P neighbors s).value.incumbent := hacc
    _ = P.cost s.incumbent := by rw [localSearchMetered_incumbent]

/-- Certified budget for one *closed selection and acceptance round*. -/
structure RoundBudget (P : Problem) (budget : Nat) where
  state : SearchState P
  candidates : List (Candidate P)
  fits : 2 * candidates.length + 2 ≤ budget

/-- Construct an actual proof-bearing query budget, or reject the request. -/
def certifyRound (P : Problem) (budget : Nat) (s : SearchState P)
    (candidates : List (Candidate P)) : Option (RoundBudget P budget) :=
  if h : 2 * candidates.length + 2 ≤ budget then
    some ⟨s, candidates, h⟩
  else none

/-- Query bound is derived from instrumented execution, not a price table. -/
theorem RoundBudget.queries_le {P : Problem} {budget : Nat}
    (cert : RoundBudget P budget) :
    (roundMetered P (fun _ => cert.candidates) cert.state).queries ≤ budget := by
  rw [roundMetered_queries]
  exact cert.fits

end CatOpt.DSL.OracleLocalSearch
