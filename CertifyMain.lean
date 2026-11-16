import CatOpt.TSP.ExternalCertificate

/-! Read an untrusted external TSP certificate and check it in Lean.
Exit codes: 0 accepted, 1 feasible but not 2-opt locally minimal,
2 malformed input or incorrect CLI usage. -/

def main (args : List String) : IO UInt32 := do
  let [path] := args | do
    IO.eprintln "Usage: lake exe catopt-certify <certificate.txt>"
    return 2
  let contents ← IO.FS.readFile path
  match CatOpt.TSP.ExternalCertificate.parseCertificate contents with
  | .error message =>
      IO.eprintln s!"INVALID: {message}"
      return 2
  | .ok c =>
      let cost := CatOpt.TSP.tourCost c.instanceData c.tour
      if CatOpt.TSP.ExternalCertificate.verify c then
        IO.println s!"ACCEPTED: N={c.n + 1}; cost={cost}; all finite 2-opt segment reversals checked"
        return 0
      else
        IO.println s!"REJECTED: N={c.n + 1}; cost={cost}; an improving 2-opt segment exists"
        return 1
