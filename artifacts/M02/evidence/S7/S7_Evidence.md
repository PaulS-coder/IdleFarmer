# M02 S7 — Progression scenarios, content freeze and handoff (M02-T17, T18)

Recorded: 2026-10-30 UTC, branch `m02-implementation`.

- **Default suite** from a clean import (`idle_farmer\.godot` removed): exit 0, **370 tests, 12,511 assertions, 0 failures, 20.1 s** (`run_s7_suite/`).
- **Balancing suite** (`-Dir res://balancing`): exit 0, **4 tests, 191 assertions, 148.9 s** (`run_s7_balancing/`). It covers the solver benchmark, the Smart benchmark and the strategy harness.

## Delivered

| Area | Files |
|---|---|
| Strategy harness (T17, V11, B4) | `balancing/support/strategy_player.gd` (`StrategyPlayer`: a scripted player on a real `GameController`, plus a `Ledger` that builds the cost and idle record from committed events and harvest records); `balancing/test_strategy_pacing.gd` (5 strategies × active-only and mixed-offline, plus a determinism test) |
| Deferred scope (V14) | `tests/unit/test_deferred_scope.gd`: Seed Efficiency, Research Facilities and Growth Booster are absent from every table. Each command surface rejects them uncharged with `UNKNOWN_UPGRADE`, `UNKNOWN_RESEARCH`, `UNKNOWN_SKILL` or `UNKNOWN_FERTILIZER` (Plant, Configure, ApplyAndStart). Exactly four fertilizers remain. |
| Content freeze (T18, E1) | `tests/unit/test_manifest_freeze.gd` pins the canonical digest of every script field of `content_m01_v1` and `content_m02_v1`. A second test shows that an edit to any table changes the digest: crops, research, skills, curve, upgrades, fertilizers, bands, economy. The `content_m02_v1.gd` header now reads "Frozen at M02-T18". |
| Handoff (T18) | [M02_Handoff.md](../../M02_Handoff.md), [M02_Proposed_Doc_Changes.md](../../M02_Proposed_Doc_Changes.md) (C1–C9, none applied) |

## Harness checks (assertions in every run)

- **Approved empty start:** 0 coins, level 1, 0 XP, no research, 24 plots, 0 points.
- **The final state validates** against `content_m02_v1`.
- **No rejected intents.** Every intent was built from its quote and accepted.
- **The wallet reconciles exactly:** final coins = harvest gross − seeds − fertilizer − research − boost − plots − equipment − reset.
  - Seeds and fertilizer come from the cycle snapshots: the harvested ones plus those still growing.
  - Every other cost comes from committed events.
- **Total XP equals harvest XP.**
- **Catalog costs:**
  - research spend = catalog cost of completed and active projects;
  - plot spend = band costs for plots 25..N;
  - equipment spend = rank costs of the owned ranks.
- **One point per level** (allocated + unspent = level − 1).
- **Milestones:** every run reaches full automation within 16 h, and all four automation nodes are bought with real points.
- **Determinism:** two runs of focused/mixed-offline give the same gameplay digest, decisions and milestones.

## Pacing results

The report table, protocol and findings are in [M02_Handoff.md §4](../../M02_Handoff.md#4-pacing-report-v11-t17).

**Per-run costs** (coins; idle = plot-hours not producing):

| Strategy / mode | Seeds | Fertilizer | Research | Boost | Plots | Equipment | Gross | Harvests manual / auto | Idle plot-h | Decisions | End coins, level, plots |
|---|---|---|---|---|---|---|---|---|---|---|---|
| focused / active | 2,448 | 0 | 3,750 | 0 | 2,500 | 0 | 19,522 | 252 / 56 | 0.00 | 283 | 10,824, L7, 28 |
| focused / mixed | 1,476 | 0 | 3,750 | 0 | 2,500 | 0 | 18,516 | 282 / 56 | 60.87 | 278 | 10,790, L7, 28 |
| mixed growth/profit / active | 7,700 | 0 | 3,750 | 1,875 | 10,500 | 18,650 | 49,508 | 366 / 29 | 3.05 | 607 | 7,033, L9, 30 |
| mixed growth/profit / mixed | 6,765 | 0 | 3,750 | 1,875 | 10,500 | 18,650 | 46,709 | 422 / 29 | 96.82 | 657 | 5,169, L9, 30 |
| coin_xp / active | 2,448 | 0 | 3,750 | 0 | 2,500 | 0 | 19,522 | 252 / 56 | 0.00 | 283 | 10,824, L7, 28 |
| coin_xp / mixed | 1,476 | 0 | 3,750 | 0 | 2,500 | 0 | 18,516 | 282 / 56 | 60.87 | 278 | 10,790, L7, 28 |
| low_reserve / active | 2,970 | 3,300 | 3,750 | 475 | 2,500 | 6,650 | 28,754 | 254 / 56 | 1.48 | 277 | 9,109, L7, 28 |
| low_reserve / mixed | 1,908 | 2,120 | 3,750 | 475 | 2,500 | 6,650 | 23,588 | 281 / 84 | 68.60 | 283 | 6,185, L7, 28 |
| high_reserve / active | 2,160 | 0 | 3,750 | 0 | 0 | 0 | 18,624 | 264 / 48 | 0.00 | 289 | 12,714, L7, 24 |
| high_reserve / mixed | 1,296 | 0 | 3,750 | 0 | 0 | 0 | 18,672 | 312 / 48 | 68.40 | 293 | 13,626, L7, 24 |

**Notes:**

- No run paid for a reset.
- No run had a stall event. Seed costs stay small next to the wallet at this stage.
- Research spend of 3,750 is Carrots 150 + Corn 800 + Tomatoes 2,800. Tomatoes starts at level 7.
- Each run's line in `run_s7_balancing/test.log` also lists its skill ranks and its online/offline hours.

**Decision trace, focused_automation / active-only** (harvest and planting decisions omitted):

| Active h | Decision |
|---|---|
| 0.27 | Efficient Harvest rank 1; research Carrots (150) |
| 0.65 | Batch Planting; plots 25 and 26 (250 each) |
| 1.15 | Batch Harvesting; research Corn (800) |
| 2.15 | Efficient Harvest rank 2; plots 27 and 28 (1,000 each) |
| 2.65 | Automatic Harvesting; farm Auto Harvest on |
| 3.65 | Automatic Replanting; research Tomatoes (2,800); loop Corn + None on 28 plots |

## Mutation checks (each run in isolation)

| Injected defect | Suite | Caught by |
|---|---|---|
| Frozen manifest edited in place (Basic price coefficient 1,500 → 1,600 bp) | default | 11 tests, including `test_frozen_manifests_are_unchanged` and the fertilizer price, T-004 and Smart oracle tests |
| A deferred fertilizer ID accepted by ConfigureAutomation | default | `test_every_command_surface_rejects_deferred_ids_uncharged` (new) and the S4 `test_configuration_codes` |
| Research unlocks without paying (a free unlock in progression evidence) | strategy harness | `test_v11_strategies_active_and_mixed_offline` (wallet reconciliation and catalog research cost) |
| Harness ledger drops the research boost spend | strategy harness | `test_v11_strategies_active_and_mixed_offline` (wallet reconciliation in the boosting strategies) |

All mutations were reverted (the script restores from a backup), and the clean-import suite passes.

## Notes and decisions

- **"Active hours"** in the target judgement means online time. In mixed-offline runs, offline time is reported separately and never counted as active (DEC-024).
- **The harness lives in `balancing/`** (B4). Its support class is under `balancing/support/` and uses the test fixtures' manifest catalog and fake commit sink, so the default suite keeps its runtime.
- **No balance value was changed.** The pacing numbers are recorded as evidence for the owner's review (FRS §12.1).
- **No existing specification document was edited.** The only doc change is the build-plan §9 row; C1–C9 wait for approval.
