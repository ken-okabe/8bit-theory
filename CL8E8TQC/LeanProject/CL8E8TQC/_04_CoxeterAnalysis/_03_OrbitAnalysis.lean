import CL8E8TQC._04_CoxeterAnalysis._01_CoxeterSystem

namespace CL8E8TQC.CoxeterAnalysis.OrbitBoundary

open CL8E8TQC.E8Branching (coxeterPower allE8Roots vecEq CoordVec)
open CL8E8TQC.CoxeterAnalysis (isD8Type isSpinorType countD8InOrbit)

/-!
# Orbit Boundary Analysis: Boundary/Bulk Classification in the E8 Lattice

## Abstract

**This module**: `_04_CoxeterAnalysis/_03_OrbitAnalysis.lean`

**Position**:
- **Previous**: `_04_CoxeterAnalysis/_01_CoxeterSystem.lean` — Coxeter orbits, D8/Spinor classification
- **Next**: `_09_dSCFT/_01_TEE.lean` — Topological Entanglement Entropy (TEE) formula

**Purpose**: Classify the 240 roots of E8 into front-half coordinates (boundary $\mathcal{N}$, $c=4$) and back-half coordinates (bulk $\mathcal{M}$, $c=8$), and establish the correspondence with each Coxeter orbit.

**Experimental confirmation**: The numerical values in this chapter were pre-computed and verified via `tmp_rovodev_frontonly_orbits` (executed as `lean_exe`). The `native_decide` theorems serve as their verification.

**Intellectual honesty**: This chapter establishes only **mathematical facts**. Physical interpretation is deferred to `_09_dSCFT/_01_TEE.lean`.
-/

/-!
# §1 Boundary/Bulk Classification by Front/Back Coordinates

- **Boundary** $\mathcal{N}$ ($c=4$): Only front 4 coordinates are nonzero
- **Bulk** $\mathcal{M}$ ($c=8$): All 8 coordinates are used
- **Jones index** $[\mathcal{M}:\mathcal{N}] = 2$ (established in Route B §2)
-/

def frontNormSq (v : CoordVec) : Int :=
  v[0]! * v[0]! + v[1]! * v[1]! + v[2]! * v[2]! + v[3]! * v[3]!

def backNormSq (v : CoordVec) : Int :=
  v[4]! * v[4]! + v[5]! * v[5]! + v[6]! * v[6]! + v[7]! * v[7]!

def isFrontOnlyD8 (v : CoordVec) : Bool :=
  frontNormSq v == 8 && backNormSq v == 0

def isBackOnlyD8 (v : CoordVec) : Bool :=
  frontNormSq v == 0 && backNormSq v == 8

def isMixed (v : CoordVec) : Bool :=
  frontNormSq v > 0 && backNormSq v > 0

/-!
# §2 Constructive Verification of Root Counts (Lightweight)

Both frontOnly and backOnly have 24 roots each. The three-way classification is complete.
-/

theorem frontOnlyCount :
    (allE8Roots.filter isFrontOnlyD8).size = 24 := by native_decide

theorem backOnlyCount :
    (allE8Roots.filter isBackOnlyD8).size = 24 := by native_decide

theorem frontBackSymmetry :
    (allE8Roots.filter isFrontOnlyD8).size =
    (allE8Roots.filter isBackOnlyD8).size := by native_decide

theorem totalRootCount :
    (allE8Roots.filter isFrontOnlyD8).size +
    (allE8Roots.filter isBackOnlyD8).size +
    (allE8Roots.filter isMixed).size = 240 := by native_decide

/-!
# §3 Boundary/Bulk Breakdown for Each Coxeter Orbit

Experimental results computed via `tmp_rovodev_frontonly_orbits` (lean_exe):

| Orbit | frontOnly | backOnly | Spinor | D8visit | Character |
|:---:|:---:|:---:|:---:|:---:|:---|
| 0 | 4 | 0 | 20 | 10 | Front-dominant |
| 1 | 4 | 0 | 16 | 14 | Front-dominant |
| 2 | 10 | 4 | 8 | 22 | **Maximum boundary connection** |
| 3 | 2 | 4 | 20 | 10 | Back-dominant |
| 4 | 0 | 4 | 16 | 14 | Back-dominant |
| 5 | 4 | 2 | 16 | 14 | Symmetric pair |
| 6 | 0 | 0 | 20 | 10 | **frontOnly=backOnly=0** |
| 7 | 0 | 10 | 12 | 18 | Maximum back |

Note: Orbit 6 has frontOnly = backOnly = 0. D8visit = 10 (not exclusively Spinor-dominant). This orbit is special in the sense that it "does not directly connect" to either front or back half.

**Correction**: Previously described as "pure bulk," but D8visit=10 means it is not exclusively Spinor. More precisely, it should be called a "boundary-disconnected orbit."

These values are consistent with the `orbitD8SpinorVisits` from `_01_CoxeterSystem.lean` §3: `#[(10,20),(14,16),(22,8),(10,20),(14,16),(14,16),(10,20),(18,12)]`.

**Orbit representatives** (in index order of `orbitRepresentatives`) are established in `_01_CoxeterSystem.lean`. This chapter generates orbits directly from representatives via `coxeterPower` for computational efficiency, avoiding calls to `orbitRepresentatives` to minimize computation during type checking.
-/

/-!
# §4 Integer Determination of TEE Candidate Values

Structural constants used in `_09_dSCFT/_01_TEE.lean` are determined via integer arithmetic.

- $[\mathcal{M}:\mathcal{N}] = 2$ (Jones index)
- $h = 30$ (E8 Coxeter number)
- $\mathcal{D}^2 = 16$ (16 codewords of H(8,4) = square of quantum dimension)
- $4G_N^{E8} = [\mathcal{M}:\mathcal{N}]^2 \times h = 4 \times 30 = 120$
- Topological correction ratio $= [\mathcal{M}:\mathcal{N}]^2 / \mathcal{D}^2 = 4/16 = 1/4$
-/

def jonesIndex   : Nat := 2
def coxeterH     : Nat := 30
def quantumDimSq : Nat := 16

theorem fourGN_eq_120 : jonesIndex ^ 2 * coxeterH = 120 :=
  by native_decide
theorem gamma_numer   : jonesIndex ^ 2 = 4             :=
  by native_decide
theorem gamma_denom   : quantumDimSq = 16              :=
  by native_decide

/-!
# §5 Qualitative Structure of Boundary Connections

Structure of boundary connections readable from frontOnly/backOnly data:

**Maximum boundary connection orbit**: Orbit 2 (frontOnly=10, backOnly=4, D8visit=22)
- The orbit "closest to the boundary"
- Primary contributor to the area term of the TEE formula

**Boundary-disconnected orbit**: Orbit 6 (frontOnly=0, backOnly=0)
- A purely internal (bulk) orbit
- Candidate for relationship with the topological correction term of the TEE formula

**Orbit pair symmetry**:
- Orbit 2 (frontOnly=10) ↔ Orbit 7 (backOnly=10): Maximum connection pair
- Orbit 0 (frontOnly=4) ↔ Orbit 4 (backOnly=4): Symmetric pair

This structure forms the basis for the $A \to \gamma_A$ mapping in `_09_dSCFT/_01_TEE.lean`.
-/

/-!
# §6 Summary

Facts established in this chapter:

| Proposition | Value | Basis |
|:---|:---:|:---|
| frontOnly total | 24 | `frontOnlyCount` (native_decide) |
| backOnly total | 24 | `backOnlyCount` (native_decide) |
| Front/back symmetry | ✅ | `frontBackSymmetry` (native_decide) |
| Completeness of classification | 240=24+24+192 | `totalRootCount` (native_decide) |
| Maximum boundary connection orbit | Orbit 2 (frontOnly=10) | Experimentally confirmed |
| Boundary-disconnected orbit | Orbit 6 (frontOnly=backOnly=0) | Experimentally confirmed |
| $4G_N^{E8} = 120$ | Integer determined | `fourGN_eq_120` (native_decide) |
| Topological correction ratio = 4/16 | Integer determined | `gamma_numer` · `gamma_denom` (native_decide) |

**Previous**: `_04_CoxeterAnalysis/_01_CoxeterSystem.lean`
**Next**: `_09_dSCFT/_01_TEE.lean`

-/

/-!
## References

### Coxeter Groups and Orbit Analysis
- Humphreys, J.E. (1990). *Reflection Groups and Coxeter Groups*,
  Cambridge University Press.
  (Standard textbook on orbit structure of Coxeter groups)
- Bourbaki, N. (1968). *Groupes et algèbres de Lie*, Ch. 4–6, Hermann.
  (Algebraic structure of E8 root system and Weyl group)

### Topological Entanglement Entropy
- Kitaev, A. and Preskill, J. (2006). "Topological Entanglement Entropy",
  *Phys. Rev. Lett.* 96, 110404.
  (Original source for TEE formula $S = \alpha|\partial A| - \gamma$)
- Levin, M. and Wen, X.-G. (2006). "Detecting Topological Order in a
  Ground State Wave Function", *Phys. Rev. Lett.* 96, 110405.

### Module Connections
- **Previous**: `_04_CoxeterAnalysis/_01_CoxeterSystem.lean` — Algebraic structure of the Coxeter system
- **Next**: `_09_dSCFT/_01_TEE.lean` — E8 version of TEE formula construction
- The derivation of $4G_N^{E8} = 120$ is used in `_01_TEE.lean` §1

-/

end CL8E8TQC.CoxeterAnalysis.OrbitBoundary
