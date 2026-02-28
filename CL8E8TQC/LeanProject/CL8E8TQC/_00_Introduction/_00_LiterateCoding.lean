namespace CL8E8TQC.Introduction.LiterateCoding

/-!
# Literate Coding

## Abstract

This project consists entirely of 51 Lean 4 source files that simultaneously serve as an academic paper, composed in a Literate Coding style. The compiler automatically verifies over 550 `native_decide` theorems during `lake build`. This file explains the methodological foundations of this approach.

## Tags

literate-coding, native-decide, constructive-verification, lean4

---

# §1. Principles of Literate Coding

The style in which **code and documentation are unified** is called **Literate Programming** (Knuth, 1984). This paper fully embraces this principle: every document is itself Lean 4 source code. Markdown within `/-! ... -/` blocks is rendered as documentation, while Lean code simultaneously implements and verifies the theory.

| Traditional Paper | This Paper (Literate Coding) |
|:---|:---|
| Written in LaTeX, code managed separately | **Lean code = paper** (single source) |
| Risk of theory–implementation divergence | **Divergence is structurally impossible** (same file) |
| Verification depends on the author's claims | **Compiler verifies automatically** (see next section) |
| Reproducibility requires reader effort | **`lake build` reproduces all verifications instantly** |

All 51 files in this project can be directly built by the reader via `lake build`, allowing every theorem and computed result to be re-verified in their own environment. The **complete absence of any gap** between theory and implementation is the greatest advantage of Literate Coding.

---

# §2. Theory Structure = Code Dependency Structure

The second principle of Literate Coding is the **isomorphism between the logical dependency structure of the theory and the `import` dependency structure of the code**.

In this project, the independence, dependence, and confluence among concepts asserted by the theory are directly reflected as the `import` graph among files. The theoretical statement "A and B are independent" is expressed in code by A and B not mutually `import`ing each other, and "C is the confluence point of A and B" is expressed by C `import`ing both A and B. This correspondence is not a post-hoc consistency imposed on theory and code; since theory *is* code in Literate Coding, it is a **structural isomorphism that arises naturally**.

Concrete examples:

| Theoretical Structure | Correspondence in the Code `import` Graph |
|:---|:---|
| `_05_SpectralTriple` and `_06_E8Branching` are **two independent lenses** on `_03_E8Dirac` | Both do not mutually `import`; each `import`s only `_03_E8Dirac` |
| Routes A/B/C/D are **parallel group-theoretic projections** with no mutual dependence | Each Route file `import`s only `_00_Overview` and does not `import` other Routes |
| `_07_HeatKernel` is the **confluence point of both lenses** | `_07_HeatKernel` `import`s both `_05_SpectralTriple` and `_06_E8Branching` |

If a discrepancy between the theory structure and code structure is detected, it indicates either a logical error in the theory or an implementation defect in the code. The GraphViz dependency graph in `_00_Introduction/_01_Overview.lean` is a visual representation of this isomorphism, **faithfully reflecting both** the theoretical dependencies and the code `import` structure.

---

# §3. Constructive Verification

As part of the Literate Coding approach described in the previous section, we verify whether the actual computed values from the code implementing the theory match the theoretically expected values, using Lean 4's formal proof capabilities.

All verification theorems are automatically executed at compile/build time, and if any computed result does not match its expected value, a **build error** occurs. In other words, **successful build = all verifications passed**.

## 3.1 `decide` vs. `native_decide` — Why `native_decide` Is Necessary

Lean 4 provides two tactics for automatically proving decidable propositions.

| | `decide` | `native_decide` |
|:---|:---|:---|
| **Mechanism** | Reduces terms within the kernel and constructs a proof term | Compiles to native code and executes; returns only the result |
| **Trust basis** | The kernel verifies every step (highest trust) | Trusts the correctness of the compiler |
| **Complexity** | Proportional to proof term size (can explode exponentially) | Proportional to execution time (efficient) |

In principle, `decide` is safer, but this project requires reducing geometric product operations on 256-dimensional Clifford algebra vectors (sum over 120 roots × 120 roots = 14,400 operations) within the kernel. In this case, `decide` **reaches the maximum recursion depth** and fails to complete the proof:

```lean
-- ❌ decide → "maximum recursion depth has been reached"
theorem diracSquaredState_scalar :
    diracSquaredState.getD 0 0 = 9920 :=
  by decide
```

Simply replacing `decide` with `native_decide` succeeds immediately:

```lean
-- ✅ native_decide → succeeds immediately
theorem diracSquaredState_scalar :
    diracSquaredState.getD 0 0 = 9920 :=
  by native_decide
```

Since the majority of verification targets in this project involve 256-dimensional vector operations, all theorems are uniformly written using `native_decide`.

## 3.2 How Mechanical Proof via `native_decide` Works

```lean
-- Example: Proof that H84 has 16 codewords
theorem h84Codewords_size : h84Codewords.size = 16 :=
  by native_decide

-- Example: Matching the grade-3 kernel with its theoretical value
theorem grade3Kernel_self_eq_56 :
    grade3Kernel 0b00000000#8 0b00000000#8 = 56 :=
  by native_decide
```

`native_decide` automatically performs the following:

1. **Fully evaluates the left-hand side** — compiles to native code and executes
2. **Compares the result with the right-hand side** (theoretical value)
3. **If they do not match**, a compilation error occurs and the build fails

In other words, **the fact that a theorem containing `native_decide` passes the build means the compiler guarantees that "the computed result of the implementation and the theoretical expected value are in perfect agreement."**

Over **550 `native_decide` theorems** are defined across this entire project, and the compiler automatically verifies all of them every time `lake build` is executed.

-/

end CL8E8TQC.Introduction.LiterateCoding
