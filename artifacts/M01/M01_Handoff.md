# M01 — Foundation gate closure and handoff (M01-T16)

Date: 2026-10-30 · Branch: `m01-implementation` · Toolchain: Godot `4.7.2.stable.official.ed1daf0bf` (console binary), GUT 9.7.1 (`aeb5d4f3…`), Compatibility renderer, Windows x86_64.

Final run: `tools/run_tests.ps1` from a clean import, exit 0, **210 tests, 6,354 assertions, 0 failures**, with no script errors and no leaks (`evidence/S5/run_s5_final/`).

**Claim boundary.** This closes the M01 *headless foundation* only:

- No graphics, audio, durable persistence, real platform clock or browser behavior is implemented or claimed.
- The commit sink is an in-memory fake/implementation of the TRS §20.2 contract.
- Suspend/resume uses injected observations.
- Gameplay numbers are provisional development data (FRS), not final balance.

## 1. Task status (M01-T01 to T16)

| Task | Status | Evidence |
|---|---|---|
| T01 Toolchain/project contract | Done | [T01_Toolchain_Evidence.md](T01_Toolchain_Evidence.md), [S0](evidence/S0/S0_Evidence.md) |
| T02 Content IDs and validation | Done | [S1](evidence/S1/S1_Evidence.md) |
| T03 Initial state and XP fixtures | Done | [S1](evidence/S1/S1_Evidence.md) (curve), [S2](evidence/S2/S2_Evidence.md) (new game) |
| T04 Checked integer arithmetic | Done | [S1](evidence/S1/S1_Evidence.md) |
| T05 Records and deep cloning | Done | [S2](evidence/S2/S2_Evidence.md); field coverage enforced in S5 |
| T06 Commands, events, batches | Done | [S2](evidence/S2/S2_Evidence.md), [S4](evidence/S4/S4_Evidence.md) |
| T07 Deterministic scheduler | Done | [S2](evidence/S2/S2_Evidence.md), [S4](evidence/S4/S4_Evidence.md) |
| T08 Injectable clock | Done | [S3](evidence/S3/S3_Evidence.md) |
| T09 Base planting calculations | Done | [S3](evidence/S3/S3_Evidence.md) |
| T10 Manual planting | Done | [S3](evidence/S3/S3_Evidence.md) |
| T11 Maturity and manual harvest | Done | [S3](evidence/S3/S3_Evidence.md) |
| T12 Cumulative XP and levels | Done | [S3](evidence/S3/S3_Evidence.md) |
| T13 SimulationEngine API | Done | [S4](evidence/S4/S4_Evidence.md) |
| T14 Replay and mode equivalence | Done | [S4](evidence/S4/S4_Evidence.md) |
| T15 Architecture/portability boundary | Done | [S5](evidence/S5/S5_Evidence.md), [M01_Dependency_Report.md](M01_Dependency_Report.md), §6 below |
| T16 Gate closure and handoff | Done | This document |

## 2. Validation status (M01-V01 to V14)

| ID | Status | Where it is proven (test files under `idle_farmer/tests/`) |
|---|---|---|
| V01 | Pass | `unit/test_new_game_state.gd` |
| V02 | Pass | `unit/test_maturity_harvest.gd`, `unit/test_plant_command.gd`, `simulation/test_controller_acceptance.gd` |
| V03 | Pass | `unit/test_plant_command.gd`, `unit/test_maturity_harvest.gd`, `simulation/test_engine_api.gd`, `simulation/test_controller_acceptance.gd` |
| V04 | Pass | `unit/test_scheduler_ordering.gd`, `simulation/test_engine_api.gd`, `simulation/test_replay_equivalence.gd` (restore) |
| V05 | Pass | `unit/test_integer_math.gd`, `unit/test_invalid_content.gd`, `unit/test_level_curve.gd`, `unit/test_progression.gd` |
| V06 | Pass | `unit/test_simulation_clock.gd`, `simulation/test_replay_equivalence.gd` |
| V07 | Pass | `unit/test_deep_clone.gd`, `architecture/test_serialization_coverage.gd` |
| V08 | Pass | `simulation/test_replay_equivalence.gd` |
| V09 | Pass (headless part) | `architecture/test_core_dependencies.gd`, `architecture/test_headless_boot.gd`. The music/render assertions of T-002 are deferred to M04. |
| V10 | Pass | `simulation/test_engine_api.gd`, `unit/test_integer_math.gd`, `unit/test_simulation_clock.gd`, `unit/test_maturity_harvest.gd` |
| V11 | Pass | `unit/test_new_game_state.gd`, `unit/test_level_curve.gd` |
| V12 | Pass (M01 scope) | `unit/test_deep_clone.gd`, `unit/test_simulation_clock.gd`. M03-T18 probe recipe in §6 (**not executed**). |
| V13 | Pass | `unit/test_level_curve.gd`, `unit/test_progression.gd`, `simulation/test_replay_equivalence.gd`; Selected/Verified labels in `T01_Toolchain_Evidence.md` |
| V14 | Pass (I1 scope) | `simulation/test_commit_outcomes.gd`, `simulation/test_controller_acceptance.gd`, `simulation/test_manifest_binding.gd`, `simulation/test_replay_equivalence.gd`, `unit/test_identity.gd` |

**V14 scope, approved ruling I1.**

- Covered in M01: AV-001-01/03/04, AV-002-01/02/05, AV-003-01/02/03 and AV-004-01/02/05.
- Pending at their owners: AV-002-03/04 and AV-003-04 → M03; AV-004-03/04 → M02.
- AV-001-02 (claimed-offer rollback) needs contracts → M05.

**Source test matrix (TRS §15):**

- **Evidence recorded:** T-001, T-003, T-020 (in-memory protocol), and the core parts of T-002 and T-021.
- **Future work, not claimed:** T-004–T-019, T-022–T-030, and the M04 music/render half of T-002.

## 3. Adopted engineering decisions

Approved working decisions are recorded in [M01_Readiness_Findings.md](../../docs/implementation/M01_Readiness_Findings.md) (P1–P13, I1–I3). Build-level choices (B1–B8 plus later slice decisions) are in [M01_Build_Plan.md](../../docs/implementation/M01_Build_Plan.md) §1 and §9.

The roadmap decision records M01 had to establish:

| Record | Implemented as |
|---|---|
| D-01 toolchain | Godot 4.7.2-stable standard editor and matching templates verified by hash, signature and commit; GUT 9.7.1 vendored byte-identical; console binary; runner guards for zero tests, script errors and leaks. Templates are verified as a package; export is not exercised (M04/M06). |
| D-02 XP curve | `LevelCurveV1` (FRS levels 1–30 unchanged) plus option B expanded per step to level 349, the int64 representation boundary. That boundary is not a level cap. |
| D-03 new game | `GameState.new_game`: level 1, 0 coins/XP/points, plots 1–24 Empty, 25–32 Locked, Wheat only, nothing planted or selected. |
| D-05 integer units | `core/math/IntegerMath`: checked int64; exact `mul_div` beyond int64 intermediates; floor rewards, ceil prices and durations, 1 μs minimum; basis points. |
| D-06 ordering | Engine processes due events at a timestamp in key order before any command; the controller stamps accepted time and order after due work; no retrospective pooling. |

Other adopted contracts:

- canonical codec plus SHA-256 with separate gameplay and metadata digests;
- `(save, namespace, counter)` identities ordered numerically;
- pending events rebuilt from per-cycle insertion sequences;
- clone-then-commit controller with UNKNOWN blocking;
- manifest-bound validation through `ManifestCatalog`.

## 4. Public API and modules

[M01_Dependency_Report.md](M01_Dependency_Report.md) is generated by `tools/dependency_report.py`. It lists every core and data class with its public signatures, and the module dependency table and diagram. No core or data script references anything outside core and data.

Entry points for M02/M03:

- `GameController`: `start`, `submit_intent`, `advance_active`, `advance_suspended`, `advance_offline`, `reconcile`, `snapshot`, `quote_plant`, `add_commit_listener`, `set_speed_multiplier`.
- `SimulationEngine`: `initialize`, `advance_to`, `submit_command`, `get_state_snapshot`, `get_next_event_time`, `validate_state`.
- `CommitSink`: the contract M03's SQLite repository implements.
- `TimeProvider`: the contract M03's measured platform provider implements.
- `FarmSystem.harvest_ready_cycle`: the shared harvest transition for M02 automation.
- `EconomySystem.current_modifiers`: the hook for M02 skills, equipment and fertilizer.

## 5. Fixture manifest

| Fixture | Purpose |
|---|---|
| `data/manifests/content_m01_v1.gd` (+ `data/crops`, `levels`, `skills`) | The shipped development manifest: 15 crops, 14 research projects, 14 skills (34 ranks), the XP curve |
| `tests/fixtures/oracle_vectors.gd` | Generated by `tools/oracles/generate_oracle_vectors.py` (independent Python): 349 XP thresholds, closed-form adversary, 142 `mul_div` vectors (120 seeded overflow cases), codec encodings and digests |
| `tests/fixtures/manifest_fixtures.gd` | Counterfactual manifests `test_l7_6000` and `test_lowered` (AV-003); never edits of v1 |
| `tests/support/fixtures.gd` | Injected identities (`uuid(tag)`), new game, direct-state builders (explicit pre-unlocks only), planting and harvest command builders |
| `tests/support/fake_time_provider.gd` | Scripted active, suspended and UTC observations; monotonic clock excludes sleep |
| `tests/support/fake_commit_sink.gd` | COMMITTED / NOT_COMMITTED / lost-ack UNKNOWN / unwritten UNKNOWN / unreadable read-back |
| `tests/support/scenario_driver.gd` | One script run in 1×, 60×, offline or mixed seeded partitions |

Fixture rules:

- Fixtures may pre-unlock content explicitly. Production paths never bypass gates; manual planting enforces level and research.
- Helper files under `tests/` must not start with `test_`.

## 6. Portability boundary and the M03-T18 probe recipe (prepared, not executed)

**Browser-safe core assumptions (verified for M01 code by the V09 audit):**

- The core is pure GDScript: `RefCounted` records plus `Resource` content definitions.
- It uses no threads, file I/O, OS/time/display/audio/input APIs, `Engine` globals, dynamic loading, floats, randomness or JSON.
- All time comes from `TimeProvider` observations.
- All persistence goes through `CommitSink`.
- The state's only serialized form is `GameState.to_primitive()` plus `CanonicalCodec` bytes. These are portable and contain no native types.

**Adapter interfaces M03 must supply:**

1. **Windows SQLite `CommitSink`.** It lives in a repository/adapter module outside `core/`. Its tests import godot-sqlite; core never does.
2. **Browser test-snapshot `CommitSink`.** It writes `CanonicalCodec` bytes to `user://`, which is IndexedDB-backed in a web export.
3. **Measured `TimeProvider`** per DEC-014.

**Probe recipe for M03-T18 (T-030, M03-V17).** Record each assertion as pass, partial or fail; never claim full web durability.

1. Export a minimal Compatibility-renderer web build containing `core/`, `data/` and a thin probe scene. Exclude `addons/gut` and every native extension (verify the export file list).
2. **Boot:** build `ManifestCatalog` → `GameState.new_game` → `GameController.start` with the browser sink. Assert `start` returns no errors and `snapshot().validate()` is empty.
3. **Render:** show a single label or sprite driven from `snapshot()`. This proves Compatibility rendering of a scene reading committed state.
4. **Storage success:** plant Wheat, then reload the page. Load bytes → `CanonicalCodec.decode` → `GameState.from_primitive`, and assert the gameplay digest is unchanged.
5. **Storage denied or unavailable:** make the sink return NOT_COMMITTED or UNKNOWN (for example, quota or blocked storage). Assert the controller does not publish, blocks on UNKNOWN, and shows a recoverable error. There must be no silent reset.
6. **Suspend/resume:** with the browser `TimeProvider`, hide the tab for a known interval, then resume. Assert the interval is credited once, suspended time runs at 1× even at 60× debug speed, and nothing is credited twice.
7. **Leakage check:** run `tools/dependency_report.py` and the V09 audit on the probe build's sources. Any native import found in shared core is a defect to fix, not a browser limitation.

## 7. Known limitations

1. **Commits per tick.** The in-memory controller commits every `advance_*` call. M03 sets the real checkpoint cadence (30 s real at 1× and 60×, per G4). The gameplay/metadata split already makes cadence irrelevant to gameplay IDs.
2. **Intent de-duplication window.** It is controller memory bounded at 1,024 and is not persisted. An intent re-delivered after eviction, or after restart, is treated as new input. Harvest stays safe through cycle identity; planting would be a new purchase. M04 must keep UI pending deliveries short-lived; M03 decides any durable intent ledger.
3. **Research completion is a phase-1 placeholder.** The phase and event exist, but there is no producer before M02.
4. **Plot expansion purchase does not exist yet** (M02). The 1..N prefix rule is enforced as a state invariant only.
5. **Identity modifiers only.** No skill, equipment or fertilizer effects; `EconomySystem.current_modifiers` is the hook.
6. **Extension records are inert placeholders.** Contract instances and statistics buckets are untyped primitive dictionaries until their owning milestones define schemas.
7. **Logical module cycles remain** (`economy` ↔ `simulation` ↔ `farming`, `state` ↔ `time`) from type references between records. Checked math was moved to an independent `core/math`. These cycles are harmless in GDScript and can be split later if needed.
8. **Performance is not measured.** The full suite (32-plot scenarios × modes) runs in about 22 s headless. The optimizer and long-offline benchmarks are M02, M03 and M06 obligations.
9. **`GameSettings` defaults (80/80, sound on) are provisional placeholders.**
10. **Deviation from the M01 plan's suggested path.** `IntegerMath` lives at `core/math/integer_math.gd`, not `core/economy/` as the plan suggests. Plan paths are "suggested"; this is recorded in the build plan change log.

## 8. Open items and owners

| Item | Owner |
|---|---|
| Research flow and completion events, skills allocation/reset, equipment, plot purchase, batch commands, automation/fertilizer/optimizer, AV-004-03/04 (boost and reset quotes) | M02 |
| SQLite `CommitSink` (DEC-001 godot-sqlite qualification), durable replay marks and intent policy, real `TimeProvider` (DEC-014 measurements), checkpoint cadence, offline catch-up aggregation, AV-002-03/04, AV-003-04 migrations, M03-T18 browser probe | M03 |
| Rendering, UI, audio and the T-002 music/render assertions; export with templates | M04 |
| Contracts (incl. AV-001-02), statistics, final balance | M05 |
| Hardware qualification (DEC-023), release export, performance | M06 |
| DEC-001 verification entry and D-record synchronization into existing docs | **Applied 2026-10-30** with owner approval: see [M01_Proposed_Doc_Changes.md](M01_Proposed_Doc_Changes.md) |
