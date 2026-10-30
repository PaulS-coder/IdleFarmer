# M02 — Economy gate closure and handoff (M02-T18)

Date: 2026-10-30 · Branch: `m02-implementation` · Toolchain: Godot `4.7.2.stable.official.ed1daf0bf` (console binary), GUT 9.7.1, Windows x86_64.

**Final runs** (evidence in [S7](evidence/S7/S7_Evidence.md)):

- `tools/run_tests.ps1` from a clean import: exit 0, **370 tests, 12,511 assertions, 0 failures, 20.1 s**.
- `tools/run_tests.ps1 -Dir res://balancing`: exit 0 (solver and Smart benchmarks, strategy pacing harness).

**Claim boundary.** This closes the M02 *headless economy* only:

- Nothing is persisted. `schema_version` stays 1 until M03 freezes the durable layout (E2).
- The commit sink is still the in-memory fake.
- There is no UI.
- Every number is provisional FRS development data, not final balance.
- The pacing report measures automated economics. It says nothing about human engagement, which is **unobserved** (DEC-024/G5).

## 1. Task status (M02-T01 to T18)

| Task | Status | Evidence |
|---|---|---|
| T01 Freeze skill and economic policy data | Done | [S1](evidence/S1/S1_Evidence.md); `content_m02_v1` frozen in S7 |
| T02 Modifier snapshots and quotes | Done | [S1](evidence/S1/S1_Evidence.md) |
| T03 Plot expansion | Done | [S2](evidence/S2/S2_Evidence.md) |
| T04 Skill allocation and capabilities | Done | [S2](evidence/S2/S2_Evidence.md) |
| T05 Paid complete reset | Done | [S2](evidence/S2/S2_Evidence.md); loop disarming in [S4](evidence/S4/S4_Evidence.md) |
| T06 Permanent upgrades | Done | [S2](evidence/S2/S2_Evidence.md) |
| T07 Research and acceleration | Done | [S3](evidence/S3/S3_Evidence.md) |
| T08 Authorized batch actions | Done | [S4](evidence/S4/S4_Evidence.md) |
| T09 Auto-harvest and auto-replant | Done | [S4](evidence/S4/S4_Evidence.md) |
| T10 Inherited settings and authorization | Done | [S4](evidence/S4/S4_Evidence.md); group records in [S6](evidence/S6/S6_Evidence.md) |
| T11 Seed-first shared-wallet allocator | Done | [S4](evidence/S4/S4_Evidence.md) |
| T12 Fixed recurring fertilizer | Done | [S4](evidence/S4/S4_Evidence.md) |
| T13 Exact small-batch oracle | Done | [S0](evidence/S0/S0_Evidence.md), [S5](evidence/S5/S5_Evidence.md) |
| T14 Smart Fertilizer modes | Done | [S5](evidence/S5/S5_Evidence.md) |
| T15 Coherent batches and safe retries | Done | [S4](evidence/S4/S4_Evidence.md), [S5](evidence/S5/S5_Evidence.md) |
| T16 Accounting and later-system hooks | Done | [S6](evidence/S6/S6_Evidence.md) |
| T17 Normal-speed progression scenarios | Done (report; target met for the focused strategy) | §4 below, [S7](evidence/S7/S7_Evidence.md) |
| T18 Economy gate and persistence handoff | Done | This document |

## 2. Validation status (M02-V01 to V15)

All test paths are under `idle_farmer/`.

| ID | Status | Where it is proven |
|---|---|---|
| V01 | Pass | `tests/unit/test_skill_rules`, `tests/simulation/test_automation_path` |
| V02 | Pass | `tests/unit/test_plant_fertilizer` (T-004: seed 55, Basic 41, gross 337, XP 70, profit 241), `tests/unit/test_modifier_snapshot` |
| V03 | Pass | `tests/simulation/test_batch_credits_before_seeds` |
| V04 | Pass | `tests/simulation/test_allocator_stalls` |
| V05 | Pass | `tests/unit/test_reset` |
| V06 | Pass | `tests/unit/test_research`, `tests/simulation/test_research` |
| V07 | Pass | `tests/simulation/test_smart_oracle`, `tests/unit/test_fertilizer_optimizer` |
| V08 | Pass | `tests/simulation/test_smart_32_plot`, `balancing/test_smart_benchmark` |
| V09 | Pass | `tests/simulation/test_purchases`, `tests/unit/test_modifier_snapshot` |
| V10 | Pass | `tests/simulation/test_long_automation` |
| V11 | Reported | `balancing/test_strategy_pacing`. Full-cost report in §4. The target is reported, not tuned. |
| V12 | Pass | `tests/simulation/test_purchases`, `tests/unit/test_skill_rules` |
| V13 | Pass | `tests/unit/test_seed_allocator` (DVS-008), `tests/simulation/test_smart_oracle`, `tests/unit/test_research` (boost) |
| V14 | Pass | `tests/unit/test_deferred_scope` (S7), `tests/simulation/test_purchases`, `balancing/test_strategy_pacing` (real costs reconciled; engagement marked unobserved) |
| V15 | Pass (M02 scope) | See below |

**V15 by audit item:**

| Items | Tests |
|---|---|
| AV-003 | `tests/simulation/test_manifest_binding`, `tests/unit/test_state_validation` |
| AV-004-02–05 | `tests/unit/test_plant_command`, `tests/unit/test_reset`, `tests/unit/test_research`, `tests/simulation/test_research`, `tests/simulation/test_controller_acceptance` |
| AV-005-01–05 | `tests/unit/test_seed_allocator`, `tests/simulation/test_allocator_stalls`, `tests/simulation/test_smart_oracle` |
| AV-006-01–04 | `tests/simulation/test_purchases` |
| AV-007-01/04 | `tests/unit/test_reserved_records`: contract fixtures only; group commands return `FEATURE_UNAVAILABLE` until M05 |

## 3. Solver guarantee and measured benchmark

These are two separate claims. The guarantee does not depend on the benchmark, and the benchmark is not a policy approval.

**Guarantee (exact, DEC-009):**

- **Maximum Profit and Budget Protection** return the exact optimum of Σ gainᵢ/durationᵢ within the budget, using the approved tie rules (max rate → lower spend → higher tier on the lower plot ID).
- **Method** (`RateFrontier`):
  - identical-plot classes;
  - an integer lower approximation with a certified error bound;
  - every comparison inside that bound decided in exact BigInt.
- **Capital Efficiency** follows Q2 exactly: rational per-cycle ROI with the approved tie chain. Like any greedy rule, it is a policy, not a global optimum.
- **Never chosen:** a negative-net option, or anything over M (or over C for Budget Protection).
- **Verified against:**
  - 66 frontier vectors and 45 Smart vectors from the independent Python `Fraction` oracle;
  - a GDScript brute force for groups of 8 plots or fewer;
  - mutation checks in S0 and S5.

**Measured** (headless, dev machine, median of 7; [S5](evidence/S5/S5_Evidence.md)):

| Case | Cold | Warm (cached) | Gate (B3, owner-amended) |
|---|---|---|---|
| Uniform 32-plot Tomatoes MP | 3.27 ms | 0.18 ms | ≤ 5 ms: pass |
| Mixed 8 crops MP | 17.5 ms | 0.20 ms | ≤ 50 ms: pass |
| S0 worst case | 40.3 ms | — | ≤ 50 ms: pass |
| Whole planner batch, V08 farm | about 23 ms | 5.7–8.5 ms | not gated |

**Notes:**

- Results are cached for identical solver inputs only, bounded at 256 entries and never persisted.
- Hardware qualification stays with M06 (DEC-023).

## 4. Pacing report (V11, T17)

**Protocol** (`balancing/test_strategy_pacing.gd`, `balancing/support/strategy_player.gd`):

- **Start.** The untouched new-game state: 0 coins, level 1, Wheat only, 24 plots. There are no grants and no fixture unlocks.
- **Real costs.** Every crop, research run, boost, plot, equipment rank and skill rank is an explicit intent built from its quote, and pays its real cost. After each run the harness checks that:
  - the wallet reconciles exactly with harvest gross minus every cost;
  - XP equals harvest XP;
  - research, plots and equipment were paid at catalog cost;
  - no intent was rejected.
- **Clock.** Normalized 1×.
- **Active-only.** The player looks every simulated minute, which is perfect attention at a 1-minute cadence: an economic lower bound, not a human.
- **Mixed-offline.** 20 minutes online, then 40 minutes with the application closed (offline credit at 1×, no input). "Active h" counts online time only; the figure in brackets is total elapsed time.
- **Full automation** is reached when level 7 has been reached, Auto Harvest is enabled farm-wide, and every unlocked plot has an armed Auto Replant loop.
- **Target:** 3–5 active hours (FRS §12.1). It is reported as met or missed and never tuned.

**Strategies:**

- **focused_automation:** automation nodes first, spare points into Efficient Harvest; research in catalog order; buys plots; no fertilizer, no equipment, no boost.
- **mixed_growth_profit:** two ranks each of Faster Germination and Efficient Harvest before the automation nodes; buys Irrigation and Improved Soil; boosts research.
- **coin_xp:** like focused, but ranks crops by XP per hour.
- **low_reserve:** like focused, plus Basic fertilizer whenever its net is positive, both equipment families and research boosts.
- **high_reserve:** keeps 50% of coins back; no plots, equipment, fertilizer or boost.

**Results** (active hours; mixed-offline adds total elapsed hours in brackets):

| Strategy | Mode | Level 7 | Batch Planting | Batch Harvesting | Auto Harvest | Auto Replant | Full automation | 3–5 h target |
|---|---|---|---|---|---|---|---|---|
| focused_automation | active-only | 3.65 | 0.65 | 1.15 | 2.65 | 3.65 | **3.65** | met |
| focused_automation | mixed-offline | 2.00 (6.00) | 0.58 (1.25) | 0.92 (2.25) | 1.67 (5.00) | 2.00 (6.00) | **2.00 (6.00)** | faster than 3 h active |
| mixed_growth_profit | active-only | 3.45 | 2.62 | 3.45 | 4.70 | 5.48 | **5.48** | missed |
| mixed_growth_profit | mixed-offline | 2.00 (6.00) | 1.67 (5.00) | 2.00 (6.00) | 2.67 (8.00) | 3.00 (9.00) | **3.00 (9.00)** | met |
| coin_xp | active-only | 3.65 | 0.65 | 1.15 | 2.65 | 3.65 | **3.65** | met |
| coin_xp | mixed-offline | 2.00 (6.00) | 0.58 (1.25) | 0.92 (2.25) | 1.67 (5.00) | 2.00 (6.00) | **2.00 (6.00)** | faster than 3 h active |
| low_reserve | active-only | 3.68 | 0.65 | 1.15 | 2.78 | 3.68 | **3.68** | met |
| low_reserve | mixed-offline | 2.23 (6.23) | 0.58 (1.25) | 0.92 (2.25) | 1.67 (5.00) | 2.23 (6.23) | **2.23 (6.23)** | faster than 3 h active |
| high_reserve | active-only | 3.90 | 0.65 | 1.40 | 2.90 | 3.90 | **3.90** | met |
| high_reserve | mixed-offline | 2.33 (7.00) | 0.58 (1.25) | 1.00 (3.00) | 2.00 (6.00) | 2.33 (7.00) | **2.33 (7.00)** | faster than 3 h active |

Costs, idle plot time, stalls and the decision trace for every run are in [S7_Evidence.md](evidence/S7/S7_Evidence.md).

**Findings** (evidence for the owner's balance review; no value was changed):

1. **The focused player meets the target.** Full basic automation takes 3.65 active hours at perfect 1-minute attention. Level 7 is the binding constraint (Auto Replant is a level 7 node), so the time to full automation is the time to earn 5,200 XP.
2. **Level 7 at about 3.65 h is driven by XP, not coins.** Every run still holds 5,169–13,626 coins when it reaches full automation. Plots, equipment and fertilizer move the time by at most 0.25 h. The XP table and crop XP set the pace.
3. **Delaying automation for growth/profit ranks costs about 1.8 h active** (5.48 h: Auto Replant moves to level 9), even though Faster Germination and equipment bring level 7 forward to 3.45 h. That is a miss for this strategy, which FRS §12.1 allows ("not promised for every strategy").
4. **Mixed-offline reaches automation with fewer active hours** (2.0–3.0 h) but more elapsed time (6–9 h), because crops keep growing while the application is closed. Offline earnings are not reduced (FRS §12.1).
5. **coin_xp matches focused exactly.** Through level 7, ranking crops by XP per hour and by coins per hour gives the same order (Corn > Carrots > Wheat), so the two strategies make the same decisions. This is a property of the provisional content, not a harness defect.
6. **Human engagement is unobserved.** Real players do not act every minute. The ~48 further engaging active hours and the human playtests (DEC-024) stay with M05/M06.

## 5. M03 persistence handoff

The complete field inventory is [M03_Field_Inventory.md](M03_Field_Inventory.md) (every field `GameState.to_primitive()` produces, with notes). The records that must stay atomic with the gameplay state:

| Record | Contents | Invariant M03 must keep |
|---|---|---|
| Shared farm budget (DEC-010) | `automation.budget_reserve`, `budget_protection_percent`, `budget_seed_protection` | Farm-only. No independently overridable wallet fields. |
| Accepted fallback and loop authorization (Q1, E11) | Per-plot `PlotAutomation`: tri-state settings, `group_id`, `authorization{armed, plan_digest, authorized_revision}` | Sparse ascending list; default records are not canonical. Reset disarms; re-buying a skill never re-arms. |
| Inactive rules | Settings stay stored while the capability is missing; `SettingsResolver.loop_status` reports them inactive | Capabilities are derived from `skill_ranks`, never stored (E12). |
| Rotation cursor | `PlotAutomation.rotation{entries, cursor}` | Cursor within entries; crops in the bound manifest. Behavior is M05. |
| Research snapshots (E7) | `research.active_*` incl. paid cost, original duration, run `EntityId`, insertion sequence; `boost_used` | Never repriced. The completion event is rebuilt from these fields. |
| Cycle snapshots | `CropCycle` costs, rewards, modifiers, manifest, transaction IDs | Immutable after planting (V02). |
| Plot runtime | `stall_reason` | `none` while a cycle exists. |
| Group, contract records (reserved) | `GroupRecord`, `ContractInstance` | Validated now; commands are M05. |

**G1/G2 invariants still enforced by `GameState.validate`:**

- point conservation (level − 1 = unspent + allocated);
- the 1..N plot prefix, where 25→32 needs the band level;
- next-ID purchase binding (E16);
- level derived from XP;
- allocators above every stored ID.

**Typing still needed before M03 freezes the layout:** `statistics` (DEC-017).

**Ports for later milestones:**

- the committed-harvest observer, which publishes only after a commit (S6);
- `EconomicTransaction` categories, which M03 decides whether to persist for statistics (TRS §10).

## 6. M05 backlog (tracked, not omitted)

| Item | State in M02 |
|---|---|
| Farm presets (L12), Enhanced Budget Management (L15), Crop Rotation (L20) | Skills and capabilities exist. Behavior is not built; rotation is a reserved record. |
| Group commands and UI (Create, Rename, AssignPlotGroup, Delete) | `GroupRecord` reserved; commands return `FEATURE_UNAVAILABLE` (AV-007) |
| Custom priority and seed-protection commands (Q3) | Allocator logic and level-15 gates are tested with fixtures; the commands return `FEATURE_UNAVAILABLE`. |
| Smart grouping by custom priority | `solve_groups` already keys groups by (priority desc, mode); every M02 plot has equal priority. |
| Contracts (DEC-019 twelve offers) | `ContractInstance` reserved and validated; `contract_claim` / `contracts` category reserved; consumes the committed-harvest port |
| Statistics (DEC-017) | Untyped placeholder; `Accounting` gives cash flow and operating profit |
| Final balance, ~48 h engagement, human playtests | Pacing evidence in §4; tuning needs a recorded owner decision and a new manifest ID |

## 7. Known limitations

1. **Smart policies plant their first cycle with None** when ApplyAndStart plants directly. Every automatic replant uses Smart (S5).
2. **Strategy players are economic, not human.** They have perfect attention at a 1-minute cadence, and maturity times line up with those visits, so active-only idle plot time is 0 for most runs. Mixed-offline uses one fixed 20/40-minute schedule.
3. **The balancing harness is slow:** about 150 s for twelve full runs. It stays outside the default suite (B4).
4. **Controller commits every call** (M01 limitation 1); M03 sets the checkpoint cadence.
5. **Performance outside the solver:** a warm 32-plot planner batch costs 6–8 ms. TRS §14 (30 days within 5 s) depends on M03's aggregation of identical offline cycles.
6. **Manifests are frozen by digest.** `tests/unit/test_manifest_freeze.gd` pins `content_m01_v1` and `content_m02_v1`. Any balance change needs a new manifest ID; cycles already planted keep their snapshots.

## 8. Open items and owners

| Item | Owner |
|---|---|
| Durable layout, migrations, intent ledger, checkpoint cadence, offline aggregation, typed statistics | M03 |
| UI for quotes, budgets, loops, stall reasons, research boost preview | M04 |
| §6 backlog, contracts, statistics, final balance review of §4 | M05 |
| Human engagement evidence (DEC-024), hardware qualification (DEC-023), performance acceptance | M06 |
| Documentation changes, including C1–C3 | **Applied 2026-10-30** with owner approval: see [M02_Proposed_Doc_Changes.md](M02_Proposed_Doc_Changes.md) |
