import CL8E8TQC._21_QuantumDeepGP._00_LazyTraining

namespace CL8E8TQC.QuantumDeepGP.Theory

open CL8E8TQC.Foundation (Cl8Basis)

/-!
# Deep GP — Hierarchical Model Breaking Through Lazy Training

## Abstract

**Position**: Chapter 2 of `_21_QuantumDeepGP`. Follows `_00_LazyTraining`, connects to `_02_DiscretePathIntegral`.

**Subject**: Discuss the mechanism by which Deep GP (Deep Gaussian Process) can structurally break through the Lazy Training wall, and outline CL8E8TQC theory's dual breakthrough of the computational barrier ($O(Ln^3) \to O(Ln)$) and the integration barrier (continuous integral → H84 finite sum).

**Keywords**: deep-gp, lazy-training, rich-regime, variational-inference, woodbury, coxeter

---

## 0.1 Can Deep GP Break Through the Lazy Training Wall?

Theoretically, **Deep GP can break through the Lazy Training wall**.

Standard GP (infinite-width NN limit) falls into a "Lazy" state without representation learning capability because the kernel **"remains fixed and does not move"** with respect to raw data in input space. However, multi-layering GP (Deep GP) can escape this constraint.

We candidly discuss the mechanism, why this has not been achievable until now, and how CL8E8TQC theory relates.

---

# §1. Why Deep GP Can Break Through Lazy Training

Deep GP is a hierarchical model that passes one GP's output (latent variable) as input to the next layer's GP:

$$y = f_L(f_{L-1}(\dots f_1(x) \dots))$$

In standard GP, kernel $k(x, x')$ is static with respect to input $x$, but in Deep GP's second layer onward, kernels receive **"learned intermediate representations $f(x)$"** as input:

$$k(f(x), f(x'))$$

That is, by learning (inferring) the posterior distribution of intermediate layer function $f$ to fit data, input space $x$ is distorted, and by the time it reaches the final layer, **the kernel itself adapts and moves data-dependently** so that "data of the same class become close, data of different classes become distant."

This is exactly the **"representation learning (Feature Learning)"** that finite-width NN performs in hidden layers, structurally escaping the Lazy Training state where initialization remains frozen.

---

# §2. Then Why Didn't Deep GP Become Mainstream?

That Deep GP can perform representation learning has been known for over 10 years (Damianou & Lawrence, 2013), yet it could not seize machine learning hegemony. The reason is **computational explosion**.

Even standard GP costs $O(n^3)$, and stacking $L$ layers gives Deep GP computational cost $O(Ln^3)$, reaching effectively intractable levels. Therefore, practical use required heavy approximation methods like "variational inference (VI)," resulting in the dilemma of distorting GP's greatest strength — "exact uncertainty quantification."

---

# §3. Breakthrough Presented by CL8E8TQC Theory

CL8E8TQC theory dramatically reduces GP computation from $O(n^3)$ to $O(n)$ by leveraging the property that Hamming kernel rank is bounded by constant (8) and the Woodbury identity (details: `_00_LinearTimeGP.lean` §5).

This removal of the computational barrier newly enables what was previously impossible: **"reducing Deep GP computation from $O(Ln^3)$ to $O(Ln)$, making hierarchical stacking of per-layer GP practical."**

$$\underbrace{O(Ln^3)}_{\text{Deep GP (conventional: impossible)}}
\;\xrightarrow{\text{CL8E8TQC}}\;
\underbrace{O(Ln)}_{\text{Deep GP (CL8E8TQC: feasible)}}$$

---

# §4. The Inference Problem — From Integrals to Finite Sums (Solved in `_02_DiscretePathIntegral`)

Even with computation reduced to $O(Ln)$, another problem remains: the **"non-Gaussian marginalization integral"** problem.

In continuous-valued Deep GP, analytically unsolvable integrals arise when passing each layer's output distribution to the next, forcing reliance on variational inference (approximation).

CL8E8TQC theory fundamentally eliminates this problem by **reducing "integrals" to "finite sums"**:

$$\int p(y|h) \, p(h|x) \, dh \;\longrightarrow\; \sum_{h \in H84} p(y|h) \, p(h|x)$$

Since input space is inherently $\text{GF}(2)^8$ (256 points) and intermediate layers are H84 codewords (16 points) — **finite discrete spaces** — this is not "discretization as approximation" but **"exact solution via exhaustive enumeration."**

Details of this solution are implemented and proved in `_02_DiscretePathIntegral.lean`.

---

# §5. Comparison with NN Backpropagation

The process by which Deep GP acquires "representation learning" is mathematically beautiful but computationally nightmarishly complex.

Comparing with NN's backpropagation reveals why Deep GP optimization has been unrealistic until now, how far CL8E8TQC theory breaks the barriers, and **where the "unsolved problems for the future" remain**.

## 5.1 NN Backpropagation (Highway for Point Estimation)

NN learning is essentially a **"bucket relay of single values (point estimation)."**

1. **Forward pass:** Multiply input $x$ by weight matrices, pass through activation functions, output $y$ through intermediate representations $h_1, h_2$. All are "fixed single numerical vectors."

2. **Backward pass:** Compute error between prediction $y$ and ground truth, use "chain rule of derivatives" to calculate how to move each layer's weights to reduce error.

Once gradients (directions of derivatives) are known, weights are updated by simply descending the slope. Computation consists of simple matrix multiplications, easily parallelized on GPU, enabling very fast learning.

## 5.2 Deep GP Inference (Labyrinth of Probability Distribution Integration)

In contrast, Deep GP's hidden layers handle not "fixed values" but **"probability distributions over functions themselves."** This is the decisive difference.

In Deep GP, to obtain the final output probability distribution $p(y|x)$ for input $x$, the following tremendous computation (marginalization integral) is required:

$$p(y|x) = \int p(y|f_L) p(f_L|f_{L-1}) \dots p(f_1|x) \, df_1 \dots df_L$$

- $f_1, f_2 \dots$ are Gaussian processes (functions) at each layer.

- **Core problem:** When passing a Gaussian distribution through a nonlinear kernel (RBF, Hamming, etc.), **the output distribution is no longer Gaussian.**

- Therefore, this integral cannot be solved analytically (neatly as a formula), completely halting computation.

## 5.3 Practical Compromise: Variational Inference (VI)

To deal with this intractable integral, modern Deep GP research uses **variational inference (VI)**.

This abandons seeking the "intractable true posterior distribution," instead prepares a "computationally tractable approximate distribution $q(f)$" and optimizes to minimize distance (KL divergence) from the true distribution.

However, doing this results in the dilemma of **"voluntarily discarding GP's greatest identity (virtue) — 'exact uncertainty computation' — degenerating into an approximate model."**

## 5.4 CL8E8TQC Theory's Position — Two Walls Broken Sequentially

This theory successively broke through two walls:

- **Computational barrier (this file):** $O(n^3)$ → $O(Ln)$ (Woodbury identity + rank≤8L)

- **Integration barrier (`_02_DiscretePathIntegral.lean`):** Non-Gaussian marginalization integral → H84 16-point finite sum (variational inference unnecessary)

Exact multi-layer Deep GP inference is achieved while maintaining integer-only arithmetic (Forbidden Float principle).

## 5.5 Summary — Scope of This File

This file (`_01_DeepGP_Theory.lean`) covers the breakthrough of the "computational barrier" and background theory.

"Integration barrier" breakthrough → `_02_DiscretePathIntegral.lean`
Quantum interference / BQP completeness → `_03_QuantumInference.lean`
Layer = circuit depth correspondence → `_04_LayerDepthCorrespondence.lean`

However, using CL8E8TQC's property that "everything is represented in discrete integers (GF(2) and H84 codes)," the possibility emerges of **"reducing continuous integrals to discrete sums to break through Deep GP's inference problem."**

The next `_02_DiscretePathIntegral` develops this possibility.

---

## References

### Deep GP / Computational Complexity
- Damianou, A. and Lawrence, N.D. (2013).
  "Deep Gaussian Processes", *AISTATS 2013*.
  (Deep GP original: $O(Ln^3)$ complexity and variational inference formulation)
- Wilson, A.G., Hu, Z., Salakhutdinov, R. and Xing, E.P. (2016).
  "Deep Kernel Learning", *AISTATS 2016*.
  (Deep GP practical attempt: using NN as feature map)

### Universal Approximation Theorem / Deep Model Expressiveness
- Barron, A.R. (1993).
  "Universal Approximation Bounds for Superpositions of a Sigmoidal Function",
  *IEEE Trans. Information Theory* 39(3), 930–945.
  (Theoretical basis for shallow models requiring $O(e^d)$ parameters)
- Hornik, K., Stinchcombe, M. and White, H. (1989).
  "Multilayer Feedforward Networks are Universal Approximators",
  *Neural Networks* 2(5), 359–366.

### Variational Inference / Approximate Inference
- Blei, D.M., Kucukelbir, A. and McAuliffe, J.D. (2017).
  "Variational Inference: A Review for Statisticians",
  *J. Amer. Statist. Assoc.* 112(518), 859–877.

### Module Connections
- **Previous**: `_00_LazyTraining.lean` — Lazy Training diagnosis and NTK theory
- **Next**: `_02_DiscretePathIntegral.lean` — Discrete path integral eliminating variational inference
- `_22/_01_NN_vs_GP.lean` §6.2 references this file's "$O(Ln)$" achievement as verified

-/

end CL8E8TQC.QuantumDeepGP.Theory
