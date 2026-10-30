# M02 S0 — Exact-rate solver spike, command plumbing and M01 carry-over fixes

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import: exit 0, **224 tests, 8,577 assertions, 0 failures** (`run_s0_suite/`). Benchmark: `tools/run_tests.ps1 -Dir res://balancing` (`run_s0_benchmark/`).

## 1. Exact rate solver (E3, B1, B2): exact and verified

**Files:** `core/math/big_int.gd`, `core/economy/rate_frontier.gd`, `tools/oracles/m02_oracle.py` → `tests/fixtures/m02_oracle_vectors.gd`, `tests/unit/test_big_int.gd`, `tests/unit/test_rate_frontier.gd`.

**`BigInt`:**

- signed, with 24-bit limbs;
- add, subtract, multiply, compare, int64 and decimal conversion;
- immutable;
- verified against 144 independent Python vectors (limb boundaries, ±2^63, sizes up to about 1,000 bits) plus 200 seeded algebraic-property checks.

**`RateFrontier.solve`:** the exact optimum of Σ gainᵢ/durationᵢ under a budget (the Maximum Profit and Budget Protection core), with the approved tie rules (max rate → lower spend → higher tier on the lower plot ID). It matches the exhaustive Python `Fraction` oracle on **all 66 frontier vectors**:

- the six DVS-010 cases: Basic+Basic at budget 95 (52/h); None at 23; plot 1 Basic at 41; Premium+Premium at 1,000;
- 40 random sets, including ones whose durations need BigInt;
- 12 cross-class exact ties;
- 4 within-class count ties.

**Method** (every decision exact, no floating point):

1. Identical plots form a class and are solved over option counts.
2. Classes combine in a Pareto frontier keyed by an integer lower approximation of the rate, with an error bound below 1 per class.
3. A comparison inside that bound is decided exactly in BigInt over Π distinct durations.
4. Candidates are sorted natively by spend.

## 2. Benchmark (B3 gate)

Median of 7 solves, headless Godot 4.7.2, dev machine (Ryzen 5 7600X3D), 32 plots unless noted. Effective durations are rounded up to the μs.

| Scenario | First version | Final | Frontier | Note |
|---|---:|---:|---:|---|
| Uniform Tomatoes ×1 / ×8 / ×16 | — | 0.10 / 0.51 / 0.99 ms | 3 / 17 / 33 | Grows roughly with the square of the plot count |
| Uniform Tomatoes, ample budget | 10.02 ms | **3.00 ms** | 65 | B3 uniform gate is 2 ms: **missed** |
| Uniform Tomatoes, half budget | 9.70 ms | 3.08 ms | 65 | |
| Mixed 8 crops, ample | 169 ms | 16.5 ms | 1,080 | Exact fallback used for ties |
| Mixed 8 crops, half budget | 156 ms | 16.0 ms | 908 | |
| Varied growth reductions, half budget (BigInt denominators) | 1,220 ms | **41.1 ms** | 1,370 | Worst case. B3 worst gate is 50 ms: **passed** |
| Adversarial large-prime durations, half / ample | 380 / 424 ms | 20.5 / 18.9 ms | 425 / 437 | |

**Gate verdict:**

- **Worst case: PASS.** 41 ms against 50 ms.
- **Uniform farm: missed.** 3.0 ms against the 2 ms threshold. That threshold was my own provisional engineering number (B3), not an approved requirement. The solver's exactness is not in question, so this is not a reason to reopen DEC-009.
- **Context for the owner decision:**
  - The approved performance target is TRS §14's "30 days of stable 32-plot automated production within 5 s", owned by M03/M06.
  - 30 days of synchronized 32-plot Tomatoes is about 720 batches × 3 ms ≈ 2.2 s of solver time.
  - Stable production usually has an ample budget, which leaves the solver inputs unchanged from batch to batch. Caching the result for identical inputs (proposed for S5) removes most repeat solves.
  - Wheat, Carrots and Corn have no profitable paid fertilizer (see the build plan §5 price table), so their batches are trivial.

## 3. Command plumbing (E17)

- Commands moved to `core/simulation/commands/`.
- `CommandFactory.build` is now the only type → class map. Both replay decoding and intent acceptance use it.
- `RawIntent` is now `{intent_id, type, terms}`, and its `plant`/`harvest` constructors are unchanged for callers.

## 4. M01 carry-over fixes (findings §5)

| # | Fix | Test |
|---|---|---|
| 2 | `StateChangeBatch.append` keeps the first failure. `advance_to` stops at a failing timestamp. `GameController._advance` commits nothing on failure. | `test_m02_carryover.gd` (append), with engine and controller paths in place for M02 batches |
| 4 | `EconomicTransaction`: nullable `cycle_id`; `origin` (`manual` / `automatic` / `system`), validated on decode. Harvest and planting record their origin. | `test_m02_carryover.gd`, `test_serialization_coverage.gd` |
| 5 | Compact replay-cache entries `{success, failure_code, command_id, state_sequence}`; full results stay in controller memory only. | `test_m02_carryover.gd`. Side effect: the default suite dropped from about 21 s to 12.7 s because cloned states are smaller. |
| 1 | Committed-harvest port | Scheduled for S6 (T16) |
| 3 | Plan-then-apply for multi-member commands | Scheduled for S4 (E4) |

## 5. Mutation checks

| Injected defect | Caught? |
|---|---|
| BigInt subtraction borrow off by one | Yes: oracle and property tests |
| Cross-class tie rule inverted | Yes: frontier oracle |
| Approximation error margin set to 0 | Yes: frontier oracle |
| Within-class count tie rule inverted | **Not at first.** No oracle case had two different count mixes with equal spend and gain. Added 4 `class_count_tie` vectors; now caught. |

All mutations were reverted, and the clean suite passes.

## 6. Other

- `tools/run_tests.ps1` now takes `-Milestone` (default `M02`) and writes runs to `artifacts/M02/test_runs/`.
- The benchmark lives in `idle_farmer/balancing/` (B4) and is outside the default suite.
