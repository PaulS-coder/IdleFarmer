# M02 — Developer build plan

Date: 2026-10-30 · Status: **working build plan, non-authoritative** · Approved inputs: owner "Accept all" (2026-10-30) for Q1–Q3 and E1–E18 in [M02_Readiness_Findings.md](M02_Readiness_Findings.md).

**Authority order:**

1. [FRS](../requirements/IdleFarmer_Functional_v1.0.md) owns gameplay.
2. [TRS](../architecture/IdleFarmer_Technical_v1.5.md) owns architecture.
3. The [M02 plan](02_M02_Economy_Skills_Research_Automation.md) owns tasks and acceptance criteria.
4. This document turns those into files, contracts, tests and order on top of the merged M01 code ([M01 handoff](../../artifacts/M01/M01_Handoff.md)). It changes no rule.

If this plan disagrees with a source, the source wins: fix this plan and log the change in §9.

Branch: `m02-implementation`. Runner: `tools/run_tests.ps1` (M01 guards apply). All values in §5 are provisional FRS data, recomputed independently, not final balance.

---

## 1. Approved decisions

### 1.1 Product answers (owner, 2026-10-30)

| ID | Ruling |
|---|---|
| Q1 | A manual **Plant** arms a plot's recurring loop **only when** the planted crop and fertilizer policy equal the plot's effective configured plan, Auto Replant is owned and enabled, and the confirmed terms include that plan's digest. Otherwise it is a one-off planting and the loop stays unarmed until an explicit ApplyAndStart. Plant never changes stored settings. |
| Q2 | Capital Efficiency ranks a tier step by **per-cycle ROI**: Δ incremental net coins ÷ Δ fertilizer cost. Ties go to higher Δ per-hour rate, then lower Δ cost, then lower plot ID, then lower tier. |
| Q3 | Seed protection and custom priorities: M02 implements and tests their **allocator logic and level-15 gates using fixtures**. Their configuration commands return `FEATURE_UNAVAILABLE` until M05. All plots have equal priority in M02 gameplay. |

### 1.2 Engineering decisions (E1–E18, approved) and build choices (B)

| ID | Decision |
|---|---|
| E1 | New manifest `content_m02_v1` (§3.1). It is a superset of v1 with the M01 rows unchanged. It stays a draft until T18, when it is frozen. `content_m01_v1` stays registered in tests for AV-003 regressions. |
| E2 | `schema_version` stays 1 until M03 freezes the durable layout. Every field change is logged in §9. |
| E3 | Exact rates use a big-integer type (`core/math/big_int.gd`) with a common-denominator weight scheme (§3.7). The S0 spike gates it. |
| E4 | Pure `BatchPlanner` → immutable `BatchProposal` → `BatchApplier`. Every due batch and every farming command uses this path (§3.5). |
| E5 | A numeric failure while advancing stops at that timestamp and commits nothing (DEC-026). |
| E6 | Stalled armed loops retry only inside a batch that has a wallet credit, or when a configuration/authorization command touches them. Retries are never scheduled events. |
| E7 | Each research run gets an `EntityId`. A boost cancels the completion event and re-inserts it with a new insertion sequence. Rebuild includes the active research. |
| E8 | Replant after a manual harvest runs inside the same command batch: credits first, then replant spending. |
| E9 | New failure codes and their order (§3.3). |
| E10 | Typed tri-state settings resolved Plot > Group > Farm. Budget fields are farm-only. `PlotState` keeps only runtime fields (§3.4). |
| E11 | Typed `LoopAuthorization` per plot: `{armed, plan_digest, authorized_revision}`. Reset disarms; re-buying a skill never re-arms. |
| E12 | Capabilities are always derived from `PlayerState.skill_ranks` and never stored. |
| E13 | Separate seed and fertilizer transactions; nullable `cycle_id`; `origin` field (`manual` / `automatic` / `system`). |
| E14 | Smart groups in M02 are partitioned by mode only, in the order Maximum Profit (MP) → Capital Efficiency (CE) → Budget Protection (BP). |
| E15 | Oracle: an independent Python generator (`tools/oracles/m02_oracle.py`) plus a GDScript brute force for groups of 8 plots or fewer. |
| E16 | Purchase confirmations bind the "next" identity (next rank, plot N+1, research run, reset level), so a re-delivered intent fails `STALE_TERMS` instead of buying twice. |
| E17 | Commands move to `core/simulation/commands/`. One `CommandFactory` handles decode and intent → command. `CommandResult` gains per-member outcomes. |
| E18 | Keep `PlayerState.skill_ranks`. Promote `ExtensionState.Research` to `core/research/research_state.gd`, keeping the primitive keys and adding fields. |
| B1 | `BigInt`: sign plus an `Array[int]` of 24-bit limbs, little-endian. Operations: add, subtract, multiply by BigInt or int, exact divide by a positive int64, compare, from/to decimal string. No floats. |
| B2 | The frontier groups identical plots (same crop, effective duration, option set) into classes and chooses option *counts* per class. The canonical assignment gives higher tiers to lower plot IDs inside a class, which matches the tie rule in §3.7. |
| B3 | S0 benchmark gate (provisional engineering threshold, recorded rather than approved): worst-case 32-plot exact MP solve ≤ 50 ms, and a uniform single-class farm ≤ 2 ms headless on the dev machine. If missed, stop and bring DEC-009 to the owner. Do not approximate. **Amended by owner, 2026-10-30 ("Accept and start S1"):** the uniform threshold is 5 ms, against a measured 3.0 ms. S5 adds result caching for identical solver inputs. Exactness is unchanged. |
| B4 | Long strategy harnesses live in `idle_farmer/balancing/` and run with `-Dir res://balancing`, so the default suite stays fast. |
| B5 | Equal-priority ordering is ascending plot ID. Higher custom priority will run first (M05). |
| B6 | Seed reservation skips an unaffordable request and keeps funding later ones. Free seeds are always fundable. |

## 2. File layout (new and changed under `idle_farmer/`)

```text
core/math/            big_int.gd, big_rational helpers (in big_int.gd)            [S0]
core/content/         upgrade_definition.gd, fertilizer_definition.gd, expansion_band.gd,
                      economy_parameters.gd; skill_definition.gd (+effect_kind, effect_bp_per_rank,
                      capability_id); content_manifest.gd/content_registry.gd (+new tables, validation) [S1]
core/economy/         modifier_snapshot.gd, upgrade_system.gd, fertilizer_pricing.gd,
                      planting_quote.gd (+fertilizer, plan digest); economy_system.gd (registry-aware) [S1–S2]
core/progression/     skill_rules.gd, capabilities.gd                                [S2]
core/research/        research_state.gd, research_system.gd                          [S3]
core/farming/         farming_settings.gd, settings_resolver.gd, loop_authorization.gd,
                      automation_system.gd; farm_system.gd (plan/apply split)          [S4]
core/simulation/      batch_planner.gd, batch_proposal.gd, batch_applier.gd,
                      seed_budget_allocator.gd                                         [S4]
core/simulation/commands/  game_command.gd (moved), command_factory.gd, plant_crop_command.gd,
                      harvest_crop_command.gd, purchase_plot_command.gd, allocate_skill_command.gd,
                      reset_skills_command.gd, purchase_upgrade_command.gd, start_research_command.gd,
                      accelerate_research_command.gd, batch_plant_command.gd,
                      batch_harvest_command.gd, apply_and_start_command.gd,
                      configure_automation_command.gd, configure_budget_command.gd,
                      unavailable_command.gd (reserved M05 types)                       [S0, S2–S4]
core/economy/         fertilizer_optimizer.gd, allocation_proposal.gd                  [S5]
core/application/     game_controller.gd (+quote APIs, committed-harvest port, compact cache) [S0, S6]
data/                 skills/skill_catalog_v2.gd, upgrades/upgrade_catalog_v1.gd,
                      fertilizers/fertilizer_catalog_v1.gd, economy/expansion_v1.gd,
                      economy/economy_parameters_v1.gd, manifests/content_m02_v1.gd   [S1]
tests/unit/ …         one suite per new module; tests/simulation/ … batch, automation, solver
tests/fixtures/       m02_oracle_vectors.gd (generated)
balancing/            test_strategy_*.gd (B4)                                          [S7]
tools/oracles/        m02_oracle.py                                                     [S1, S5]
```

## 3. Cross-cutting contracts

### 3.1 Manifest `content_m02_v1` (E1)

`ContentM02V1.build_manifest()` holds:

- the v1 crops, research, curve and start unlock, unchanged;
- **skills (v2):** the same IDs, plus `effect_kind` (`growth_reduction` / `coin_bonus` / `capability`), `effect_bp_per_rank` and `capability_id`:

| Skill | Effect per rank |
|---|---|
| faster_germination | 400 bp growth reduction |
| improved_cultivation | 300 bp growth reduction |
| climate_control | 500 bp growth reduction |
| efficient_harvest | 800 bp coin bonus |
| soil_productivity | 1,200 bp coin bonus |
| premium_produce | 2,000 bp coin bonus |
| automation nodes | capability with the same ID |

- **upgrades:**
  - `irrigation` ranks 1–6, cost 650 / 2,100 / 12,000 / 60,000 / 300,000 / 1,500,000, 500 bp growth reduction each;
  - `improved_soil` ranks 1–5, cost 900 / 3,000 / 20,000 / 110,000 / 650,000, coin bonus +1,000 / +1,000 / +1,500 / +1,500 / +2,000 bp;
  - guards per FR-AUD-006.
- **fertilizers**, ordered None < Basic < Premium < Advanced:
  - `none` 0 bp, price 0;
  - `basic` +2,500 bp, price max(20, ⌈1,500·B/10,000⌉);
  - `premium` +5,000 bp, price max(75, ⌈3,500·B/10,000⌉);
  - `advanced` +10,000 bp, price max(240, ⌈7,800·B/10,000⌉);
  - B is the unmodified base coin reward.
- **expansion bands:** plots 25–26 level 3, cost 250; 27–28 level 5, 1,000; 29–30 level 8, 4,000; 31–32 level 12, 12,000.
- **economy parameters:**
  - growth cap 6,000 bp (moved out of `EconomySystem.GROWTH_CAP_BP`);
  - reset cost max(250, 50·L²);
  - budget defaults R=0, p=25, seed protection off.

Registry validation adds:

- unique upgrade ranks 1..n with positive costs;
- fertilizer coefficients ≥ 0 and floors ≥ 0, with None present;
- bands cover plots 25–32 exactly, in order;
- effects ≥ 0;
- every capability ID matches an automation skill.

A v1-bound profile has no upgrades, fertilizers or bands; M02 commands for it return the appropriate `UNKNOWN_*` code (AV-003: no implicit upgrade). New games use v2.

### 3.2 Modifiers and quotes (T02)

`ModifierSnapshot.for_plot(state, registry, fertilizer_id)` → `{growth_reduction_bp, coin_bonus_bp, fertilizer_id, fertilizer_bonus_bp}`. The keys match M01's stored dict plus the fertilizer keys. Where each value comes from:

| Value | Calculation |
|---|---|
| Growth reduction | Σ growth-skill ranks × bp + Irrigation rank × 500, then capped at `growth_cap_bp`. Quotes also expose the uncapped value and the waste. |
| Coin bonus | Σ coin-skill ranks × bp + Σ owned Improved Soil rank effects + fertilizer bonus. All additive (FRS §6.3). No XP bonus. |
| Duration | `IntegerMath.growth_us`, as in M01. |
| Gross | ⌊B·(10,000 + coin_bonus)/10,000⌋. |
| Fertilizer price | From B only (FRS §6.2): ⌈coef·B/10,000⌉ via `mul_div_ceil`, then max with the floor. |
| Incremental net (per fertilizer f) | gross(with f) − gross(None) − price(f). Seed cost cancels. |
| Rate | incremental ÷ effective duration (§3.7). |

`PlantingQuote` adds the following fields:

- `fertilizer_id`, `fertilizer_cost`, `fallback_accepted`;
- `plan_digest`, the canonical digest of `{crop_id, fertilizer_policy, fallback}`, present only when arming (Q1);
- `min_ending_balance`, present only for a manual reserve override.

`matches()` compares every term. Quotes and execution call the same functions.

### 3.3 Command plumbing and failure order (E9, E16, E17)

- **One `CommandFactory`** maps a type to its decoder and intent builder. `RawIntent` becomes `{intent_id, type, terms: Dictionary}`, and each command class validates its own terms.
- **`CommandResult.member_outcomes`** is a list of `{plot_id, outcome, failure_code}` for batch commands.
- **Response-cache entries are compact** (carry-over 5): `{success, failure_code, command_id, state_sequence, commit_status}`. The full result is returned to the caller but not stored in state.

**Confirmed terms by command:**

| Command | Terms |
|---|---|
| PurchasePlot | target plot ID (must be N+1), cost |
| AllocateSkill | skill ID, target rank (current + 1) |
| ResetSkills | current level, price, allocated points > 0 |
| PurchaseUpgrade | family, target rank, cost |
| StartResearch | project, cost, duration |
| AccelerateResearch | run ID, charge ⌈C/2⌉, `rule: "halve_remaining"` (AV-004-03) |
| Plant | crop, fertilizer, fallback, seed/fertilizer costs, growth, gross, XP, manifest, optional plan digest, optional min ending balance |
| Harvest | cycle ID |
| BatchPlant / ApplyAndStart | per-member terms |

**Failure precedence** (first match wins):

1. `MALFORMED_ENVELOPE`
2. `INVALID_COMMAND_TIME`
3. `STALE_COMMAND`
4. `DUPLICATE_COMMAND`
5. `PERSISTENCE_UNAVAILABLE`
6. `FEATURE_UNAVAILABLE` (M05 commands, and seed toggle / priority / preset / rotation / group)
7. `UNKNOWN_PLOT` / `UNKNOWN_CROP` / `UNKNOWN_SKILL` / `UNKNOWN_UPGRADE` / `UNKNOWN_RESEARCH` / `UNKNOWN_FERTILIZER`
8. `PLOT_LOCKED` / `PLOT_UNLOCK_ORDER_REQUIRED` / `PLOTS_FULL` / `PLOT_OCCUPIED` / `NO_CYCLE` / `CYCLE_MISMATCH` / `CROP_NOT_READY` / `SKILL_MAX_RANK` / `UPGRADE_MAX_RANK` / `UPGRADE_PREDECESSOR_REQUIRED` / `RESEARCH_ACTIVE` / `RESEARCH_DONE` / `NO_ACTIVE_RESEARCH` / `BOOST_USED` / `NO_TIME_SAVED` / `NOTHING_TO_RESET`
9. `LEVEL_REQUIRED` / `RESEARCH_REQUIRED` / `SKILL_PREREQUISITE_REQUIRED` / `SKILL_NOT_UNLOCKED` (missing capability) / `INSUFFICIENT_POINTS`
10. `STALE_TERMS`
11. `INSUFFICIENT_COINS`
12. `NUMERIC_LIMIT`

Batch members report per-plot codes from steps 7–12; the envelope uses steps 1–6.

### 3.4 Settings, authorization, capabilities (E10–E12, Q1, Q3)

- **`FarmingSettings`** holds tri-state fields `{set: bool, value}`:
  - `crop_id`;
  - `auto_harvest`;
  - `auto_replant`;
  - `fertilizer_policy` ∈ {`none`, `basic`, `premium`, `advanced`, `smart_mp`, `smart_ce`, `smart_bp`};
  - `fallback_accepted`.
- **Records:**
  - farm defaults: every field set; crop unset means no crop; auto actions false; policy `none`; fallback false;
  - one optional `group_id` per plot, with group records reserved and inert (AV-007-01/04 fixtures);
  - plot overrides.
- **`SettingsResolver.effective(state, plot_id)`** walks Plot > Group > Farm. An explicit false or zero stays set.
- **`FarmBudget`:** `reserve`, `protection_percent`, `seed_protection` (fixture-only in M02).
- **`LoopAuthorization`** per plot: `{armed, plan_digest, authorized_revision}`.
  - A loop runs only if it is armed, its digest equals the current effective plan digest, and the capabilities are present.
  - A changed effective plan leaves it unarmed until ApplyAndStart or a matching Plant re-arms it (FRS §9.2, FR-AUD-007).
  - Reset disarms every loop. Re-buying a skill never re-arms (E11).
- **`Capabilities.of(state, registry)`** is derived from skill ranks:
  - batch planting / harvesting;
  - auto harvest / replant;
  - smart fertilizer (modes plus R and p);
  - enhanced budget (priorities and seed toggle, used only by fixtures in M02);
  - presets and rotation (unavailable).
- **Gates:** fixed recurring fertilizer needs no Smart. Smart policies need `smart_fertilizer`. A stored but unusable rule stays inactive; it never authorizes action.
- **`PlotState` becomes runtime-only:**
  - `unlocked`, `crop_cycle`;
  - `stall_reason` (`none` / `seed_funds` / `fertilizer_funds` / `capability` / `unarmed`).
  - M01's flat `selected_crop_id`, `auto_*`, `spending_priority` and `blocked_reason` move into settings. The old keys are removed from the schema and logged in §9.

### 3.5 Batch pipeline (E4–E8; TRS §4.2)

The engine processes one timestamp t as follows:

1. Pop phase-1 events (research completion) and phase-2 events (maturity) at t, in key order. Apply completion and maturity markers. These cannot fail numerically.
2. **Plan:** `BatchPlanner.plan(state_view, registry, inputs)` → `BatchProposal`, a pure function of a read-only view with all arithmetic checked:
   - **Phase 2b (auto-harvest set):** Ready plots with an enabled `auto_harvest` setting, the `auto_harvest` capability and an unlocked plot, in ascending plot ID.
   - **Phases 3–4:** all credits (coins, XP, level grants) accumulated with checked math, plus the accounting rows.
   - **Phase 5 (replant requests):** each harvested plot whose loop is armed and enabled, plus each stalled armed loop when the batch has any wallet credit (E6).
   - **Phase 6:** seeds (§3.6).
   - **Phase 7:** fixed fertilizer and replan (§3.6), then Smart groups (§3.7).
   - **Phase 8:** new cycles, their snapshots, ID allocation counts and scheduler entries.
3. If the proposal has a `failure_code`, abort the timestamp (E5).
4. **Apply:** `BatchApplier.apply(state, scheduler, proposal)` mutates the state in proposal order. It cannot fail because every value was pre-validated.
5. If the batch changed anything, increment `state_sequence` once.

**Manual commands** run the same planner with an explicit input set:

- **Harvest / BatchHarvest:** credits for the selected plots, then phases 5–8 for the harvested plots whose loops are armed (E8). Automatic budgets apply (FRS §7.1).
- **Plant / BatchPlant:** direct manual planting from the wallet. The confirmed minimum ending balance must hold (reserve override, FRS §7.1). Arms the loop per Q1.
- **ApplyAndStart:** writes plot overrides (future settings), arms the loops, plants Empty members, and reports per-member outcomes. It needs `batch_planting` for more than one plot.
- **Ready-on-enable:** ConfigureAutomation enabling `auto_harvest` on a Ready plot harvests it inside that command's batch (FRS §9.2).

A command that is rejected or has no eligible member changes nothing. Due work runs before the command, as in M01. **Carry-over fixes:** `StateChangeBatch` keeps the first `failure_code`, and the controller does not commit an `_advance` whose batch failed.

### 3.6 Seed allocator and fixed-fertilizer replan (T11, T12, T15; FR-AUD-005; AV-005-01–04)

```text
candidates := requests sorted by (priority desc [all equal in M02], plot_id asc)
excluded := {}
repeat (pass ≤ N+1):
  seed_limit := W, or max(0, W−R) for paid seeds when seed_protection is on (fixtures only)
  for c in candidates \ excluded: fund the seed if affordable, else mark c seed_funds-stalled (skip, B6)
  S := Σ funded seeds;  A := max(0, W−S−R);  F := 0
  for c in funded, in order, with a fixed fertilizer f:
     if F + price(f) ≤ A: F += price(f)
     elif c.fallback_accepted: c.fertilizer := none
     else: excluded += {c}; continue repeat (discard all tentative reservations)
  break
M := A − F;  C := ⌊M·p/100⌋   (computed once for the batch)
```

Excluded requests stall with `fertilizer_funds` and are never re-added in this batch. Termination is guaranteed: at most N exclusions and N+1 passes, which the tests check.

### 3.7 Smart solver (T13, T14; DEC-009; FRS §7.2–7.3)

**Groups** (E14) run in the order MP → CE → BP. Each group sees the remaining M; BP also sees the remaining C. Candidates are per-plot options {None} ∪ {f : price(f) ≤ funds, incremental_net(f) > 0}.

**Exact rate arithmetic** (E3):

- Let L = lcm of the distinct effective durations in the group, computed in BigInt.
- Each plot gets a weight wᵢ = L / dᵢ (exact BigInt division).
- An option's rate numerator is incremental_net × wᵢ.
- A group's objective is the BigInt sum of numerators, so comparing objectives needs only addition and comparison.

**MP / BP:**

- Run a Pareto frontier over plot classes (B2). State = (spend, rate numerator, canonical assignment).
- State X dominates Y when spend_X ≤ spend_Y and rate_X ≥ rate_Y; ties are resolved by the order below.
- Choose the maximum rate. Among equal rates prefer lower spend. If still tied, take the canonical lexicographic assignment: at the first differing plot ID, the higher tier on the lower plot ID wins (DVS-010 tie: plot 1 gets Basic).
- The budget is the remaining M (MP) or min(remaining M, remaining C) (BP).
- Zero- or negative-gain options are never candidates, so None wins them.

**CE (Q2):**

- Repeatedly pick the affordable step (plot, current tier → higher tier) with positive Δnet that has the highest Δnet/Δcost.
- Compare ratios by cross-multiplication with checked int64; on overflow, fall back to BigInt.
- Ties: higher Δrate (BigInt), then lower Δcost, then lower plot ID, then lower target tier.
- After each pick, refresh that plot's candidates. Stop when no affordable positive step remains.

**Oracle (E15):** `m02_oracle.py` enumerates all assignments for groups of up to 6 plots with Python `Fraction`, covering MP, BP and CE, and emits vectors. A GDScript brute force for groups of 8 plots or fewer is cross-checked on random seeded groups.

### 3.8 Research (T07; DEC-007; AV-004-03)

**`ResearchState`** (core/research):

- `completed` (sorted);
- an `active` record `{run_id: EntityId, project_id, paid_cost, started_us, original_duration_us, completes_us, boost_used, insertion_seq}`, or null.

**Start:** the project is known, not completed and nothing is active; then the level gate; then the terms; then coins. The run schedules a phase-1 event keyed (completes_us, 1, 0, run.counter, seq).

**Boost:**

- remaining = completes − now. It is > 0, because due work runs first.
- new = ⌈remaining/2⌉. If new = remaining (that is, remaining = 1 μs), reject with `NO_TIME_SAVED`.
- Charge ⌈C/2⌉. Cancel and reinsert the event, and mark `boost_used`.
- The result reports the accepted-time new completion time.

**Completion:** adds the project to `completed`, clears `active` and emits `ResearchCompleted`. It never auto-starts another project, assigns a crop or buys a boost.

**Invariants:** active `completes_us` > `simulation_time_us`, and `EventScheduler.rebuild` re-creates the event from these fields.

### 3.9 Accounting and the committed-harvest port (T16, E13; carry-over 1, 4)

**`EconomicTransaction` types:** `seed_purchase`, `fertilizer_purchase`, `harvest_credit`, `research_purchase`, `research_boost`, `upgrade_purchase`, `plot_purchase`, `skill_reset`. The `cycle_id` is nullable and each transaction carries an `origin`.

**Port:** `GameController.add_committed_harvest_observer(callable)` receives typed `CommittedHarvest` records after a commit only:

- simulation time and sequence;
- cycle, plot and crop;
- quantity 1, gross, XP;
- origin.

Observers cannot mutate state. They receive a read-only copy.

### 3.10 Other skill, plot, reset and upgrade rules (T03–T06)

- **PurchasePlot:** the target must equal N+1, and N must be below 32 (else `PLOTS_FULL`). The band's level, then terms, then coins. On success it unlocks the plot only; nothing is planted automatically.
- **AllocateSkill:**
  - checks: rank below max; level ≥ `min_level`; predecessor rank ≥ 1; at least one unspent point;
  - effect: one point per rank;
  - capabilities apply from the next batch onward; current snapshots are unchanged.
- **ResetSkills:**
  - requires at least one allocated point (else `NOTHING_TO_RESET`); price max(250, 50·L²);
  - refunds all points and disarms every loop; settings stay stored but inactive;
  - keeps XP/level, plots, upgrades, research and snapshots.
- **PurchaseUpgrade:** the next rank only (predecessor owned); max-rank and unaffordable requests are rejected uncharged; future plantings only.

## 4. Slices

| Slice | Tasks | Build | Exit evidence |
|---|---|---|---|
| **S0** Spike + plumbing | T01 (prep) | `BigInt` and tests; a prototype frontier solver over synthetic 32-plot groups; benchmark (B3); `CommandFactory` and the `commands/` move; compact cache; carry-over fixes 2–5 | Benchmark report under `artifacts/M02/evidence/S0/` that decides go/no-go on exact DEC-009. M01 suite still green. |
| **S1** Content + quotes | T01, T02 | v2 definitions, registry validation, `content_m02_v1`, `ModifierSnapshot`, fertilizer pricing, extended `PlantingQuote`, `m02_oracle.py` (prices/modifiers) | Price table (§5), cap waste, invalid-content codes, AV-003 v1/v2 coexistence |
| **S2** Purchases | T03–T06 | PurchasePlot, AllocateSkill, ResetSkills, PurchaseUpgrade, `Capabilities`, quote APIs | V09, V12, V05 (reset), AV-004-04, AV-006-01–03 |
| **S3** Research | T07 | `ResearchState`, `ResearchSystem`, phase-1 events, Start/Accelerate | V06, AV-004-03, DVS-006 |
| **S4** Automation core | T08–T12, T15 (part) | Typed settings and authorization, planner/applier, engine pipeline, Batch*/ApplyAndStart/Configure*, auto-harvest/replant, seed allocator, fixed fertilizer + replan, retries | V01, V03, V04, V10, AV-005-01–04, DVS-012 |
| **S5** Smart | T13, T14, T15 (rest) | Oracle, MP/BP/CE, 32-plot benchmark | V07, V08, V13 (Smart parts), AV-005-05, DVS-010 |
| **S6** Accounting + schemas | T16 | Transaction categories, committed-harvest port, reserved advanced records (AV-007-01/04), M03 field inventory | V15 (AV-007), no pre-commit observer writes |
| **S7** Progression + handoff | T17, T18 | Strategy harness (B4), pacing report at 1× normalized, handoff, `content_m02_v1` frozen | V11, V14, M02 handoff, proposed doc changes |

Each slice ends with green tests, evidence in `artifacts/M02/evidence/S<n>/`, at least one mutation or positive control, and a commit.

## 5. Validation map and exact oracles (V01–V15)

| V | Tests | Oracle |
|---|---|---|
| V01 | `unit/test_skill_rules`, `simulation/test_automation_path` | Batch Planting at L3, Batch Harvesting L4, Auto Harvest L6, Auto Replant L7. Four points (L3/4/6/7) give a repeating harvest/replant loop at level 7. Fixed fertilizer repeats without Smart. Smart, R and p need L9; enhanced (fixture-only) L15; rotation L20 is unavailable. |
| V02 | `unit/test_modifier_snapshot`, `unit/test_fertilizer_pricing` | **T-004:** Tomatoes seed 55, Basic 41, gross 337, XP 70, profit 241. The snapshot survives a later Improved Soil purchase and a reset. |
| V03 | `simulation/test_batch_credits_before_seeds` | All harvest credits precede seed reservation. Permuting input order gives the same digest. One wallet covers 32 plots. |
| V04 | `simulation/test_allocator_stalls` | Seeds insufficient → stall uncharged. Fixed fertilizer unaffordable without fallback → stall uncharged; with fallback → plant with None. R ≥ W → no Smart spend, seeds still fundable. The next credit retries once. |
| V05 | `unit/test_reset` | Reset prices: L1 250, L2 250, L3 450, L7 2,450, L10 5,000, L30 45,000. Mid-growth reset keeps the snapshot, XP/level, plots, upgrades and research, refunds exactly, stops automation, and disarms loops. |
| V06 | `unit/test_research` | Corn C=800 → boost 400. 20 min remaining → 10; 10 → 5. 2 μs → 1 μs; 1 μs → `NO_TIME_SAVED` uncharged. One active project; no auto-next; boosting twice → `BOOST_USED`; a stale event is ignored after a boost. |
| V07 | `simulation/test_smart_oracle` | **DVS-010:** two 60-min Tomatoes plots, W=205, R=0, 95 available. MP → Basic+Basic, spend 82, rate 52/h. BP at 25% → C=23 → None. Budget 41 → Basic on plot 1. CE with Q2 → Basic first. Plus generated vectors. |
| V08 | `simulation/test_smart_32_plot` | 32 mixed plots with large balances: proposal valid (budget, authorization), runtime and frontier size recorded, deterministic across permutations. |
| V09 | `unit/test_purchases` | Expansion: 25–26 L3/250, 27–28 L5/1,000, 29–30 L8/4,000, 31–32 L12/12,000, total 34,500. Irrigation total 1,874,750; Soil total 783,900. Full growth stack 50% + 30% capped to 60%: Wheat 192,000,000 μs, Tomatoes 1,440,000,000 μs. A failed command leaves state digest-equal. |
| V10 | `simulation/test_long_automation` | 8+ simulated hours of mixed automation plus a mid-run clone/replay with an equal digest. The retry queue stays bounded. No automatic skill, research or purchase. |
| V11 | `balancing/test_strategy_*` | Full-cost strategies report time to level 7 and to the four automation nodes at 1×. The 3–5 h target is reported as met or missed, never tuned. |
| V12 | `unit/test_purchases`, `unit/test_skill_rules` | Requesting 27 while N=24 fails even with a high level and coins; a failed 25 does not make 26 eligible; N=32 → `PLOTS_FULL`. One preceding rank is enough for tier entry. |
| V13 | `simulation/test_budget_ceiling`, `simulation/test_research` | **DVS-008:** W=1,000, S=200, R=100, F=100 → A=700, M=600, C=150 once. All-BP total fertilizer ≤ 250 and wallet ≥ 550. MP/CE before BP can leave BP less. Free seeds below R. Boost rules as in V06. Eligible-subset atomic batches; reset/re-arm explicit. |
| V14 | `unit/test_deferred_scope`, `balancing/` | Seed Efficiency, Research Facilities and Growth Booster IDs are rejected uncharged as `UNKNOWN_*`. Exactly four fertilizers. Strategy traces carry real costs and mark human engagement as unobserved. |
| V15 | `simulation/test_m02_audit` | AV-003-02/03 (v1 profile untouched by v2 content); AV-004-02–05 (Plant terms, boost, reset quote, re-delivery); **AV-005-01** (W=100: plot 1 Corn+Premium no fallback, plot 2 Corn+None → only plot 2 planted, spend 18, end 82); AV-005-02 (≤N exclusions, ≤N+1 passes, permutation-invariant); **AV-005-03** (W=100: plot 1 Corn+Basic 20, plot 2 Corn+Premium 75, plot 3 Corn+None → pass 1 S=54, A=46, Premium fails → exclude plot 2 → final S=36, A=64, F=20, M=44, wallet 44); AV-005-04/05; AV-006-01–04; AV-007-01/04 record fixtures. |

**Fertilizer price oracle** (B = base coins; net = incremental net per cycle with no other bonuses):

| Crop | Basic | Premium | Advanced | Net B / P / A |
|---|---|---|---|---|
| Wheat 16 | 20 | 75 | 240 | −16 / −67 / −224 |
| Carrots 36 | 20 | 75 | 240 | −11 / −57 / −204 |
| Corn 110 | 20 | 75 | 240 | 7 / −20 / −130 |
| Tomatoes 270 | 41 | 95 | 240 | 26 / 40 / 30 |
| Pumpkins 1,200 | 180 | 420 | 936 | 120 / 180 / 264 |
| Sunflowers 810 | 122 | 284 | 632 | 80 / 121 / 178 |
| Strawberries 445 | 67 | 156 | 348 | 44 / 66 / 97 |
| Blueberries 1,600 | 240 | 560 | 1,248 | 160 / 240 / 352 |
| Soybeans 785 | 118 | 275 | 613 | 78 / 117 / 172 |
| Grapes 5,900 | 885 | 2,065 | 4,602 | 590 / 885 / 1,298 |
| Coffee 4,400 | 660 | 1,540 | 3,432 | 440 / 660 / 968 |
| Cotton 12,500 | 1,875 | 4,375 | 9,750 | 1,250 / 1,875 / 2,750 |
| Rice 2,900 | 435 | 1,015 | 2,262 | 290 / 435 / 638 |
| Vanilla 24,500 | 3,675 | 8,575 | 19,110 | 2,450 / 3,675 / 5,390 |
| Saffron 10,000 | 1,500 | 3,500 | 7,800 | 1,000 / 1,500 / 2,200 |

Smart never chooses a negative-net option, so Wheat, Carrots and Corn above Basic always resolve to None or Basic. This is provisional-balance evidence for M05, not something to change here.

## 6. Out of scope (do not build in M02)

| Item | Owner |
|---|---|
| Presets, rotation, group commands and UI, custom priority and seed-toggle commands | M05 (records reserved now; commands return `FEATURE_UNAVAILABLE`) |
| Durable persistence, real clock, offline aggregation of identical cycles, intent ledger | M03 |
| UI and audio | M04 |
| Contracts behaviour | M05 |
| Final balance and performance acceptance | M05 / M06 |
| DEC-008 deferred families | Never added |

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Exact solver too slow in GDScript | S0 spike plus the B3 gate before any production code. Class grouping (B2). If the gate fails, escalate DEC-009 to the owner. Never silently approximate. |
| BigInt bugs | An independent Python oracle; property tests (a+b−b=a, multiply/divide round-trip) at limb boundaries; mutation checks. |
| Batch atomicity regressions | Plan/apply separation. A test asserts the planner never mutates its input (digest before and after). Numeric-limit injection mid-plan. |
| Settings migration from M01 flat fields | Schema stays 1 (no saves yet). Log the removed keys. Update the M01 tests that referenced `selected_crop_id`. |
| Retry storms | Retries only inside credit or config batches (E6). A long-run test asserts the stalled set and work per batch stay bounded. |
| Suite runtime growth | Balancing harness kept separate (B4). Synthetic benchmarks marked and timed. |

## 8. Definition of done (M02)

- S0–S7 are committed on `m02-implementation`.
- The default suite and the `-Dir res://balancing` suite are green from a clean import.
- The M01 regressions are green.
- `artifacts/M02/` contains:
  - the evidence for each slice;
  - the S0 benchmark decision;
  - `M02_Handoff.md`: the M03 field inventory, the solver guarantee next to its measured benchmark, the M05 backlog, the pacing report and limitations;
  - a proposed doc-change list, including C1–C3 from the findings (not applied without approval).

## 9. Change log

| Date | Change |
|---|---|
| 2026-10-30 | Initial version from the approved Q1–Q3 and E1–E18. Oracle values recomputed independently in Python (fertilizer table, reset prices, upgrade totals, capped durations, AV-005-03 replan). |
| 2026-10-30 | S0: the exact solver is implemented as `RateFrontier`: identical-plot classes, an integer lower approximation with a certified error bound, and an exact BigInt fallback (denominator = Π distinct durations instead of an lcm). Benchmark: worst case 41 ms (gate 50, passed); uniform 32-plot 3.0 ms (gate 2, missed); see `artifacts/M02/evidence/S0`. `RawIntent` is now `{intent_id, type, terms}`. Runner gained `-Milestone`. |
| 2026-10-30 | Owner accepted the S0 benchmark: B3 uniform threshold raised to 5 ms; identical-input result caching added to S5 scope. |
| 2026-10-30 | S1: `CropCycle.fertilizer_transaction_id` (nullable) with `fertilizer_id` defaulting to `none`. The growth cap comes from the manifest (`EconomyParameters`; legacy 6,000 for v1). `UNKNOWN_FERTILIZER` sits after `UNKNOWN_CROP` in the precedence order. PlantCrop terms now include `fertilizer_id` and `fertilizer_cost`; fallback, plan digest and minimum ending balance arrive in S4. |
| 2026-10-30 | S2: purchase-style commands share a `TermsCommand` base (typed flat terms). Logic lives in `PurchaseSystem` (plots, equipment) and `SkillSystem` (allocate, reset). Re-delivered purchases are rejected by the first failing check in precedence order (`PLOT_UNLOCK_ORDER_REQUIRED`, `UPGRADE_MAX_RANK`/`STALE_TERMS`). Equipment ranks are validated against the bound manifest. Loop disarming on reset is deferred to S4 (E11). |
| 2026-10-30 | S3: `ExtensionState.Research` is replaced by `core/research/research_state.gd` (`ResearchState`). The M01 keys are kept and `active_run_id` (nullable EntityId), `active_original_duration_us` and `active_insertion_seq` are added; the active run stays flat `active_*` fields rather than the nested record in §3.8 (E18). New failure codes `UNKNOWN_RESEARCH`, `RESEARCH_ACTIVE`, `RESEARCH_DONE`, `NO_ACTIVE_RESEARCH`, `BOOST_USED`, `NO_TIME_SAVED` follow the §3.3 order, so `RESEARCH_ACTIVE` is reported before `RESEARCH_DONE`. AccelerateResearch binds the run as its `EntityId.key()` string; a boost on a finished run gives `NO_ACTIVE_RESEARCH` (or `STALE_TERMS` once a newer run is active). The oracle gained odd paid-cost vectors because every FRS §8 cost is even; see `artifacts/M02/evidence/S3`. |
| 2026-10-30 | S4: `PlotState` keeps `unlocked`, `crop_cycle` and a new `stall_reason`; `selected_crop_id`, `auto_harvest`, `auto_replant`, `group_id`, `spending_priority` and `blocked_reason` are removed. `automation` becomes `AutomationState`: typed tri-state `FarmingSettings` (farm defaults, groups) and a sparse, ascending list of non-default `PlotAutomation {plot_id, settings, group_id, authorization}` records; `priority` is a fixture-only settings field (Q3). PlantCrop args gain `fallback_accepted`, `plan_digest` and `min_ending_balance` (−1 = none); `CommandResult` gains `member_outcomes`; `INVALID_CONFIGURATION` (target state) and `SKILL_NOT_UNLOCKED` (gate) join the precedence order. Configuration never arms and disarms on a changed plan digest or Auto Replant off; ApplyAndStart also sets `auto_replant`. Smart policies plant with None until S5. See `artifacts/M02/evidence/S4`. |
| 2026-10-30 | S5: `FertilizerOptimizer` runs MP/BP on the S0 `RateFrontier` and CE per Q2; `solve_groups` funds groups keyed by (priority desc, mode MP → CE → BP) from the remaining M, BP also from the remaining C. Identical solver inputs are memoized (bounded, funds normalized to the most a group could spend); planting quotes are memoized per plan. CE skips steps without positive Δcost (no ROI). ApplyAndStart's first planting with a Smart policy stays None (direct manual planting); every automatic replant uses Smart. `BatchProposal.allocation` gains `smart_spend`/`bp_spend`. See `artifacts/M02/evidence/S5`. |
| 2026-10-30 | S6: `EconomicTransaction.TYPE_RULES` binds each type to one category, sign and cycle-binding, checked on decode (`contract_claim`/`contracts` reserved for M05). `CropHarvested` data gains `seed_cost`, `fertilizer_id`, `fertilizer_cost`; `Accounting` keeps cash flow and operating profit separate. The committed-harvest port publishes immutable `CommittedHarvest` records (in `core/economy`) only after a commit. Reserved typed records: `GroupRecord` (EntityId, name, revision, settings; ordered list), per-plot `RotationState` (replaces `automation.rotation`), `ContractInstance` (replaces untyped instances). M03 field inventory: `artifacts/M02/M03_Field_Inventory.md`; see `artifacts/M02/evidence/S6`. |
