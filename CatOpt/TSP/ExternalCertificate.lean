import CatOpt.TSP.LocalOptimality

/-!
# v0.10 — Untrusted text to a proof-backed TSP tour

The external solver supplies *data*, never Lean code or a proof. The decoder
checks the number of cities, every city identifier, and explicit left/right
inverse equations before constructing `Equiv.Perm`. The matrix is checked to
be square before its values are used to define an `Instance`.

Acceptance runs v0.9's full directed-distance local-optimality checker. This
certifies a local minimum for *all* inclusive interval reversals, not a global
TSP optimum, and does not establish a bound on runtime or wall-clock cost.

The text interface is deliberately small and restrictive: a city count,
that many space-separated matrix rows, and one space-separated route row.
Empty lines and CRLF are permitted. Invalid text never produces a typed case.
-/

namespace CatOpt.TSP.ExternalCertificate
open CatOpt.TSP

/-- A validated external input whose tour is a genuine finite permutation. -/
structure Case where
  n : Nat
  instanceData : Instance n
  tour : Tour n

/-- Search all finite positions to construct a *computable* inverse candidate.
    The two inverse laws are checked separately before accepting any tour. -/
def inverseCandidate {n : Nat} (forward : Fin (n + 1) → Fin (n + 1))
    (city : Fin (n + 1)) : Fin (n + 1) :=
  ((List.finRange (n + 1)).find? (fun pos => forward pos == city)).getD 0

/-- Decode a list of (n+1) untrusted natural-number city identifiers into a
    verified permutation, or reject it. No `Classical.choice` is used to
    construct the inverse: it is obtained by a finite, executable search. -/
def decodeTour (n : Nat) (raw : Array Nat) : Option (Tour n) :=
  if raw.size != n + 1 then none
  else
    let cityAt : Fin (n + 1) → Nat := fun pos => (raw[pos.val]?).getD 0
    if hRange : ∀ pos : Fin (n + 1), cityAt pos < n + 1 then
      let forward : Fin (n + 1) → Fin (n + 1) :=
        fun pos => ⟨cityAt pos, hRange pos⟩
      let inverse : Fin (n + 1) → Fin (n + 1) := inverseCandidate forward
      if hLeft : ∀ pos : Fin (n + 1), inverse (forward pos) = pos then
        if hRight : ∀ city : Fin (n + 1), forward (inverse city) = city then
          some { toFun := forward, invFun := inverse,
                 left_inv := hLeft, right_inv := hRight }
        else none
      else none
    else none

/-- A successfully decoded route is bijective by its constructed type. -/
theorem decodeTour_bijective {n : Nat} (raw : Array Nat) (tour : Tour n)
    (_h : decodeTour n raw = some tour) : Function.Bijective tour :=
  tour.bijective

/-- Decimal natural numbers separated by single/multiple spaces. -/
def parseNumbers (line : String) : Option (Array Nat) := do
  let tokens := (line.splitOn " ").filter (fun s => s != "")
  let values ← tokens.mapM String.toNat?
  return values.toArray

/-- A deliberately conservative limit for an exhaustive, full-cost checker.
    This is an operational guard, not a theorem about algorithmic complexity. -/
def maxCities : Nat := 32

/-- Turn an external UTF-8 certificate into an intrinsically feasible tour.
    Format: count N; N whitespace-separated matrix rows; one route row.
    Only ordinary spaces are supported within rows; newline may be CRLF. -/
def parseCertificate (contents : String) : Except String Case := do
  let lines := ((contents.replace "\r" "").splitOn "\n").filter (fun s => s != "")
  let some first := lines.head? | throw "missing city count"
  let some count := first.toNat? | throw "invalid city count"
  if count == 0 then throw "city count must be positive"
  if count > maxCities then throw "city count exceeds the demonstrator limit (32)"
  if lines.length != count + 2 then
    throw "expected N matrix rows followed by exactly one tour row"
  let matrixLines := (lines.drop 1).take count
  let some parsedRows := matrixLines.mapM parseNumbers |
    throw "matrix contains a non-natural value"
  let rows := parsedRows.toArray
  if rows.size != count || !(rows.all (fun row => row.size == count)) then
    throw "distance matrix must be N by N"
  let some tourLine := (lines.drop (count + 1)).head? |
    throw "missing route row"
  let some rawTour := parseNumbers tourLine | throw "route contains a non-natural value"
  let n := count - 1
  let some tour := decodeTour n rawTour |
    throw "tour is not a permutation of 0 .. N-1"
  let inst : Instance n := {
    distance := fun src dst =>
      match rows[src.val]? with
      | none => 0
      | some row => (row[dst.val]?).getD 0
  }
  return { n := n, instanceData := inst, tour := tour }

/-- The certificate verdict is computed *only* by the checked Lean theorem's
    Boolean precondition, on data decoded by this module. -/
def verify (c : Case) : Bool :=
  checkLocalOptimum c.instanceData c.tour

/-- Successful verification entails every 2-opt interval inequality.
    This theorem reuses the soundness theorem of the v0.9 checker. -/
theorem verify_sound (c : Case) (h : verify c = true)
    (lo hi : Fin (c.n + 1)) (hOrder : lo.val ≤ hi.val) :
    tourCost c.instanceData c.tour ≤
      tourCost c.instanceData (twoOpt c.tour ⟨lo, hi, hOrder⟩) := by
  exact checkLocalOptimum_sound c.instanceData c.tour h lo hi hOrder

/-- The text-to-verdict path used by the CLI, with malformed inputs rejected. -/
def verifyText (contents : String) : Except String Bool :=
  (parseCertificate contents).map verify

/-- End-to-end theorem: the *decoded text*, when accepted, has no
    strictly improving reversal in the fully enumerated neighborhood. -/
theorem verifyText_accepted_sound (contents : String) (c : Case)
    (hParsed : parseCertificate contents = .ok c)
    (hAccepted : verifyText contents = .ok true)
    (lo hi : Fin (c.n + 1)) (hOrder : lo.val ≤ hi.val) :
    tourCost c.instanceData c.tour ≤
      tourCost c.instanceData (twoOpt c.tour ⟨lo, hi, hOrder⟩) := by
  have hv : verify c = true := by
    simp only [verifyText, hParsed] at hAccepted
    change (Except.ok (verify c) : Except String Bool) = Except.ok true at hAccepted
    injection hAccepted with hValue
  exact verify_sound c hv lo hi hOrder

end CatOpt.TSP.ExternalCertificate
