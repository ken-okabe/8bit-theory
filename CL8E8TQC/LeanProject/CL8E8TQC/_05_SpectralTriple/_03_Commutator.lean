import CL8E8TQC._05_SpectralTriple._02_DiracSquared

namespace CL8E8TQC.SpectralTriple

open CL8E8TQC.Foundation (grade)
open CL8E8TQC.QuantumComputation (QuantumState cliffordProduct addState
  stateNormSquared stateInnerProduct scaleState h84State)

/-!
# Dirac Commutator $[D, a]$ and Connes Metric Tensor

## Abstract

**Position**: Chapter 3 of the `_05_SpectralTriple` module. Follows `_02_DiracSquared.lean` and serves as the final chapter of this module.

**Subject**: This chapter constructively computes the commutator $[D, a] = D \cdot a - a \cdot D$, which is the algebraic generalization of "differentiation" in Connes' noncommutative geometry, and derives the Connes metric tensor $g_{ij} = \langle [D, e_i], [D, e_j] \rangle$.

**Main results**:
- Constructive verification that $[D, e_i]$ is purely grade-2 in all 8 directions
- Closed formula for metric tensor diagonal components: $g_{ii} = 4(9920 - D_i^2)$ (consistent across all 8 directions)
- Verification of anticommutator $\{D, e_i\} = 2D_i$ and associativity

**Keywords**: commutator, connes-distance, spectral-triple, metric-tensor, ncg

## Theory

### Grade Structure

$D_+$ is grade-1 (sum of Clifford elements of E8 positive roots). The Clifford product of two grade-1 elements decomposes into grade-0 (scalar) and grade-2 (bivector):

$$D \cdot e_i = \underbrace{D_i}_{\text{grade-0}} +
  \underbrace{\sum_{j \neq i} D_j\, e_j \wedge e_i}_{\text{grade-2}}$$

The commutator eliminates grade-0 and doubles grade-2:

$$[D, e_i] = 2 \sum_{j \neq i} D_j\, (e_j \wedge e_i)$$

The anticommutator eliminates grade-2 and doubles grade-0:

$$\{D, e_i\} = 2 D_i$$

### Metric Tensor

$$g_{ii} = \|[D, e_i]\|^2 = 4 \sum_{j \neq i} D_j^2 = 4(\|D\|^2 - D_i^2)$$

Since $D_+$ is the sum of **positive roots only** and each directional component $D_i$ is generally different, $g_{ii}$ is direction-dependent. This accurately reflects the structure of $D_+$.

## Main definitions

* `subState` — Subtraction of QuantumStates
* `commutatorState` — $[D, a] = D \cdot a - a \cdot D$
* `grade1CommStates` — Pre-computed commutators for 8 directions (performance optimization)
* `metricTensor` — $g_{ij} = \langle [D, e_i], [D, e_j] \rangle$

## Tags

commutator, connes-distance, spectral-triple, metric-tensor, ncg

---

# §1. Basic Definitions
-/

/-- Subtraction of QuantumStates: $a - b$ -/
def subState : QuantumState → QuantumState → QuantumState :=
  λ a b =>
    addState a (scaleState (-1) b)

/-- State representation of the Dirac commutator: $[D, a] = D \cdot a - a \cdot D$

By associativity, $[D, a](\psi) = (D \cdot a - a \cdot D) \cdot \psi$. -/
def commutatorState : QuantumState → QuantumState :=
  λ a =>
    subState (cliffordProduct diracOperatorState a)
             (cliffordProduct a diracOperatorState)

/-- Operator application of the Dirac commutator: $[D, a](\psi)$ -/
def commutatorOp : QuantumState → QuantumState → QuantumState :=
  λ a ψ =>
    cliffordProduct (commutatorState a) ψ

/-- State representation of the anticommutator: $\{D, a\} = D \cdot a + a \cdot D$ -/
def anticommutatorState : QuantumState → QuantumState :=
  λ a =>
    addState (cliffordProduct diracOperatorState a)
             (cliffordProduct a diracOperatorState)

/-- Grade-1 basis vector $e_i$ (index $2^i$) -/
def grade1Basis : Nat → QuantumState :=
  λ i =>
    (Array.range 256).map (λ j => if j == (1 <<< i) then (1 : Int) else 0)

/-- Norm² of components at Grade $k$ -/
def gradeNormSq : QuantumState → Nat → Int :=
  λ state k =>
    (Array.range 256).foldl (λ acc i =>
      let bv := BitVec.ofNat 8 i
      if grade bv == k then acc + (state.getD i 0) * (state.getD i 0)
      else acc) 0

/-!
---

# §2. Pre-computation and Batch Verification

**Performance optimization**: Commutators for all 8 directions are computed once, and all analyses are derived from the cache.
-/

/-- Pre-compute commutator states for 8 directions -/
def grade1CommStates : Array QuantumState :=
  (Array.range 8).map (λ i => commutatorState (grade1Basis i))

/-- Metric tensor $g_{ij}$ (from pre-computed commutators) -/
def metricTensor : Array QuantumState → Nat → Nat → Int :=
  λ comms i j =>
    stateInnerProduct (comms.getD i #[]) (comms.getD j #[])


theorem grade1CommStates_norms :
    grade1CommStates.map stateNormSquared =
    #[5824, 37376, 38080, 38656, 39104, 39424, 39616, 39680] := by native_decide

theorem grade1CommStates_pureGrade2 :
    (grade1CommStates.all (λ c => gradeNormSq c 0 == 0)) &&
    (grade1CommStates.all (λ c => gradeNormSq c 1 == 0)) &&
    (grade1CommStates.all (λ c => gradeNormSq c 3 == 0)) = true := by native_decide

theorem diracOp_grade1Components :
    (Array.range 8).map (λ i => diracOperatorState.getD (1 <<< i) 0) =
    #[92, 24, 20, 16, 12, 8, 4, 0] := by native_decide

theorem metricTensor_diag :
    (Array.range 8).map (λ i => metricTensor grade1CommStates i i) =
    #[5824, 37376, 38080, 38656, 39104, 39424, 39616, 39680] := by native_decide

theorem metricTensor_formula :
    (Array.range 8).all (λ i =>
      let di := ((Array.range 8).map (λ j => diracOperatorState.getD (1 <<< j) 0)).getD i 0
      (metricTensor grade1CommStates i i) == 4 * (9920 - di * di)) = true := by native_decide

theorem anticommutatorState_eq_2Di :
    (Array.range 8).all (λ i =>
      let di := ((Array.range 8).map (λ j => diracOperatorState.getD (1 <<< j) 0)).getD i 0
      (anticommutatorState (grade1Basis i)).getD 0 0 == 2 * di) = true := by native_decide

theorem commutatorOp_associativity :
    ((subState
      (cliffordProduct diracOperatorState (cliffordProduct (grade1Basis 0) h84State))
      (cliffordProduct (grade1Basis 0) (cliffordProduct diracOperatorState h84State))) ==
    commutatorOp (grade1Basis 0) h84State) = true := by native_decide

/-!
---

# §3. Analysis of Results

The following is confirmed from the `native_decide` theorem verifications above:

## 3.1 Grade Structure

$[D, e_i]$ has **grade-0 = 0, grade-1 = 0, grade-3 = 0** across all 8 directions, and is **purely grade-2**. This is a constructive verification of the theoretical prediction:

$$[D, e_i] = 2(D \wedge e_i) \quad \text{(purely grade-2)}$$

## 3.2 Metric Tensor

The diagonal components $g_{ii} = \|[D, e_i]\|^2$ are completely explained by a closed formula:

$$g_{ii} = 4(\|D\|^2 - D_i^2) = 4(9920 - D_i^2)$$

$D_i$ is the $e_i$-directional component of $D_+$, which is the sum of the $i$-th coordinate across all 120 E8 positive roots: $D_i = \sum_{r \in \Phi^+} r_i$.

Since $D_i$ varies by direction, $g_{ii}$ is also direction-dependent, meaning the **single-site metric** is an anisotropic tensor reflecting the positive-root structure of $D_+$.

## 3.3 Isotropy on the QCA Lattice

This anisotropy is a **single-site** property. As shown in `_10_E8CA/_00_E8CellularAutomaton.lean` §0.5, **QCA propagation on the lattice** possesses the symmetry of the D4 Weyl group $W(D4)$ (order 192), and is **constructively isotropic** in the Connes metric.

That is, the anisotropy of the local metric tensor is globally isotropized by the symmetry of the lattice's neighborhood structure.

## 3.4 Verification Summary

| Verification Item | Result |
|:---|:---|
| $[D, e_i]$ is purely grade-2 | ✅ All 8 directions |
| $g_{ii} = 4(9920 - D_i^2)$ | ✅ All 8 directions |
| $\{D, e_i\} = 2D_i$ | ✅ All 8 directions |
| Associativity | ✅ |

---

# §4. Correspondence with NCG Theory

| NCG Concept | Continuous Theory | This Implementation (Discrete) |
|:---|:---|:---|
| Differential $da$ | $[D, f] = i\gamma^\mu \partial_\mu f$ | `commutatorState a` |
| Metric tensor | $g_{\mu\nu}$ | $g_{ij} = 4(9920 - D_i D_j \delta_{ij})$ |
| Connes distance | $d(x,y) = \sup\{|\omega(a)|: \|[D,a]\| \leq 1\}$ | Constructively computable via finite search |

## Connections to Other Modules

- $g_{ii} = 4(9920 - D_i^2)$ is derived from $D_+^2 = 9920$
  (`_05_SpectralTriple/_02_DiracSquared.lean`)
- The heat kernel coefficients $a_0, a_2, a_4$ in `_07_HeatKernel/_01_Derivation.lean`
  correspond to the transformation from this local metric to global invariants over the lattice
-/

/-!
## References

### Noncommutative Geometry and Distance Formula
- Connes, A. (1994). *Noncommutative Geometry*, Academic Press. (Original source for distance formula)
- Connes, A. (1996). "Gravity coupled with matter and the foundation of
  non-commutative geometry", *Commun. Math. Phys.* 182, 155–176.
- Chamseddine, A.H. & Connes, A. (1997).
  "The Spectral Action Principle", *Commun. Math. Phys.* 186, 731–750.
- van Suijlekom, W.D. (2015).
  *Noncommutative Geometry and Particle Physics*, Springer.
  (§3.3: Distance formula for discrete spectral triples)

### Subsequent Module Connections
- `_07_HeatKernel/_01_Derivation.lean` — Derivation of heat kernel coefficients $a_0, a_2, a_4$ from the metric tensor
- `_10_E8CA/_00_E8CellularAutomaton.lean` §0.5 — Isotropy on the lattice QCA (D4 Weyl group symmetry)

-/

end CL8E8TQC.SpectralTriple
