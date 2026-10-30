# M01 — Headless simulation foundation

> **Audit corrections A1 — 2026-10-28:** Apply the approved contracts in [TRS §§15.1/20](../architecture/IdleFarmer_Technical_v1.5.md), [FRS audit requirements](../requirements/IdleFarmer_Functional_v1.0.md) and the [Audit Decision Register](../decisions/Audit_Decision_Register.md). The task crosswalk below is normative for the listed existing tasks; it does not add gameplay or implement later-stage features. [Correction changelog](../audit/round_01/Audit_Correction_Changelog.md) preserves before/after references. Existing provisional values and Open/Deferred evidence remain unchanged.

> **M01 implementation status — 2026-10-30:** All tasks M01-T01–T16 are implemented on branch `m01-implementation`. M01-V01–V14 pass within the scope stated in the [M01 handoff](../../artifacts/M01/M01_Handoff.md); the final clean-import run had 210 tests and 6,354 assertions. Evidence per slice is under `artifacts/M01/evidence/`. Task text below is unchanged. Working decisions are in [M01_Readiness_Findings.md](M01_Readiness_Findings.md) (P1–P13, I1–I3) and [M01_Build_Plan.md](M01_Build_Plan.md). Graphics, durable persistence, a real platform clock and browser behavior are not claimed.

Priority P0 · Planning only · Depends on toolchain/content decisions · Next: M02

**Approved foundation update — 2026-10-26:** Apply [Group 1 in the Decision Register](../decisions/Decision_Register.md) and TRS clarification G1: DEC-005/006/013/016/026 are binding; DEC-001's standard Godot/Compatibility/GUT/SQLite-evaluation direction is approved, with actual artifact/fingerprint verification still open after C1 selects the names. Other decisions and gameplay values retain their existing proposed/provisional status. This document defines future work; approval is not implementation/test evidence.

**Approved G2 update — 2026-10-27:** Apply [Decision Register Group 2](../decisions/Decision_Register.md) and TRS clarification G2: DEC-003 zero/Empty start, DEC-004 one-point/minimum-rank skill rules, and amended DEC-020 fixed eight-column 8×3 start with strict fourth-row 25→32 unlocking. DEC-002's through-30 table is approved provisional development data; G2 did not select continuation; C1 now approves increasing option B below. G1 contracts remain binding; no game implementation or test execution is claimed.

**Approved G3 update — 2026-10-27:** [Decision Register Group 3](../decisions/Decision_Register.md) / TRS G3 now binds research boost, farm-wide budgets/cap, Smart guarantees/priority, lifecycle/batches and staged advanced work (DEC-007/009/010/011/012/025). Numeric defaults remain provisional for balance; G4 policy is now approved as stated below; actual evidence and named partial subparts remain pending. Earlier notes describing these G3 choices as unresolved are superseded by the synchronized source contracts; no game implementation is claimed.

[Master roadmap and decision register](00_IdleFarmer_Master_Roadmap.md) · [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md) · [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md)

## Objectives and scope

Build the scene-independent deterministic kernel used by every subsequent mode: authoritative state, validated definitions, typed commands/results/events, integer economics, clocks, scheduling, manual planting/maturity/harvesting and XP levels. Represent all 32 plots, initially unlock 1–24, and keep individual crop cycles independent. No graphical farm, production persistence, paid research, skills, automation or contract gameplay is required at this milestone. Define extension records and transaction boundaries so those systems do not require a replacement kernel.

Primary references: FRS §§1,3–5.1,6.3,9.1,12–14; FR-FARM-01–05; TRS §§1–5,7,13,15–18; ARCH-001–007. Provisional catalog numbers are fixtures, not final balance approval.

## Prerequisites and dependencies

- Both source documents and master roadmap read; preserve their separation of gameplay and technical authority.
- Apply approved DEC-005 rounding, DEC-006 phase order, DEC-013 interval-accounting contract, DEC-016 replay identities and DEC-026 numeric-limit recovery. DEC-001's approved engine4.7.2/templates/GUT 9.7.1 names still require exact artifact/commit/fingerprint verification before adoption; DEC-003 initial state and amended DEC-020 geometry/order are approved; DEC-002's through-30 development table is approved provisionally, and C1 now approves increasing option B beyond level 30. Do not reselect the approved framework/renderer or silently adopt other pending decisions.
- No engine/addon is assumed installed. Named C1 versions are selected; verify their exact artifacts and official pinned documentation during future dependency setup. No downloads or application code are part of this plan delivery.
- Decide root `idle_farmer/`, naming and test command convention before generating project files. Do not make native SQLite a dependency of core compilation.

## Required classes and suggested file structure

All runtime records/services below extend `RefCounted` unless stated. Exported content definitions extend `Resource`. Use typed fields, parameters, returns and collections supported by the pinned Godot version; validate heterogeneous serialization dictionaries at the boundary.

| Suggested path under `idle_farmer/` | Classes / responsibility |
|---|---|
| `core/state/game_state.gd`, `player_state.gd`, `plot_state.gd`, `crop_cycle.gd` | `GameState`, `PlayerState`, `PlotState`, `CropCycle`; validation, explicit deep clone |
| `core/state/time_anchor.gd`, `game_settings.gd` | `TimeAnchor`, `GameSettings`; versioned plain fields, no OS calls |
| `core/state/extension_state.gd` | Typed minimal upgrade/research/contract/automation/statistics records, later expanded with migrations |
| `core/content/crop_definition.gd`, `level_curve_definition.gd`, `content_registry.gd` | `CropDefinition`, `LevelCurveDefinition` resources; `ContentRegistry` validates and exposes immutable definitions |
| `core/simulation/game_command.gd`, `command_result.gd`, `simulation_event.gd` | `GameCommand`, typed Plant/Harvest commands, `CommandResult`, `SimulationEvent`, failure enums |
| `core/simulation/event_scheduler.gd`, `simulation_engine.gd`, `state_change_batch.gd` | `EventScheduler`, `SimulationEngine`, `StateChangeBatch`; sole mutation orchestration |
| `core/economy/integer_math.gd`, `economy_system.gd`, `economic_transaction.gd` | `IntegerMath`, `EconomySystem`, immutable `EconomicTransaction` (as implemented, 2026-10-30: `IntegerMath`/`MathResult` live in the independent `core/math/`) |
| `core/math/integer_math.gd`, `math_result.gd` *(added 2026-10-30)* | Checked int64 arithmetic with no dependency on other core modules |
| `core/application/game_controller.gd`, `raw_intent.gd`, `commit_sink.gd` *(added 2026-10-30, ruling I2)* | In-memory `GameController`: due work before stamping, controller-issued command counters, intent de-duplication, clone-then-commit and the commit sink contract with COMMITTED/NOT_COMMITTED/UNKNOWN |
| `core/time/time_provider.gd`, `simulation_clock.gd` | `TimeProvider` abstraction; `SimulationClock`; no scene dependencies |
| `core/farming/farm_system.gd`, `core/progression/progression_system.gd` | Manual `FarmSystem`, cumulative-XP `ProgressionSystem` |
| `data/crops/`, `data/levels/`, `tests/fixtures/` | Versioned source catalog, full curve and intentionally isolated fixtures |
| `tests/support/`, `tests/unit/`, `tests/simulation/`, `tools/` | `FakeTimeProvider`, canonical serializer/digest, headless runner and scenario reports |

Do not serialize a live Resource/Node. Pending events must be explicitly serializable or reconstructible with the same IDs, phases and insertion sequences. Public methods follow TRS §5; exact typed signatures are implementation decisions.

## Detailed implementation tasks

Execute in listed dependency order. A task is complete only with its stated evidence; fixtures may pre-unlock content explicitly but production paths may not bypass gates.

### M01-T01 — Freeze reproducible project/toolchain contract

Dependencies: none. Use C1-selected standard Godot 4.7.2-stable/editor+matching standard templates, GUT v9.7.1, Compatibility/Windows x86_64 and project-owned headless scenarios. Verify and record actual artifact identities/checksums/licenses; typed-GDScript conventions follow the selected release. Document supported CLI invocation, failure exit status, import step, renderer baseline and native-addon exclusion boundary. Record candidate reference Windows hardware. Deliver future project skeleton plus toolchain record; validate an empty test suite in headless mode without UI/audio scenes. References: TRS §§1.1,13,17; ARCH-002,006,007; D-01/23.

**Approved G1 constraints:** The approved direction is standard non-.NET stable Godot 4.x, exactly matching export templates, Compatibility renderer and GUT. C1 selects the version names/target; verify the actual artifact/commit identities, checksums and licenses before adoption. SQLite candidate evaluation is M03 work; no dependency is installed by this plan update.

**Approved G5 constraints:** Apply approved DEC-023/G5 representative Windows baseline/vendor qualification method. Record actual candidate CPU/GPU/RAM/storage/OS/driver only if available, never null placeholders as a chosen machine; named baseline selection stays Open before M04. Reference TRS §14.1.

**Approved C1 constraints:** Use approved standard Godot 4.7.2-stable/editor+standard matching templates, GUT v9.7.1, Compatibility and Windows x86_64. Record actual artifact URLs/full commit IDs/SHA-256/publisher checks/licenses before project adoption; do not reselect versions or auto-upgrade. Native godot-sqlite v4.9/reportedSQLite 3.51.0 is the M03 evaluation candidate, not a passing integration.

**R2-C1 dependency-adoption gate — Not Yet Verified (2026-10-29):** Complete M01-T01's artifact evidence before adopting affected dependencies for subsequent tasks; T02 and other T01-dependent tasks remain gated. Verification-only candidate inspection/probes precede project adoption. Require (1) the official standard Godot 4.7.2-stable Windows x86_64 editor archive and its supplied executable(s), (2) matching standard 4.7.2-stable export-template package with the intended Windows x86_64 templates, (3) the GUT v9.7.1 tagged source/archive and resolved full commit, and (4) each artifact's provenance, SHA-256, publisher-manifest comparison where supplied, and complete required license/notice inventory. Record archive and extracted-binary identities, editor reported version, exact headless/import/runner commands and logs. Verify a clean headless empty-suite success and a deliberate failing assertion returning a nonzero process exit, without presentation/native-SQL imports. A written version selection, available URL, file hash alone or this documentation correction does not pass compatibility/runner checks. No required local candidate artifacts or executable evidence were located in the bounded R2-C1 inventory; nothing was installed or run. M01 may begin with T01 acquisition/verification, not bypass it. SQLite v4.9 native/WAL/FULL/backup/export qualification remains M03-T01 and is not a prerequisite for the M01 core. See [R2 correction record — artifact gate](../audit/round_02/R2_Correction_Changelog.md#m01-t01-artifact-verification-gate).

### M01-T02 — Define content IDs and validation rules

**Applied A1 task constraints:** AUD-DEC-003 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01. Establish content/schema version strings, stable string IDs, duration units, basic/advanced classification and immutable content lookup. Validate uniqueness, positive durations, nonnegative values, exactly five art-stage references (may be labeled placeholders before M04), missing references and level gates. Import all 15 FRS crops as provisional definitions without enabling them prematurely. Deliver registry/definitions and invalid-content fixtures. Validate source table transcription and fail-fast diagnostics. References: FRS §4; TRS §§3.4,4.4; ARCH-005.

### M01-T03 — Supply full initial-state and XP fixtures

**Applied A1 task constraints:** AUD-DEC-003 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02. Apply approved DEC-003/G2: zero coins/XP/skill points, level 1, no upgrades/post-start research/active contracts, Wheat sole start unlock, no preplanted or automatically selected paid crop. All 32 stable IDs use a fixed eight-column map: 1–24 Empty/unlocked in rows 1–3 (8×3), 25–32 Locked in row 4. Implement the approved complete level 1–30 table from FRS §5.1, including integer-linear interpolated entries; all values remain provisional for balance. Validate anchors, every intermediate threshold and strict monotonicity. C1 approves the increasing option B continuation; no hidden cap or constant-tail substitution. Deliver source-linked tables and new-game/layout fixtures. References: FRS §3 / FR-FARM-01/02/08, §§5.1,16; TRS §§3.1–3.3; DEC-002/003/020.

**Approved G2 constraints:** G2 replaces the previous starting geometry/purchase proposal. Logical rows are IDs 1–8, 9–16, 17–24, 25–32; all columns are fixed from the start. No unlock gaps: valid unlocked IDs form exactly 1..N, 24≤N≤32. No arbitrary auto-planting or starting grant is allowed.

**Approved C1 constraints:** Preserve all through level 30 thresholds and add FRS §5.1.1 option B: first post30 step57,500, each later step ceil(previous×110/100), cumulative addition after rounding each step. No constant57,500 tail/cap. Use exact integer definition/versioned fixtures; level 31=577500,32=640750,35=871045,40=1436418.

### M01-T04 — Implement checked integer arithmetic primitives

Dependencies: T01. Define signed 64-bit limits, overflow-safe multiply/divide and addition, explicit floor/ceil helpers and basis-point operations. Apply approved DEC-005 ceiling growth durations to whole microseconds and minimum 1 μs; coin rewards floor and fertilizer prices ceil. Do not route authoritative multiplication through floating-point conversion. Deliver arithmetic module and table/boundary tests, including near-limit overflow rejection and 60% growth cap. References: FRS §§5.2,6.2–6.3; TRS §4.4; D-05/26.

**Approved G1 constraints:** Use checked 64-bit/basis-point arithmetic from TRS §4.4. Include representable quotients whose naive intermediate multiplication would overflow; only a genuinely unrepresentable result fails. A numeric-limit failure applies no partial state or anchor change (DEC-026). The 60% cap remains provisional content.

**Approved C1 constraints:** Use safe ceil-ratio recurrence p+ceil(p/10), not a naive overflowing p×110. At a next threshold beyond int64, valid current XP lookup still succeeds; only genuinely unrepresentable state updates take DEC-026 recovery. Use independent high-precision documentation/test-oracle vectors.

### M01-T05 — Implement authoritative records and deep cloning

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-003 B, AUD-DEC-008 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02–T04. Implement root/player/plot/cycle/time/settings and empty extension records. Validate all TRS §3 invariants, counters, references and 0/1 cycle per plot; reject locked active crops. Add canonical primitive serialization used for state digest, without selecting a database schema yet. Verify mutating each nested field/container on a clone never changes the source. Deliver records, invariants and clone fixtures. References: TRS §§3,9.4; ARCH-001/002; FRS §13.

**Approved G1 constraints:** Add typed CommandReplayState and bounded AccountedInterval/reconciliation records to the root/clone/primitive-codec inventory under TRS §§3.1/3.5/9.4. Apply G4 profile-owned settings and completed-minute simulation windows under DEC-021/017.

**Approved G2 constraints:** Validate exactly 32 unique plot records and the 1..N unlock prefix, no growing cycle on the Locked suffix, zero/Empty initial defaults and valid skill-point/rank references. Scattered Empty/Growing/Ready unlocked plots are valid; the prefix rule is not crop occupancy. Deep clones preserve ID/coordinate ownership.

**Approved G3 constraints:** Reserve typed/deep-copyable G3 records: FarmBudgetConfiguration (R=0, percentage=25, seed toggle Off), loop/purchase-plan authorization, inactive rules, rotation cursor and research paid/timing/boost-used fields. Defaults are inert in the level-1 Empty farm; no paid first cycle or advanced capability starts automatically. GameSettings ownership/metric windows are approved under G4/TRS §§9.4,10.

**Approved G4 constraints:** Include profile-owned versioned GameSettings in the typed root/clone inventory, excluding persisted debug speed. Reserve explicit contract offer/acceptance/claim eligibility and simulation-bucket/segment/session/state-time fields; ownership/windows and C2 exact contract content are approved; M01 reserves records only, while real contract behavior/evidence remains M05/M06. References: DEC-017/018/019/021; TRS §§3,9.4,10.

**Approved C2 constraints:** Reserve typed ContractDefinition/instance snapshot fields for the approved C2 IDs/guards/goals/frozen rewards and acceptance ordering; this is a data/interface foundation, not M01 contract gameplay. Preserve lossless clone/serialization boundaries.

**Applied ruling I3 — 2026-10-30:** Skill allocations are represented as data only in `PlayerState.skill_ranks` (TRS §9.4 `player.skill_ranks`), validated against the bound manifest's skill definitions (rank range, level gate, rank ≥ 1 prerequisite). This exists solely for AV-003 point-conservation and manifest-binding tests. Allocation, reset and skill effects remain M02.

### M01-T06 — Define typed commands, events and mutation batches

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T05. Specify IDs, failure codes, revision changes, immutable transactions and result shape. Implement approved DEC-006 controller acceptance order: research completion before the due farming batch, then serial manual command batches. Reject malformed/stale/future time envelopes without gameplay mutation. Use the TRS §4.2 phase table, including future research/automation phases. Add an in-memory idempotency contract and explicit post-application notification boundary, later made durable in M03. Deliver contract tests for duplicate/invalid commands and full-state equality on rejection. References: TRS §§4.1–4.2,5; ARCH-003.

**Approved G1 constraints:** Model command identity as profile ID + writer UUID epoch + increasing in-epoch counter. Inject deterministic tokens in tests; controller-issued IDs are not rejected gameplay mutations. Mirror the committed-success high-water, retired-epoch rejection and bounded cached-response semantics in memory; M03 later makes them durable. Rejection must leave authoritative gameplay and ID allocation unchanged.

**Approved G3 constraints:** Include per-plot batch outcomes in the envelope/result extension contract. M02 later implements eligible-subset batches atomically; a rejected whole command changes nothing after independently due work; NOT_COMMITTED is unpublished and UNKNOWN stops for full reconciliation under TRS §20.2 and failed manual members are not partly charged.

### M01-T07 — Implement deterministic scheduler

**Applied A1 task constraints:** AUD-DEC-001 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T06. Implement ordered event insertion/pop/cancellation using the full source tuple. Preserve insertion sequence, stable entity IDs and stale-cycle rejection. Add snapshot/restore or deterministic reconstruction contract. Bound queue growth to pending logical work rather than retaining completed events. Deliver scheduler with tied timestamp/phase/priority/ID tests, canceled/stale event tests and identical ordering after restore. References: TRS §§4.2–4.3,8,14.

**Approved G1 constraints:** Assert research→maturity/auto-harvest→credits/XP/contracts/accounting→replant/retry collection→seeds→optional fertilizer→new cycles. Commands do not interleave phases or retrospectively pool their receipts with an earlier automatic batch. Use placeholder events for systems not implemented until M02.

### M01-T08 — Implement injectable clock foundation

Dependencies: T04,T06. Define TimeProvider UTC/monotonic/resume observations and fake source; implement SimulationClock independent of OS calls and `Engine.time_scale`. Support integer 1–60 multiplier, fractional carry if needed, reset to 1× and offline advance always 1×. Expose active versus suspended inputs separately; native sleep behavior is M03 work. Validate partitioned elapsed intervals equal one combined interval and active UTC changes have no effect. References: FRS §§9.1,12; TRS §§5,7; T-013,016; D-13/14.

**Approved G1 constraints:** Define active, suspended and offline accounted intervals and real-versus-simulated deltas in the clock contract; anchor advancement is real elapsed only. Preserve a future high-water anchor on rollback and do not re-credit sleep-inclusive observations. Native suspend source remains an empirical DEC-014/M03 decision.

**Approved G4 constraints:** Use approved DEC-014 measurement-first interface: sufficient duration and active/suspended partition observations, injectable fakes, no long-frame or focus-only sleep heuristic. Exact Godot/native provider remains Open until M03 measurements.

### M01-T09 — Implement base planting calculations

Dependencies: T02–T05. Calculate snapshotted cost, base reward, XP and maturity from definitions, initially with identity modifiers. Record transaction ID/cycle ID and content version. Establish fertilizer/modifier extension inputs without implementing skill or Smart policies. Validate Wheat 480,000,000 μs / free / 16 coins / 6 XP and Corn 1,800,000,000 μs / 18 / 110 / 32. No reward on planting or maturity. References: FRS §§4,6.3; TRS §§3.4,4.4; T-001,003.

**Approved G1 constraints:** Base and modified calculations both use approved DEC-005 floor reward/ceil cost/ceil microsecond duration rules, with DEC-026 safe intermediate arithmetic. No implementation task may select another rounding default.

### M01-T10 — Implement manual planting transition

Dependencies: T06–T09. Validate unlocked/empty/eligible crop and seed affordability; all-or-nothing debit plus cycle creation plus maturity scheduling. Until research exists, only Wheat is naturally available; non-start crop fixtures explicitly inject completed unlock state. Preserve selected crop separately from current cycle. Reject wrong IDs, occupied/locked plots, missing gates and insufficient funds without any state/ID-counter drift. Deliver PlantCrop command integration tests. References: FR-FARM-03–05; FRS §4.1; TRS §4.3.

### M01-T11 — Implement maturity and manual harvest transition

Dependencies: T10. Derive stages from progress (proposed 0/25/50/75/100% boundaries), mark ready exactly at maturity, keep ready indefinitely and credit snapshotted reward once only on harvest. Terminate cycle, retain next crop configuration, emit economic/accounting records and one ready intent. Ensure stale maturity events and duplicate harvest commands cannot repay. Deliver ready/no-spoilage/harvest tests including exact timestamp boundaries. References: FRS §§2.1,4.1; TRS §§4.2–4.3; T-001,003,020.

**Approved G1 constraints:** A harvest requires the current unconsumed cycle; stale events/old commands cannot recreate a terminated cycle or repay it. Add current-epoch duplicate, retired-epoch and response-cache eviction assertions to the in-memory contract.

### M01-T12 — Implement cumulative XP and level awards

**Applied A1 task constraints:** AUD-DEC-003 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03,T11. Map XP to complete configured thresholds; grant one point per crossed level, never spend XP, handle multiple levels atomically with reward transaction. No automatic point allocation. Keep purchased/growing cycle snapshots independent of level change. Deliver boundary tests immediately below/at/above each configured threshold, several levels in one reward and overflow failure. Beyond configured curve must be explicit validation/decision handling, not an undocumented terminal cap. References: FRS §5.1; TRS §§3.2,5; T-010 precursor.

**Approved G2 constraints:** Use all 30 approved development thresholds exactly, including XP 29,334 at level 13 and 462,500 at 29, with original anchors unchanged. Test below/at/above every threshold and multi-level unspent-point grants. Use approved C1 increasing option B, not constant+57,500; preserve XP and points, and never treat a valid lookup beyond level 30 as DEC-026 overflow.

**Approved C1 constraints:** Lookup highest reached option B threshold and grant all crossed levels once, one unallocated point each; surplus points persist after all existing ranks/nodes are full. Test below/at/above30–35 and finite representation boundary without discarding XP or adding content.

### M01-T13 — Assemble SimulationEngine command/advance API

**Applied A1 task constraints:** AUD-DEC-002 B, AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T07–T12. Implement initialize, submit, advance_to, snapshot, next-event query and validate per TRS §5. Advance between events rather than frames. Validate state and stage outcomes before application; no hidden service mutations bypass engine. Add narrow committed-harvest/accounting hooks for later systems with no-op implementations initially. Deliver core-only headless scenario and render-independent advancement. References: TRS §§2,5,8; ARCH-001,003,006,007.

**Approved G1 constraints:** Expose only accepted logical outcomes at the kernel boundary. M01 uses an in-memory sink, not a claim of production durability. M03 must commit state, replay marks, interval metadata and anchor before presentation.

### M01-T14 — Add replay and mode-equivalence scenarios

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B, AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M01-V14 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T13. Record accepted command schedules and fixture versions. Compare whole-step, random deterministic partitions, 1× and 60× clocks at the same target simulated time; include all 32 plots with mixed explicit test unlocks and different maturity times. Replay tied manual inputs and scheduler restoration. Canonicalize only clock-observation/presentation metadata, never economics or ordering IDs. Deliver repeatable state-digest report. References: TRS §§1,15; T-002 core portion, T-021.

**Approved G1 constraints:** Record accepted command times/order and inject fixed writer tokens so mode comparisons retain meaningful identity/order checks. Separately verify duplicate/stale handling after cache pruning and epoch changes; never normalize away economics, crop identities or missing replay guards.

**Approved G2 constraints:** Initial fixtures use eight-column row-major IDs; any fully unlocked or partially expanded fixture must have a contiguous prefix. State-digest replay may vary crop occupancy but cannot introduce out-of-order unlocked plots.

**Approved C1 constraints:** Compare active1×/60×/offline partitions across30/31/32/35 with identical earned XP and point grants; no bypass table or constant-tail substitution. Clock/replay metadata normalization remains explicit.

### M01-T15 — Validate architecture and portability boundaries

Dependencies: T13. Add a dependency audit that core imports no scene/audio/SQL/native Windows code, and a headless boot that does not create presentation nodes. Document browser-safe content and adapter interface assumptions; prepare the required end-M03 T-030 probe recipe, not a production web adapter. Deliver boundary report and module dependency diagram/table. References: ARCH-001–007; TRS §§1.1,9.5,13; D-22.

**Approved G1 constraints:** GUT/test harness SceneTree ownership is allowed outside core services; audit that the gameplay core imports no scenes/audio/SQL/native extension. Use the approved Compatibility direction with DEC-022/G4 scheduling the minimal probe for end M03.

**Approved G4 constraints:** Prepare the required end-M03 T-030 probe handoff, including shared-core boot/render, test storage success/denial and resume reconciliation without Windows SQLite. M03-T18 owns execution; full production web release remains future. References: DEC-022; TRS §9.5.

**Approved C1 constraints:** Audit approved4.7.2/x86_64 toolchain/headless boundary; GUT belongs to harness, godot-sqlite v4.9 imports only to repository tests/adapter. Browser probe continues without native dependency.

### M01-T16 — Close foundation gate and handoff

Dependencies: T14,T15. Run validation below; summarize adopted engineering decisions and provisional content curve, list remaining research/skill/storage decisions with M02/M03 owners. Deliver API inventory, fixture manifest, actual test logs and known limitations. Review all new fields for clone/serialization coverage. No graphical or persistence claims allowed. References: TRS §§16 M01,18; FRS §15 relevant entries.

**Approved G1 constraints:** Report the approved G1 contracts as requirements implemented/tested only when real evidence exists. Keep actual artifact/fingerprint verification and DEC-014 empirical choices Open and optional added content Deferred. Apply G2's approved initial state, through-30 provisional table, skill prerequisites and amended plot geometry/order.

**Approved G2 constraints:** Record G2's confirmed scope and still-provisional balance values; only actual artifact verification and genuinely unconfirmed policies/evidence remain pending; C1 names/target/curve are approved.

**Approved G3 constraints:** Research/budget/optimizer/lifecycle/staging choices DEC-007/009/010/011/012/025 are now approved under G3. Keep actual artifact/fingerprint verification, exact provider/artifact verification subparts and empirical evidence pending; G4 policy is approved below.

**Approved G4 constraints:** Hand off G4 policy as approved; list only exact provider/API evidence as pending within G4; C2 now supplies the approved catalog. Include M03-T18 probe dependency and profile-settings/statistics field checklist.

**Approved G5 constraints:** DEC-008 optional families are explicitly Deferred; DEC-024 evidence method and DEC-023 qualification procedure are approved. Carry only exact hardware/art, actual artifact/provider/hardware/art verification and future empirical work as pending; no approved protocol is actual evidence.

**Approved C1 constraints:** Selected version/target and increasing continuation are approved. Pending DEC-001 work is actual artifact/commit/checksum/license inventory/adoption evidence; exact provider/hardware/art verification remains separately unresolved; C2 content is approved. Do not ask to reapprove the selected version names or option B.

**Approved C2 constraints:** DEC-019 exact catalog and predicates are approved under C2. Hand off only genuinely open artifact/provider/hardware/art verification; no repeated content-approval gate.

## Automated tests and validation procedures

Run the pinned runner headlessly from a clean import; suites must fail the process on assertion errors. Save exact engine/content version, commands, state digest and test output. Runner invocation is fixed by M01-T01; no unverified third-party framework is mandated here.

| Validation ID | Procedure / exact oracle |
|---|---|
| M01-V01 | New game: IDs 1–32 unique; 24 unlocked/8 locked; level 1, XP 0, approved coins 0, Wheat eligible only. Locked plots contain no cycle. |
| M01-V02 | T-001/T-003: plant Wheat; at 479,999,999 μs growing, 480,000,000 ready; harvest pays 16/6 once. Corn fixture debits 18, grows 30 min, harvests 110/32. |
| M01-V03 | T-020: retry same command and harvest terminated cycle using another command; no double reward. Rejected command leaves canonical state including counters unchanged. |
| M01-V04 | All scheduler tie fields vary independently; due events precede same-time commands; reconstructed queue emits identical ordered IDs. No infinite zero-time loop. |
| M01-V05 | Integer price/reward/rounding/cap vectors plus maximum-value arithmetic; malformed content fails before new-game mutation. All XP threshold crossings exact. |
| M01-V06 | T-002 core/T-021: 480 game seconds at 1× equals 8 real seconds at 60×; same gameplay state and reward. Fake UTC rollback/DST leaves active simulated delta unchanged. |
| M01-V07 | Deep clone: mutate nested arrays/maps/cycles/settings in clone, compare original digest and individual references; no shared mutable children. |
| M01-V08 | 32 independent crop fixtures, mixed planting times, arbitrary advance partitions and repeated replay produce identical state/events; pending queue remains bounded. |
| M01-V09 | No graphics/audio/native-storage initialization in headless run; dependency audit passes. Music/render assertions for T-002 remain explicitly deferred to M04. |
| M01-V10 | Approved G1 edge cases: reject malformed command time and retired writer epochs; evict response cache without permitting repayment; fail true numeric overflow without partial mutation while accepting safe representable quotients. Fake active/suspended intervals keep anchor real-time based and do not duplicate sleep. |
| M01-V11 | G2 baseline: 0 coins/XP/points, level 1, 24 Empty plots in 8×3, row-4 IDs 25–32 Locked. Map all 32 IDs to fixed eight-column coordinates and reject a hole-bearing unlock fixture. All 30 XP thresholds match FRS; source anchors remain unchanged; C1 option B continuation is defined explicitly, without changing these1–30 thresholds. |
| M01-V12 | G4 typed settings/contracts/accounting fields deep-clone independently; debug speed not persisted. TimeProvider exposes active/suspended observations; headless/native-free audit produces required M03-T18 probe recipe without claiming executed browser evidence. |
| M01-V13 | C1: exact option B increment/cumulative vectors31–40, per-step ceil versus rounded closed-form adversary, multi-level/surplus points and independent high-precision oracle. Largest representable threshold/valid max-XP lookup succeeds even when next threshold exceeds int64; no invented cap or naive intermediate overflow. Named toolchain/artifact manifest labels distinguish selected from verified. |
| M01-V14 | Audit A1: Checkpoint receipt/attempt metadata is separate from gameplay allocation: extra time/settings commits must not change crop/event IDs; compare gameplay exactly and validate per-run durable metadata separately. AV-001-01/03/04; AV-002-01–05 with in-memory commit fakes; AV-003-01–04; AV-004-01/02/05. Freeze identity, manifest, prepared-result/sink and accepted-envelope contracts; no native repository or UI implementation is required. Scope ruling I1 (2026-10-30): see the note after the crosswalk below. |

## Acceptance criteria and definition of done

- All M01 tasks have artifacts and M01-V01–V14 pass; no production durability or visual behavior is represented as implemented.
- Manual Wheat farming works from the actual initial state; advanced seed formula fixtures cannot leak unlock bypasses into player commands.
- All 32 plots, exact base rewards, immutable snapshots, independent timing, typed APIs, deterministic replay and checked arithmetic are demonstrated.
- XP curve exists before level code and remains visibly provisional where inferred. C1 increasing option B is tested beyond level 30; M05 validates final balance rather than selecting a missing continuation.
- Core runs without scene tree dependencies; clocks, adapters, event ordering and state-change boundaries support M02/M03 unchanged in principle.
- T-001,003,020 and core parts of T-002/021 have recorded evidence; other source tests are accurately marked future work.

## Expected deliverables

Future implementation outputs: pinned Godot project and test runner; typed kernel and definitions; complete provisional level/crop fixtures; command/event API and phase table; arithmetic and state validation suite; deterministic scenario reports; dependency audit; D-01/02/03/05/06 decision records; M02/M03 handoff. The current deliverable is this Markdown plan only.

## Audit A1 task and validation corrections

These are required constraints on existing tasks, with their original dependency order retained. Source contracts: TRS §§20.1–20.7 (AUD-R-001–007), FRS FR-AUD-001–007; exact test oracles are TRS §15.1 AV-001–009. Historical approval notes describe their original scope; the explicitly applied A1 additions define the current selected clarification. No test is marked passed by this document update.

| Issue / selected decision | Existing task / validation target | Required correction | Exact acceptance extension |
|---|---|---|---|
| AUD-001 / AUD-DEC-001 B | T05/T06/T07/T14; V03/V04/V07/V10 | Reserve namespaced identity in state/commands/clone; preserve scheduler order with fixed injected tokens. | AV-001-01/03/04; M01 replay/clone; M01-V14 |
| AUD-002 / AUD-DEC-002 B | T06/T13/T14; V03/V10 | Model candidate outcomes and stopped/unknown fake sink path; keep durable revision distinct from unsaved simulation state. | AV-002-01/02/05 with fakes; M01-V14 |
| AUD-003 / AUD-DEC-003 B | T02/T03/T05/T12/T14; V05/V07/V13 | Bind state to immutable rules before lookup/validation; preserve derived level and point conservation. | AV-003-01–03; current option-B exactness; M01-V14 |
| AUD-004 / AUD-DEC-004 B | T06/T13/T14; V03/V04/V10 | Define accepted stamp/order, immutable replay envelope and post-due rejection baseline. | AV-004-01/02/05 with fakes; M01-V14 |
| AUD-008 / AUD-DEC-008 A | T05 L90 | Mark G4-only content reservation historical; C2 catalog is settled. | AV-008-01; M01-V14 |

**Applied scope ruling I1 — 2026-10-30:** M01-V14's AV ranges are read through the crosswalk above:

- **M01 executes:** AV-001-01/03/04, AV-002-01/02/05 and AV-003-01/02/03 (with in-memory commit fakes), plus AV-004-01/02/05.
- **AV-002-03/04** (catch-up, settings, migration, startup, backup and shutdown receipts during UNKNOWN) and **AV-003-04** (schema migration with backup) are owned by M03.
- **AV-004-03/04** (boost and reset quotes) are owned by M02.
- **AV-001-02** (claimed-offer rollback) needs contracts and is owned by M05.

This resolves the wording difference between the V14 row and the crosswalk without changing any AV criterion.

**Additional exit condition:** complete the task-level A1 obligations above and M01-V14 at the stage owned by this milestone. Later-runtime cases may be specified with fakes now only where the staging explicitly permits it; they remain required for their real integration milestone. No new mandatory gameplay family, final balance value or earlier native/UI implementation follows from A1.
