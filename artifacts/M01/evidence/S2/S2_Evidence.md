# S2 — State, identities, commands and scheduler (M01-T05, T06, T07)

Recorded: 2026-10-30 UTC, branch `m01-implementation`. Run: `tools/run_tests.ps1`, exit 0, **116 tests, 3,021 assertions, 0 failures** (`run_s2_pass/`).

## Delivered

| Area | Files |
|---|---|
| Authoritative records (T05) | `core/state/game_state.gd`, `player_state.gd`, `plot_state.gd`, `crop_cycle.gd`, `time_anchor.gd`, `game_settings.gd`, `command_replay_state.gd`, `extension_state.gd` (Upgrades, Research, Contracts, Automation, Statistics stubs), `core/time/accounted_interval.gd` |
| Identities (T05/T06, AUD-001) | `core/state/entity_id.gd`, `command_id.gd`; strict decoding via `core/state/primitive_reader.gd` |
| Commands/results/events (T06) | `core/simulation/game_command.gd`, `plant_crop_command.gd`, `harvest_crop_command.gd`, `command_result.gd`, `failure_code.gd`, `simulation_event.gd`, `state_change_batch.gd`, `core/economy/economic_transaction.gd` |
| Scheduler (T07) | `core/simulation/event_scheduler.gd`, `scheduled_event.gd`, `event_phase.gd` |
| Tests | `tests/support/fixtures.gd`; `tests/unit/test_new_game_state.gd`, `test_state_validation.gd`, `test_deep_clone.gd`, `test_identity.gd`, `test_command_envelope.gd`, `test_scheduler_ordering.gd` |

## Validation coverage (S2 portions)

- **V01:**
  - 32 unique ordered plots: 1–24 unlocked and Empty, 25–32 Locked, no cycles, nothing selected;
  - player at level 1 with 0 XP, coins and points;
  - Wheat is the only available crop;
  - no research, upgrades or contracts;
  - G3 budget defaults are 0 / 25% / Off.
- **V11:**
  - every ID maps to fixed eight-column coordinates;
  - a fixture with a gap in the unlocked plots (1–24 plus 26) is rejected;
  - every contiguous prefix from 24 to 32 is valid;
  - scattered occupancy is valid;
  - a locked plot holding a cycle is rejected.
- **V07:**
  - 23 targeted mutations of nested containers in a clone, covering every record and extension stub, leave the source digest unchanged;
  - no object references are shared;
  - exported primitives contain no typed containers;
  - lossless codec round-trip;
  - 11 malformed snapshots are rejected by the strict decoder.
- **V12 (state part):** settings carry no debug-speed key. Gameplay and metadata digest projections are disjoint, and checkpoint metadata does not change the gameplay digest.
- **V04 (queue part):**
  - each tuple field decides order independently;
  - entity order is numeric, never by UUID;
  - 25 seeded push permutations pop identically;
  - `pop_at` groups by time;
  - duplicate insertion sequences are rejected;
  - cancellation compacts storage to at most 2 × pending + 1;
  - rebuilding from state and from a clone reproduces identical keys and order.
- **V03/V10 (contract part):**
  - accepted envelopes cannot be edited through accessors and round-trip losslessly as replay records;
  - nine malformed-envelope cases are rejected;
  - the response cache is bounded, and eviction never restores execution eligibility;
  - epoch retirement makes old commands stale.
- **AV-001-01/04 (data part):**
  - IDs round-trip at counters 1, MAX−1 and MAX;
  - malformed IDs are rejected;
  - allocation at the int64 limit fails without counter drift;
  - a new namespace allocates new IDs while restored entities keep theirs.
- **AV-003-01/03 (data part):**
  - a level-7, 5,200-XP profile with the four-node automation chain and 2 unspent points is valid;
  - level−1 = unspent + allocated is enforced;
  - prerequisite and level gates are enforced;
  - a state bound to another manifest is not validated against this registry.

## Mutation checks

| Injected defect | Caught by |
|---|---|
| Scheduler entity-order tie-break reversed | 3 scheduler tests failed |
| `GameState.clone()` returns `self` | All clone isolation tests failed (23 mutation assertions, 13 reference assertions) |
| Unlock-gap validation disabled | `test_v11_hole_bearing_unlock_is_rejected` failed |

All mutations were reverted, and the clean suite passes.

## Findings

1. **`to_primitive()` exported typed containers.** `duplicate()` of a `Dictionary[String, int]` stays typed, so exported "primitives" rejected writes of other types. All exports now go through `PrimitiveReader.plain()`, and a test asserts that no typed container remains anywhere in the state primitive.
2. **`namespace` is a reserved word in GDScript.** The `EntityId` field is named `allocation_namespace`; the primitive key stays `"namespace"`.
3. **During the mutation run the runner exited −1 without a summary.** Cause: the invoking console command piped output through `Select-Object -First 60`, which stops the child process early. GUT's results were complete. This is not a runner defect; only invoke the runner without truncating its output.

## Plan deviations (recorded in the build plan change log)

- `SkillState` is represented as `PlayerState.skill_ranks`, matching the TRS §9.4 logical schema `player.skill_ranks`.
- New files: `primitive_reader.gd`, `command_id.gd`, `scheduled_event.gd`, `plant_crop_command.gd`, `harvest_crop_command.gd`.
- Each `CropCycle` stores `maturity_insertion_seq`, so `EventScheduler.rebuild` reproduces exact keys (B2 refinement).
- `SimulationEvent` is the emitted outcome record, and `ScheduledEvent` is the queued future event.
