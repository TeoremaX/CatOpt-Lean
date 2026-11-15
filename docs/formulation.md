# Mathematical formulation and design choice

## 0. Scientific evaluation

The initial hypothesis `Algorithm = Accept ∘ LocalSearch ∘ Shake` is
**too weak if every operator is an arbitrary endomorphism `S → S`**. Any
algorithm is a function and functions compose. Neither the existence of a
category nor the use of function composition establishes an interesting
mathematical result. More importantly, a unary `Accept : S → S` cannot in
general compare the newly proposed solution with a discarded incumbent.

The project becomes more useful when a composition is simultaneously:

1. **Feasibility-preserving:** invalid solutions cannot appear at the boundary
   of a certified primitive;
2. **Protocol-typed:** constructing a candidate, improving it and accepting it
   are separate phases;
3. **Property-bearing:** theorem statements track the incumbent even when
   perturbations increase candidate cost;
4. **Interpretable:** syntax maps to an actual semantic category;
5. **Executable:** concrete operators can be supplied without reproving the
   generic structural theorem.

The categorical structure is justified as a *common language of composition*.
It is not claimed that category theory is strictly necessary for these
individual monotonicity proofs; ordinary functions, dependent types and
induction suffice. The categorical viewpoint could become more substantive
when heterogeneous state spaces, interfaces, effects, quotient laws and
interpretation-preserving translations are investigated.

## 1. Three formulations considered

| Formulation | Benefit | Difficulty | Limitation |
|---|---|---|---|
| Endomorphism monoid on `S` | Easy executable code; simple closure laws | Low | Nearly tautological; lacks incumbent/feasibility protocol |
| Predicate-preserving category + indexed DSL **(selected)** | Feasibility proof, heterogeneous arrows, sound sequencing, meaningful acceptance theorem | Medium | Currently uses one runtime carrier for all phases; proof is structural, not convergence |
| Stochastic effect category (Kleisli of a suitable probability monad / Markov kernels) | Honest mathematical treatment of randomized algorithms | High | Requires choice of finite measures / distributions, laws and potentially expectations; not needed for the first deliverable |

**Selection:** a predicate-preserving category supports independent
certification and composition; the indexed DSL prevents illegal phase
transitions. Seeded pseudo-random algorithms can be added without incorrectly
calling seeded deterministic functions Markov kernels.

## 2. Objects and arrows

A *space* is a pair `X = (|X|, F_X)` where `F_X : |X| → Prop` is a predicate.
A morphism `f : X → Y` has underlying total function `|f| : |X| → |Y|` and
a witness

```
∀ x : |X|, F_X(x) → F_Y(f(x)).
```

The identity maps `x ↦ x`. For `f : X → Y` and `g : Y → Z`,

```
(g ∘ f)(x) = g(f(x)).
```

Preservation follows from two applications of the morphism proof. Equality
of morphisms is extensional equality of their functions (the proof fields
are propositions and proof-irrelevant). Associativity and both unit axioms
are proved and packaged as Mathlib's `CategoryTheory.Category`.

Objects are *not algorithms* here. Objects are spaces with invariants;
morphisms are state transformations. They may map between different types.

## 3. Optimization operators and objective

A `Problem` holds `State`, `feasible : State → Prop` and
`cost : State → Nat`. A typed operator for this problem is an endomorphism of
its feasible-state object. The separate predicate

```
NonWorsening(P,f) := ∀ x, feasible(x) → cost(f(x)) ≤ cost(x)
```

is not a prerequisite for being an arrow: `Shake` or random mutation would
often violate it. Two certified non-worsening arrows compose to a certified
non-worsening arrow. The same holds under any finite number of iterations.

## 4. Incumbents and candidates

A search state carries

```
(incumbent, candidate, feasible(incumbent), feasible(candidate)).
```

Operators have intentionally different effects:

- `construct`, `shake`, `destroyRepair`: compute a new candidate from the
  incumbent, but leave the incumbent unchanged;
- `localSearch`: change only the candidate;
- `accept`: replace both tracks with the better of the two states.

Tie handling is deterministic: accept the candidate on equality. Because the
objective is `Nat`, selecting the lower-cost solution is decidable.

Consequently, for any feasible `p` and `d`,

```
cost(incumbent(accept(localSearch_d(shake_p(state)))))
  ≤ cost(incumbent(state)).
```

No theorem asserts that the candidate is improved by a perturbation, that a
randomized algorithm converges, or that local minima are globally optimal.

## 5. Typed syntax and semantics

Let `Obj` be a type of syntactic objects and `Edge a b` the primitive
arrows declared in a signature. Define syntax by:

```
Program.skip                  : Program a a
Program.atom (e : Edge a b)   : Program a b
Program.seq p q              : Program a c
     where p : Program a b and q : Program b c
```

The result is an **indexed syntax tree**. Distinct trees encode different
parenthesizations: `seq (seq p q) r` is not literally the same syntax as
`seq p (seq q r)`.

Given a semantic category `C`, an object map `Obj → C` and an assignment
of primitive arrows to corresponding arrows of `C`, the interpretation is:

```
⟦skip⟧ = id
⟦atom(e)⟧ = interpret(e)
⟦seq(p,q)⟧ = ⟦p⟧ ≫ ⟦q⟧
```

Theorems establish that `⟦(p ≫ q) ≫ r⟧ = ⟦p ≫ (q ≫ r)⟧` and that
left/right syntactic units have equal denotations. If we take the quotient of
syntax by these equations, we can obtain the corresponding free category,
and the interpretation extends to a genuine functor out of that quotient.
**The quotient and resulting `Functor` record are not yet constructed.**

For the search DSL, objects are `ready`, `candidate`, `improved`. Generators
allow exactly the five well-typed transitions defined in
`CatOpt/DSL/Search.lean`. Each stage is interpreted as a feasible, proof-
carrying search-state type; a generic `Interpretation` maps each generator
into a morphism of the predicate-preserving category. `denote_run` expresses
agreement with the executable interpreter.

## 6. Structural soundness theorem

Each primitive preserves incumbent quality or leaves the incumbent
unchanged. Composition respects this relation by transitivity of `≤`.
Induction on well-typed `Program` gives:

```
∀ (p : SearchProgram a b) (s : SearchState P),
 cost ((run impl p s).incumbent) ≤ cost (s.incumbent).
```

This statement is **parametric** in all implementations of `construct`,
`shake`, `destroyRepair`, and `localSearch`, provided they preserve feasibility.
This parametrization is the main nontrivial educational contribution compared
to showing the two-line theorem that composition of two decreasing functions
is decreasing.

The proof, though useful, depends critically on elitist acceptance. If one
changes the semantics of `accept` to allow a worse incumbent (as often done
in simulated annealing), the theorem is false. The framework should use
more general contracts for such algorithms, rather than hiding the problem.
