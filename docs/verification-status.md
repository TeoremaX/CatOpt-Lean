# Verification status (updated for v0.10)

- **v0.9: user-confirmed** `lake build` succeeded (17,369 jobs), full demo
  executed, Python tests passed, three local commits, clean tree; branch pushed
  to GitHub (`feat/proof-carrying-local-optimum-v09`).
- **v0.10: not yet Lean-compiled**. The external decoder, interface and
  soundness theorem are new. The user's pinned Lean 4.32.0 compiler must
  accept them before claims of a verified software release.
- Python format/reference tests are independent and do not verify Lean's CLI.
- The v0.10 integration script exercises accepted, rejected, malformed and
  Windows-style CRLF certificates; its execution requires the Lean toolchain.
- The certificate asserts local minimality only over inclusive two-opt
  reversals, with no assertion of global TSP optimality.
- Publication of a code branch is not equivalent to scientific novelty
  or a peer-reviewed publication.
