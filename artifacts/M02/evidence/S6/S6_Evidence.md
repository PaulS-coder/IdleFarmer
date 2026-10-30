# M02 S6 — Accounting, committed-harvest port, reserved records (M02-T16)

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import (`idle_farmer\.godot` removed): exit 0, **366 tests, 12,428 assertions, 0 failures, 24.9 s** (`run_s6_suite/`). The `-Dir res://balancing` suite also passes.

## Delivered

| Area | Files |
|---|---|
| Transaction categories (E13) | `EconomicTransaction.TYPE_RULES` maps each type to one category, a coin-delta sign and whether it is cycle-bound: seeds, fertilizer, harvest, expansion, equipment, reset, research (purchase and boost), and contracts (claim, reserved for M05). `is_consistent()` is checked on decode, so a wrong category, a wrong sign, a missing or extra cycle, an unknown type or negative XP is rejected. |
| Cost attribution | `CropHarvested` events now carry the cycle's `seed_cost`, `fertilizer_id` and `fertilizer_cost` from its snapshot. `core/economy/accounting.gd` provides `cash_flow` (per category, at payment time) and `operating` (completed-cycle gross minus that cycle's own costs); the two are kept separate (TRS §10). |
| Committed-harvest port (carry-over 1) | `core/economy/committed_harvest.gd` is an immutable record: time, state_sequence, ordinal, cycle, plot, crop, quantity 1, gross, XP, origin and costs; `cycle_id()` returns a copy. `GameController.add_committed_harvest_observer` publishes records only from `_on_committed`, that is, after a COMMITTED outcome or a reconcile that confirmed an UNKNOWN commit. Records are built before presentation listeners run. |
| Reserved records (AV-007-01/04) | `core/farming/group_record.gd` (EntityId identity, name, revision, settings; serialized in ascending identity order); `core/farming/rotation_state.gd` (entries and cursor, per plot); `core/state/contract_instance.gd` (offer and version, acceptance time and sequence, objective and reward snapshot, progress, status, claim identity). These replace the untyped `automation.groups` / `rotation` and `contracts.instances`. |
| Validation | `GROUP_RECORD_INVALID`, `GROUP_KEY_MISMATCH`, `GROUP_ID_FOREIGN`, `GROUP_UNKNOWN`, `ROTATION_CURSOR_RANGE`, `ROTATION_CROP_UNKNOWN`, and the `CONTRACT_*` codes: instance invalid, negative or duplicate; status unknown; claim inconsistent or unrecorded; claimed IDs unsorted; foreign ID. |
| M03 inventory | `artifacts/M02/M03_Field_Inventory.md`, generated from a fully populated state and then annotated. |
| Tests | `simulation/test_m02_accounting` (4), `unit/test_reserved_records` (6). `test_deep_clone` and `test_serialization_coverage` now cover the new records. |

## Validation coverage

- **Every category, with exact cash flow.** One scripted engine run:
  - a manual Corn + Basic Plant (which also arms the loop), Irrigation I, plot 25, Tomatoes research and its boost, an automatic Corn harvest and replant at 30 minutes, then a reset;
  - the result is seeds −36, fertilizer −40, harvest +137, expansion −250, equipment −650, research −4,200, reset −2,450, contracts 0, XP 32;
  - this reconciles exactly with the wallet;
  - every transaction is consistent and round-trips;
  - origins: a manual seed purchase, an automatic seed purchase and an automatic harvest.
- **Transaction rules:** five corrupted forms are rejected on decode.
- **Port publishes only after commit:**
  - planting publishes nothing;
  - a NOT_COMMITTED advance publishes nothing, and the harvest commits on the next advance;
  - a lost acknowledgement (UNKNOWN) publishes nothing until `reconcile()` returns COMMITTED, and then exactly one record;
  - record values: time 30 min, state_sequence equal to the committed state, ordinal 0, plot 1, Corn, quantity 1, gross 137, XP 32, automatic, seed 18, Basic 20, operating profit 99;
  - a misbehaving presentation listener that rewrites event data does not change the record;
  - a manual Wheat harvest gives a manual-origin record, and a rejected re-harvest publishes nothing;
  - `Accounting.operating`: 2 harvests, gross 153, operating profit 115.
- **Observers cannot mutate.** An observer that edits the cycle ID returned by a record changes nothing, and the wallet holds only the committed credit.
- **AV-007-01:**
  - group IDs are unique, round-trip, and allow zero or one membership per plot;
  - a dangling reference, an invalid record, a foreign ID and a key mismatch are each rejected;
  - unordered or duplicate group lists do not decode;
  - CreateGroup, RenameGroup, AssignPlotGroup and DeleteGroup give `FEATURE_UNAVAILABLE`, uncharged.
- **AV-007-04:**
  - a rename (name and revision) keeps the loop runnable;
  - a group field that the plot overrides leaves the plan, and so the authorization, unchanged;
  - an explicit `false` stays an override;
  - a real plan change through the group stalls with `unarmed`.
- **Rotation and contracts:**
  - both round-trip;
  - a cursor out of range and an unknown crop are rejected;
  - seven contract invariant violations are each rejected with their own code.

## Mutation checks (each run in isolation)

| Injected defect | Caught by |
|---|---|
| Harvests published for an UNKNOWN commit before reconcile | Port test and 3 AV-002 tests |
| Harvest records built after presentation listeners | Port test (and the duplicate listener calls break 5 more) |
| Research boost booked as equipment | Cash-flow test and the S3 replay test |
| Harvest event drops the cycle's fertilizer cost | Port test |
| Transaction sign not checked | Transaction-rules test |
| Dangling group reference accepted | AV-007-01 test and the S4 validation test |

All mutations were reverted (the script restores from a backup), and the clean-import suite passes.

## Notes and decisions

- **`CommittedHarvest` lives in `core/economy`.** Accounting consumes it, so economy does not depend on the application layer. The controller only publishes it.
- **Deterministic order** is (time_us, state_sequence, ordinal). One commit can span several timestamps, so `state_sequence` is the committed state's value and `ordinal` counts harvests within that commit.
- **Group identity:** groups use EntityIds (AUD-DEC-001), and plots reference them by `EntityId.key()`. Group commands, presets and rotation behavior remain M05.
- **Statistics** (`buckets`, `segments`, `lifetime`) is still untyped. The M03 inventory flags it to be typed before the layout is frozen.
- **Schema changes** (E2, `schema_version` 1):
  - `automation.groups` becomes an ordered list of `GroupRecord`;
  - `automation.rotation` is removed in favour of `PlotAutomation.rotation`;
  - `contracts.instances` becomes typed;
  - `CropHarvested` event data gains three keys.

  These are logged in build plan §9.
