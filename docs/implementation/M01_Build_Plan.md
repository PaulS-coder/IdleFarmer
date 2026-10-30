# M01 — Developer build plan

Date: 2026-10-29 · Status: **working build plan, non-authoritative** · Approved inputs: owner "Approve all" (2026-10-29) for P1–P13 and I1–I3 in [M01_Readiness_Findings.md](M01_Readiness_Findings.md).

**Authority order:**

1. [FRS](../requirements/IdleFarmer_Functional_v1.0.md) owns gameplay.
2. [TRS](../architecture/IdleFarmer_Technical_v1.5.md) owns architecture.
3. The [M01 plan](01_M01_Headless_Simulation_Foundation.md) owns tasks and acceptance criteria.
4. This document turns those into concrete files, APIs, tests and order. It does not change any rule.

If this plan disagrees with those sources, the sources win. Fix this plan and record the reason in §9.

Toolchain status: T01 artifacts are verified. See [T01_Toolchain_Evidence.md](../../artifacts/M01/T01_Toolchain_Evidence.md).

---

## 1. Approved working decisions

These carry the approved P/I rulings, plus build-level choices (B1–B8) that this plan makes within them. Any B item can be revised during S0/S1 if the toolchain disproves it; record the reason in §9.

| ID | Decision |
|---|---|
| P1/P2 | Godot project lives in `idle_farmer/`. The layout follows the M01 table plus `core/application/`. Docs stay in `docs/`. |
| P3 | GUT CLI via `tools/run_tests.ps1`. Always use `Godot_v4.7.2-stable_win64_console.exe`. The run fails if zero tests ran. |
| P4 | Evidence goes in `artifacts/M01/`. Committed per-slice evidence goes in `artifacts/M01/evidence/S<n>/`. Scratch runs go in `artifacts/M01/test_runs/` (gitignored). |
| P5 | Custom canonical codec plus SHA-256 digest (§3.2). Never use Godot `JSON` for authoritative data. |
| P6 | Checked int64 arithmetic (§3.1), checked against an independent Python oracle. |
| P7 | Crop IDs `wheat … saffron`; research IDs `unlock_<crop_id>`; manifest `content_m01_v1`. |
| P8 | Stage is derived: growing → `min(3, floor(elapsed×4 / growth))`; `elapsed ≥ growth` → stage 4 (Ready). |
| P9 | Phase codes 1–9 follow TRS §4.2. Only phase 1 (ResearchCompleted, no producer in M01) and phase 2 (CropMatured) are queued events. `numeric_entity_order` = the entity counter. |
| P10 | One injected UUID per writer epoch serves both as `writer_epoch_uuid` and `allocation_namespace`. The command counter and the entity counter are separate. |
| P11 | Failure codes and their precedence are listed in §3.4. |
| P12 | Response cache holds 256 entries per epoch; tests can configure it. |
| P13 | Branch `m01-implementation`. One commit per slice, or smaller. Each commit must have green tests. |
| I1 | M01 covers AV-001-01/03/04, AV-002-01/02/05, AV-003-01/02/03 and AV-004-01/02/05. Deferred: AV-002-03/04 and AV-003-04 to M03; AV-004-03/04 to M02 (boost and reset quotes). |
| I2 | An in-memory `GameController` (`core/application/game_controller.gd`) handles stamping, counters, intent dedupe and the commit sink. |
| I3 | A data-only skill allocation record (`SkillState`) plus minimal skill definitions in the manifest. These exist only for point-conservation and manifest tests; there is no skill behavior. |
| B1 | Content source tables are GDScript constant files (exact ints, diffable). `ContentRegistry` builds immutable `CropDefinition` Resources from them. No `.tres`/JSON for catalog numbers. |
| B2 | Pending events are reconstructed from state, not serialized. State stores `next_insertion_sequence`. A test proves that the live and reconstructed queues pop identically. |
| B3 | Commit IDs come from a controller `commit_attempt_counter`, never from `next_entity_id` (TRS §20.2). |
| B4 | The controller always works on a clone: clone → mutate → prepare → sink. It keeps a separate `committed_state` that is replaced only on COMMITTED. |
| B5 | `state_sequence` increments once per applied batch (due batch or accepted command). Rejections and pure stamping change nothing in `GameState`. |
| B6 | Speed is an integer from 1 to 60 and time is integer μs, so no fractional carry is needed. The clock still exposes `carry_us = 0` for M03. |
| B7 | `configured_priority = 0` for all M01 events. Plot spending priority is M02. |
| B8 | Project setting `debug/gdscript/warnings/untyped_declaration = Error`, with addons excluded. S0 verifies GUT still runs under it. |

## 2. Project setup (S0 — completes M01-T01)

```text
IdleFarmer/                              (repo root)
  .gitignore                             idle_farmer/.godot/, artifacts/*/test_runs/, *.tmp
  docs/                                  unchanged authority
  artifacts/M01/                         T01 evidence (exists), evidence/S<n>/
  tools/
    run_tests.ps1                        import → GUT → junit → zero-test guard → exit code
    oracles/xp_curve_oracle.py           independent vectors (Python, big ints)
    oracles/arith_oracle.py              mul_div/rounding vectors
  idle_farmer/
    project.godot                        Compatibility renderer, typed warnings, no autoloads
    .gutconfig.json                      dirs: res://tests, include_subdirs, junit path
    addons/gut/                          vendored verified GUT 9.7.1 (commit aeb5d4f3…)
    core/
      application/game_controller.gd, commit_sink.gd, raw_intent.gd
      state/      game_state.gd, player_state.gd, plot_state.gd, crop_cycle.gd,
                  time_anchor.gd, game_settings.gd, entity_id.gd, command_replay_state.gd,
                  extension_state.gd, canonical_codec.gd
      content/    crop_definition.gd, level_curve_definition.gd, skill_definition.gd,
                  content_manifest.gd, content_registry.gd, manifest_catalog.gd
      simulation/ game_command.gd, plant_crop_command.gd, harvest_crop_command.gd,
                  command_result.gd, failure_code.gd, simulation_event.gd, event_phase.gd,
                  event_scheduler.gd, state_change_batch.gd, simulation_engine.gd
      economy/    integer_math.gd, economy_system.gd, economic_transaction.gd
      time/       time_provider.gd, simulation_clock.gd, accounted_interval.gd
      farming/    farm_system.gd
      progression/progression_system.gd
    data/
      crops/crop_catalog_v1.gd           FRS §4.2 + §8 research rows, as constants
      levels/level_curve_v1.gd           FRS §5.1 table + §5.1.1 option B parameters
      skills/skill_catalog_v1.gd         ids + max ranks only (I3)
      manifests/content_m01_v1.gd        binds the three above
    tests/
      support/   fake_time_provider.gd, fake_commit_sink.gd, fixtures.gd, digest_assert.gd
      fixtures/  test_manifest_l7_6000.gd, invalid_content/*.gd
      unit/      (one file per class or area, see §5)
      simulation/(scenario and replay suites)
      architecture/test_core_dependencies.gd
```

`tools/run_tests.ps1` does the following:

1. Resolve `$env:GODOT_BIN`. It defaults to `C:\_\tools\godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe`.
2. Run `--headless --path idle_farmer --import`.
3. Run `--headless --path idle_farmer -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gexit`. An optional `-Dir` or `-Test` parameter forwards `-gdir`/`-gselect`.
4. Copy the log and JUnit XML to `artifacts/M01/test_runs/<UTC timestamp>/`.
5. Scan the import and test logs for script load/parse errors and exit 5 if any are found. GUT skips such files and exits 0 (found in S0).
6. Parse the JUnit XML. If it shows zero tests, exit 2. Otherwise return GUT's exit code.

S0 exit evidence:

- In the real project, the empty suite fails because of the zero-test guard.
- A smoke test passes with exit 0.
- A temporary failing test exits 1 and is then removed.
- Logs go to `artifacts/M01/evidence/S0/`.

## 3. Cross-cutting technical contracts

### 3.1 `IntegerMath` (T04, DEC-005/026)

GDScript `int` wraps silently, so every authoritative operation goes through these helpers. They return a `MathResult` (`ok: bool`, `value: int`) or use the `NumericLimit` failure path. They never return a wrapped value.

| Function | Rule |
|---|---|
| `add(a, b)`, `sub(a, b)` | Pre-check against `INT64_MAX`/`INT64_MIN` before the operation. |
| `mul(a, b)` | Zero shortcut. Otherwise check with `abs`-safe division (`a > MAX / b`, with sign cases and the `MIN` special case). |
| `floor_div(a, d)`, `ceil_div(a, d)` | Correct for negatives. GDScript `/` truncates toward zero, so adjust when the remainder ≠ 0 and the signs differ. |
| `mul_div_floor(a, b, d)`, `mul_div_ceil(a, b, d)` | For `a, b ≥ 0`, `d > 0`. Fast path when `mul(a, b)` is ok. Slow path: 128-bit product from 32-bit limbs, then shift-subtract long division by `d`. Fails only if the quotient exceeds int64. |
| `apply_bp_floor(x, bp)`, `apply_bp_ceil(x, bp)` | `mul_div_*(x, bp, 10_000)` |
| `growth_us(base_us, reduction_bp, cap_bp)` | `max(1, ceil(base × (10_000 − min(reduction, cap)) / 10_000))` |
| `next_option_b_increment(p)` | `p + ceil_div(p, 10)`, checked |

Tests:

- table vectors from `tools/oracles/arith_oracle.py`;
- `INT64_MAX`/`MIN` edges;
- a product that overflows but whose quotient fits (succeeds);
- a quotient that does not fit (fails);
- the Tomato cap of 24 min (1,440,000,000 μs);
- the 1 μs minimum.

### 3.2 Canonical codec and digest (T05, P5)

- Every record implements `to_primitive() -> Variant`, `static from_primitive(v) -> Self` (with validation), `clone() -> Self` and `validate() -> Array[String]` (an empty array means valid).
- **Allowed primitives:** `int`, `bool`, `String`, `null`, `Array`, and `Dictionary` with String keys. A `float`, `Object` or `Resource` makes encoding fail.
- **`CanonicalCodec.encode(v) -> PackedByteArray`** produces UTF-8 text:
  - `n` / `t` / `f` for null, true and false;
  - `i<decimal>` for ints;
  - `s<len>:<utf8>` for strings;
  - `[…,…]` for arrays;
  - `{k:v,…}` for dictionaries, with keys sorted by code point.
- **`CanonicalCodec.decode(bytes)`** is the exact inverse. It is used for snapshot round-trips (AV-001-04).
- **`digest(v) -> String`** is the SHA-256 hex digest via `HashingContext`.
- **Two projections on `GameState`** (TRS §20.2, M01-V14):
  - `gameplay_primitive()`: everything except the durable and clock metadata listed next;
  - `metadata_primitive()`: `durable_revision`, `last_commit_id`, `time_anchor` diagnostics, the interval summary and the commit counter.
  - Mode-equivalence tests compare gameplay digests exactly and check metadata separately.

### 3.3 Identities (T05/T06, AUD-001, P10)

- **`EntityId`** = `{save_id: String, namespace: String, counter: int}`.
  - Order is by `counter` only. Equality uses all three fields.
  - It is allocated by `GameState.allocate_entity_id()`, which checks `next_entity_id` and fails with `NUMERIC_LIMIT` at `INT64_MAX`.
- **`CommandId`** = `{save_id, writer_epoch: String, counter: int}`.
  - The controller issues these and keeps its issue counter outside `GameState`.
  - `GameState.command_replay` holds `current_epoch`, `committed_success_counter`, `retired_epochs: Array[String]` and the bounded `response_cache` (oldest-first eviction, P12).
- **Injection:** tests use `Fixtures.uuid("A")`, which produces fixed tokens such as `00000000-0000-4000-8000-00000000000A`. No core code generates UUIDs.

### 3.4 Commands, results, failures (T06, P11, AUD-004)

**`RawIntent`** (controller input, never replayed) carries:

- `intent_id` (stable pending-delivery ID),
- `type`,
- `target` (plot_id / cycle EntityId),
- `terms`.

**`PlantCrop` terms:** `crop_id`, `manifest_id`, `seed_cost`, `growth_us`, `gross_coins`, `xp`.

**`HarvestCrop` terms:** `plot_id`, `cycle_id`.

**Accepted `GameCommand`** is immutable after construction. It holds `command_id`, `type`, `accepted_time_us`, `accepted_order` and typed args/terms.

**`CommandResult`** holds:

- `success`, `failure_code`, `failure_detail`;
- `affected_ids`, `events: Array[SimulationEvent]`, `transactions: Array[EconomicTransaction]`;
- `state_sequence`, `command_id`;
- a `commit_status` slot (`COMMITTED`/`NOT_COMMITTED`/`UNKNOWN`/`NONE`).

**`FailureCode`** enum, checked in this precedence order (the first failing check wins):

1. `MALFORMED_ENVELOPE`
2. `INVALID_COMMAND_TIME`. The accepted time ≠ the engine's current time after due work; past and future both fail.
3. `STALE_COMMAND`. The command belongs to a retired epoch.
4. `DUPLICATE_COMMAND`. The counter is ≤ the high-water mark.
5. `PERSISTENCE_UNAVAILABLE`. The controller is blocked in UNKNOWN.
6. `UNKNOWN_PLOT`, `UNKNOWN_CROP`
7. `PLOT_LOCKED`
8. `PLOT_OCCUPIED`, `NO_CYCLE`, `CYCLE_MISMATCH`, `CROP_NOT_READY`
9. `LEVEL_REQUIRED`, `RESEARCH_REQUIRED`
10. `STALE_TERMS`. Quoted terms ≠ the recomputed terms.
11. `INSUFFICIENT_COINS`
12. `NUMERIC_LIMIT`

`INVALID_CONFIGURATION` and `SKILL_NOT_UNLOCKED` are reserved for M02.

**Rejection rule:** a rejection produces no change in `GameState`. The gameplay and metadata digests stay equal to the post-due-work baseline. The controller's issue counter may advance.

### 3.5 Scheduler (T07, P9, B2, B7)

- **`EventKey`** = `(time_us, phase, configured_priority, entity_order, insertion_seq)`, compared lexicographically as ints.
- **`EventScheduler`** is a binary heap over `EventKey`. Its API:
  - `push(event) -> EventKey`
  - `peek_time()`, `pop_due(time_us) -> Array[SimulationEvent]`
  - `cancel(entity_id)` (lazy tombstones, compacted when tombstones > live count)
  - `size()`
  - `static rebuild(state) -> EventScheduler`
- **Staleness:** events carry `cycle_id`. When popped, the event is dropped if the plot's current cycle ≠ `cycle_id`, or if the cycle is not Growing.
- **Bound:** the queue holds at most one live maturity per Growing cycle. Completed events are never retained (V08).
- **Zero-time loop guard:** if a batch at time `t` makes no state progress, the engine stops processing at `t` (V04).

### 3.6 Engine and controller (T13, I2, B3–B5, AUD-002/004)

**`SimulationEngine`** is pure: no I/O and no clock reads. It operates on the state it was given. Methods:

- `initialize(state: GameState, registry: ContentRegistry) -> Array[String]` (validation errors)
- `advance_to(target_us) -> StateChangeBatch`: processes all due events with `time ≤ target` in key order, grouped per timestamp by phase, then sets `simulation_time_us = target`.
- `submit_command(cmd: GameCommand) -> CommandResult`
- `get_next_event_time() -> int` (−1 if none)
- `get_state_snapshot() -> GameState` (a clone)
- `validate_state() -> Array[String]`

**Hooks** (no-op in M01): `on_committed_harvest(tx)` and `on_accounting(batch)`. M02/M05 attach to these.

**`GameController`** (in-memory). Its fields:

- `committed_state`
- `registry_catalog: ManifestCatalog`
- `sink: CommitSink`
- `clock: SimulationClock`
- `issue_counter`
- `commit_attempt_counter`
- `pending_intents: Dictionary` (intent_id → result)
- `blocked_unknown: bool` plus `pending_commit` context

Its methods:

1. **`start(save_id, epoch_uuid, state)`**: retires any previous epoch into `retired_epochs`, sets the namespace and epoch, and commits a startup checkpoint.
2. **`tick(real_elapsed_us)`**: the clock converts real time to a simulation target. Then: clone → `advance_to` → prepare → commit.
3. **`submit_intent(intent: RawIntent) -> CommandResult`**:
   1. If the intent was seen before, return the cached result (AV-004-05).
   2. If `blocked_unknown`, return `PERSISTENCE_UNAVAILABLE`.
   3. Clone, and run `advance_to(now)` so due work happens first.
   4. Stamp the command with `accepted_time = now` and the next `issue_counter`.
   5. Call `engine.submit_command`.
   6. If the command fails, commit the due work only, if there was any.
   7. If it succeeds, prepare a checkpoint `{commit_id: (epoch, ++commit_attempt_counter), expected_parent: committed.durable_revision, state}` and call `sink.commit(prepared)`.
4. **`reconcile(read_back) -> Status`**: used during UNKNOWN. A read-back revision equal to the expected new revision makes the prepared state committed. One equal to the parent means NOT_COMMITTED. Anything else stays blocked (AV-002-01/02).

**`CommitSink` interface:** `commit(prepared) -> Status` and `read_back() -> {durable_revision, commit_id, state}`. `FakeCommitSink` scripts its outcomes per call.

### 3.7 Time (T08, DEC-013/014)

**`TimeProvider`** (abstract `RefCounted`):

- `get_utc_unix_time_us()`
- `get_monotonic_time_us()`
- `get_resume_elapsed_us()`
- `observe_partition() -> {active_us, suspended_us}`

`FakeTimeProvider` exposes setters and scripted UTC jumps. No Godot `Time` calls are made in M01 core. The real adapter is M03.

**`SimulationClock`** works only from deltas it is given:

| Method | Simulation advance | Anchor (`credited_through_utc_us`) advance |
|---|---|---|
| `advance_active(real_us)` | `real_us × speed` | `real_us` |
| `advance_suspended(real_us)` | `real_us` (1×) | `real_us` |
| `advance_offline(real_us)` | `real_us` (1×) | `real_us` |

All three record an `AccountedInterval {kind, real_us, sim_us}`. The interval list is bounded: anything older than the last committed anchor is compacted.

Other methods: `set_speed_multiplier(1..60)` (anything else is rejected) and `reset_speed()`. UTC is never read to compute deltas. A backward UTC change never moves the anchor back.

Oracles:

- 480 s at 1× equals 8 s at 60×.
- 10 s active at 60× plus 1 h suspended = 4,200 s simulated, and the anchor advances by 3,610 s.

### 3.8 Content and manifests (T02/T03, AUD-003, I3)

- **`ContentManifest`**: `manifest_id`, `crops`, `level_curve`, `skills`, `research` (data only).
- **`ContentRegistry`**: built from a manifest. It validates and then freezes; there are no setters after build.
- **`ManifestCatalog`**: `supported: Dictionary[String, ContentRegistry]`. `GameState.content_version` must resolve through it before validation; if it doesn't, the result is a recoverable error and the state is not mutated.
- **`LevelCurveDefinition`**:
  - `explicit_thresholds` (30 entries) plus `option_b_first_increment = 57_500` and `option_b_growth = 10%` (as `p + ceil(p/10)`);
  - the full threshold list is generated once at registry build until the next threshold would exceed int64, giving 349 levels;
  - `level_for_xp(xp)` is a binary search;
  - `next_threshold(level)` returns −1 past the representable end, which is not a cap.
- **Validation** fails fast on any of these:
  - duplicate IDs;
  - non-positive duration;
  - negative values;
  - stage-reference count ≠ 5;
  - missing references;
  - non-monotonic thresholds;
  - an unknown research gate.

## 4. Slices and tasks

Each slice ends with all suites green through `tools/run_tests.ps1`, evidence in `artifacts/M01/evidence/S<n>/` and one commit.

| Slice | M01 tasks | Build | Tests added (see §5) |
|---|---|---|---|
| **S0** Toolchain/project | T01 | §2 skeleton, vendored GUT, runner, `.gitignore`, typed-warning setting | `tests/unit/test_smoke.gd`; runner exit-code evidence |
| **S1** Math, codec, content | T02, T03, T04 | `IntegerMath`, `CanonicalCodec`, content classes, catalog/curve/skill data, `ManifestCatalog`, oracle scripts | `test_integer_math`, `test_canonical_codec`, `test_content_registry`, `test_invalid_content`, `test_level_curve` |
| **S2** State, identity, commands, scheduler | T05, T06, T07 | All state records and extension stubs, `EntityId`/`CommandId`, `GameCommand`/`CommandResult`/`FailureCode`, `EventScheduler`, `StateChangeBatch` | `test_new_game_state`, `test_state_validation`, `test_deep_clone`, `test_identity`, `test_command_envelope`, `test_scheduler_ordering` |
| **S3** Clock, farming, XP | T08–T12 | `TimeProvider`/`SimulationClock`, `EconomySystem`, `FarmSystem.plant/mark_mature/harvest`, `ProgressionSystem.add_xp/get_level_for_xp` | `test_simulation_clock`, `test_planting_quotes`, `test_plant_command`, `test_maturity_harvest`, `test_progression` |
| **S4** Engine, controller, replay | T13, T14 | `SimulationEngine`, `GameController`, `CommitSink`, `FakeCommitSink`, replay recorder | `test_engine_api`, `test_controller_acceptance`, `test_commit_outcomes`, `test_replay_equivalence`, `test_manifest_binding` |
| **S5** Boundaries and handoff | T15, T16 | Dependency audit test, headless-boot check, boundary report, M03-T18 probe recipe, API inventory, fixture manifest, limitations | `test_core_dependencies`, `test_headless_boot`; `artifacts/M01/M01_Handoff.md` |

### Extension stubs (T05, minimal and inert, each with clone/codec/validate)

- `UpgradeState{ranks: {}}`
- `ResearchState{completed: [], active: null, boost_used: false}`. Wheat is a start unlock and has no research record.
- `ContractState{offers: [], instances: [], claimed_offer_ids: []}`
- `AutomationConfiguration{defaults: {}, groups: {}, budget: FarmBudgetConfiguration{reserve: 0, protection_percent: 25, seed_protection: false}, authorizations: {}, rotation: {}}`
- `StatisticsState{buckets: [], segments: []}`
- `SkillState{allocated: {}}` (I3)
- `GameSettings{version: 1, sound_enabled: true, music_volume: 80, sfx_volume: 80}` (provisional defaults). It has no debug speed field.

## 5. Validation map (M01-V01–V14 → tests → exact oracles)

| V | Test files | Exact oracle / assertion |
|---|---|---|
| V01 | `unit/test_new_game_state` | IDs 1–32 unique; 1–24 unlocked and Empty; 25–32 Locked with no cycle; level 1; XP 0; coins 0; points 0; eligible crops == `[wheat]` |
| V02 | `unit/test_maturity_harvest`, `simulation/test_wheat_corn_scenario` | Wheat planted at t=0: at t=479,999,999 it is Growing; at 480,000,000 it is Ready. Harvest gives +16 coins and +6 XP, once. Corn fixture: −18 coins, matures at 1,800,000,000, harvest gives +110/+32. No reward at planting or maturity. |
| V03 | `unit/test_command_envelope`, `unit/test_maturity_harvest` | Retrying the same command gives `DUPLICATE_COMMAND`. Harvesting a terminated cycle gives `NO_CYCLE`/`CYCLE_MISMATCH`. Every rejection leaves gameplay and metadata digests equal to the post-due-work baseline, including `next_entity_id` and `state_sequence`. |
| V04 | `unit/test_scheduler_ordering`, `simulation/test_tied_batches` | Vary each tuple field independently and check the pop order. Due events come before a same-time command. Rebuilt queue pops the same keys. A no-progress batch terminates. DVS-007 order with placeholder research events. |
| V05 | `unit/test_integer_math`, `unit/test_content_registry`, `unit/test_level_curve` | Oracle vectors. Malformed manifest fails before any state is created. Below/at/above every threshold 1–30 (e.g. 239→1, 240→2, 5,199→6, 5,200→7, 519,999→29, 520,000→30). |
| V06 | `unit/test_simulation_clock`, `simulation/test_speed_equivalence` | 480 s at 1× and 8 s at 60× give equal gameplay digests and the same reward. Fake UTC rollback or a DST-style jump gives zero change in active simulation delta. |
| V07 | `unit/test_deep_clone` | For every nested container in every record (including extension stubs), mutating the clone leaves the source digest unchanged and no references are shared. |
| V08 | `simulation/test_32_plot_independence` | All 32 plots unlocked by an explicit fixture, mixed crops and plant times. 1-step, random-partition (fixed seed list) and per-event advances give identical digests and event logs. Queue size ≤ Growing count. |
| V09 | `architecture/test_core_dependencies`, `architecture/test_headless_boot` | Scan `core/**/*.gd` for `extends`/`preload`/`load`/class references outside `core/`, and for Node, scene, Audio*, Display*, OS, Time, FileAccess or SQL tokens; none may appear. Headless boot creates no presentation nodes. |
| V10 | `unit/test_command_envelope`, `unit/test_integer_math`, `unit/test_simulation_clock` | Malformed or future/past accepted time is rejected. Retired epoch gives `STALE_COMMAND`. After cache eviction, a re-submitted old counter is still `DUPLICATE_COMMAND`. A true overflow (wallet at `INT64_MAX − 5` + 16) gives `NUMERIC_LIMIT` with no partial change. A representable quotient succeeds. Suspended interval is credited once and the anchor follows real time. |
| V11 | `unit/test_new_game_state`, `unit/test_level_curve` | Coordinates: `row = 1 + (id−1)/8`, `col = 1 + (id−1)%8` for all 32 plots. A fixture with a hole (1–24 + 26) fails validation. 30 thresholds equal the FRS. Option B continuation is defined from level 31. |
| V12 | `unit/test_deep_clone`, `unit/test_simulation_clock`, S5 report | Settings, contract and accounting stubs clone independently. `GameSettings.to_primitive()` has no debug-speed key. The provider exposes an active/suspended partition. The M03-T18 probe recipe exists in the handoff, labeled as not executed. |
| V13 | `unit/test_level_curve`, `unit/test_progression` | L31 = 577,500; L32 = 640,750; L33 = 710,325; L34 = 786,858; L35 = 871,045; L36 = 963,651; L37 = 1,065,518; L38 = 1,177,572; L39 = 1,300,832; L40 = 1,436,418. The closed-form adversary (`round(57500·1.1^k)`) gives L35 = 871,044 and L40 = 1,436,402; these must **not** match. L349 = 9,203,731,170,706,289,434; `level_for_xp(INT64_MAX)` = 349 with 348 points. A multi-level grant gives one point per level, and surplus points persist. Toolchain manifest labels say Selected vs Verified. |
| V14 | `simulation/test_commit_outcomes`, `simulation/test_replay_equivalence`, `unit/test_identity`, `simulation/test_manifest_binding` | **AV-001-01:** restore an older snapshot under a new epoch; new IDs differ, old entities keep their IDs, old command payloads are `STALE_COMMAND`. **AV-001-03:** the same namespace and inputs give equal IDs and order across 1×, 60×, offline and per-event runs. **AV-001-04:** codec round-trips at counter `INT64_MAX − 1`; colliding or malformed refs are rejected. **AV-002-01:** fake sink commits rev 41 but returns UNKNOWN; everything stays blocked until a read-back of 41 adopts it, with no second debit. **AV-002-02:** read-back of the parent gives NOT_COMMITTED; an unreadable read-back stays blocked. **AV-002-05:** after reconciliation, the gameplay digest and replay marks equal an uninterrupted run; metadata is checked separately. Extra time-only commits do not change crop/event IDs. **AV-003-01:** a level-7/5,200-XP profile on `content_m01_v1` with allocated Auto Replant stays valid while the test manifest `test_l7_6000` coexists. **AV-003-02:** a lowered-threshold manifest never applies implicitly; a missing manifest is a recoverable error. **AV-003-03:** `level − 1 == unspent + allocated` across active, offline, replay and restart. **AV-004-01:** a click across a due harvest; due work commits first, then the command is stamped at the current time. **AV-004-02:** changed cycle, cost or manifest gives `STALE_TERMS` with no charge. **AV-004-05:** a duplicate pending intent returns the cached result; replay of the accepted log reproduces it exactly. |

**Source-test coverage claimed at M01 close:** T-001 and T-003, T-020 (in-memory part), and the core parts of T-002 and T-021. The music/render half of T-002 stays M04.

## 6. Out of scope (do not build in M01)

- Paid research flow and boosts.
- Skill allocation behavior. Only the I3 data record exists.
- Upgrades and plot purchases. A `PurchasePlot` command is M02. Its prefix rule is validated as a state invariant only.
- Automation, fertilizer and optimizer.
- Contracts behavior.
- Statistics aggregation.
- SQLite or any file persistence.
- A real time provider.
- UI, scenes and audio.
- Export presets.

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Silent int wrap in a code path that skips `IntegerMath` | Code review rule: no raw `+`/`*` on coins, XP, μs or counters in core. `test_integer_math` plus the overflow scenario in V10. Consider a grep check in `test_core_dependencies`. |
| GDScript `/` and `%` truncate toward zero | Use `floor_div`/`ceil_div` only; negative vectors are tested. |
| Float leakage (`int()` of float, `pow`, `JSON`) | The codec rejects floats. Grep the core for `float`, `pow(`, `JSON` in the architecture test. |
| Dictionary iteration order hiding nondeterminism | Iterate only over sorted keys or fixed arrays in core. Determinism is checked by random-partition replay (V08). |
| Clone cost per command (B4) | 32 plots plus stubs is small. Measure in S4; optimize only if it is over 1 ms. |
| GUT/typed-warning interaction (B8) | Verified in S0. If GUT breaks, downgrade the setting to Warning and enforce typing by review. |
| Scope creep from AV cases | I1 bounds M01. Anything else is listed in the handoff with its owner milestone. |

## 8. Definition of done (M01)

- S0–S5 are committed on `m01-implementation`, and `tools/run_tests.ps1` is green from a clean import.
- `artifacts/M01/` contains:
  - the T01 evidence;
  - evidence for each slice;
  - `M01_Handoff.md` with the API inventory, fixture manifest, adopted decisions (P/I/B), test log references, known limitations, and open items with their M02/M03 owners;
  - the M03-T18 probe recipe.
- A proposed change list for the existing docs is ready for owner approval. It is not applied:
  - DEC-001 T01 closure;
  - D-01/02/03/05/06 decision records;
  - optional sync of I1–I3 into the M01 plan.

## 9. Change log of this plan

| Date | Change |
|---|---|
| 2026-10-29 | Initial version from approved P1–P13 and I1–I3. Oracle vectors recomputed independently in Python; they match FRS §5.1.1 and TRS §5. |
| 2026-10-30 | S0: added a runner script-error guard (exit 5), because GUT silently skips unparsable test scripts. `--import` does not parse scripts, so S5's dependency audit must load every core script. See `artifacts/M01/evidence/S0/S0_Evidence.md`. |
| 2026-10-30 | S1: added `core/economy/math_result.gd` (checked-result type) and `core/content/research_definition.gd` (FRS §8 data). The oracle generator lives at `tools/oracles/generate_oracle_vectors.py` and writes `tests/fixtures/oracle_vectors.gd`. A mutation check showed the slow `mul_div` path was under-tested; added an exhaustive small-remainder test and 120 seeded overflow vectors. |
| 2026-10-30 | S2: `SkillState` is represented as `PlayerState.skill_ranks` (TRS §9.4 `player.skill_ranks`). Added `primitive_reader.gd` (strict decoding plus `plain()` untyped export), `command_id.gd`, `scheduled_event.gd` (queued events; `SimulationEvent` = emitted outcomes) and per-command files. Each `CropCycle` stores `maturity_insertion_seq` so a rebuild reproduces exact keys (B2). `EntityId.allocation_namespace` (`namespace` is a reserved word). |
| 2026-10-30 | S3: manual PlantCrop does not change `selected_crop_id` (selection is not a purchase, DVS-012). `FarmSystem.harvest_ready_cycle` is the shared harvest transition for M02 automation. Added `planting_quote.gd` and `xp_grant.gd` (prepare-then-apply for atomic batches), `TimeAnchor.credit()` and `observe_utc()`. |
