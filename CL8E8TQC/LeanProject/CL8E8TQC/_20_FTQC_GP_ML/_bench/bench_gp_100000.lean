-- O(n) Scaling Benchmark: n=100000
-- Measurement: time lake env lean --run _bench/bench_gp_100000.lean
-- Due to Lean4's lazy evaluation, IO.monoMsNow cannot be used. Output to IO.println forces evaluation; measure with external time command.

import CL8E8TQC._20_FTQC_GP_ML._00_LinearTimeGP

open CL8E8TQC.Foundation (Cl8Basis)
open CL8E8TQC.FTQC_GP_ML.LinearTimeGP

def drugActivity : Cl8Basis → Int :=
  λ x => e8Kernel x (0b00110101#8 : Cl8Basis)

def main : IO Unit := do
  let n := 100000
  let xs := (Array.range n).map (λ i => (BitVec.ofNat 8 (i % 256) : Cl8Basis))
  let ys := xs.map drugActivity
  let gp := mkLinearGP xs ys 1
  let positives := (Array.range 256).foldl (λ acc i =>
    let x := (BitVec.ofNat 8 i : Cl8Basis)
    let p := predict gp x
    let _ := uncertainty gp x
    acc + if p.numerator > 0 then 1 else 0) (0 : Nat)
  IO.println s!"n={n}, positives={positives}/256, solDen_digits={toString gp.solDen |>.length}"
