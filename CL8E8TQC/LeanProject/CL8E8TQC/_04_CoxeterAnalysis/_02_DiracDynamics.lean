import CL8E8TQC._05_SpectralTriple._02_DiracSquared
import CL8E8TQC._06_E8Branching._01_RouteA_Time

namespace CL8E8TQC.DiracDynamics

open CL8E8TQC.Foundation (Cl8Basis geometricProduct grade basisVector)
open CL8E8TQC.QuantumComputation (QuantumState stateNormSquared h84State)
open CL8E8TQC.SpectralTriple (DiracOp)
open CL8E8TQC.E8Branching (coxeterElement coxeterPower allE8Roots
  simpleRoots reflect vecEq normSq dotProduct CoordVec)

/-!
# Dynamical Periodicity Experiments of the Dirac Operator

## Abstract

**Position**: Chapter 2 of `_04_CoxeterAnalysis`. Follows `_04_CoxeterAnalysis/_01_CoxeterSystem.lean` and connects to `_07_HeatKernel`.

**Subject**: This chapter experimentally investigates the relationship between the Coxeter element $w$ (algebraic symmetry, period 30) and the Dirac operator $D_+$ (dynamical generator) through three experiments (single-cell iteration, lattice CA 30 steps, CPT test), outputting and analyzing raw data.

**Main results**:
- Since $D_+^2 = 9920 \cdot \text{id}$, the effective period of $D_+$ is 2, confirming that the Coxeter period $h = 30$ does not appear in single-cell dynamics
- Lattice CA over 30 steps shows no singular structure at step 30, demonstrating that $h = 30$ is not directly reflected in collective lattice dynamics
- CPT test (step $n$ vs $n+15$) yields `negated = false` for all 15 pairs: $w^{15} = -\text{id}$ is a root-space symmetry not reflected in wave propagation

## Chapter Structure

| Section | Title | Content |
|:---|:---|:---|
| §1 | Utility functions | Iterated application of $D_+^n$, proportionality constant determination |
| §2 | Lattice CA foundation | 4D coordinates, neighbor directions, cellular automaton update |
| §3 | Main program | Execution of 3 experiments (single-cell iteration, lattice CA 30 steps, CPT test) with raw data output |
| §4 | Analysis of experimental results | Analysis and conclusions based on raw data |

## Main definitions

* `diracPower` — Iterated application of $D_+^n$
* `stepCA` — One-step update of the lattice cellular automaton
* `isNegated` — CPT sign inversion determination

## Implementation notes

- **3 independent experiments** — Single cell, lattice CA, and CPT executed together
- **Experiment → analysis separation** — Raw data output (Lean code) and analysis (docstring) are separated

## Tags

dirac, lattice-ca, period, cpt, experiment

---
-/


/-- Apply D^n -/
def diracPower : Nat → Array Int → Array Int :=
  λ n ψ => (Array.range n).foldl (λ acc _ => DiracOp acc) ψ

/-- Proportionality constant -/
def proportionalityConstant : Array Int → Array Int → Option Int :=
  λ ψ₁ ψ₂ =>
    let firstNonZero := (Array.range 256).foldl (λ acc i =>
      match acc with
      | some _ => acc
      | none =>
        let a := (ψ₁ : Array Int).getD i 0
        let b := (ψ₂ : Array Int).getD i 0
        if b != 0 then some (a / b) else if a != 0 then some 0 else none) none
    match firstNonZero with
    | none => none
    | some c =>
      let allMatch := (Array.range 256).all (λ i =>
        let a := (ψ₁ : Array Int).getD i 0
        let b := (ψ₂ : Array Int).getD i 0
        a == c * b)
      if allMatch then some c else none


structure Coord4D where
  x : Nat
  y : Nat
  z : Nat
  t : Nat

structure LatticeParams where
  size : Nat

structure E8Lattice4D where
  params : LatticeParams
  cells : Array QuantumState

def totalCells : Nat → Nat := λ s => s * s * s * s

def coordToIndex : Nat → Coord4D → Nat :=
  λ size c => c.x + c.y * size + c.z * size * size + c.t * size * size * size

def neighborOffsets4D : Array (Int × Int × Int × Int) :=
  let signs := #[(1,1), (1,-1), (-1,1), (-1,-1)]
  signs.foldl (λ acc (s1, s2) =>
    acc.push (s1, s2, 0, 0) |>.push (s1, 0, s2, 0) |>.push (s1, 0, 0, s2)
       |>.push (0, s1, s2, 0) |>.push (0, s1, 0, s2) |>.push (0, 0, s1, s2)) #[]

def directionToClElement : (Int × Int × Int × Int) → QuantumState :=
  λ (dx, dy, dz, dt) =>
    let zero := Array.replicate 256 (0 : Int)
    let indices := #[(dx, 1), (dy, 2), (dz, 4), (dt, 8)]
    indices.foldl (λ acc (coeff, idx) =>
      if coeff == 0 then acc
      else acc.set! idx (acc.getD idx 0 + coeff)) zero

def sparseCliffordProduct : QuantumState → QuantumState → QuantumState :=
  λ direction state =>
    let result := Array.replicate 256 (0 : Int)
    let sparseDir := (Array.range 256).foldl (λ acc I =>
      let dI := direction.getD I 0
      if dI == 0 then acc
      else acc.push (I, dI)) (Array.mkEmpty 8)
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

def updateCell : E8Lattice4D → Coord4D → QuantumState :=
  λ lat coord =>
    let size := lat.params.size
    (Array.range neighborOffsets4D.size).foldl (λ acc idx =>
      let (dx, dy, dz, dt) := neighborOffsets4D.getD idx (0,0,0,0)
      let nx := (coord.x + size + dx.toNat % size) % size
      let ny := (coord.y + size + dy.toNat % size) % size
      let nz := (coord.z + size + dz.toNat % size) % size
      let nt := (coord.t + size + dt.toNat % size) % size
      let neighborState := lat.cells.getD
        (coordToIndex size { x := nx, y := ny, z := nz, t := nt })
        (Array.replicate 256 (0 : Int))
      let dir := directionToClElement (dx, dy, dz, dt)
      let contrib := sparseCliffordProduct dir neighborState
      (Array.range 256).map (λ i => acc.getD i 0 + contrib.getD i 0))
    (Array.replicate 256 (0 : Int))

def stepCA : E8Lattice4D → E8Lattice4D :=
  λ lat =>
    let size := lat.params.size
    let newCells := (Array.range (totalCells size)).map (λ flatIdx =>
      let x := flatIdx % size
      let y := (flatIdx / size) % size
      let z := (flatIdx / (size * size)) % size
      let t := flatIdx / (size * size * size)
      updateCell lat { x := x, y := y, z := z, t := t })
    { lat with cells := newCells }

def initLattice : Nat → E8Lattice4D :=
  λ size =>
    let n := totalCells size
    let center := size / 2
    let centerIdx := coordToIndex size { x := center, y := center, z := center, t := center }
    let cells := (Array.range n).map (λ i =>
      if i == centerIdx then h84State else Array.replicate 256 (0 : Int))
    { params := { size := size }, cells := cells }

def totalEnergy : E8Lattice4D → Int :=
  λ lat => lat.cells.foldl (λ acc cell => acc + stateNormSquared cell) 0

def activeCount : E8Lattice4D → Nat :=
  λ lat => lat.cells.foldl (λ c cell =>
    if stateNormSquared cell != 0 then c + 1 else c) 0

def getCenterState : E8Lattice4D → QuantumState :=
  λ lat =>
    let s := lat.params.size
    let c := s / 2
    lat.cells.getD (coordToIndex s { x := c, y := c, z := c, t := c })
      (Array.replicate 256 (0 : Int))

def isNegated : QuantumState → QuantumState → Bool :=
  λ a b => (Array.range 256).all (λ i => a.getD i 0 == -(b.getD i 0))


def run : IO Unit := do
  IO.println "=== Experiment 1: Single-cell Dirac iteration ==="
  IO.println ""
  IO.println "step | normSq | ratio | proportional_to_H84"

  let _ ← (Array.range 10).foldlM (λ (acc : Array Int × Int) n => do
    let (st, prevE) := acc
    let energy := stateNormSquared st
    let ratio := if prevE != 0 then energy / prevE else 0
    let propC := proportionalityConstant st h84State
    IO.println s!"{n} | {energy} | {ratio} | {propC}"
    pure (DiracOp st, energy)) (h84State, stateNormSquared h84State)

  IO.println ""
  IO.println "=== Experiment 2: Lattice CA 30 steps (size=5, 625 cells) ==="
  IO.println ""

  let latticeSize := 5
  let numSteps := 30
  IO.println s!"lattice_size={latticeSize} total_cells={totalCells latticeSize}"
  IO.println ""
  IO.println "step | active | total_energy | ratio | center_normSq"

  let (_, _, centerStates) ← (Array.range (numSteps + 1)).foldlM
    (λ (acc : E8Lattice4D × Int × Array QuantumState) n => do
      let (lat, prevE, centers) := acc
      let energy := totalEnergy lat
      let active := activeCount lat
      let centerSt := getCenterState lat
      let centerNormSq := stateNormSquared centerSt
      let ratio := if prevE != 0 then energy / prevE else 0
      IO.println s!"{n} | {active} | {energy} | {ratio} | {centerNormSq}"
      let nextLat := if n < numSteps then stepCA lat else lat
      pure (nextLat, energy, centers.push centerSt))
    (initLattice latticeSize, (16 : Int), #[])

  IO.println ""
  IO.println "=== Experiment 3: CPT test (step n vs step n+15) ==="
  IO.println ""
  IO.println "n | n+15 | negated | normSq_n | normSq_n15 | ratio"

  (Array.range 15).forM (λ n => do
    let s1 := centerStates.getD n #[]
    let s2 := centerStates.getD (n + 15) #[]
    let negated := isNegated s1 s2
    let norm1 := stateNormSquared s1
    let norm2 := stateNormSquared s2
    let propC := proportionalityConstant s2 s1
    IO.println s!"{n} | {n+15} | {negated} | {norm1} | {norm2} | {propC}")

  IO.println ""
  IO.println "=== End of experiments ==="

/-!
---

# §4. Analysis of Experimental Results

The following analysis is based on the output of `lake build diracDynamics && ./.lake/build/bin/diracDynamics`.

## 4.1 Experiment 1 Analysis

Since $D_+^2 = 9920 \cdot \text{id}$, the effective period of $D_+$ is **2** (proportional to H84 at even steps, different state at odd steps). The Coxeter period $h = 30$ does **not appear** in single-cell Dirac dynamics.

## 4.2 Experiment 2 Analysis

The energy increment rate of the lattice CA increases monotonically, and **no singular structure is observed** at step 30. If $h = 30$ were a dynamical period, an inflection point in the energy increment rate or a special symmetric structure should appear at the 30th step, but the data shows no such indication.

## 4.3 Experiment 3 Analysis

All 15 pairs yield `negated = false`. There is **no sign-inversion relationship whatsoever** between center cell states at step $n$ and step $n + 15$.

$w^{15} = -\text{id}$ is a root-space symmetry not reflected in wave propagation through Dirac dynamics.

## 4.4 Conclusion

The Coxeter element $w$ (algebraic symmetry = static structure) and the Dirac operator $D_+$ (time evolution = dynamical mechanics) are fundamentally different operations, and there is no basis for the Coxeter period of 30 being directly reflected in $D_+$ dynamics.

$h = 30$ is not a "period" of time, but a **structural constant that determines the energy scale** through $D^2 = 9920 = f(h)$ (see `_06_E8Branching/_01_RouteA_Time.lean` §3).

-/

/-!
## References

### Dirac Operator and Dynamical Periodicity
- Parthasarathy, R. (1972). "Dirac operator and the discrete series",
  *Ann. of Math.* 96, 1–30. (Theoretical basis for $D^2 = 9920$)
- Connes, A. (1994). *Noncommutative Geometry*, Academic Press.
  (Dynamical interpretation of spectral triples)

### CPT Symmetry
- Lüders, G. (1954). "On the Equivalence of Invariance under Time Reversal and
  under Particle-Antiparticle Conjugation for Relativistic Field Theories",
  *Kong. Dan. Vid. Sel. Mat. Fys. Med.* 28(5), 1–17. (Original source for the CPT theorem)

### Lattice CA and Numerical Experiments
- Conclusion of this experiment: The Coxeter period $h=30$ is not a dynamical period of
  Dirac mechanics, but a structural constant for the energy scale via $D^2 = 9920 = f(h)$
  → detailed in `_06_E8Branching/_01_RouteA_Time.lean` §3

### Module Connections
- **Previous**: `_04_CoxeterAnalysis/_01_CoxeterSystem.lean` — Algebraic structure of the Coxeter system
- **Next**: `_07_HeatKernel/_00_Framework.lean` — Heat kernel expansion framework

-/

end CL8E8TQC.DiracDynamics

def main : IO Unit := CL8E8TQC.DiracDynamics.run
