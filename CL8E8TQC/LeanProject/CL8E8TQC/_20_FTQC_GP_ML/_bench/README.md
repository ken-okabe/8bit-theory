# `_bench/` — O(n) Scaling Measurement Scripts

## Purpose

Measurement scripts providing empirical evidence for the "O(n) scaling" claimed in `CL8E8TQC/_20_FTQC_GP_ML/_02_DrugDiscovery_GP.lean` §5 and `CL8E8TQC/_20_FTQC_GP_ML/_03_MultiE8_GP.lean` §6.

**Measurement method**: Due to Lean4's lazy evaluation of pure functions, wall-clock measurement via `IO.monoMsNow` does not function correctly. By passing computed results to `IO.println` in `main`, lazy evaluation is forced, and the `real` value from the external `time` command reflects actual computation time.

---

## Script List

### Single E8 GP (d=8)

| Script | n | Corresponding argument |
|:---|:---|:---|
| `bench_gp_100.lean` | 100 | `_02` §5.3 |
| `bench_gp_1000.lean` | 1,000 | `_02` §5.3 |
| `bench_gp_10000.lean` | 10,000 | `_02` §5.3 |
| `bench_gp_100000.lean` | 100,000 | `_02` §5.3 |

### Multi-E8 GP (n=10,000)

| Script | L | d | Corresponding argument |
|:---|:---|:---|:---|
| `bench_multi_L1.lean` | 1 | 8 | `_03` §6.2 |
| `bench_multi_L2.lean` | 2 | 16 | `_03` §6.2 |
| `bench_multi_L4.lean` | 4 | 32 | `_03` §6.2 |

---

## How to Run

Run from the `____working/` directory.

```bash
# Single E8 GP scaling (small → large)
time lake env lean --run _bench/bench_gp_100.lean
time lake env lean --run _bench/bench_gp_1000.lean
time lake env lean --run _bench/bench_gp_10000.lean
time lake env lean --run _bench/bench_gp_100000.lean

# Multi-E8 GP scaling (L=1,2,4)
time lake env lean --run _bench/bench_multi_L1.lean
time lake env lean --run _bench/bench_multi_L2.lean
time lake env lean --run _bench/bench_multi_L4.lean
```

Run each script **3 or more times** and use the best value (warm cache). (First run includes JIT warm-up cost and serves only as reference.)

---

## Expected Output Example

```
n=1000, positives=128/256, solDen_digits=25
```

---

## Notes

- `IO.monoMsNow` cannot be used for wall-clock measurement of pure functions due to Lean4's lazy evaluation
- Measured values depend on environment (CPU, RAM, Lean version)
- The §5.3 table values in the main text are measured on NixOS / Lean 4.25.0
