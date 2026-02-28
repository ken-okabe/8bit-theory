import CL8E8TQC._20_FTQC_GP_ML._04_ActiveLearning

namespace CL8E8TQC.QuantumDeepGP.LazyTraining

/-!
# Quantum Deep Gaussian Processes via Topological Quantum Computation

## Abstract

Infinite-width neural networks (NN) become equivalent to Gaussian processes (GP) (Neal 1996, Jacot et al. 2018 NTK theory), but at this limit the kernel freezes to its initial value, causing "Lazy Training" where representation learning capability is lost. This module first rigorously diagnoses, based on NTK theory, that CL8E8TQC's $O(n)$ exact GP belongs to the Lazy Regime (static kernel model), acknowledges this constraint, and then presents two complementary strategies. First, exact uncertainty enables Active Learning that transforms Lazy from a lack of expressiveness into a search efficiency advantage. Second, breaking through the $O(n^3)$ computational barrier to $O(n)$ makes Deep GP (representation learning via multi-layering) feasible at realistic computational cost for the first time, opening the path from Lazy Training to Rich Regime. Subsequent modules `_01`–`_04` fully develop this Quantum Deep GP.

## 1. Introduction

The equivalence theorem "infinite-width NN = GP" was proved by Neal (1996) for 1 hidden layer and extended to arbitrary depth by Jacot et al. (2018). This theorem means that even when training an infinite-width NN, the Neural Tangent Kernel $\Theta_t(x,x') = \nabla_\theta f(x;\theta_t)^T \nabla_\theta f(x';\theta_t)$ does not change from initialization ($\Theta_t \approx \Theta_0$). Individual parameters move only $O(1/\sqrt{m})$, and since no feature space distortion occurs, the network cannot rewrite its internal representation upon seeing data — entering a "lazy training" state.

Meanwhile, in practical finite-width NNs (ResNet, Transformer, etc.), parameters move significantly because width is finite, and $\Theta_t$ changes dramatically in response to data — entering the "Rich Regime (representation learning regime)." This is the fundamental reason infinite-width GP is inferior to finite-width NN in practical performance. CL8E8TQC single-layer GP has computational superiority with $O(n)$ exact inference, but since kernel $k(x,y)$ is a fixed static model, it is classified in the Lazy Regime.

The Quantum Deep GP presented in this module constructs an effective kernel via multi-layering: $k_{\text{eff}}^{(L)}(x,y) = \sum_{\vec{h} \in H84^L} \prod_{l=0}^{L} k(h_l, h_{l+1})$, achieving $\partial k_{\text{eff}}^{(L)} / \partial x \neq 0$. This corresponds to breaking the discrete counterpart of NTK theory's Lazy condition $\partial\Theta/\partial t = 0$, representing a structural transition to Rich Regime. The variation is in the depth direction (GP multi-layering) rather than the time direction (NN training), but the essence of acquiring input-dependent nonlinear transformations is shared.

## 2. Relationship to Prior Work

| Prior Work | Content | Relationship to This Module |
|:---|:---|:---|
| Neal (1996) *Bayesian Learning for NN* | Convergence proof: infinite-width 1-hidden-layer NN = GP | Theoretical explanation of Lazy Training's origin |
| Jacot et al. (2018) NTK | NTK extension to arbitrary depth / establishment of Lazy Training | Primary source for §5's NTK theory |
| Lee et al. (2019) | Rich/Lazy Regime discrimination criteria for finite-width NN | Criteria for CL8E8TQC GP's Lazy diagnosis |
| Damianou & Lawrence (2013) | Deep GP original / $O(Ln^3)$ complexity / variational inference | `_01` breaks through to $O(Ln^3) \to O(Ln)$ |
| `_20_FTQC_GP_ML/_04_ActiveLearning` | $O(n)$ single-layer GP / function identification with 9 points | Inherited as exploration strategy for Lazy GP |

## 3. Contributions of This Chapter

- **Rigorous Lazy Training diagnosis**: Explicitly identify CL8E8TQC single-layer GP as static kernel model (Lazy Regime) based on NTK theory
- **Structural path to Rich Regime**: Argument for input-dependence of effective kernel via multi-layering $\partial k_{\text{eff}}^{(L)}/\partial x \neq 0$
- **Formulation of two complementary strategies**: ①Active Learning via exact uncertainty (search optimization) ②$O(n)$ Quantum Deep GP (representation learning)
- **Formal connection between NTK theory and Quantum Deep GP**: Argument for correspondence: discrete routing ≡ Rich Regime
- **Theoretical foundation for subsequent modules `_01`–`_04`**: Lazy diagnosis is the starting point for Deep GP theory, path integrals, and BQP completeness

## 4. Chapter Structure

| Section | Title | Content |
|:---|:---|:---|
| §1 | Problem Setting | Paradox: "If infinite-width NN = GP, why is GP inferior to NN?" |
| §2 | Concept of Lazy Training | Kernel freezing / feature space stasis mechanism |
| §3 | Adaptive vs Static Kernels | Essential contrast: finite-width NN (Rich) vs infinite-width GP (Lazy) |
| §4 | Difference Between Standard GP and NNGP | Computational cost comparison: practical GP vs NTK/NNGP |
| §5 | NTK Theory | Formulation of $\Theta_t(x,x')$ / mathematical mechanism of Lazy Training |
| §6 | Lazy Diagnosis of CL8E8TQC GP | Explicit Lazy certification / two complementary strategies / formal connection to Rich Regime |

Central results are as follows:

1. **Lazy Training diagnosis** (this file):
   Analyze the kernel freezing mechanism in infinite-width NN=GP based on NTK theory, and rigorously determine that CL8E8TQC GP is a static kernel model (Lazy Regime).

2. **Deep GP theory and $O(Ln^3) \to O(Ln)$ breakthrough** (`_01`):
   Reconstruct Damianou-Lawrence (2013) Deep GP with CL8E8TQC's rank-bounded kernel, achieving $O(n)$ exact inference per layer.

3. **Elimination of variational inference via discrete path integral** (`_02`):
   Discretization to $H84$ codewords (not approximation but exact exhaustive enumeration) reduces inter-layer marginalization integral to 16-term finite sums, completely eliminating variational inference.

4. **Quantum interference and BQP structure** (`_03`):
   When GoldenGate kernel ($C^6$, Non-Clifford) is used for hidden layer transitions, positive-negative mixed interference (discrete manifestation of quantum interference) emerges between paths, and the inference computation is proved as theorem to belong to BQP class.

5. **Layer = quantum depth equation** (`_04`):
   Show that Quantum Deep GP layers and TQC circuit depth reduce to the same Fusion+Braiding operations, deriving the equation $\text{Quantum Deep GP} \equiv \text{TQC}$.

**Keywords**: quantum-deep-gp, lazy-training, ntk, deep-gp, variational-inference, forbidden-float, h84-codeword, golden-gate, bqp, topological-quantum-computation

## Prerequisites — Established Theoretical Foundations Inherited by This Module

This module `_21_QuantumDeepGP` is constructed **fully assuming and inheriting** the theoretical results of the following two preceding modules. Readers are expected to have read these before proceeding.

### Foundation 1: `_01_TQC` — Cl(8) Algebra and Topological Quantum Computation

| File | Established Result |
|:---|:---|
| `_01_Cl8E8H84` | Cl(8) algebra's 256 bases, $H(8,4)$ code's 16 codewords, `geometricProduct`'s XOR+sign operation |
| `_02_PinSpin` | Pin/Spin groups, spinor reflection `reflect` constructive implementation |
| `_03_QuantumState` | 256-dimensional integer-valued discrete wavefunction `QuantumState`, interference Level 1 (positive-negative coexistence of amplitude components) |
| `_04_TQC_Universality` | GoldenGate $C^6$ (Non-Clifford, order 5) quantum computational universality, BPP→BQP |
| `_05_FTQC` | Norm preservation over 100-stage gate application (zero-error FTQC) |

### Foundation 2: `_20_FTQC_GP_ML` — $O(n)$ Exact Gaussian Process

| File | Established Result |
|:---|:---|
| `_00_LinearTimeGP` | $O(n)$ exact GP inference via Hamming kernel (rank $\le$ 8), Bareiss algorithm, `featureMap`, `e8Kernel` |
| `_01_KernelCatalog` | Systematic catalog of E8 kernel family, grade-wise kernel properties |
| `_02_DrugDiscovery_GP` | Concrete application to drug discovery, comparison with Tanimoto similarity |
| `_03_MultiE8_GP` | Multi-E8 kernel composition method |
| `_04_ActiveLearning` | Active learning based on exact uncertainty, function identification with 9 points |

### Subsequent to This Module: `_22_ExactDeepBayesianOptimization`

The Quantum Deep GP established in this module is applied and extended in:

| File | Application of This Module's Results |
|:---|:---|
| `_22/_00_ExactDeepBO` | Integrates Deep Feature Map with Woodbury reduction to achieve exact Deep BO |
| `_22/_01_NN_vs_GP` | Uses Lazy Training diagnosis (this file §6) as foundation for complete GP vs NN comparison |

### Logical Structure of Inheritance

$$\underbrace{\text{Cl(8), H84, GoldenGate}}_{\text{\_00\_TQC}}
\;\xrightarrow{\text{kernel construction}}\;
\underbrace{O(n)\text{ exact GP}}_{\text{\_20\_FTQC\_GP\_ML}}
\;\xrightarrow{\text{multi-layering}}\;
\underbrace{\text{Quantum Deep GP}}_{\text{\_21\_QuantumDeepGP (this module)}}$$

What this module newly introduces is the theory of **multi-layering** (Deep-ification). Specifically:

- Stack the **$O(n)$ single-layer GP** established in `_20` into multiple layers
- Use `_20`'s `e8Kernel` (Hamming) and `_01_TQC`'s `goldenKernel` (GoldenGate) as **inter-layer transition kernels**
- Analyze **inter-path interference** (a new phenomenon absent in single-layer GP) that emerges with multi-layering, and discuss connection to computational complexity class BQP

---

# §1. Problem Setting — If Infinite-Width NN Equals GP, Why Is GP Inferior to NN?

Infinite-dimensional (infinite-width) neural networks (NN) become Gaussian processes (GP). GP is the computationally expensive superstructure of NN, and there appears to be no reason for inferiority.

**"A neural network with infinitely many hidden layer units (infinite-width NN) becomes mathematically equivalent to a Gaussian process (GP)"** — this is a fact fully proven since Radford Neal's 1996 proof, through recent **Neural Tangent Kernel (NTK)** and **NNGP (Neural Network Gaussian Process)** theories.

Neal (1996) proved this GP convergence for **1 hidden layer** NN, and Jacot et al. (2018)'s NTK theory provided extension to **arbitrary depth**. Below, we distinguish these two results.

"Since infinite-width NN = GP, GP is a strictly superior superset that includes NN; there should be no inferiority" — this logic is theoretically entirely correct.

Then why does the paradox arise: "In real machine learning tasks (images, language, etc.), GP (infinite-width NN) is inferior to the finite-width NN we normally use?"

**The moment you take width to infinity to become GP, NN's greatest weapon — "Feature Learning" capability — dies.**

---

# §2. What Happens When Going Infinite-Width (GP): "Lazy Training"

The NN we normally use (finite-width), as training progresses, significantly changes layer weights and acquires optimal representations by distorting "the feature space itself" to fit data (representation learning).

However, when theoretically taking NN width to infinity, a surprising phenomenon occurs.

Each neuron's weight change becomes infinitesimal, and **"from the point of initialization, the feature space (kernel) does not move at all even as training progresses."**

In deep learning theory, this state is called **"Lazy Training (Lazy Learning Regime)."**

Infinite-width NN (= GP) appears to be learning parameters, but in reality degenerates into mere linear regression (kernel method) using "a fixed kernel (NTK or NNGP kernel) determined at initialization."

---

# §3. "Adaptive Kernel" vs "Static Kernel"

Here lies the true identity of GP's "structural inferiority" to NN.

**Finite-width NN (real NN):**

While observing data, **dynamically (adaptively)** rewrites internal feature representations (kernel). For images: hierarchically learns features from edges to cat ear shapes.

**Infinite-width NN (= GP / NNGP / NTK):**

Mathematically a superior structure with enormous computation, but the kernel is **static (fixed)**. No matter how much data is given, it must fight with only "the geometric prior knowledge inherent in the initial network structure" and cannot optimize feature representations to fit data.

---

# §4. Difference Between Standard GP and NNGP

There is another reason for "GP's inferiority" in practical terms.

The GP kernels theoretically equivalent to NN (NNGP kernel, NTK) have extremely complex formulas and astronomical computational cost, so in practice one must approximate the computation or run only on small datasets.

Therefore, models generally used as "GP" employ **simple general-purpose kernels** like RBF or Matérn kernels that depend only on Euclidean distance between data. Without powerful structures (inductive biases) like "locality" and "ordering" found in CNNs and Transformers, they cannot compete with complex data like raw images.

## Summary

GP is undoubtedly the superstructure that is the "infinite-width limit" of NN. However, **as the price of taking the infinite limit, it loses "the ability to dynamically learn representations" and becomes a fixed kernel**, so for complex real data, it loses in performance to NN that deliberately stays "finite" to perform feature learning.

The moment it obtains "the strongest spear" of infinity, it no longer needs to move and becomes "just a fixed mirror (GP)." This is the fundamental reason infinite-width NN (GP) is inferior in performance to finite-width NN on real tasks.

---

# §5. NTK (Neural Tangent Kernel) Theory — Mathematical Mechanism Elucidation

We enter the world of "NTK theory" — one of the most beautiful yet counter-intuitive theories in deep learning.

We unravel through mathematical dynamics the paradox: "Why does infinitely increasing parameters (width) cause learning to become lazy?"

## 5.1 Formulating NN Learning as a "Kernel"

Let $f(x; \theta)$ be the NN output for input $x$ ($\theta$ denotes all parameters: weights, biases, etc.).

As parameters $\theta$ are updated over time $t$ through learning (gradient descent), the output $f(x; \theta)$ changes accordingly. The **NTK (Neural Tangent Kernel)** is the following kernel function describing "how easily the output changes":

$$\Theta_t(x, x') = \nabla_\theta f(x; \theta_t)^T \nabla_\theta f(x'; \theta_t)$$

This formula represents "when parameters are moved to correct error at data $x'$, how much the prediction at different data $x$ is pulled along."

In other words, **$\Theta_t(x, x')$ is the NN's "current way of perceiving feature space (measuring similarity between data)" itself.**

## 5.2 Infinite-Width Limit: Emergence of Lazy Training

Here is the crux. Take the hidden layer width (number of neurons) $m$ to infinity ($m \to \infty$).

With appropriate initialization (scaling weights by $1/\sqrt{m}$, etc.) to prevent NN output from diverging, a surprising phenomenon occurs.

Because width is infinite, to bring the loss function to zero (complete training), **individual parameters $\theta$ need to move only slightly ($O(1/\sqrt{m})$).** An infinite accumulation of tiny effects.

Individual parameters barely moving from initial values means the function gradient $\nabla_\theta f$ also doesn't change from the initial state. Consequently, the kernel during training $\Theta_t$ becomes frozen at the initialization-time kernel $\Theta_0$.

$$\Theta_t(x, x') \approx \Theta_0(x, x') \quad (\text{for all } t)$$

This is the true identity of **"Lazy Training."** Infinite-width NN (= GP) appears to learn parameters, but is actually "just performing linear regression (kernel method) using the fixed kernel $\Theta_0$ that happened to form at initialization." It completely abandons distorting feature space to fit data (learning representations).

## 5.3 Real NN (Finite-Width): The Power of Feature Learning

Meanwhile, what happens in actually used finite-width NNs (ResNet, Transformer, etc.)?

Since width $m$ is finite, **individual parameters must move significantly (macroscopically)** to reduce loss. When parameters $\theta$ move significantly, naturally the kernel $\Theta_t$ changes dramatically over time.

1. **Early training:** Kernel $\Theta_0$ is random, measuring meaningless similarity.

2. **Training progression:** Parameters move significantly to capture data features (image contours, word contexts, etc.).

3. **Late training:** Kernel $\Theta_t$ becomes optimized for data, acquiring a **powerful unique feature space** that can determine "data of the same class are similar."

In the theory community, this state is called **"Rich Regime"** or **"Feature Learning Regime"** in contrast to Lazy Training. Because width is finite, there is "need to work hard moving parameters," and as a result, intelligent feature representations are acquired.

The approach of actually measuring and confirming on a given model whether it is "lazy" or "in Rich representation learning" (measuring representation change using CKA, etc.) is also being researched.

---

# §6. Rigorous Determination of Lazy Training in CL8E8TQC GP

In this theory's discrete GP as well, the drawback of infinite-width NN — "Lazy Training (the lack of representation learning capability)" — is **structurally unavoidable and fully present**.

However, this theory's characteristic is that it does not hide this, but rather **acknowledges it as a "clear constraint (freezing)" and then attempts to complement and break through that weakness with entirely different approaches**.

## 6.1 Rigorous Determination: The Kernel Is "Frozen"

CL8E8TQC GP achieves ultra-fast, exact inference at $O(n)$, but as the cost (premise), it **retains GP's inherent property that "the kernel (how data similarity is measured) is fixed."**

In `_22/_01_NN_vs_GP.lean` §3.1 "Representation Learning: Lazy Training → Rich Regime" (citing this module's diagnostic results), the following is explicitly stated:

- "GP's greatest constraint is that kernel $k(x,y)$ is fixed a priori"

- "The E8 kernel ... is mathematically beautiful, but inductive bias is **frozen**"

- "Does CL8E8TQC solve representation learning? — **Directly, No.**"

That is, adaptive representation learning where internal feature representations (kernel) are dynamically rewritten while observing data, like NN (finite-width), **does not occur.** This state is essentially identical to the "Lazy Training" of infinite-width NN (NTK) where the initialized kernel stops moving.

## 6.2 This Theory's Response — Two Alternative Approaches

This theory uses two weapons — **"breaking the computational barrier"** and **"exact uncertainty"** — against the weakness that "the kernel does not adaptively move (is Lazy)," presenting the following alternative routes.

### ① Competing via "Search Optimization" Rather Than "Representation Learning"

While NN "rewrites the map (feature space) to fit data," this theory's GP takes the stance of "the map is fixed (Lazy), but possesses an **absolutely reliable compass (complete confidence computation)**."

As demonstrated in `_04_ActiveLearning.lean`, since near-zero-approximation exact `uncertainty` can be computed, when running Active Learning loops, it can pinpoint unexplored regions with efficiency impossible for NN (theoretically, just 9 data points for L=1 to completely identify the function).

### ② Breaking the $O(n^3)$ Wall and Opening the Path to "Quantum Deep GP"

This is the most ambitious point of this theory.

Previously, even attempting to stack GPs in layers for hierarchical representation learning like NN (Deep GP), computational complexity exploded to $O(Ln^3)$, making it practically impossible.

However, this theory succeeded in reducing GP computation to **$O(n)$** using Cl(8) algebra properties. This means **"composing multiple kernels" and "multi-layering GP (Quantum Deep GP)" — research to acquire representation learning within the GP framework — has become feasible at realistic computational cost for the first time**.

### ③ Formal Connection to NTK Theory — Discrete Routing ≡ Rich Regime

In NTK theory, the diagnostic condition for Lazy Training was $\partial \Theta_t / \partial t = 0$ (kernel is time-invariant) (see §5).

Quantum Deep GP's discrete routing can be shown to **structurally break** this condition as follows:

The single-layer CL8E8TQC GP effective kernel is $k_{\text{eff}}(x,y) = k(x,y)$, fixed (Lazy). However, the multi-layer Quantum Deep GP effective kernel is:

$$k_{\text{eff}}^{(L)}(x,y) = \sum_{\vec{h} \in H84^L}
\prod_{l=0}^{L} k(h_l, h_{l+1})$$

This composite kernel **changes nonlinearly depending on input $x$**. Specifically, when $x$ is close to H84 codeword $c_1$ versus $c_{10}$, the routing path weight distribution changes, so the effective kernel implicitly varies data-dependently.

$$\frac{\partial k_{\text{eff}}^{(L)}}{\partial x} \neq 0$$

This means the discrete counterpart of NTK theory's Lazy condition $\partial \Theta / \partial t = 0$ does not hold, providing formal basis that Quantum Deep GP's discrete routing **belongs to Rich Regime (representation learning state)**.

However, while NN's Rich Regime has "kernel changing during training," Quantum Deep GP has "kernel changing by stacking layers" — a structural difference. The former is variation in time direction, the latter in depth direction, but both share the essence of **escaping kernel fixation and acquiring input-dependent nonlinear transformations**.

## 6.3 Conclusion

This theory's discrete GP itself, viewed alone, remains a static kernel model in "Lazy Training" state.

However, this theory's true contribution is not directly fixing Lazy, but **"pulling 'quantum Deep-ification of GP (Quantum Deep GP),' which was previously untouchable due to $O(n^3)$ complexity, down onto the $O(n)$ playing field."**

This opens the path for GP-based models to acquire "representation learning (hierarchy)" rivaling NN while maintaining exact confidence.

The next `_01_DeepGP_Theory` discusses the theoretical foundation and computational barriers of this Quantum Deep GP in detail.

---

## References

### Lazy Training / NTK Theory
- Neal, R.M. (1996). *Bayesian Learning for Neural Networks*,
  Lecture Notes in Statistics, Springer.
  (Original source of infinite-width NN = GP convergence theorem)
- Jacot, A., Gabriel, F. and Hongler, C. (2018).
  "Neural Tangent Kernel: Convergence and Generalization in Neural Networks",
  *NeurIPS 2018*.
  (NTK extension to arbitrary depth / theoretical establishment of Lazy Training)
- Lee, J. et al. (2019).
  "Wide Neural Networks of Any Depth Evolve as Linear Models Under Gradient Descent",
  *NeurIPS 2019*.
  (Rich Regime / Lazy Regime discrimination criteria for finite-width NN)

### Deep GP / Uncertainty Estimation
- Damianou, A. and Lawrence, N.D. (2013).
  "Deep Gaussian Processes", *AISTATS 2013*.
  (Deep GP original: $O(Ln^3)$ complexity and introduction of variational inference)
- Lakshminarayanan, B., Pritzel, A. and Blundell, C. (2017).
  "Simple and Scalable Predictive Uncertainty Estimation using Deep Ensembles",
  *NeurIPS 2017*.
- Gal, Y. and Ghahramani, Z. (2016).
  "Dropout as a Bayesian Approximation: Representing Model Uncertainty in Deep Learning",
  *ICML 2016*.

### Module Connections
- **Previous**: `_20_FTQC_GP_ML/_04_ActiveLearning.lean` — $O(n)$ single-layer GP / Active Learning
- **Next**: `_01_DeepGP_Theory.lean` — Deep GP computational barrier $O(Ln^3)$ and breakthrough
- **Next**: `_22_ExactDeepBayesianOptimization/_01_NN_vs_GP.lean` — Lazy Training diagnosis referenced as foundation for GP vs NN comparison

-/

end CL8E8TQC.QuantumDeepGP.LazyTraining
