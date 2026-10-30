# M03 field inventory (from M02)

Recorded: 2026-10-30, after S6, branch `m02-implementation`. This document is the input for M03's durable layout. It lists every field `GameState.to_primitive()` produces. The list was generated from a fully populated state (`schema_version` 1), then annotated.

**Validation and copying.** Every record is decoded strictly: exact keys, exact types, and null for anything malformed. Semantic invariants are checked by `GameState.validate(registry)` against the bound manifest. `clone()` is the primitive round trip. The test `test_serialization_coverage` fails if a script field is missing from the primitive, or if the primitive has a key with no matching script field.

**Digest partition.** `gameplay_digest` covers everything except `durable_revision`, `last_commit_id` and `time_anchor`, which form the metadata digest.

**M02 does not persist anything.** M03 owns persistence, migration and the intent ledger. `schema_version` stays 1 until M03 freezes the durable layout (E2).

## 1. Root

| Field | Type | Notes |
|---|---|---|
| `save_id` | String | Profile identity; part of every EntityId |
| `schema_version` | int | 1 |
| `content_version` | String | Immutable manifest binding (`content_m01_v1` / `content_m02_v1`); resolved through `ManifestCatalog` (AV-003) |
| `state_sequence` | int | +1 per changed logical batch or successful command |
| `simulation_time_us` | int | Monotonic simulation time |
| `allocation_namespace` | String | Current writer epoch, used as the EntityId namespace |
| `next_entity_id`, `next_insertion_sequence` | int | Checked allocators; every stored ID or sequence must be below them |
| `durable_revision`, `last_commit_id` | int, {epoch, counter} or null | Metadata: the commit identity is never an EntityId |

## 2. Player, plots, cycles

| Record | Fields | Notes |
|---|---|---|
| `player` | `player_id`, `total_xp`, `level`, `available_skill_points`, `coins`, `skill_ranks{id: rank}` | Level is derived from XP and validated. Capabilities are derived, never stored (E12). |
| `plots[]` (32, ordered) | `plot_id`, `unlocked`, `crop_cycle` or null, `stall_reason` | **S4:** runtime-only. `stall_reason` ∈ none, seed_funds, fertilizer_funds, capability, unarmed, ineligible. It must be `none` while a cycle exists. |
| `crop_cycle` | `cycle_id`, `plot_id`, `crop_id`, `status` (growing/ready), `planted_at_us`, `effective_growth_us`, `matures_at_us`, `maturity_insertion_seq`, `seed_cost_paid`, `fertilizer_id`, `fertilizer_cost_paid`, `gross_coin_reward`, `xp_reward`, `modifier_snapshot{growth_reduction_bp, coin_bonus_bp, fertilizer_bonus_bp}`, `content_version`, `planting_transaction_id`, `fertilizer_transaction_id` or null | Immutable snapshot taken at planting. The maturity event is rebuilt from these fields. The cycle's seed and fertilizer costs are attributed at harvest (operating profit, S6). |

## 3. Economy and progression

| Record | Fields | Notes |
|---|---|---|
| `upgrades.ranks{family: rank}` | int | Validated against the bound manifest's families and ranks |
| `research` (`ResearchState`, S3) | `completed[]` (sorted), `active_project_id`, `active_run_id` (EntityId or null), `active_paid_cost`, `active_started_us`, `active_original_duration_us`, `active_completes_us`, `active_insertion_seq`, `boost_used` | The paid-cost snapshot is never repriced. `boost_used` survives reload. The completion event is rebuilt from these fields (E7). |

## 4. Automation (S4, S6)

| Record | Fields | Notes |
|---|---|---|
| `automation.defaults` (`FarmingSettings`) | `crop_id`, `auto_harvest`, `auto_replant`, `fertilizer_policy`, `fallback_accepted`, `priority`, each with `<field>_set` | Every field is set. An unset field must carry its neutral value. |
| `automation.plots[]` (`PlotAutomation`) | `plot_id`, `settings` (tri-state overrides), `group_id` ("" or a group key), `authorization{armed, plan_digest, authorized_revision}`, `rotation{entries[], cursor}` | **Sparse:** only non-default records are written, in ascending plot ID; a default record is not canonical and is rejected. `plan_digest` = canonical digest of {crop_id, fertilizer_policy, fallback_accepted}. |
| `automation.groups[]` (`GroupRecord`, S6, reserved) | `group_id` (EntityId), `name`, `revision`, `settings` | Ascending identity order. Keyed in memory by `EntityId.key()`. Group commands are M05. |
| Budget | `budget_reserve`, `budget_protection_percent`, `budget_seed_protection` | Farm-only (DEC-010); defaults 0, 25, Off. The seed toggle is fixture-only in M02. |

## 5. Contracts, statistics, settings

| Record | Fields | Notes |
|---|---|---|
| `contracts.instances[]` (`ContractInstance`, S6, reserved) | `instance_id`, `offer_id`, `offer_version`, `accepted_at_us`, `accepted_sequence`, `objective{}` (snapshot), `reward_coins`, `reward_xp`, `progress{key: int}`, `status` (accepted/completed/claimed/abandoned), `claim_id` or null | A claim identity exists exactly when the status is claimed. A claimed offer must also appear in `claimed_offer_ids` (sorted). Behavior is M05. |
| `statistics` | `buckets[]`, `segments[]`, `lifetime{}` | Still untyped placeholders (M05 / DEC-017). **M03 should type these before freezing the layout.** |
| `settings` (`GameSettings`) | `version`, `sound_enabled`, `music_volume`, `sfx_volume` | Profile-owned; debug speed is never stored. |

## 6. Replay and time metadata (M01, carried)

| Record | Fields | Notes |
|---|---|---|
| `command_replay` | `current_epoch`, `committed_success_counter`, `retired_epochs[]`, `cache_capacity`, `response_cache[]{epoch, counter, result}` | Cached results are compact: `{success, failure_code, command_id, state_sequence}` (carry-over 5). Duplicates are decided by the high-water mark, not by the cache. |
| `time_anchor` (metadata) | `credited_through_utc_us`, `last_observed_utc_us`, `anomaly_count`, `intervals[]{kind, real_us, sim_us}` | Bounded summary (DEC-013). The anchor advances by real elapsed time only. |

## 7. Not in `GameState` (in-memory or derived)

- **Pending events.** These are not stored: `EventScheduler.rebuild(state)` re-creates maturity and research events with their original keys.
- **`EconomicTransaction`.** Transactions appear in command results and batches, not in state. They have a nullable `cycle_id` and an `origin` (manual/automatic/system). Each type maps to one category, checked when a transaction is decoded: seed, fertilizer, harvest, research (purchase and boost), equipment, expansion, reset, plus contract claims reserved for M05. M03 decides which transactions to persist for statistics (TRS §10).
- **`CommittedHarvest`.** Published by the controller only after a commit. Fields: time, state_sequence, ordinal, cycle, plot, crop, quantity 1, gross, xp, origin, seed and fertilizer costs. M05 contracts and statistics consume it.
- **`FertilizerOptimizer` cache.** A pure memo; never persisted.
- **Controller intent cache and accepted log.** In memory. The intent ledger is M03.

## 8. Migration notes for M03

1. **Schema changes in M02:**
   - `PlotState` lost `selected_crop_id`, `auto_harvest`, `auto_replant`, `group_id`, `spending_priority` and `blocked_reason`, and gained `stall_reason` (S4).
   - The automation record was replaced by `AutomationState` (S4/S6).
   - Research gained `active_run_id`, `active_original_duration_us` and `active_insertion_seq` (S3).
   - Contracts became typed (S6).
   - No saves exist yet, so no migration code is needed for these changes.
2. **Typing still needed.** `statistics` is the only remaining untyped record.
3. **Gameplay records the durable layout must keep atomic with the gameplay state:**
   - authorizations (armed, plan digest);
   - `boost_used` and the paid-cost snapshot;
   - cycle snapshots;
   - rotation cursor;
   - budget fields;
   - `stall_reason`.

   DEC-010 forbids independently overridable wallet fields.
