import CL8E8TQC._05_SpectralTriple._01_DiracOp

namespace CL8E8TQC.SpectralTriple

open CL8E8TQC.QuantumComputation (QuantumState cliffordProduct
  stateNormSquared stateInnerProduct h84State)
open CL8E8TQC.E8Dirac (diracSquared weylNorm12)

/-!
# Verification of Spectral Invariants: $D_+^2 = 9920$

## Abstract

**Position**: Chapter 2 of the `_05_SpectralTriple` module. Follows `_01_DiracOp.lean` and connects to `_03_Commutator.lean`.

**Subject**: This chapter constructively computes the spectral invariant $D_+^2$ and compares it with the theoretical prediction (9920) derived from algebraic parameters in `_03_E8Dirac`, confirming that abstract Lie theory and constructive discrete bit operations produce the same invariant.

**Main results**:
- Computation of `diracSquaredState`: Scalar component of `cliffordProduct(D₊, D₊)` = 9920 (exact agreement with Parthasarathy prediction)
- Confirmation of wedge part vanishing: Grade-1 = 0, Grade-2 = 0 (constructive verification of Weyl symmetry)
- Constructive confirmation of Theorem II–III bridge: `dim(E8) × weylNorm12(A4) = 3 × D₊² = 29760`

**Keywords**: spectral-invariant, parthasarathy-formula, spectral-action, dirac-squared, noncommutative-geometry

## Tags

spectral-invariant, parthasarathy-formula, spectral-action,
theory-vs-computation, noncommutative-geometry

---

# §1. Computation of $D_+^2$

## 1.1 Algebraic Expansion

$$D_+^2 = \left(\sum_{r \in \Phi^+} \gamma_r\right)^2 = \sum_{r,s \in \Phi^+} \gamma_r \gamma_s$$

Expanding via the geometric product:

$$D_+^2 = \underbrace{\sum_{r,s} \langle r,s \rangle}_{\text{scalar part}} + \underbrace{\sum_{r,s} r \wedge s}_{\text{wedge part}}$$

**Scalar part** = $|2\rho|^2 = 4|\rho|^2$ (norm² of the Weyl vector)
**Wedge part** = 0 (vanishes by Weyl group symmetry)

## 1.2 Correspondence with Integer Normalization

We compute $D_+^2$ using the unified integer normalization (all roots $|\alpha|^2 = 8$) established in `_03_E8Dirac/_04_PositiveRoots.lean`, and compare with the prediction from `_03_E8Dirac/_03_Parthasarathy.lean`.

| Normalization | $|\alpha|^2$ | $D_+^2$ scalar |
|:---|:---:|:---:|
| Conway-Sloane | 2 | $4|\rho|^2 = 2480$ |
| Integer normalization | 8 | $16|\rho|^2 = 9920$ |

**Origin of coefficient 16** (`_03_E8Dirac/_03_Parthasarathy.lean` §1.3):
- Scalar part $|2\rho|^2 = 4|\rho|^2$ → factor 4
- Integer normalization $|\alpha|^2: 2 \to 8$ → factor 4
- Total: $16|\rho|^2 = 16 \times 620 = 9920$
-/

/-- Compute all components of $D_+^2$

Executes `cliffordProduct(D_+, D_+)` to obtain a 256-dimensional vector.
-/
def diracSquaredState : QuantumState :=
  cliffordProduct diracOperatorState diracOperatorState

/-! ### 1.2.1 Basic Verification of $D_+^2$ -/

theorem diracSquaredState_scalar : diracSquaredState.getD 0 0 = 9920 :=
  by native_decide

theorem diracSquaredState_size : diracSquaredState.size = 256 :=
  by native_decide

theorem diracSquaredState_nonzero : (diracSquaredState.filter (· ≠ 0)).size = 1 :=
  by native_decide

/-!
---

# §2. Comparison with the Parthasarathy Formula

## 2.1 Theoretical Prediction

Proved in `_03_E8Dirac/_00_LieAlgebra.lean`:

$$D_+^2 = \frac{4 \times r \times h \times (h+1)}{3} = \frac{4 \times 7440}{3} = 9920$$

$3 \times D_+^2 = 4 \times \text{weylNorm12} = 29760$

## 2.2 Agreement with Constructive Computation

We verify that the scalar value returned by `diracSquaredState.getD 0 0` is in **exact agreement** with the theoretical value 9920.

**Rationale for consistency**:

1. D8 roots unified to integer normalization $|\alpha|^2 = 8$ via `scaleState 2` (components ±2)
2. Spinor roots already have components ±1 with $|\alpha|^2 = 8$
3. $D_+^2$ scalar = $|2\rho|^2 = 16|\rho|^2 = 16 \times 620 = 9920$ ✅
-/

theorem diracSquared_E8_val : diracSquared 8 30 = 9920 :=
  by native_decide
theorem four_weylNorm12_E8 : 4 * weylNorm12 8 30 = 29760 :=
  by native_decide

/-!
---

# §3. Structural Analysis of $D_+^2$

## 3.1 Component Distribution by Grade

We examine the component distribution of $D_+^2$ at each grade. Theoretically, only the scalar part (Grade 0) should be nonzero (the wedge part vanishes by Weyl symmetry).
-/

/-- Compute the sum of squares of components at Grade k -/
def gradeComponentNorm : QuantumState → Nat → Int :=
  λ state k =>
    (Array.range 256).foldl (λ acc i =>
      let bv := BitVec.ofNat 8 i
      if CL8E8TQC.Foundation.grade bv == k then
        acc + (state.getD i 0) * (state.getD i 0)
      else acc) 0

theorem gradeComponentNorm_grade0 : gradeComponentNorm diracSquaredState 0 = 98406400 :=
  by native_decide
theorem gradeComponentNorm_grade1 : gradeComponentNorm diracSquaredState 1 = 0 :=
  by native_decide
theorem gradeComponentNorm_grade2 : gradeComponentNorm diracSquaredState 2 = 0 :=
  by native_decide

/-!
---

# §4. Summary

## 4.1 What This File Establishes

1. ✅ **Constructive computation of $D_+^2$** — Execution of `cliffordProduct(D_+, D_+)`
2. ✅ **Scalar part = 9920** — **Exact agreement** with Parthasarathy prediction
3. ✅ **Wedge part vanishing** — Grade-1 = 0, Grade-2 = 0
4. ✅ **Theorem II–III bridge** — $3 \times 9920 = 4 \times 7440 = 29760$

## 4.2 Complete `native_decide` Verification Table

| Expression | Result | Meaning |
|:---|---:|:---|
| `diracSquaredState.getD 0 0` | **9920** | $D_+^2$ scalar = `diracSquared 8 30` ✅ |
| `diracSquaredState.size` | 256 | 256-dimensional vector |
| Nonzero component count | 1 | Only scalar is nonzero |
| `gradeComponentNorm _ 0` | **98406400** | $= 9920^2$ (square of scalar component) |
| `gradeComponentNorm _ 1` | **0** | Wedge part vanishing ✅ |
| `gradeComponentNorm _ 2` | **0** | Wedge part vanishing ✅ |
| `diracSquared 8 30` | **9920** | Parthasarathy theoretical prediction |
| `4 * weylNorm12 8 30` | **29760** | $= 3 \times D_+^2$ |
-/

/-!
## References

### Parthasarathy Formula and Spectral Invariants
- Parthasarathy, R. (1972). Dirac operator formula: $D^2 = -\Omega_\mathfrak{g} + \Omega_\mathfrak{k} + c$.
- Kostant, B. (1999). "A cubic Dirac operator and the emergence of Euler number multiplets
  of representations for equal rank subgroups", *Duke Math. J.* 100(3), 447–501.
- Chamseddine, A.H. & Connes, A. (1997).
  "The Spectral Action Principle", *Commun. Math. Phys.* 186, 731–750.

### Module Connections
- **Previous**: `_01_DiracOp.lean` — Construction of $D_+$
- **Next**: `_03_Commutator.lean` — Commutators and Connes metric tensor
- $D_+^2 = 9920$ is referenced in `_06_E8Branching/_01_RouteA_Time.lean` (relationship with Coxeter number)
  and `_07_HeatKernel/_01_Derivation.lean` (derivation of heat kernel coefficients).

-/

end CL8E8TQC.SpectralTriple
