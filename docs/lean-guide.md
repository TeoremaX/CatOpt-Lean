# Lean 4 walkthrough for CatOpt

Start with `CatOpt/Basic.lean`, then proceed to `Category`, `Operators`,
`Properties`, `DSL/Syntax`, `DSL/Semantics`, and `DSL/Search`.

## Defining data types

```lean
structure Problem where
  State : Type
  feasible : State → Prop
  cost : State → Nat
```

The expression `State → Prop` is a predicate. The `SearchState` fields
`incumbent_ok` and `candidate_ok` have types `P.feasible incumbent` and
`P.feasible candidate`: they are *proofs*, not Booleans.

## `def`, `theorem` and `by`

- `def` introduces a mathematical/programming definition.
- `theorem` introduces a proposition and a proof term.
- `by` enters tactic mode, providing a readable sequence of proof steps.
- `intro x hx` introduces variables/hypotheses from a universally
  quantified or implicative goal.
- `exact h` supplies a term of precisely the expected type.
- `apply h` reduces a goal using a theorem whose conclusion matches it.
- `rfl` establishes definitional equality.
- `funext x` reduces equality of functions to pointwise equality.
- `le_trans` chains `a ≤ b` and `b ≤ c`.
- `induction n` is natural-number induction; `induction program` is
  structural induction on a typed AST.

## Category theory API

`SafeHom` contains a function and a proof of feasibility preservation.
`SafeHom.compose f g` means **first** `f`, **then** `g`. This matches
Mathlib's `f ≫ g`, which denotes `g ∘ f` in ordinary function notation.

The `CategoryTheory.Category` instance has to supply *three axioms* in
addition to identity and composition: `id_comp`, `comp_id`, `assoc`.
They use extensionality because distinct proofs of the same proposition do
not distinguish morphisms.

## Why types matter in the DSL

The constructor

```lean
| localSearch : Action .candidate .improved
```

means a local-search step can only appear after a primitive returning a
`candidate`. The constructor

```lean
| accept : Action .improved .ready
```

makes premature acceptance ill-typed. `Program.seq` only combines a program
of type `Program a b` with a program of type `Program b c`.

## Three proofs worth studying

1. `nonWorsening_comp`: feasibility-preserving composition transports both
   the precondition and the cost decrease.
2. `acceptBetter_monotone`: the chosen feasible incumbent has cost no
   greater than the old one, even when a candidate is worse.
3. `program_monotone`: structural induction on the *syntax* proves the
   invariant for any valid pipeline, independent of the concrete heuristics.

## Exercises

1. Prove that a finite sequence of non-worsening operators is non-worsening.
2. Write an ill-typed pipeline and inspect the compiler's type mismatch.
3. Add an action `improveAgain : Action .improved .improved` and prove its
   incumbent monotonicity.
4. Replace objective `Nat` with an arbitrary preorder carrying decidable
   comparison, then state which proofs require totality.
5. Formalize a quotient by associativity and unit laws; construct the
   actual `Functor` from the path category to `Space`.
