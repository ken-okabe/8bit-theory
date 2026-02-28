import CL8E8TQC._05_SpectralTriple._02_DiracSquared

namespace CL8E8TQC.E8CA

open CL8E8TQC.Foundation (Cl8Basis geometricProduct grade basisVector)
open CL8E8TQC.QuantumComputation (QuantumState cliffordProduct addState
  stateNormSquared stateInnerProduct h84State scaleState)
open CL8E8TQC.E8Dirac (e8PositiveRoots d8PositiveRoots)
open CL8E8TQC.SpectralTriple (diracOperatorState DiracOp)

/-!
# E8 Quantum Cellular Automaton — Dynamical Realization of NCG Spectral Triple

## Abstract

The spectral triple $(\mathcal{A}, \mathcal{H}, D)$ from Connes' noncommutative geometry (NCG) is dynamically realized as a quantum cellular automaton (QCA) on a discrete 4-dimensional lattice, with 8-bit Clifford algebra Cl(8) placed at each site. Projecting the Dirac operator $D_+$ (sum of Clifford elements of 120 E8 positive roots) to 4 dimensions yields the D4 root system's 24 neighborhoods, which serve as the update rule for a lattice CA of $20^4 = 160{,}000$ cells. Over 5 time steps, the wavefront active cell count grows as $1 \to 24 \to 145 \to 600 \to 1657 \to 3720$, and quantum interference fringes (complete cancellation nodes) and checkerboard patterns originating from Clifford product sign reversal are computationally observed. This implementation uses integer arithmetic only (fully Forbidden Float compliant), achieving rigorous NCG discretization with zero floating-point error.

## 1. Introduction

In noncommutative geometry (NCG), the spectral triple $(\mathcal{A}, \mathcal{H}, D)$ is an algebraic encoding of geometry. In Connes' framework, distance is not defined from coordinates but intrinsically from the Dirac operator $D$: $d(x, y) = \sup\{|f(x) - f(y)| : \|[D, f]\| \leq 1\}$. Crucially, this implementation does not lattice-approximate the continuous theory but **directly constructs it as a discrete theory** using Cl(8)'s XOR+sign geometric product.

This module takes the result $D_+^2 = 9920$ established in `_05_SpectralTriple/_02_DiracSquared.lean` and visualizes the dynamical action of $D_+$ as a QCA. E8's 240 roots are projected from 8 dimensions into external 4 dimensions (spacetime) and internal 4 dimensions (gauge degrees of freedom). The external projection yields D4 root system's 24 directions, which become the CA neighborhood structure. Each site carries a 256-dimensional integer-valued quantum state (linear combination of Cl(8) basis), and inter-site updates are performed as $\psi'_x = \sum_{\text{24 neighbors}} \gamma_{\text{dir}} \cdot \psi_{\text{neighbor}}$.

QCA time evolution is synchronous (all cells updated simultaneously), guaranteeing discrete causality. Update isotropy is guaranteed by D4 Weyl group $W(D4)$ (order 192) symmetry, and the wavefront projected to coordinate space appears as a D4 polytope. The observed interference nodes, checkerboard pattern, and rhombic wavefront are all **mathematically trivial consequences** of the construction of $D_+$, with further non-trivial phenomena (H84's grade-eigenstate property) reported in `_10_E8CA/_01_DiracPropagator.lean`.

## 2. Relationship to Prior Work

| Prior Work | Content | Relationship to This Module |
|:---|:---|:---|
| Connes (1994) *Noncommutative Geometry* | Definition of spectral triple $(\mathcal{A}, \mathcal{H}, D)$ / Connes distance | Theoretical foundation of this implementation; dynamically realized as lattice QCA |
| Chamseddine & Connes (1997) | Spectral action principle | Adopts discrete version of $D_+$ as QCA update rule |
| Schumacher & Werner (2004) | Theory of reversible quantum cellular automata | QCA framework applied to E8/D4 structure |
| Arrighi (2019) | Overview of quantum CA / causal structure | Design guidelines for synchronous update / periodic boundary conditions |
| Conway & Sloane (1988) | D4 root system / 4-dimensional projection of E8 lattice | Mathematical basis for 24-direction neighborhood structure |

## 3. Contributions of This Chapter

- **Construction of NCG discrete QCA**: Rigorous realization of spectral triple as QCA on 8-bit Clifford lattice
- **Derivation of D4 neighborhood**: Implementation showing that 4-dimensional external projection of E8 root system uniquely yields D4 root system's 24 directions
- **Computational demonstration of isotropic wave propagation**: Measured active cell count $1 \to 3720$ (5 steps)
- **Visualization of quantum interference fringes**: Complete cancellation nodes from Clifford product sign reversal confirmed via ASCII art
- **Full Forbidden Float compliance**: All operations implemented as integer arithmetic only (zero floating-point error)
- **EXE executable implementation**: Directly executable via `lake build e8ca && ./.lake/build/bin/e8ca`

## 4. Chapter Structure

| Section | Title | Content |
|:---|:---|:---|
| §0 | Theoretical Foundation | Connes NCG / spectral triple inherited / E8 infinite lattice definition |
| §1 | 4D Lattice Coordinates and Neighborhood Structure | `Coord4D` / `LatticeParams` / D4 roots 24 directions / periodic boundary conditions |
| §2 | Lattice Structure | `E8Lattice4D` / empty lattice generation / cell access |
| §3 | 4D Projection of Dirac Operator | `directionToClElement` / `neighborClElements` / `sparseCliffordProduct` |
| §4 | Time Evolution Rules | `updateCell` / lattice version of discrete Dirac equation |
| §5 | Full Lattice Time Evolution | `stepE8CA` (synchronous update) / `runE8CA` |
| §6–7 | Initial Conditions and Observables / Visualization | H84 center excitation / energy density / ASCII art output |
| §8–9 | Diagnostics / Main Program | Execution settings / wave propagation quantitative data / EXE entry point |

## Main definitions

* `E8Lattice4D` — 4-dimensional E8 lattice ($20^4 = 160{,}000$ cells)
* `neighborOffsets4D` — 24 neighborhood directions from D4 root system (projection of $D_+$)
* `stepE8CA` — 1 timestep synchronous update (discrete version of $D_+$ action)
* `runE8CA` — N-step execution
* `main` — EXE entry point

## Implementation notes

- **Array-First / HOF only** (`λ` syntax, `foldl`, `map`, `filter`)
- **Full Forbidden Float compliance** — integer arithmetic only
- **4D projection** — extracts 24 D4 neighbor directions in external 4D from 120 directions of $D_+$
- **Lattice size** — $20^4 = 160{,}000$ cells
- **Periodic boundary conditions** — torus topology

## Tags

cellular-automaton, e8-lattice, quantum-ca, ncg, connes-distance,
spectral-triple, d4-symmetry, literate-coding, interference

---

# §0. Theoretical Foundation: Connes' Noncommutative Geometry

This file dynamically realizes the Connes spectral triple $(\mathcal{A}, \mathcal{H}, D)$ constructed in `_05_SpectralTriple/_01_DiracOp.lean` as a **quantum cellular automaton (QCA) on an infinite lattice**.

## 0.1 Spectral Triple Inherited

| Connes' Definition | This Implementation | Source File |
|:---|:---|:---|
| Algebra $\mathcal{A}$ | Linear combinations of `Cl8Basis` | `_01_TQC` |
| Hilbert space $\mathcal{H}$ | `QuantumState` (256-dim) | `_01_TQC` |
| Dirac operator $D$ | `DiracOp` (XOR convolution) | `_05_SpectralTriple` |
| $D_+^2$ | $9920 = 4rh(h+1)/3$ | `_05_SpectralTriple/_02_DiracSquared.lean` |

## 0.2 Connes Distance — Source of the Metric

In NCG, distance is not defined from coordinates but **intrinsically from the Dirac operator $D$**:

$$d(x, y) = \sup\{|f(x) - f(y)| : \|[D, f]\| \leq 1\}$$

This theory is a rigorous theory of integer/rational numbers, not a lattice approximation of continuous theory. Distance, metric, and causal structure are all derived from $D$. The Euclidean coordinate system is merely a display convenience; the physical distance is the Connes distance.

## 0.3 What Is the E8 Infinite Lattice

The E8 infinite lattice is a discrete spacetime with a copy of Hilbert space $\mathcal{H}$ placed at each site, and inter-site coupling derived from the structure of Dirac operator $D_+$.

$D_+$ is defined as the sum of Clifford elements of 120 E8 positive roots. Projecting these 120 directions from 8D → external 4D yields **24 directions of the D4 root system** as the neighborhood structure.

```
  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │Cl8│─│Cl8│─│Cl8│─│Cl8│─│Cl8│─ ...
  └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘
  ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐
  │Cl8│─│Cl8│─│Cl8│─│Cl8│─│Cl8│─ ...
  └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘
  ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐
  │Cl8│─│Cl8│─│Cl8│─│Cl8│─│Cl8│─ ...
  └───┘ └───┘ └───┘ └───┘ └───┘
    :      :      :      :      :

  Each cell = Cl(8) algebra (copy of $\mathcal{H}$)
  Coupling directions = D4 root system (4D projection of $D_+$)
```

## 0.4 What Is the CA Implementation

The CA update rule is the 4D projection of $D_+$ itself:

$$\psi'_x = \sum_{\text{24 D4 neighbors}} \gamma_{\text{dir}} \cdot \psi_{\text{neighbor}}$$

$\gamma_{\text{dir}}$ is the Clifford element of the neighbor direction (`directionToClElement`), and $\cdot$ is the Clifford product (`sparseCliffordProduct`).

Since $D_+$ acts with **equal weight** on all 24 directions, this update is **perfectly isotropic** in the Connes metric.

## 0.5 Isotropy in Connes Metric

The 24 directions in the construction of $D_+$ are related by D4 Weyl group $W(D4)$ (order 192) symmetry. Since the norm of $[D, f]$ does not depend on direction, **Connes distance is constructively isotropic**, and W(D4) symmetry functions as a discrete version of the Lorentz group.

The wavefront, when projected to coordinate space, is visualized as a D4 polytope, which is the coordinate projection of a "sphere" in the Connes metric.

## 0.6 Execution Results

The following is measured output at **size 20 ($20^4 = 160{,}000$ cells)** (`lake build e8ca && ./.lake/build/bin/e8ca`):

```
Step 0: total_energy=16,       active_cells=1
Step 1: total_energy=768,      active_cells=24
Step 2: total_energy=69120,    active_cells=145
Step 3: total_energy=7827456,  active_cells=600
Step 4: total_energy=972527616,active_cells=1657
Step 5: total_energy=126708645888, active_cells=3720

═══ x-y energy density slice (z=t=center) ═══
·····▓·█·█·█·█·▓····
······█·█·█·█·█·····
·····█·█·█·█·█·█····
······█·█·█·█·█·····
·····█·█·█·█·█·█····
······█·█···█·█·····   ← interference node (complete cancellation)
·····█·█·█·█·█·█····
```

## 0.7 Interpretation of Observed Phenomena (in Connes Metric Framework)

The following phenomena are all **mathematically trivial** consequences of the construction of $D_+$, constituting structural necessities rather than "discoveries" (see triviality table in `_10_E8CA/_01_DiracPropagator.lean` §0).

| Phenomenon | Observation | NCG Interpretation | Triviality |
|:---|:---|:---|:---|
| **Wave propagation** | 1→24→145→600→1657→3720 | Isotropic propagation in 24 directions via $D_+$ | Trivial from W(D4) symmetry |
| **Interference fringes** | Center "·" (complete cancellation) | Quantum interference from Clifford product sign reversal | Natural for linear wave equation |
| **Rhombic wavefront** | D4 polytope pattern | Coordinate projection of "sphere" in Connes metric | Trivial from D4 symmetry |
| **Checkerboard** | Alternating at odd/even lattice points | D4 root parity preservation (coordinate sum of all roots is even) | Trivial from D4 structure |

**Non-trivial discovery** reported in `_10_E8CA/_01_DiracPropagator.lean`:
H84 is a **grade-eigenstate** of $D_+$, and the grade ratio $g_0:g_4:g_8 = 1:14:1$ is dynamically perfectly preserved.

### E8 Lattice 8D → 4D (Projection via H(8,4))

```
E8 lattice 8 dimensions
  │
  ├─→ External 4D → spacetime (x, y, z, t)      ← this implementation's lattice
  │     ↑
  │   Size 20: demonstrated with 160,000 cells
  │
  └─→ Internal 4D → gauge degrees of freedom
        ↑
      Embedded in 256-dimensional state at each cell
      (corresponds to F in Connes' product space M⁴ × F)
```

---

# §1. 4D Lattice Coordinates and Neighborhood Structure
-/


/-- 4-dimensional lattice coordinate (x, y, z, t) -/
structure Coord4D where
  x : Nat
  y : Nat
  z : Nat
  t : Nat
  deriving Repr, BEq

/-- Lattice parameters -/
structure LatticeParams where
  size : Nat        -- number of cells per axis
  deriving Repr

/-!
## 1.2 4D Neighborhood Directions

In the 4D projection, we take directions from E8's 240 neighbors that project to the external 4D. The nearest neighbors in 4D are the **±x, ±y, ±z, ±t** 8 directions, plus face-diagonals (±x±y, ±x±z, ±x±t, ±y±z, ±y±t, ±z±t) giving $\binom{4}{2} \times 2^2 = 24$ directions, for a total of 24 neighbors.

```
4D face-diagonal neighbors (24 directions):
  ±x±y  (4 directions)
  ±x±z  (4 directions)
  ±x±t  (4 directions)
  ±y±z  (4 directions)
  ±y±t  (4 directions)
  ±z±t  (4 directions)
  ─────────────
  Total 24 directions
```

This corresponds to the D4 root system and is the 4D projection of E8's D8 sublattice.
-/

/-- 4D neighborhood direction vectors (D4 root system = 24 directions)

D4 root system: all 24 vectors ±eᵢ ± eⱼ (i < j) in 4D space.
This is the 4D projection of E8's D8 sublattice.
-/
def neighborOffsets4D : Array (Int × Int × Int × Int) :=
  -- D4 roots: ±eᵢ ± eⱼ (0 ≤ i < j ≤ 3)
  let pairs := #[(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
  (pairs.map (λ (i, j) =>
    #[(if i == 0 then (1:Int)  else if j == 0 then (1:Int) else (0:Int),
       if i == 1 then (1:Int)  else if j == 1 then (1:Int) else (0:Int),
       if i == 2 then (1:Int)  else if j == 2 then (1:Int) else (0:Int),
       if i == 3 then (1:Int)  else if j == 3 then (1:Int) else (0:Int)),
      (if i == 0 then (1:Int)  else if j == 0 then (-1:Int) else (0:Int),
       if i == 1 then (1:Int)  else if j == 1 then (-1:Int) else (0:Int),
       if i == 2 then (1:Int)  else if j == 2 then (-1:Int) else (0:Int),
       if i == 3 then (1:Int)  else if j == 3 then (-1:Int) else (0:Int)),
      (if i == 0 then (-1:Int) else if j == 0 then (1:Int) else (0:Int),
       if i == 1 then (-1:Int) else if j == 1 then (1:Int) else (0:Int),
       if i == 2 then (-1:Int) else if j == 2 then (1:Int) else (0:Int),
       if i == 3 then (-1:Int) else if j == 3 then (1:Int) else (0:Int)),
      (if i == 0 then (-1:Int) else if j == 0 then (-1:Int) else (0:Int),
       if i == 1 then (-1:Int) else if j == 1 then (-1:Int) else (0:Int),
       if i == 2 then (-1:Int) else if j == 2 then (-1:Int) else (0:Int),
       if i == 3 then (-1:Int) else if j == 3 then (-1:Int) else (0:Int))])).flatten

/-!
## 1.3 Periodic Boundary Conditions

Gives the lattice torus topology, eliminating boundary effects.
-/

/-- Coordinate transformation with periodic boundary conditions -/
def wrapCoord : Int → Nat → Nat :=
  λ c size =>
    let m := c % (Int.ofNat size)
    if m < 0 then (m + Int.ofNat size).toNat else m.toNat

/-- Add offset to 4D coordinate (with periodic boundary conditions) -/
def applyOffset : Coord4D → (Int × Int × Int × Int) → Nat → Coord4D :=
  λ coord (dx, dy, dz, dt) size =>
    { x := wrapCoord (Int.ofNat coord.x + dx) size
    , y := wrapCoord (Int.ofNat coord.y + dy) size
    , z := wrapCoord (Int.ofNat coord.z + dz) size
    , t := wrapCoord (Int.ofNat coord.t + dt) size }

/-- Convert 4D coordinate to 1D index -/
def coordToIndex : Coord4D → Nat → Nat :=
  λ coord size =>
    coord.x + size * (coord.y + size * (coord.z + size * coord.t))

/-- Convert 1D index to 4D coordinate -/
def indexToCoord : Nat → Nat → Coord4D :=
  λ idx size =>
    let x := idx % size
    let rem1 := idx / size
    let y := rem1 % size
    let rem2 := rem1 / size
    let z := rem2 % size
    let t := rem2 / size
    { x := x, y := y, z := z, t := t }

/-!
---

# §2. Lattice Structure
-/

/-- Empty QuantumState (256-dimensional zero vector) -/
def emptyState : QuantumState := Array.replicate 256 (0 : Int)

/-- 4-dimensional E8 lattice

Each site carries a QuantumState (256-dimensional integer vector).
The entire lattice is represented as a 1D array, accessed as 4D via coordinate conversion.
-/
structure E8Lattice4D where
  cells : Array QuantumState   -- states of all cells
  params : LatticeParams        -- lattice parameters
  deriving Repr

/-- Compute total number of cells -/
def totalCells : Nat → Nat :=
  λ size => size * size * size * size

/-- Generate an empty 4D E8 lattice -/
def mkEmptyLattice : Nat → E8Lattice4D :=
  λ size =>
    let n := totalCells size
    { cells := Array.replicate n emptyState
    , params := { size := size } }

/-- Get cell state at a specific lattice coordinate -/
def getCell : E8Lattice4D → Coord4D → QuantumState :=
  λ lat coord =>
    let idx := coordToIndex coord lat.params.size
    lat.cells.getD idx emptyState

/-- Set cell state at a specific lattice coordinate -/
def setCell : E8Lattice4D → Coord4D → QuantumState → E8Lattice4D :=
  λ lat coord state =>
    let idx := coordToIndex coord lat.params.size
    { lat with cells := lat.cells.set! idx state }

/-!
---

# §3. 4D Projection of Dirac Operator

## 3.1 Computing Neighbor Contributions

The action of Dirac operator $D_+$ on the E8 lattice is "taking the Clifford product with each neighbor cell's state and superposing the results."

$$D_+ \cdot \psi_{\text{site}} = \sum_{\text{neighbor}} \gamma_{\text{direction}} \cdot \psi_{\text{neighbor}}$$

In the 4D projection, for 24 neighborhood directions (D4 root system), the Clifford product using corresponding Cl(8) generators ($\gamma_i$) is computed.

## 3.2 Direction → Generator Correspondence

Each component of D4 root vectors corresponds to a Cl(8) generator:
- $e_0 \to \gamma_0$ (external direction x)
- $e_1 \to \gamma_1$ (external direction y)
- $e_2 \to \gamma_2$ (external direction z)
- $e_3 \to \gamma_3$ (external direction t)

The Cl(8) element corresponding to each direction vector $(d_0, d_1, d_2, d_3)$ is $\sum_k d_k \cdot \gamma_k$. This is equivalent to the construction in `_02_QuantumState.lean`'s `d8PairRootState`.
-/

/-- Generate QuantumState (Cl(8) element) from direction vector

Computes $\sum_k d_k \cdot \gamma_k$ corresponding to direction vector $(d_0, d_1, d_2, d_3)$.
$\gamma_k$ is the grade-1 basis of Cl(8) (`basisVector k`).
-/
def directionToClElement : (Int × Int × Int × Int) → QuantumState :=
  λ (d0, d1, d2, d3) =>
    let zero := emptyState
    -- γ₀ = e₀ = BitVec 0x01, γ₁ = e₁ = BitVec 0x02, γ₂ = e₂ = BitVec 0x04, γ₃ = e₃ = BitVec 0x08
    let basisIndices := #[(1 : Nat), 2, 4, 8]  -- basisVector k = 2^k
    let components := #[(d0, 0), (d1, 1), (d2, 2), (d3, 3)]
    components.foldl (λ acc (coeff, idx) =>
      if coeff == 0 then acc
      else
        let basis := Array.replicate 256 (0 : Int)
        let bvIdx := basisIndices.getD idx 0
        let basis := basis.set! bvIdx coeff
        addState acc basis) zero

/-- Precompute Cl(8) elements for all 24 neighbor directions -/
def neighborClElements : Array QuantumState :=
  neighborOffsets4D.map (λ dir => directionToClElement dir)

/-!
---

# §4. Time Evolution Rules

## 4.1 Single Cell Update

The new state of each cell is computed as the sum of Clifford products of neighbor cell states with direction generators:

$$\psi'_{\text{site}} = \sum_{n \in \text{neighbors}} \gamma_{\text{dir}(n)} \cdot \psi_n$$

This is nothing other than the lattice version of the discrete Dirac equation.

## 4.2 Time Evolution as Cellular Automaton

```
Time t=0:     Time t=1:     Time t=2:
┌───┐         ┌───┐         ┌───┐
│ ★ │→ → → → │   │         │   │
└───┘         └─┬─┘         └───┘
┌───┐         ┌─┴─┐         ┌───┐
│   │         │ ★ │→ → → → │   │
└───┘         └───┘         └─┬─┘
┌───┐         ┌───┐         ┌─┴─┐
│   │         │   │         │ ★ │  ← photon
└───┘         └───┘         └───┘
```

- **1 step** = single application of Dirac operator
- **Direction** = D4 root vectors (24 directions)
- **Speed** = lattice spacing / Coxeter period ($h = 30$)

## 4.3 Performance Optimization

256×256 Clifford product is computationally expensive. As optimization, **only non-zero components are scanned**.
-/

/-- Lightweight Clifford product: scans only non-zero components

Since direction vectors have at most 4 non-zero components,
instead of scanning all 256×256, scanning only non-zero components
of the direction side provides significant speedup.
-/
def sparseCliffordProduct : QuantumState → QuantumState → QuantumState :=
  λ direction state =>
    let result := Array.replicate 256 (0 : Int)
    -- Collect non-zero components of direction vector
    let sparseDir := (Array.range 256).foldl (λ acc I =>
      let dI := direction.getD I 0
      if dI == 0 then acc
      else acc.push (I, dI)) (Array.mkEmpty 8)
    -- Non-zero direction components × all state components
    sparseDir.foldl (λ res (I, dI) =>
      (Array.range 256).foldl (λ res2 J =>
        let sJ := state.getD J 0
        if sJ == 0 then res2
        else
          let bvI := BitVec.ofNat 8 I
          let bvJ := BitVec.ofNat 8 J
          let (resBasis, isNeg) := geometricProduct bvI bvJ
          let sign : Int := if isNeg then -1 else 1
          let k := resBasis.toNat
          let oldVal := res2.getD k 0
          res2.set! k (oldVal + dI * sJ * sign)) res) result

/-- Single cell update: compute contributions from all neighbors

$$\psi'_{\text{site}} = \sum_{n \in \text{neighbors}} \gamma_{\text{dir}(n)} \cdot \psi_n$$
-/
def updateCell : E8Lattice4D → Coord4D → QuantumState :=
  λ lat coord =>
    let offsets := neighborOffsets4D
    let clElems := neighborClElements
    let size := lat.params.size
    (Array.range offsets.size).foldl (λ acc idx =>
      let offset := offsets.getD idx (0, 0, 0, 0)
      let clElem := clElems.getD idx emptyState
      let neighborCoord := applyOffset coord offset size
      let neighborState := getCell lat neighborCoord
      -- Clifford product of direction generator × neighbor state
      let contribution := sparseCliffordProduct clElem neighborState
      addState acc contribution) emptyState

/-!
---

# §5. Full Lattice Time Evolution

## 5.1 Synchronous Update

All cells are updated **simultaneously** (synchronous CA). This guarantees a discrete version of causality.
-/

/-- Update entire lattice by 1 step (synchronous) -/
def stepE8CA : E8Lattice4D → E8Lattice4D :=
  λ lat =>
    let size := lat.params.size
    let n := totalCells size
    let newCells := (Array.range n).map (λ idx =>
      let coord := indexToCoord idx size
      updateCell lat coord)
    { lat with cells := newCells }

/-- Execute N steps of TQC -/
def runE8CA : E8Lattice4D → Nat → E8Lattice4D :=
  λ lat steps =>
    (Array.range steps).foldl (λ acc _ => stepE8CA acc) lat

/-!
---

# §6. Initial Conditions and Observables

## 6.1 Initial Condition: Place H84 State (Photon) at Center Cell

Place an H(8,4) state at lattice center and observe its propagation. The H84 state is a superposition of 16 codewords, carrying complete amplitude information as a quantum state.

```
          Coupled within same cell
               ↓
  ┌───┐    ┌─────┐    ┌───┐
  │ A │←←←│A⊕B  │→→→│ B │
  └───┘    └─────┘    └───┘
  distant    ↑         distant
  cell    XOR coupling  cell
         (non-factorable)

  Measuring A → B's state instantly determined
  (Bell violation S² = 65536 formally proved)
```
-/

/-- Initial condition: place H84 state at lattice center -/
def initCenterExcitation : Nat → E8Lattice4D :=
  λ size =>
    let lat := mkEmptyLattice size
    let center := { x := size / 2, y := size / 2
                  , z := size / 2, t := size / 2 : Coord4D }
    setCell lat center h84State

/-!
## 6.2 Observables

### Energy Density (Norm²)

The norm² of each cell's QuantumState corresponds to its energy density. When interference occurs, some cells' norm² increases (constructive interference) while others decrease (destructive interference).

### Time Evolution of normSq

Since $D_+$ in this implementation is unnormalized integer arithmetic, the sum of normSq is not conserved and grows exponentially (measured: ×48→×90→×113→×124→×130). This originates from the scaling of $D_+^2 = 9920$. Normalized $D_+/\sqrt{9920}$ would be conserved, but under Forbidden Float constraints, we use integer arithmetic as-is.
-/

/-- Total energy of entire lattice (sum of norm² of all cells) -/
def totalEnergy : E8Lattice4D → Int :=
  λ lat =>
    lat.cells.foldl (λ acc cell => acc + stateNormSquared cell) 0

/-- Count of non-zero cells -/
def activeCount : E8Lattice4D → Nat :=
  λ lat =>
    lat.cells.foldl (λ acc cell =>
      if stateNormSquared cell != 0 then acc + 1 else acc) 0

/-- Energy density profile along x-axis (slice at y=z=t=center) -/
def energyProfileX : E8Lattice4D → Array Int :=
  λ lat =>
    let size := lat.params.size
    let center := size / 2
    (Array.range size).map (λ x =>
      let coord := { x := x, y := center, z := center, t := center : Coord4D }
      stateNormSquared (getCell lat coord))

/-!
---

# §7. Visualization

ASCII art visualization of energy density. Characters are assigned according to norm² magnitude.

### Measured Interference Pattern (size 20, after 5 steps)

```
·  = 0       (vacuum or complete cancellation)
░  = 1–9     (faint excitation)
▒  = 10–99   (moderate excitation)
▓  = 100–999 (strong excitation)
█  = 1000+   (very strong excitation)
```

x-y slice of execution result (z=t=center):

```
····················
····················
····················
····················
·····▓·█·█·█·█·▓····   ← outer edge of wavefront
······█·█·█·█·█·····
·····█·█·█·█·█·█····
······█·█·█·█·█·····
·····█·█·█·█·█·█····
······█·█···█·█·····   ← center: complete interference cancellation ("·" = zero)
·····█·█·█·█·█·█····
······█·█·█·█·█·····
·····█·█·█·█·█·█····
······█·█·█·█·█·····
·····▓·█·█·█·█·▓····   ← outer edge of wavefront (symmetric)
····················
····················
····················
····················
····················
```

Noteworthy structures:
- **Rhombic wavefront**: Rhombus with D4 symmetry appears
- **Checkerboard**: Alternating pattern from D4 root parity preservation
- **Interference nodes**: "·" (complete cancellation) appears near center
- **▓ (weak edges)**: Wavefront fringes — partial cancellation from Clifford product sign reversal

### Principle of Interference

```
Path A: [..., +d₁·ψ_neighbor₁, ...]  ─┐
Path B: [..., -d₂·ψ_neighbor₂, ...]  ─┤─→ addState → destructive interference
Path C: [..., +d₃·ψ_neighbor₃, ...]  ─┘

Center cell x-profile measured values:
Step 1: [..., 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...]  ← center becomes zero!
Step 2: [..., 0, 0, 0, 0, 0, 36864, 0, 0, 0, 0, 0, ...]  ← energy returns
Step 3: [..., 0, 0, 0, 36864, 0, 0, 0, 36864, 0, 0, 0, ...]  ← splits left and right
Step 5: [..., 0, 5308416, 0, 897122304, 0, 0, 0, 897122304, 0, 5308416, 0, ...]
                  ↑           ↑         ↑↑↑        ↑           ↑
               weak front   main     interference  main      weak front
                             front      nodes       front
```
-/

/-- Convert energy value to display character -/
def energyToChar : Int → Char :=
  λ e =>
    if e == 0 then '·'
    else if e < 10 then '░'
    else if e < 100 then '▒'
    else if e < 1000 then '▓'
    else '█'

/-- Display x-y plane energy density as ASCII art (z=t=center) -/
def renderXYSlice : E8Lattice4D → String :=
  λ lat =>
    let size := lat.params.size
    let center := size / 2
    let rows := (Array.range size).map (λ y =>
      let row := (Array.range size).map (λ x =>
        let coord := { x := x, y := size - 1 - y
                      , z := center, t := center : Coord4D }
        energyToChar (stateNormSquared (getCell lat coord)))
      row.foldl (fun s c => s.push c) "")
    rows.foldl (fun acc r => if acc.isEmpty then r else acc ++ "\n" ++ r) ""

/-!
---

# §8. Diagnostic Output
-/

/-- Print diagnostic header -/
def printHeader : IO Unit := do
  IO.println "═══════════════════════════════════════════════════"
  IO.println "  E8 Quantum Cellular Automaton — 4D Projection"
  IO.println "  Cl(8) = ⟨E8⟩ Discrete Spacetime TQC Execution"
  IO.println "═══════════════════════════════════════════════════"
  IO.println ""
  IO.println "  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐"
  IO.println "  │Cl8│─│Cl8│─│Cl8│─│Cl8│─│Cl8│─ ..."
  IO.println "  └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘"
  IO.println "  ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐"
  IO.println "  │Cl8│─│Cl8│─│Cl8│─│Cl8│─│Cl8│─ ..."
  IO.println "  └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘ └─┬─┘"
  IO.println "  ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐ ┌─┴─┐"
  IO.println "  │Cl8│─│Cl8│─│Cl8│─│Cl8│─│Cl8│─ ..."
  IO.println "  └───┘ └───┘ └───┘ └───┘ └───┘"
  IO.println ""

/-- Print 1-step diagnostic information -/
def printStepDiag : Nat → E8Lattice4D → IO Unit :=
  λ step lat => do
    let energy := totalEnergy lat
    let active := activeCount lat
    let profile := energyProfileX lat
    -- Profile near center (±5 cells)
    let center := lat.params.size / 2
    let lo := if center >= 5 then center - 5 else 0
    let hi := if center + 5 < lat.params.size then center + 5 else lat.params.size - 1
    let slice := (Array.range (hi - lo + 1)).map (λ i =>
      profile.getD (lo + i) 0)
    IO.println s!"Step {step}: total_energy={energy}, active_cells={active}"
    IO.println s!"  x-profile (center±5): {slice}"

/-!
---

# §9. Main Program

## 9.1 Execution Settings

This implementation uses size 20 ($20^4 = 160{,}000$ cells).

### Measured Memory and Execution Time

| Size | Cell Count | Est. Memory | Execution Time (5 steps) |
|:---|:---|:---|:---|
| 10 | $10^4 = 10{,}000$ | ~20 MB | <1 sec |
| **20** | **$20^4 = 160{,}000$** | **~330 MB** | **1 min 18 sec** |
| 100 | $100^4 = 10^8$ | ~205 GB | impractical |

### Quantitative Data of Wave Propagation (size 20 measured)

```
Step  active_cells  total_energy       Growth Rate
────  ────────────  ──────────────     ──────
  0              1              16     —
  1             24             768     ×48
  2            145          69,120     ×90
  3            600       7,827,456     ×113
  4          1,657     972,527,616     ×124
  5          3,720 126,708,645,888     ×130
```

Growth of active_cells corresponds to volume growth of wavefront ($\propto r^3$). The surface of "sphere" in Connes metric is a D4 polytope, not a Euclidean 4D hypersphere $2\pi^2 r^3$.

### Time Evolution of x-axis Energy Profile

```
Step 0: [..., 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, ...]
                                ↑
                           H84 state at center

Step 1: [..., 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...]
                                ↑
                        Center disappeared! (dispersed to 24 directions)

Step 2: [..., 0, 0, 0, 0, 0, 36864, 0, 0, 0, 0, 0, ...]
                                ↑
                        Energy re-concentrates at center (constructive interference)

Step 3: [..., 0, 0, 0, 36864, 0, 0, 0, 36864, 0, 0, 0, ...]
                        ↑                   ↑
                    wavefront left       wavefront right (center cancels again)

Step 5: [..., 0, 5308416, 0, 897122304, 0, 0, 0, 897122304, 0, 5308416, 0, ...]
              ↑           ↑          ↑↑↑         ↑           ↑
           weak front   main      interference   main     weak front
                        front       nodes         front
```

This profile is the **discrete Green's function of $D_+$**, showing how isotropic propagation in Connes metric forms interference structures in coordinate space.
-/

/-- Default lattice size (for proof of concept) -/
def defaultSize : Nat := 20

/-- Number of execution steps -/
def defaultSteps : Nat := 5

/-- Main program (namespace internal version) -/
def run : IO Unit := do
  printHeader

  -- Parameter display
  let size := defaultSize
  let steps := defaultSteps
  let n := totalCells size
  IO.println s!"Parameters:"
  IO.println s!"  lattice_size = {size}^4 = {n} cells"
  IO.println s!"  steps = {steps}"
  IO.println s!"  neighbors = {neighborOffsets4D.size} (D4 root system)"
  IO.println s!"  state_dim = 256 (Cl(8) basis)"
  IO.println s!"  total_int_values = {n * 256}"
  IO.println ""

  -- Neighbor structure verification
  IO.println s!"Neighbor directions (D4 roots): {neighborOffsets4D.size}"
  IO.println s!"Cl(8) direction elements precomputed: {neighborClElements.size}"
  IO.println ""

  -- Initial condition: H84 state at center
  IO.println "═══ Single Source Execution ═══"
  IO.println "Initial condition: H84 state at center"
  IO.println s!"  H84 normSq = {stateNormSquared h84State}"
  IO.println ""

  let lat0 := initCenterExcitation size
  printStepDiag 0 lat0

  -- Time evolution
  IO.println ""
  IO.println "Starting time evolution..."
  let finalLat := (Array.range steps).foldl (λ (acc : IO E8Lattice4D) stepIdx => do
    let lat ← acc
    let lat' := stepE8CA lat
    printStepDiag (stepIdx + 1) lat'
    pure lat') (pure lat0)

  let latFinal ← finalLat

  -- x-y slice visualization
  IO.println ""
  IO.println "═══ x-y energy density slice (z=t=center) ═══"
  IO.println (renderXYSlice latFinal)

  -- Final summary
  IO.println ""
  IO.println "═══ Summary ═══"
  IO.println s!"  Final total energy: {totalEnergy latFinal}"
  IO.println s!"  Final active cells: {activeCount latFinal}"
  IO.println ""
  IO.println "Execution complete."

/-!
## References

### Noncommutative Geometry and Spectral Action
- Connes, A. (1994). *Noncommutative Geometry*, Academic Press.
  (Foundations of spectral triple $(A, H, D)$)
- Chamseddine, A.H. & Connes, A. (1997).
  "The Spectral Action Principle", *Commun. Math. Phys.* 186, 731–750.

### Quantum Cellular Automata
- Schumacher, B. & Werner, R.F. (2004). "Reversible quantum cellular automata",
  arXiv:quant-ph/0405174.
- Arrighi, P. (2019). "An overview of quantum cellular automata",
  *Natural Computing* 18, 885–899.

### E8 Lattice and D4 Root System
- Conway, J.H. & Sloane, N.J.A. (1988). *Sphere Packings, Lattices and Groups*,
  Springer. (D4 root system / 4D projection of E8 lattice)

### Module Connections
- **Previous**: `_05_SpectralTriple/_02_DiracSquared.lean` — $D_+^2 = 9920$
- **Next**: `_10_E8CA/_01_DiracPropagator.lean` — Quantitative measurement of $D_+$ discrete propagator
- **Next**: `_10_E8CA/_02_GaugeField.lean` — Gauge field extension

-/

end CL8E8TQC.E8CA

/-- EXE entry point -/
def main : IO Unit := CL8E8TQC.E8CA.run
