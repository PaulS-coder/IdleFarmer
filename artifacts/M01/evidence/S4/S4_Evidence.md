# S4 — Engine, controller, commit outcomes and replay (M01-T13, T14)

Recorded: 2026-10-30 UTC, branch `m01-implementation`. Run: `tools/run_tests.ps1`, exit 0, **201 tests, 6,169 assertions, 0 failures** (`run_s4_pass/`).

## Delivered

| Area | Files |
|---|---|
| Engine API (T13) | `core/simulation/simulation_engine.gd`: `initialize` (resolves the bound manifest), `advance_to` (event by event, one sequence step per timestamp with outcomes, no zero-time loops), `submit_command` (envelope → time → epoch → duplicate → domain checks), `get_state_snapshot`, `get_next_event_time`, `validate_state` |
| Controller (build plan I2) | `core/application/game_controller.gd`, `raw_intent.gd`, `commit_sink.gd` (in-memory sink) |
| Replay (T14) | `core/simulation/command_replayer.gd` |
| Test support | `tests/support/fake_commit_sink.gd` (scriptable COMMITTED / NOT_COMMITTED / lost-ack UNKNOWN / unwritten UNKNOWN / unreadable), `tests/support/scenario_driver.gd` (one script in 1×, 60×, offline or mixed seeded partitions), `tests/fixtures/manifest_fixtures.gd` (counterfactual manifests) |
| Tests | `tests/simulation/test_engine_api.gd`, `test_controller_acceptance.gd`, `test_commit_outcomes.gd`, `test_replay_equivalence.gd`, `test_manifest_binding.gd` |
| Runner | `tools/run_tests.ps1` leak guard (exit 6) |

## Validation coverage (S4 portions)

- **V03 / T-020:**
  - repeating a command gives `DUPLICATE_COMMAND`, even after its cached response is evicted;
  - harvesting a terminated cycle is rejected;
  - a re-delivered intent returns its recorded result;
  - a rejection is measured after due work, and rejected input never changes gameplay counters (the issue counter is controller metadata).
- **V04:**
  - due maturities run before a same-time command (an undrained queue gives `INVALID_COMMAND_TIME`);
  - 32 same-time maturities each run once, in numeric entity order;
  - re-advancing to the current time is a no-op;
  - restoring mid-run from codec-encoded state continues identically.
- **V06 / T-002 core:** 60× reaches the same gameplay state, events and accepted log as 1×, while the anchor advances by 1/60 of the real time.
- **V08 / T-021:**
  - 32 plots (explicit fixture unlocks), four crops, staggered plantings, tied inputs at one timestamp, harvest plus replant, and level gains;
  - 1×, 60×, offline, two mixed random partitions and a second 1× seed all match exactly on gameplay digest, event sequence and accepted log;
  - the pending queue size equals the number of growing cycles.
- **C1:** mode equivalence holds across XP crossings at levels 30, 31, 32 and 35.
- **V10:**
  - past or future accepted times, malformed envelopes and retired epochs are rejected;
  - cache eviction never lets a command pay again.
- **V14 / AV cases:**
  - **AV-001-01:** a backup restored under epoch B allocates the same numeric position with a different full identity, and an epoch-A payload is `STALE_COMMAND`.
  - **AV-001-03:** a fixed namespace gives identical cycle identities across modes; a different namespace stays visible and is never normalized away.
  - **AV-002-01:** a lost receipt (store at the new revision, memory at the parent) blocks retry, new purchases and time-only writes, and no write reaches the sink. Read-back adopts the new revision, debits once, publishes once, and a retry returns the recorded success.
  - **AV-002-02:** an unreadable read-back stays blocked. A verified unchanged parent gives `NOT_COMMITTED`, after which the intent may execute once.
  - **AV-002-05:** a run with a lost receipt and reconciliation equals the uninterrupted run (gameplay digest, replay marks, IDs, accepted log, real-time anchor). Checkpoint cadence changes durable revisions but never gameplay IDs.
  - **AV-003-01:** a level-7, 5,200-XP profile with the automation chain stays valid on `content_m01_v1` while `test_l7_6000` coexists. The same numbers are invalid under the other curve.
  - **AV-003-02:** an unsupported manifest fails at startup with nothing written, and lowered thresholds never apply implicitly.
  - **AV-003-03:** level−1 = unspent + allocated holds across 1×, offline, mixed and restart.
  - **AV-004-01:** an intent quoted before a maturity commits after the due batch, stamped at the maturity time.
  - **AV-004-02:** stale terms give `STALE_TERMS` with no charge or substitute.
  - **AV-004-05:** a duplicate pending intent returns its recorded result with no new commit.
- **T13:**
  - manual Wheat farming works from the actual initial state through the controller;
  - every operation runs on a clone and is validated before commit;
  - events are published only after commit;
  - startup checkpoints before any input;
  - a restart onto a mismatched durable parent is refused.

## Mutation checks

| Injected defect | Caught by |
|---|---|
| `state_sequence` incremented per `advance_to` call (depends on chunking) | 6 tests, including T-021, C1 crossings, engine replay, restore, AV-002-05 and checkpoint cadence |
| Engine duplicate-command check disabled | 4 engine tests |
| Controller intent de-duplication disabled | AV-004-05 |
| UNKNOWN commit treated as committed | AV-002-01, AV-002-02 |

All mutations were reverted, and the clean suite passes.

## Findings

1. **Reference-cycle leak in test support.** A listener lambda capturing the scenario driver formed a driver → controller → listener → driver cycle; Godot reported 410 leaked objects at exit. It was fixed with a separate collector object. The runner now fails on leak reports (exit 6), so a cycle in core code would also fail the build.
2. **GUT tried to load a fixture as a test.** `tests/fixtures/test_manifests.gd` matched GUT's `test_` prefix. The script-error guard turned the warning into exit 5. The fixture was renamed to `manifest_fixtures.gd` (`ManifestFixtures`). Rule: helper files under `tests/` must not start with `test_`.
3. **Fresh sink plus non-zero revision.** Restarting a revision-1 state against an empty store is refused (`STARTUP_NOT_COMMITTED`). This is the intended expected-parent check, now covered by a test.
4. **Godot normalized `project.godot` on import.** It added `config/features=PackedStringArray("4.7")` and dropped `gdscript/warnings/exclude_addons=true`, which is the default value. Behavior is unchanged: addons stay excluded and the untyped-declaration error still applies to project scripts. The normalized file is committed.

## Decisions taken in this slice (recorded in the build plan change log)

- **The intent cache is controller memory with a bound of 1,024.** A re-delivery older than that window is treated as new input; M04 keeps pending UI deliveries short-lived.
- **Rejections are cached per intent; definite NOT_COMMITTED outcomes are not,** so a retry is allowed.
- **Commit identity is `{epoch, counter}`,** from a controller attempt counter that is independent of `next_entity_id`.
