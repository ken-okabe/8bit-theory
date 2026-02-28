import Lake
open Lake DSL

package CL8E8TQC

-- Default target (lean_lib)
-- Modules built by `lake build`
@[default_target]
lean_lib CL8E8TQC where
  roots := #[`CL8E8TQC]

-- §3 Coxeter Analysis: Dirac Dynamics (executable)
-- Excluded from lean_lib (contains `def main`)
lean_exe diracDynamics where
  root := `CL8E8TQC._04_CoxeterAnalysis._02_DiracDynamics

-- §9 E8 Quantum Cellular Automaton (executables)
-- Excluded from lean_lib (contain `def main`)
lean_exe e8ca where
  root := `CL8E8TQC._10_E8CA._00_E8CellularAutomaton

lean_exe diracPropagator where
  root := `CL8E8TQC._10_E8CA._01_DiracPropagator

lean_exe gaugeField where
  root := `CL8E8TQC._10_E8CA._02_GaugeField
