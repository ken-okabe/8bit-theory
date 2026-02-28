-- Multi-E8 GP Scaling Benchmark: L=4 (d=32), n=10000
-- Measurement: time lake env lean --run _bench/bench_multi_L4.lean
-- Due to Lean4's lazy evaluation, IO.monoMsNow cannot be used. Output to IO.println forces evaluation; measure with external time command.

import CL8E8TQC._20_FTQC_GP_ML._03_MultiE8_GP

open CL8E8TQC.Foundation (Cl8Basis)
open CL8E8TQC.FTQC_GP_ML.MultiE8GP

def main : IO Unit := do
  let blockCount := 4
  let n := 10000
  let (xs, ys) := genMultiTrainData n blockCount
  let gp := mkMultiE8GP blockCount xs ys 1
  let positives := (Array.range 256).foldl (λ acc i =>
    let testX := (Array.range blockCount).map (λ l =>
      if l == 0 then (BitVec.ofNat 8 i : Cl8Basis)
      else (0b00000000#8 : Cl8Basis))
    let p := predictMulti gp testX
    let _ := uncertaintyMulti gp testX
    acc + if p.numerator > 0 then 1 else 0) (0 : Nat)
  IO.println s!"n={n}, L={blockCount}, d={8*blockCount}, positives={positives}/256, solDen_digits={toString gp.solDen |>.length}"
