-- CL8E8TQC — From 8 Bits to the Universe: A Unified Theory via Discrete Noncommutative Geometry
-- Main entry point
--
-- Build notes:
--   Standard build (lean_lib): lake build
--   Individual executables:
--     lake build diracDynamics   -- _04_CoxeterAnalysis/_02_DiracDynamics
--     lake build e8ca            -- _10_E8CA/_00_E8CellularAutomaton
--     lake build diracPropagator -- _10_E8CA/_01_DiracPropagator
--     lake build gaugeField      -- _10_E8CA/_02_GaugeField

-- _00 Introduction
import CL8E8TQC._00_Introduction._00_LiterateCoding
import CL8E8TQC._00_Introduction._01_Overview

-- _01 Algebraic Foundations
import CL8E8TQC._01_TQC._01_Cl8E8H84
import CL8E8TQC._01_TQC._02_PinSpin
import CL8E8TQC._01_TQC._03_QuantumState
import CL8E8TQC._01_TQC._04_TQC_Universality
import CL8E8TQC._01_TQC._05_FTQC

-- _02 Quantum Nonlocality
-- Note: Adds ~102 seconds on first build (bv_decide SAT proof over 2^86 is inherently heavy)
-- import CL8E8TQC._02_BellSAT._00_CortezKS
-- import CL8E8TQC._02_BellSAT._01_QuantumCHSH
-- import CL8E8TQC._02_BellSAT._02_KSTheory

-- _03 E8 Dirac Operator
import CL8E8TQC._03_E8Dirac._00_LieAlgebra
import CL8E8TQC._03_E8Dirac._01_A4Embedding
import CL8E8TQC._03_E8Dirac._02_DimensionFormula
import CL8E8TQC._03_E8Dirac._03_Parthasarathy
import CL8E8TQC._03_E8Dirac._04_PositiveRoots

-- _04 Coxeter Analysis / Boundary–Bulk Classification
-- Note: _01_CoxeterSystem: Adds ~170 seconds on first build
--   (native_decide for coxeterPower30_is_id and transitionCountsStationary is inherently heavy)
-- import CL8E8TQC._04_CoxeterAnalysis._01_CoxeterSystem
-- Note: _02_DiracDynamics: Contains `def main`, dedicated lean_exe (lake build diracDynamics)
-- import CL8E8TQC._04_CoxeterAnalysis._02_DiracDynamics
-- import CL8E8TQC._04_CoxeterAnalysis._03_OrbitAnalysis

-- _05 Connes Spectral Triple
import CL8E8TQC._05_SpectralTriple._00_ConnesNCG
import CL8E8TQC._05_SpectralTriple._01_DiracOp
import CL8E8TQC._05_SpectralTriple._02_DiracSquared
import CL8E8TQC._05_SpectralTriple._03_Commutator

-- _06 E8 Quadruple Branching (Time, Space, Force, Matter, Gravity)
import CL8E8TQC._06_E8Branching._00_Overview
import CL8E8TQC._06_E8Branching._01_RouteA_Time
import CL8E8TQC._06_E8Branching._02_RouteB_Space
import CL8E8TQC._06_E8Branching._03_RouteC_Force
import CL8E8TQC._06_E8Branching._04_RouteD_Matter
import CL8E8TQC._06_E8Branching._05_Gravity

-- _07 Heat Kernel Expansion (a₀, a₂, a₄)
import CL8E8TQC._07_HeatKernel._00_Framework
import CL8E8TQC._07_HeatKernel._01_Derivation

-- _08 Standard Model Matching
import CL8E8TQC._08_StandardModel._00_BoundaryAxioms
import CL8E8TQC._08_StandardModel._01_Verification

-- _09 dS/CFT, E8 TEE Formula, de Sitter Emergence
import CL8E8TQC._09_dSCFT._00_CosmologicalConstant
import CL8E8TQC._09_dSCFT._01_TEE
import CL8E8TQC._09_dSCFT._02_dSEmergence

-- _10 E8 Quantum Cellular Automaton (lean_exe only, not included in lean_lib)
-- Build individually: lake build e8ca / diracPropagator / gaugeField

-- _20–22 Next-Generation Quantum Machine Learning
-- Note: Clean build total ~2 min 40 s (major heavy files listed below)
-- Note: _20_FTQC_GP_ML/_01_KernelCatalog: ~25 s (exhaustive Bott periodicity kernel verification)
-- Note: _20_FTQC_GP_ML/_03_MultiE8_GP: ~23 s (Multi-E8 native_decide)
-- Note: _20_FTQC_GP_ML/_04_ActiveLearning: ~19 s (AL empirical comparison)
-- Note: _22_ExactDeepBayesianOptimization/_00_ExactDeepBO: ~19 s (Deep BO integer arithmetic verification)
-- Note: _21_QuantumDeepGP/_03_QuantumInference: ~36 s (BQP-completeness proof, heaviest native_decide)
import CL8E8TQC._20_FTQC_GP_ML._00_LinearTimeGP
import CL8E8TQC._20_FTQC_GP_ML._01_KernelCatalog
import CL8E8TQC._20_FTQC_GP_ML._02_DrugDiscovery_GP
import CL8E8TQC._20_FTQC_GP_ML._03_MultiE8_GP
import CL8E8TQC._20_FTQC_GP_ML._04_ActiveLearning
import CL8E8TQC._20_FTQC_GP_ML._05_FTQC_GP_NN_Duality
import CL8E8TQC._21_QuantumDeepGP._00_LazyTraining
import CL8E8TQC._21_QuantumDeepGP._01_DeepGP_Theory
import CL8E8TQC._21_QuantumDeepGP._02_DiscretePathIntegral
import CL8E8TQC._21_QuantumDeepGP._03_QuantumInference
import CL8E8TQC._21_QuantumDeepGP._04_LayerDepthCorrespondence
import CL8E8TQC._22_ExactDeepBayesianOptimization._00_ExactDeepBO
import CL8E8TQC._22_ExactDeepBayesianOptimization._01_NN_vs_GP
