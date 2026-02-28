import CL8E8TQC._03_E8Dirac._03_Parthasarathy
import CL8E8TQC._01_TQC._03_QuantumState

namespace CL8E8TQC.E8Dirac

open CL8E8TQC.Foundation (grade basisVector)
open CL8E8TQC.QuantumComputation (QuantumState stateNormSquared d8PairRootState spinorRootSum addState scaleState)

/-!
# Constructive Enumeration of 120 E8 Positive Roots

## Abstract

**Position**: Chapter 4 of the `_03_E8Dirac` module. Follows `_03_Parthasarathy.lean` and connects to the `_05_SpectralTriple` module.

**Subject**: This chapter constructively enumerates 120 positive roots from the 240-element E8 lattice root system, classifying them under integer normalization (all roots $|\alpha|^2 = 8$) into 56 D8 positive roots and 64 Spinor positive roots.

**Main results**:
- Enumeration of 56 D8 positive roots ($2e_i \pm 2e_j$, $i < j$) with norm² = 8 verification
- Enumeration of 64 Spinor positive roots ($s_0 = +1$ fixed, even number of $-1$s) with norm² = 8 verification
- Integration of 120 E8 positive roots (`e8PositiveRoots_size`)

**Keywords**: e8-lattice, positive-roots, weyl-chamber, d8-roots, spinor-roots, integer-normalization

## Integer Normalization (all roots $|\alpha|^2 = 8$)

The integer normalization established in `_03_Parthasarathy.lean` §1.3 is applied:

$$|\alpha|^2: 2 \to 8 \quad \text{(Conway-Sloane → integer normalization)}$$

| Sector | Conway-Sloane coordinates | Integer normalization coordinates | $|\alpha|^2$ |
|:---|:---|:---|:---:|
| **D8** | $(1, 1, 0, \ldots)$ | $(2, 2, 0, \ldots)$ | **8** |
| **Spinor** | $(\frac{1}{2}, \pm\frac{1}{2}, \ldots)$ | $(1, \pm 1, \ldots)$ | **8** |

Both sectors have their coordinates doubled, unifying to $|\alpha|^2 = 8$. This justifies the coefficient 16 in the Parthasarathy formula $D_+^2 = 16|\rho|^2$ (scalar part 4 × normalization factor 4 = 16).

**D8 positive roots (56)**: coordinate components $\pm 2$
**Spinor positive roots (64)**: coordinate components $\pm 1$

## Main definitions

* `d8PositiveRoots` - Array of 56 D8 positive root QuantumStates (integer normalization)
* `spinorPositiveRoots` - Array of 64 Spinor positive root QuantumStates
* `e8PositiveRoots` - Array of all 120 E8 positive root QuantumStates

## Main statements

* `e8PositiveRoots_size` - Positive root count = 120
* Weyl invariance argument (documentation)

## Implementation notes

- Based on `d8PairRootState` (`_02_QuantumState.lean` §7), with ×2 scaling applied
- `spinorRootSum` (ibid.) is used directly (already integer-normalized)
- norm² = 8 for all roots verified via `native_decide`

## Tags

e8-lattice, positive-roots, weyl-chamber, d8-roots, spinor-roots,
integer-normalization

---

# §1. Enumeration of D8 Positive Roots

## 1.1 Definition

The D8 root system consists of 112 roots $\pm e_i \pm e_j$ ($0 \leq i < j \leq 7$). The positive roots are the following 56:

- **Type A**: $2e_i + 2e_j$ ($i < j$) — 28 roots (integer normalization: components $\pm 2$)
- **Type B**: $2e_i - 2e_j$ ($i < j$) — 28 roots

**Justification for integer normalization**: In Conway-Sloane, these are $e_i + e_j$, but under integer normalization ($|\alpha|^2 = 8$), coordinates are doubled to $2e_i + 2e_j$. This yields $|\alpha|^2 = 4 + 4 = 8$, unifying with Spinor roots ($|\alpha|^2 = 8$).
-/

/-- Array of 56 D8 positive root QuantumStates (integer normalization: components ±2)

Type A: $2e_i + 2e_j$ ($i < j$) — 28 roots, $|\alpha|^2 = 8$
Type B: $2e_i - 2e_j$ ($i < j$) — 28 roots, $|\alpha|^2 = 8$

The output of `d8PairRootState` (components ±1) is integer-normalized via `scaleState 2`.
-/
def d8PositiveRoots : Array QuantumState :=
  (Array.range 8).foldl (λ acc i =>
    (Array.range 8).foldl (λ acc2 j =>
      if h1 : i < 8 then
        if h2 : j < 8 then
          if i < j then
            let plus  := scaleState 2 (d8PairRootState ⟨i, h1⟩ ⟨j, h2⟩ true)
            let minus := scaleState 2 (d8PairRootState ⟨i, h1⟩ ⟨j, h2⟩ false)
            acc2.push plus |>.push minus
          else acc2
        else acc2
      else acc2) acc) #[]

/-! ### 1.1.1 Verification of D8 Positive Roots -/

theorem d8_positive_root_count : d8PositiveRoots.size = 56 :=
  by native_decide
theorem d8_positive_roots_norm_sq : d8PositiveRoots.all (λ r => stateNormSquared r == 8) = true :=
  by native_decide

/-!
---

# §2. Enumeration of Spinor Positive Roots

## 2.1 Definition

The Spinor root system consists of 128 roots $\frac{1}{2}(s_0, s_1, \ldots, s_7)$ ($s_k = \pm 1$, even number of $-1$s).

Under integer normalization, coordinates are doubled to $(s_0, s_1, \ldots, s_7)$ ($s_k = \pm 1$).

**Positive root condition**: Fix $s_0 = +1$. The number of arrangements with an even number of $-1$s among $(s_1, \ldots, s_7)$ is:

$$\binom{7}{0} + \binom{7}{2} + \binom{7}{4} + \binom{7}{6} = 1 + 21 + 35 + 7 = 64$$

## 2.2 Justification of Weyl Invariance

**Theorem**: $|2\rho|^2 = |\sum_{r \in \Phi^+} r|^2$ does not depend on the choice of Weyl chamber.

**Proof**: $2\rho$ is the Weyl vector, and for any element $w$ of the Weyl group $W$, $w(\rho)$ equals $\rho'$ corresponding to a different Weyl chamber. $|\rho|^2 = |\rho'|^2$ follows immediately from the fact that the Weyl group is an isometry group.

Therefore, in verifying $D_+^2 = |2\rho|^2$, the choice of positive roots does not affect the result. The simplest coordinate condition ($s_0 = +1$) suffices.
-/

/-- Generate Spinor sign array from a 7-bit pattern

Each bit of `bits` determines the sign of $s_1, \ldots, s_7$. Bit 1 → $s_k = +1$, bit 0 → $s_k = -1$. $s_0 = +1$ is always fixed.
-/
def spinorSignsFromBits : Nat → Array Int :=
  λ bits =>
    let s0 : Array Int := #[1]
    (Array.range 7).foldl (λ acc k =>
      let sign : Int := if (bits >>> k) &&& 1 == 1 then 1 else -1
      acc.push sign) s0

/-- Determine whether a 7-bit pattern has an even number of $-1$s -/
def hasEvenMinusCount : Nat → Bool :=
  λ bits =>
    let minusCount := (Array.range 7).foldl (λ count k =>
      if (bits >>> k) &&& 1 == 0 then count + 1 else count) 0
    minusCount % 2 == 0

/-- Array of 64 Spinor positive root QuantumStates

$s_0 = +1$ fixed, enumerating all patterns with an even number of $-1$s.
-/
def spinorPositiveRoots : Array QuantumState :=
  (Array.range 128).foldl (λ acc bits =>
    if hasEvenMinusCount bits then
      acc.push (spinorRootSum (spinorSignsFromBits bits))
    else acc) #[]

/-! ### 2.2.1 Verification of Spinor Positive Roots -/

theorem spinor_positive_root_count : spinorPositiveRoots.size = 64 :=
  by native_decide
theorem spinor_positive_roots_norm_sq : spinorPositiveRoots.all (λ r => stateNormSquared r == 8) = true :=
  by native_decide

/-!
---

# §3. Integration of E8 Positive Roots

## 3.1 D8 + Spinor = E8 Positive Roots

E8 root system (240) = D8 roots (112) + Spinor roots (128)

Positive roots (120) = D8 positive roots (56) + Spinor positive roots (64)
-/

/-- Array of all 120 E8 positive root QuantumStates -/
def e8PositiveRoots : Array QuantumState :=
  d8PositiveRoots ++ spinorPositiveRoots

/-! ### 3.1.1 Verification of E8 Positive Roots -/

/-- E8 has 120 positive roots -/
theorem e8PositiveRoots_size : e8PositiveRoots.size = 120 :=
  by native_decide

/-!
---

# §4. Summary

## 4.1 What This File Establishes

1. ✅ **56 D8 positive roots** — $2e_i \pm 2e_j$ ($i < j$), $|\alpha|^2 = 8$
2. ✅ **64 Spinor positive roots** — $s_0 = +1$, even number of $-1$s, $|\alpha|^2 = 8$
3. ✅ **Unified root normalization** — $|\alpha|^2 = 8$ (consistent with Parthasarathy formula)
4. ✅ **120 E8 positive roots** — Integration of D8 + Spinor
5. ✅ **Weyl invariance** — Argument that $|2\rho|^2$ is independent of positive root choice

## 4.2 Complete `native_decide` Verification Table

| Expression | Expected Value | Verified |
|:---|:---|:---:|
| `d8PositiveRoots.size` | 56 | ✅ |
| `d8PositiveRoots.all (normSq == 8)` | true | ✅ |
| `spinorPositiveRoots.size` | 64 | ✅ |
| `spinorPositiveRoots.all (normSq == 8)` | true | ✅ |
| `e8PositiveRoots.size` | 120 | ✅ |
-/

/-!
## References

### E8 Lattice and Root Systems
- Conway, J.H. & Sloane, N.J.A. (1988). *Sphere Packings, Lattices and Groups*,
  Springer. (Standard reference for E8 lattice D8+Spinor decomposition and Conway-Sloane coordinates)
- Wilson, R.A. (2009). *The Finite Simple Groups*, Springer.
  (Constructive description of the E8 root system)
- Ebeling, W. (2013). *Lattices and Codes*, Springer.
  (Relationships between lattice theory, root systems, and error-correcting codes)

### Weyl Groups and Positive Root Choice
- Humphreys, J.E. (1972). *Introduction to Lie Algebras and Representation Theory*,
  Springer. (Definition and invariance of Weyl chambers and positive roots)
- Bourbaki, N. (1968). *Groupes et algèbres de Lie*, Chapitres 4–6, Hermann.
  (Standard presentation of E8 positive root system and Weyl vector $\\rho$)

### Module Connections
- **Previous**: `_03_Parthasarathy.lean` — Unified Parthasarathy formula (Theorem III)
- **Next**: `_05_SpectralTriple/_01_DiracOp.lean` — Construction of $D_+$ (positive-root Dirac operator)
- The `e8PositiveRoots` (120 roots) from this file are used in `_05_SpectralTriple/_02_DiracSquared.lean` for the formal proof that $D_+^2 = 9920$

-/

end CL8E8TQC.E8Dirac
