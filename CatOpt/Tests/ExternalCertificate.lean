import CatOpt.TSP.ExternalCertificate

namespace CatOpt.Tests.ExternalCertificate
open CatOpt.TSP.ExternalCertificate

-- The decoder rejects malformed lengths, duplicates, and unknown cities.
example : (decodeTour 3 #[0, 1, 2, 3]).isSome = true := by decide
example : (decodeTour 3 #[0, 1, 1, 3]).isNone = true := by decide
example : (decodeTour 3 #[0, 1, 2]).isNone = true := by decide
example : (decodeTour 3 #[0, 1, 2, 4]).isNone = true := by decide

-- Constructive proof transfer from the trusted Boolean checker.
example (c : Case) (hc : verify c = true)
    (lo hi : Fin (c.n + 1)) (h : lo.val ≤ hi.val) :
    CatOpt.TSP.tourCost c.instanceData c.tour ≤
      CatOpt.TSP.tourCost c.instanceData
        (CatOpt.TSP.twoOpt c.tour ⟨lo, hi, h⟩) :=
  verify_sound c hc lo hi h

end CatOpt.Tests.ExternalCertificate
