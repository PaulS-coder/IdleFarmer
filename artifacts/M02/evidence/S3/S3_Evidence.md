# M02 S3 — Research projects and the one-time boost (M02-T07)

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import (`idle_farmer\.godot` removed): exit 0, **300 tests, 10,901 assertions, 0 failures** (`run_s3_suite/`).

## Delivered

| Area | Files |
|---|---|
| State | `core/research/research_state.gd`: `ResearchState`, promoted from `ExtensionState.Research` (E18). It adds the run identity, the original duration and the scheduler insertion sequence. |
| Rules | `core/research/research_system.gd`: start, quote, boost quote and as-of preview, accelerate, and phase-1 completion |
| Commands | `start_research_command.gd` (terms: project, cost, duration); `accelerate_research_command.gd` (terms: run ID, charge, `rule: "halve_remaining"`); `CommandFactory` registration |
| Scheduling | Phase-1 `ResearchCompleted` event keyed (completes_us, 1, 0, run counter, insertion seq). The engine dispatches it. `EventScheduler.rebuild` re-creates it from the persisted fields. |
| Wiring | Failure codes `UNKNOWN_RESEARCH`, `RESEARCH_ACTIVE`, `RESEARCH_DONE`, `NO_ACTIVE_RESEARCH`, `BOOST_USED`, `NO_TIME_SAVED`, placed in the §3.3 order. Transaction types `research_purchase` and `research_boost`, both in category `research`. Events `ResearchStarted` and `ResearchBoosted`. Controller APIs `quote_research`, `quote_research_boost`, `preview_research_boost`. |
| Validation | `GameState.validate` checks the active run: a known project, a run ID allocated by this save, an insertion sequence that is allocated and not shared with any cycle, a start not in the future, completion still in the future, timing consistent with the boost flag, and the project not also completed. |
| Oracle | `tools/oracles/m02_oracle.py` adds `RESEARCH` (an independent transcription of FRS §8: 14 projects, ⌈C/2⌉, ⌈D/2⌉), `BOOST` (halving, including 1 μs, 2 μs and INT64_MAX), `BOOST_CHARGE` (odd paid costs) and `BOOST_ACCEPTED` (AV-004-03 quote/accept pairs). They use a separate RNG stream, so every earlier vector is byte-identical (the diff is insert-only). |
| Tests | `tests/unit/test_research.gd` (14 tests), `tests/simulation/test_research.gd` (5 tests) |

## Validation coverage

- **V06, project table and gates:**
  - all 14 projects match the oracle (crop, level, cost, duration), and so do their quotes;
  - each one starts at its own level and exact cost, and boosting at start gives ⌈D/2⌉;
  - check order: `UNKNOWN_RESEARCH` (including `unlock_wheat`) → `LEVEL_REQUIRED` → `STALE_TERMS` (cost or duration) → `INSUFFICIENT_COINS`;
  - every rejection is digest-identical, so nothing is charged and no ID is allocated.
- **V06, one active slot:**
  - a second project, or the same one again, while a run is active gives `RESEARCH_ACTIVE`;
  - a completed project gives `RESEARCH_DONE`;
  - a new run may start once the slot is free.
- **DVS-006:**
  - Corn paid 800, so the boost costs 400: 20 min remaining becomes 10, and 10 becomes 5;
  - a second boost gives `BOOST_USED`;
  - 2 μs becomes 1 μs;
  - at 1 μs the boost is rejected with `NO_TIME_SAVED`, uncharged, and the boost is not consumed;
  - a paid snapshot of 599 (repriced content) charges ⌈599/2⌉ = 300, not half the current price, and 299 coins is not enough;
  - after a restart (clone plus rebuild) the boosted event has the same key and the boost is still used.
- **Stale and duplicate completion:**
  - after a boost, the original pre-boost event delivered directly changes nothing;
  - the original completion time passes with no second completion;
  - a duplicate completion event after the run has finished is ignored.
- **Completion (T-009 part):**
  - it unlocks the crop, which is then available because the level gate is also met;
  - it clears the slot and starts no next project;
  - it buys no boost, and it neither assigns nor plants a crop;
  - nothing else is scheduled afterwards.
- **TRS §4.2 phase order:** research completing at the same timestamp as a wheat maturity is emitted first, even though the cycle has the lower entity counter and insertion sequence.
- **AV-004-03 (controller):**
  - for 20 oracle quote/accept pairs across four projects, the preview is labelled with its as-of time and the charge is fixed;
  - the accepted-time result is accept time + ⌈remaining at acceptance/2⌉, and it is returned in the `ResearchBoosted` event;
  - a preview that saved 1 μs but reaches acceptance with 1 μs left is rejected with `NO_TIME_SAVED`, uncharged;
  - a run that completes before acceptance gives `NO_ACTIVE_RESEARCH`, uncharged.
- **E16 / AV-004-05:**
  - re-delivered start and boost intents return their recorded results and never charge twice;
  - a fresh intent with the same boost terms gives `BOOST_USED`;
  - old boost terms against a new run give `STALE_TERMS`;
  - the accepted log replays to identical research state and coins.
- **Persistence:** the active run, its paid snapshot and the boost flag round-trip through `clone()`. Eight corrupted-state cases (including an insertion sequence shared with a cycle) are each rejected by validation with their specific code.

## Mutation checks (each run in isolation)

| Injected defect | Caught by |
|---|---|
| Boost charge ⌊C/2⌋ instead of ⌈C/2⌉ | **Not caught at first.** Every FRS §8 cost is even, so floor and ceiling agree on all real data. The fix: oracle `BOOST_CHARGE` odd vectors plus a 599 paid-snapshot test. After the fix it is caught by 2 tests. |
| Halving ⌊r/2⌋ instead of ⌈r/2⌉ | 3 tests (oracle halving, 1/2 μs, AV-004-03) |
| Completion guard on insertion sequence and time removed | Stale-event test |
| Research event in phase 2 instead of phase 1 | Phase-order test and rebuild-key test |
| One-active-slot check removed | One-slot test |
| `EventScheduler.rebuild` omits the research event | 3 tests (restart, completed-before-acceptance, replay) |

All mutations were reverted (the script restores from a backup), and the clean-import suite passes.

## Notes and decisions

- **Flat fields instead of a nested record.** The active run is stored as flat `active_*` fields, not as the nested `active` record described in §3.8. E18 asks to keep the M01 primitive keys and add fields. The new keys are `active_run_id` (a nullable EntityId), `active_original_duration_us` and `active_insertion_seq`. `ExtensionState.Research` is removed. `schema_version` stays 1 (E2). This is logged in build plan §9.
- **`RESEARCH_ACTIVE` is checked before `RESEARCH_DONE`.** This follows the §3.3 precedence list; the prose in §3.8 names "not completed" first. So starting a completed project while another run is active reports `RESEARCH_ACTIVE`.
- **Boost terms.** `run_id` is the run's `EntityId.key()` string, which keeps the terms flat and typed. Any rule other than `halve_remaining` is malformed (`MALFORMED_ENVELOPE`), not stale. Remaining time is deliberately not a term (AV-004-03).
- **Boosting a run that has completed** gives `NO_ACTIVE_RESEARCH`, or `STALE_TERMS` if a newer run is active. The specification's "completed" rejection maps onto these two codes; no separate code was added.
- **Two layers against stale events.** A boost both cancels the old scheduler entry and changes the run's insertion sequence and time, which `complete()` checks. Removing only the cancel would not change behaviour, so it is not a useful mutation; the guard was mutated instead.
- **v1 profiles.** Research also works for v1-bound profiles, because `content_m01_v1` carries the same research table. There is no `FEATURE_UNAVAILABLE` here, unlike the economy tables.
- **Not in S3.** Offline aggregation breaking at research completion is M03. The committed-harvest port and the accounting categories beyond these two transaction types are S6.
