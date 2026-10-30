# M02 S4 — Automation core (M02-T08 to T12, T15 part)

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import (`idle_farmer\.godot` removed): exit 0, **340 tests, 11,897 assertions, 0 failures, 25.8 s** (`run_s4_suite/`). The `-Dir res://balancing` suite also passes.

## Delivered

| Area | Files |
|---|---|
| Settings (E10) | `core/farming/farming_settings.gd`: tri-state fields `crop_id`, `auto_harvest`, `auto_replant`, `fertilizer_policy`, `fallback_accepted`, `priority` (fixture-only, Q3), each with a `<field>_set` flag. `settings_resolver.gd` resolves Plot > Group > Farm; an explicit false or `""` stays set. |
| Authorization (E11, Q1) | `loop_authorization.gd` `{armed, plan_digest, authorized_revision}`. The plan digest is the canonical digest of `{crop_id, fertilizer_policy, fallback_accepted}`. A loop is runnable only when it is armed for the *current* effective digest, Auto Replant is enabled and owned, and any Smart policy has its capability. |
| State | `automation_state.gd` replaces `ExtensionState.Automation`. It holds farm defaults, one `PlotAutomation` per plot (overrides, group, authorization), inert groups and rotation, and the farm-only budget (R, p, seed protection). `PlotState` is runtime-only: `unlocked`, `crop_cycle`, `stall_reason`. |
| Pipeline (E4–E6, E8) | `seed_budget_allocator.gd` (pure, §3.6); `batch_planner.gd` → `batch_proposal.gd` → `batch_applier.gd`. The engine runs one planned farming batch per due timestamp: auto-harvest set, then all credits and XP, then replant and retry requests, then seeds and fixed fertilizer with replan, then plantings. A failed plan aborts the timestamp. |
| Farming | `FarmSystem.apply_planting` is the one planting transition (manual and automatic). Manual `HarvestCrop` runs through the planner, so an authorized replant follows in the same batch (E8). |
| Commands | `PlantCrop` terms gain `fallback_accepted`, `plan_digest`, `min_ending_balance`. New: `BatchPlant`, `BatchHarvest`, `ApplyAndStart`, `ConfigureAutomation`, `ConfigureBudget`, and `UnavailableCommand` for the M05 types, which return `FEATURE_UNAVAILABLE`. `CommandResult.member_outcomes`. `INVALID_CONFIGURATION` and `SKILL_NOT_UNLOCKED` are added to the precedence order. |
| Reset (E11) | `ResetSkills` disarms every loop. Stalled Empty plots then report `unarmed`. |
| Controller | `quote_plant_on` (plot-bound: plan digest and minimum ending balance), `quote_batch_plant`, `quote_apply_and_start`. |
| Oracle | `m02_oracle.py` gains `ALLOCATOR`: an independent implementation of FRS §7.1 / FR-AUD-005 written from the specification text. It has 10 named cases (AV-005-01 with and without fallback, AV-005-03, DVS-008, R ≥ W, seed protection, B6 skip, exact exhaustion, priorities, cascading exclusions) plus 40 random cases. It uses a separate RNG stream, so the diff is insert-only. |
| Tests | `unit/test_seed_allocator` (3), `simulation/test_automation_path` (17), `test_allocator_stalls` (7), `test_batch_commands` (7), `test_batch_credits_before_seeds` (4), `test_long_automation` (1); support `tests/support/automation_fixtures.gd`. Five M01/S2 tests were updated for the removed flat plot fields. |

## Validation coverage

- **V01:**
  - capability levels 3 / 4 / 6 / 7 / 9 / 12 / 15 / 20;
  - at level 7 with four points, configure plus ApplyAndStart gives five automatic harvest-and-replant cycles. The selected crop persists, and no point, research or purchase is spent automatically;
  - fixed Corn + Basic repeats without Smart: 3 × (137 − 38) coins, and 20 is charged for fertilizer at every planting;
  - Smart policies and R/p give `SKILL_NOT_UNLOCKED` before level 9 and succeed after it.
- **V03:**
  - 32 armed loops mature at one timestamp with a wallet of 0;
  - every credit is recorded before any purchase;
  - plot 1's Tomatoes seed (55) is funded only by pooled credits;
  - one wallet funds all 32 plots, as one logical batch;
  - the planner leaves the state digest unchanged;
  - ascending, descending and shuffled cycle creation (different insertion orders) give the same farm, XP and level.
- **E8:** BatchHarvest pools only its own selected credits before its replant spending, and an unselected Ready plot is untouched. A manual harvest's replant is automatic-origin and uses automatic budgets.
- **V04 / AV-005 (engine level):**
  - AV-005-01: spend 18, end at 82, plot 1 stalls `fertilizer_funds`, 2 passes, 1 exclusion. With fallback, plot 1 plants Corn with None;
  - AV-005-03: S=36, A=64, F=20, M=44, wallet 44;
  - an unfunded seed stalls `seed_funds` uncharged, and its settings are kept;
  - with R ≥ W, the mandatory seed is still bought and fallback avoids optional spend;
  - a stalled loop does not retry on a maturity-only batch, even when it has funds. It retries once inside the next credit batch;
  - seed protection (fixture): paid seeds are protected below R, while free seeds are still planted.
- **AV-005-02:** for 50 oracle cases there are at most N exclusions and N+1 passes; the result is identical across three shuffles; the wallet never goes negative; C ≤ M.
- **DVS-012:**
  - configuring a crop and Auto Replant on an Empty plot never plants or arms;
  - enabling Auto Harvest on a Ready plot harvests it inside that command, and only that plot;
  - a manual harvest on an armed plot replants in the same command, with the credit first;
  - ApplyAndStart on a growing plot keeps the snapshot and charges nothing, and the next cycle follows the new plan;
  - reset disarms and keeps the settings. Re-buying the skills restores Auto Harvest but never the replant loop (`unarmed`), until an explicit ApplyAndStart.
- **Q1:**
  - a plot-bound quote carries the plan digest only when the planting equals the configured plan with Auto Replant enabled and owned;
  - a one-off Plant, without the digest, does not arm, and the next harvest stalls `unarmed`;
  - a Plant with the digest arms;
  - a plan changed between quote and acceptance gives `STALE_TERMS`, uncharged.
- **Disarm rules:**
  - changing a field outside the plan (Auto Harvest) keeps the authorization;
  - changing the crop disarms (`LoopsDisarmed`), and reverting does not re-arm;
  - turning Auto Replant off disarms;
  - an effective plan changed by a path that does not disarm (an inherited group edit) never runs, because the digest check stalls it `unarmed`.
- **T-008 batch commands:**
  - BatchPlant processes members in canonical order and skips occupied and unfunded members;
  - all-invalid commands change nothing; duplicate or empty member lists are `MALFORMED_ENVELOPE`;
  - batch commands are gated on their skills, and ApplyAndStart needs `batch_planting` only for more than one plot;
  - ApplyAndStart member codes are `LEVEL_REQUIRED`, `SKILL_NOT_UNLOCKED` (Smart), `PLOT_LOCKED` and `INSUFFICIENT_COINS`; a failed member writes no settings; a stale digest gives `STALE_TERMS`.
- **FR-AUD-004 reserve override:**
  - a manual Plant ending below R carries a confirmed minimum ending balance;
  - without it, or below it, the result is `STALE_TERMS`;
  - more income is accepted.
- **Configuration codes:** priority gives `FEATURE_UNAVAILABLE` (Q3); an unknown plot, crop or fertilizer gives the matching `UNKNOWN_*` code; clearing a farm default gives `INVALID_CONFIGURATION`; enabling without the capability gives `SKILL_NOT_UNLOCKED`; disabling is always allowed; a value of the wrong type does not decode. All 15 reserved M05 command types give `FEATURE_UNAVAILABLE`, uncharged.
- **V10:**
  - 72 steps of 7 minutes (8 h 24 min), with ApplyAndStart, a configuration change and a re-arm mid-run;
  - a restart from a clone at the midpoint reaches the identical gameplay digest;
  - a replay of the accepted log reaches the identical farm and player;
  - pending events stay at or below 33;
  - no automatic skill, research, equipment or expansion.
- **Persistence:** settings, authorizations and stall reasons round-trip in clones. The automation encoding is canonical: only non-default plot records are serialized, in ascending order, and an unordered or default record is rejected.

## Mutation checks (each run in isolation)

| Injected defect | Caught by |
|---|---|
| An excluded fixed request keeps the other tentative reservations (no replan) | 4 tests (oracle, AV-005-01, AV-005-03, R ≥ W) |
| Seeds reserved from the pre-credit wallet | 4 tests (V03, planner, E8, fixed fertilizer) |
| Accepted fallback ignored | 3 tests |
| Stalled loops retry in every batch, not only credit batches (E6) | Retry test |
| Reset leaves loops armed | DVS-012 reset test |
| Configuration never disarms | Disarm test |
| Loop runnable while armed for a stale plan digest | **Not caught at first.** The fix: a group-edit vector (`test_loop_runs_only_for_the_authorized_plan_digest`). |
| Enabling Auto Harvest on one plot collects every Ready auto plot | **Not caught at first.** The fix: the ready-on-enable test now has a second Ready plot with Auto Harvest already on. |

All mutations were reverted (the script restores from a backup), and the clean-import suite passes.

## Notes and decisions

- **Smart policies plant with None in S4.** Configuring and arming a Smart policy works and is gated at level 9, and the planner computes M and the single C for each batch (`BatchProposal.allocation`). The Smart phase (MP → CE → BP over M and C) is S5, so in S4 Smart-policy plantings, and the first ApplyAndStart planting, use None.
- **Configuration never arms.** `ConfigureAutomation` disarms a plot when its effective plan digest changes or its effective Auto Replant turns off. Reverting a change does not silently re-arm; an explicit ApplyAndStart or a matching Plant is required (FRS §9.2, FR-AUD-007). Toggling Auto Harvest keeps the authorization.
- **ApplyAndStart** writes plot overrides for crop, policy and fallback, plus `auto_replant = true`, arms the loop, and plants Empty members as direct manual plantings. Occupied members get future settings only. It does not change Auto Harvest.
- **Manual reserve override.** R protects automated fertilizer, and manual planting may go below R only with a confirmed `min_ending_balance` (FRS §7.1, FR-AUD-004). The override check runs after the affordability check, so an unaffordable planting still reports `INSUFFICIENT_COINS`, and a missing or violated override reports `STALE_TERMS`. Members of BatchPlant and ApplyAndStart use a running wallet for this.
- **One-off Plant.** A Plant without a plan digest is a one-off planting even on a configured plot (Q1), and its `fallback_accepted` must be false. With a digest, both terms must match the current plan.
- **Stall reasons.** The values are `seed_funds`, `fertilizer_funds`, `capability`, `unarmed` and `ineligible`. A harvested plot whose configured loop cannot run, or a stalled plot touched by a command or a credit batch, reports why; a change emits `PlotStalled`. Only a credit batch, a configuration command touching the plot, or a budget change retries a stalled loop (E6).
- **Schema changes (E2, `schema_version` stays 1).**
  - `PlotState` loses `selected_crop_id`, `auto_harvest`, `auto_replant`, `group_id`, `spending_priority` and `blocked_reason`, and gains `stall_reason`.
  - `automation` becomes `AutomationState`: `defaults` and groups are typed `FarmingSettings`; `plots` is a sparse list of `PlotAutomation {plot_id, settings, group_id, authorization}`; the M01 keys `authorizations` and `defaults` (a free dictionary) are gone.
  - `PlantCrop` args gain three keys.
  - `CommandResult` gains `member_outcomes`.
  - These changes are logged in build plan §9.
- **Suite runtime** grew from 18 s (S3) to 25.8 s. The extra time is the planner running at every due timestamp and the larger validation. Profiling showed that dense automation records dominated clone and digest cost (1.74 → 0.59 ms per clone and 1.51 → 0.39 ms per digest after the sparse encoding).
- **Not in S4.** The Smart solver, caching and CE ranking are S5. Accounting categories and the committed-harvest port are S6. Group commands, priorities and the seed-protection toggle remain fixture-only (Q3).
