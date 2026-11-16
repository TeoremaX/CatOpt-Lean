# Related work and originality boundaries

This is a **research positioning note**, not a systematic review or a novelty
certificate. Existing work is substantial in categorical learning and in
automated heuristic design.

## Closest conceptual touchstones

**Fong, Spivak, Tuyéras (2019), Backprop as Functor.** Compositional training
updates associated with parametrized functions and a monoidal functor show
what a substantial categorical result looks like: compositionality is not
merely asserted, but an interesting transformation is proved to preserve
structure. We borrow the standard of rigor, **not** their functor or a
backpropagation theorem. Source: https://arxiv.org/abs/1711.10455

**Gavranović (2024), Fundamental Components of Deep Learning.** The thesis
combines parametric maps, optics and compositional learning architectures.
Those notions are interesting future connections but no weighted optics or
parametric network theory are implemented in CatOpt. Source:
https://arxiv.org/abs/2403.13001

**Gavranović et al. (2024), Categorical Deep Learning is an Algebraic Theory
of All Architectures.** A framework for network architecture constraints
and implementations, not an existing proof of CatOpt's metaheuristic
semantics. The broader methodological goal of linking syntax and meaning is
relevant; importing its monad-algebraic machinery now would be unjustified.
Source: https://proceedings.mlr.press/v235/gavranovic24a.html

**Shiebler (2021), Generalized Optimization.** Categorically generalized
derivative-based optimization and transformed invariances, rather than the
combinatorial local-search grammar formalized here. It is a closely related
use of category theory in optimization, so a novelty claim cannot ignore it.
Source: https://arxiv.org/abs/2109.10262

## Adjacent literatures that must be searched before a paper submission

- *Hyper-heuristics*, selection and generation of low-level heuristics;
- *Automatic algorithm configuration / automated algorithm design*;
- *Grammar-guided algorithm generation* and strongly typed genetic programming;
- Formal verification of iterative optimizers and algorithm invariants;
- Categorical semantics of effectful programs / state and probability monads;
- Combinatorial optimization using verified data structures and permutation proofs.

Initial keywords: `grammar based hyper heuristic`, `typed combinatorial
optimization DSL`, `evolutionary algorithm composition`, `Lean verified
optimization`, `formal verification stochastic local search`, `categorical
semantics algorithms`.

## Potentially original direction (not yet a result)

A **contract-aware, heterogeneous algebra of optimization components** whose
generator types and graded effect contracts allow an automated synthesizer to
construct *only semantically admissible pipelines*. The key question is not
whether random compositions exist but whether the contract system can:

1. eliminate incompatible pipelines *before execution*;
2. derive nontrivial guarantees on expected progress, feasibility or
   resource usage;
3. safely rewrite programs using proved equivalences, then optimize the
   resulting search space of algorithms;
4. demonstrate an empirical advantage in statistically sound benchmarks.

An especially interesting route would label arrows with resource/effect
information and track non-elitist acceptance with a weaker, compositional
contract (e.g., expected potential or a lower bound on improvement
probability). None is in the current proof set.

## Claims we cannot make today

- No claim of the first categorical treatment of optimization or of
  metaheuristics;
- No claim that category theory itself improves solution quality;
- No claim of a new optimization algorithm from typed composition;
- No claim of novelty relative to full hyper-heuristic literature;
- No claim of correctness of unverified Python algorithms *from* Lean;
- No claim of global convergence, polynomial complexity or optimality.

## Explicit comparison with grammar-based automatic design (v0.2 review)

The literature already includes finite grammars that produce metaheuristics,
so **typed enumeration itself is not an originality claim**:

- Mascia et al., *Grammar-based generation of stochastic local search
  heuristics through automatic algorithm configuration tools*, Computers &
  Operations Research 51 (2014), 190–199,
  https://doi.org/10.1016/j.cor.2014.05.020
- Pagnozzi & Stützle, *Evaluating the impact of grammar complexity in
  automatic algorithm design*, International Transactions in Operational
  Research (2020), https://doi.org/10.1111/itor.12902
- *On the automatic generation of metaheuristic algorithms for combinatorial
  optimization problems*, European Journal of Operational Research 318(3)
  (2024), https://doi.org/10.1016/j.ejor.2024.06.001

The latter explicitly describes an **implicit grammar driven by component
requirements/contracts**, so neither the use of contracts to permit component
substitution nor grammar generation alone is new. CatOpt-Lean v0.2 instead
studies a very small **proof-assistant-checked semantics**: stage safety,
feasibility carried in the primitive interface, formal incumbent-monotonicity,
and a proof that *user-declared estimated* work stays under budget. The
incremental result is educational; a research contribution would need stronger
verified cost/refinement theorems or substantive empirical benefits.
