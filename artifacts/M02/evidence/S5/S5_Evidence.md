# M02 S5 — Smart Fertilizer modes (M02-T13, T14, T15 rest)

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import (`idle_farmer\.godot` removed): exit 0, **356 tests, 12,307 assertions, 0 failures, 25.0 s** (`run_s5_suite/`). Balancing suite: exit 0 (`run_s5_benchmark/`).

## Delivered

| Area | Files |
|---|---|
| Optimizer | `core/economy/fertilizer_optimizer.gd`. Maximum Profit and Budget Protection use the exact `RateFrontier` from S0. Capital Efficiency is the Q2 greedy ranking by Δnet/Δcost, with ties broken by higher Δnet/duration, then lower Δcost, then lower plot ID, then lower tier. `solve_groups` funds groups in order: MP and CE from the remaining M, BP from min(remaining M, remaining C), and BP spend also reduces C. Products are compared exactly: checked int64, falling back to BigInt. |
| Caching (owner condition on B3) | A bounded memo (256 entries, first in, first out) keyed by mode, normalized funds and the canonical member list. Funds are clamped to the most any assignment could spend, so a growing wallet still hits the cache. Results are returned as copies. |
| Planner | Phase 7b in `BatchPlanner`. Funded Smart requests are grouped by (priority descending, then mode MP → CE → BP); priority is fixture-only (Q3). Options come from real quotes (price and incremental net per fertilizer tier) at the plot's effective duration. `BatchProposal.allocation` gains `smart_spend` and `bp_spend`. Planting quotes are memoized per plan by (crop, fertilizer). |
| Oracle (E15) | `m02_oracle.py` gains `SMART`: 45 batch vectors. The 9 named cases are DVS-010 (MP, BP 25 %, budget 41, CE), DVS-008 (all BP; MP before BP), MP/CE/BP order, CE ROI order, and Wheat/Carrots/Corn; the other 36 are random multi-mode batches. Groups of up to 6 plots are enumerated exhaustively with `Fraction`, and CE is written from the Q2 text. A separate RNG stream keeps the earlier vectors unchanged (the diff is insert-only). |
| Tests | `unit/test_fertilizer_optimizer` (6, including the GDScript brute-force cross-check), `simulation/test_smart_oracle` (8), `simulation/test_smart_32_plot` (2); `balancing/test_smart_benchmark.gd` (B4). |

## Validation coverage

- **V07 / DVS-010:**
  - all 45 oracle batches match tiers, Smart spend and Budget Protection spend;
  - the planner path gives the named outcomes:

    | Case | Result |
    |---|---|
    | MP, W=205 (M=95) | Basic + Basic, spend 82, wallet 13, gross 337 |
    | BP at 25 % (C=23) | None |
    | MP with M=41 | Basic on plot 1, which wins the tie |
    | CE | Basic first, then Basic + Basic |

- **E15 brute-force cross-check:** for 14 seeded random groups of 3–8 plots, the GDScript exhaustive enumeration (exact integer rates over lcm 720 min) equals the production MP and BP results.
- **Q2 ties:** equal ROI goes to the higher Δnet/duration, then the lower Δcost, then the lower plot ID, then the lower tier. Candidates refresh after each pick (a Basic → Premium upgrade is its own step). A non-positive net is never bought.
- **V13:**
  - with W=1,000, R=100, fixed Basic on two plots and BP on three: S=275, A=625, F=82, M=543, C=135, computed once;
  - BP buys three Basics (123); a Premium plus a Basic (136) does not fit;
  - the wallet ends at 520, which is not below W−S−F−C;
  - groups are funded in priority, then MP → CE → BP order:
    - with M=41, only the MP plot gets Basic;
    - with M=82, MP and CE get Basic and BP gets nothing;
    - a priority-1 BP plot is funded first;
  - MP and CE spending can leave BP less;
  - a stored Smart rule without the skill stays inactive and stalls with `capability`.
- **V08:**
  - 32 mixed plots across 8 crops at level 20, through the planner, with an ample budget (M=100,000) and with half (M=15,000);
  - all 32 are planted and armed, every bought fertilizer has a positive net, and spend ≤ M;
  - the result is identical for a reversed build order;
  - a repeat batch hits the cache with the same result;
  - with a starved budget (M=0), seeds are still planted and no fertilizer is bought.
- **AV-005-05:**
  - one Pumpkins credit funds four replants and the rest stay stalled;
  - the batch is one logical batch;
  - stalls schedule nothing at the same time, and advancing to the same time again changes nothing.
- **Caching:**
  - a cold result equals the warm one;
  - a growing wallet above the useful maximum hits the cache;
  - member order does not matter;
  - MP and CE results on the same inputs are kept apart;
  - the cache stays within its bound, and returned copies cannot corrupt it.

## Benchmark (headless, dev machine, median of 7, 32 plots)

| Scenario | Cold solve | Warm (cached) |
|---|---:|---:|
| Uniform Tomatoes MP, ample | 3.27 ms (B3 gate 5 ms: pass) | 0.18 ms |
| Mixed 8 crops MP, ample | 17.5 ms (gate 50 ms: pass) | 0.20 ms |
| Mixed 8 crops MP, half | 15.1 ms | 0.20 ms |
| Mixed MP/CE/BP groups, half | 5.0 ms | 0.18 ms |
| S0 worst case (varied durations, half) | 40.3 ms (gate 50 ms: pass) | — |

Whole planner batch for the V08 farm (requests, quotes, allocator and Smart): about 23 ms cold and 5.7–8.5 ms warm. Before per-plan quote memoization it was 44 ms and 23–29 ms: the planner computed about 190 quotes per batch, 44 μs each.

## Mutation checks (each run in isolation)

| Injected defect | Caught by |
|---|---|
| CE ROI order inverted | 3 tests (oracle, DVS-010 CE, planner CE) |
| BP not limited by the ceiling C | 3 tests (oracle, DVS-010 BP, V13) |
| BP funded before MP (mode order reversed) | **Not caught at first.** The oracle supplies group order, so only the planner orders groups. The fix: `test_v13_group_order_priority_then_mp_ce_bp`. |
| CE plot-ID tie inverted | 2 tests |
| Cache key without the mode | **Not caught at first.** The fix: an MP-versus-CE disagreement on the same inputs in the cache test. |
| Planner ignores the Smart result | 4 tests |

All mutations were reverted (the script restores from a backup), and the clean-import suite passes.

## Notes and decisions

- **ApplyAndStart's first planting with a Smart policy still uses None.** It is a direct manual planting with confirmed costs. Smart chooses fertilizer for every automatic replant and retry, inside the batch's M and C.
- **CE steps without a positive Δcost are skipped.** Such steps have no ROI (FRS §7.2), and the current fertilizer prices increase strictly by tier, so none occur.
- **Mode groups.** Smart groups are keyed by (priority, mode). All priorities are 0 in M02 gameplay, so a uniform-mode farm is optimized together (E14).
- **The cache is a static, bounded memo inside `FertilizerOptimizer`.** It holds no gameplay state and cannot change a result. Tests clear it in `before_each` so the hit counts are deterministic.
- **Performance note for M03/M06.** A 32-plot mixed farm costs about 6–8 ms per warm planner batch, outside the solver. TRS §14 (30 days within 5 s) still depends on the M03 aggregation of identical cycles; this is recorded here, not tuned.
- **Not in S5.** Accounting categories, the committed-harvest port and the reserved records are S6.
