# M03 — Saves, clock integrity and offline farming

> **Audit corrections A1 — 2026-10-28:** Apply the approved contracts in [TRS §§15.1/20](../architecture/IdleFarmer_Technical_v1.5.md), [FRS audit requirements](../requirements/IdleFarmer_Functional_v1.0.md) and the [Audit Decision Register](../decisions/Audit_Decision_Register.md). The task crosswalk below is normative for the listed existing tasks; it does not add gameplay or implement later-stage features. [Correction changelog](../audit/round_01/Audit_Correction_Changelog.md) preserves before/after references. Existing provisional values and Open/Deferred evidence remain unchanged.

Priority P0 · Planning only · Depends on M01–M02 and verified SQLite integration · Next: M04

**Approved foundation update — 2026-10-26:** [Decision Register Group 1](../decisions/Decision_Register.md) / TRS G1 is binding for arithmetic, phases, interval ledger, writer-epoch replay protection and numeric-limit recovery. DEC-001 approves the SQLite evaluation candidate/direction, not an exact native binary or successful integration. DEC-014 clock measurements and other named unconfirmed selections remain pending; G4 now approves DEC-015 cadence below. **Historical scope:** reservations in this dated approval describe that revision; current C1–C3/A1 rules and original remaining evidence obligations govern.

**Approved G2 update — 2026-10-27:** Apply [Decision Register Group 2](../decisions/Decision_Register.md) and TRS clarification G2: DEC-003 zero/Empty start, DEC-004 one-point/minimum-rank skill rules, and amended DEC-020 fixed eight-column 8×3 start with strict fourth-row 25→32 unlocking. DEC-002's through-30 table is approved provisional development data; G2 did not select continuation; C1 now approves increasing option B below. G1 contracts remain binding; no game implementation or test execution is claimed.

**Approved G3 update — 2026-10-27:** [Decision Register Group 3](../decisions/Decision_Register.md) / TRS G3 now binds research boost, farm-wide budgets/cap, Smart guarantees/priority, lifecycle/batches and staged advanced work (DEC-007/009/010/011/012/025). Numeric defaults remain provisional for balance; G4 policy is now approved as stated below; actual evidence and named partial subparts remain pending. Earlier notes describing these G3 choices as unresolved are superseded by the synchronized source contracts; no game implementation is claimed.

**Approved G4 update — 2026-10-27:** Project owner: “Group4 approved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G4 binds DEC-015/017/018/021/022 durability/cadences, completed-minute statistics, session/productive utilization, profile-owned settings and end-M03 minimal browser probe. DEC-014 measurement-first policy and DEC-019 authored lifecycle/schema are approved; provider/API evidence remains pending; C2 now approves the exact twelve contract rows/guards/rewards. All earlier pending-G4 statements are updated below; no application tests or implementation are claimed.

**Approved G5 update — 2026-10-27:** Project owner: “group 5 aapproved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G5 approves DEC-023 qualification/sample-review policy (named hardware/art still Open), defers DEC-008 Seed Efficiency/Research Facilities/Growth Booster, and approves DEC-024 costed economy plus normal-speed human evidence with the provisional five-real-minute/diary indicator. Preserve v1 research acceleration; no new balance values, hardware, assets or empirical results are inferred.

**Approved G6 update — 2026-10-27:** [Decision Register](../decisions/Decision_Register.md) / TRS G6 records “Group 6 approved as recommended”: standalone versioned Windows ZIP/executable, required dependencies/licenses/checksums and per-user save preservation. Installer/signing optional by separate selection; Steam/cloud/storefront integration deferred beyond v1. This changes future delivery requirements, not the current milestone's game scope or implementation status.

**Approved closeout C1 — 2026-10-27:** Owner: “DEC-001 - approved, DEC-002 - use option B.” [Decision Register](../decisions/Decision_Register.md) / TRS C1 selects standard Godot 4.7.2/matching templates, GUT v9.7.1, godot-sqlite v4.9 evaluation/reportedSQLite 3.51.0, Compatibility/Windows x86_64. Actual artifacts/hashes/licenses/integration remain unverified. Increasing option B beyond level 30 is approved provisional data: first step57,500; subsequent steps ceil(previous×110/100), one point/level with retained surplus and no arbitrary cap. All existing levels 1–30 values remain unchanged; no code/test result is claimed.

**Approved closeout C2 — synchronized 2026-10-28:** Owner: “Closeout B option A - approved.” [Decision Register](../decisions/Decision_Register.md) / TRS C2 makes FRS §§10.2–10.4's twelve authored offers, exact guards/predicates and frozen provisional rewards binding. Existing optional/manual/three-slot/one-time/offline lifecycle remains intact. This settles DEC-019 content; actual game implementation and balance evidence remain future work.

[Master roadmap / D-xx decisions](00_IdleFarmer_Master_Roadmap.md) · [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md) · [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md)

## Objectives and scope

Persist all authoritative state safely, resume using offline-first time policy, simulate closed/suspended intervals at 1×, and atomically commit catch-up plus credited-through UTC. Provide backups, compatible migrations, one-writer ownership, failure states and durable base statistics needed before historical offline activity occurs. Test recovery by intentional faults, not only clean exits.

Windows SQLite is the planned repository with WAL and `synchronous=FULL`; select and verify integration rather than assuming a plugin. The approved minimal end-M03 browser probe checks the adapter boundary; a full browser implementation remains future. Contract state/schema and generic claim idempotency are covered now; actual contract objectives/rewards and T-011 land in M05. No scene presentation is necessary beyond a minimal recoverable lifecycle status interface.

Primary references: FRS §§9,9.1,11,13; TRS §§3,7–10,12,14–18; T-009/010/012–021/025–029; ARCH-004.

## Prerequisites and dependencies

- M01/M02 APIs, state clones, economic records and batch ordering stable and tested.
- M02 provides schema inventory for all systems, including inactive future settings. Each new persisted field must have default/validation/version policy.
- D-01 SQLite addon selection verified in T01; D-13/14 real elapsed and sleep semantics must be settled empirically before final clock implementation.
- Use test profiles and fake time for destructive tests; never corrupt a real player's save or set the Windows system clock in automated validation.

## Required classes and suggested file structure

Runtime/services/records extend typed `RefCounted`; runtime lifecycle bridge and the test-only browser boot controller may use `Node` outside the shared core. Core engine must not import the SQLite addon or native time extension.

| Suggested path | Classes / role |
|---|---|
| `persistence/repositories/{save_repository,in_memory_repository,fault_injection_repository}.gd` | `SaveRepository` logical interface and fake/failing adapters |
| `persistence/repositories/windows_sqlite_repository.gd`, `profile_lock.gd` | `WindowsSQLiteRepository`, `ProfileLock`; native boundary only |
| `persistence/{save_manager,snapshot_codec,checkpoint_validator,migration_runner}.gd` | `SaveManager`, `SnapshotCodec`, `CheckpointValidator`, `MigrationRunner` |
| `persistence/backups/backup_manager.gd`, `persistence/migrations/` | `BackupManager`, versioned forward migrations and fixtures |
| `core/time/{windows_time_provider,time_reconciler,accounted_interval}.gd` | `WindowsTimeProvider`, `TimeReconciler`, `AccountedInterval`; isolate any native calls |
| `core/simulation/{offline_catch_up,offline_report,cycle_aggregator}.gd` | `OfflineCatchUp`, `OfflineReport`, proven-equivalent `CycleAggregator` |
| `core/statistics/{statistics_state,statistics_system,time_bucket,accounting_segment}.gd` | `StatisticsState`, base `StatisticsSystem`, `TimeBucket`, `AccountingSegment` |
| `application/{game_controller,lifecycle_state}.gd` | `GameController` (`Node`), lifecycle states and safe error routing |
| `tests/portability/{browser_probe,browser_test_repository}.gd` | Test-only browser boot scene/controller and RefCounted snapshot adapter; no production browser package |
| `tests/{persistence,recovery,simulation,performance}/`, `tests/support/` | DB fixtures, crash subprocess harness, fake resume sources and storage fault points |

Save logical schema follows TRS §9.4. Include settings, scheduler sequence metadata, command deduplication policy, accounting segment mapping and future typed contract/configuration fields. Stable IDs and immutable cycle snapshots survive content changes.

## Detailed implementation tasks

### M03-T01 — Verify SQLite adapter and packaging spike

Dependencies: M01/M02. Evaluate C1-named `2shady4u/godot-sqlite v4.9` on Godot 4.7.2/Windows x86_64; verify its exact native artifact/fingerprint/license inventory and Windows export behavior before adoption. Prove WAL, FULL, transaction rollback, consistent backup, busy/error reporting and clean packaged launch. Document DLL architecture and native dependency placement; headless core loads without addon. Benchmark basic batch commit cost. Deliver integration decision/spike evidence; unsupported WAL/backup/durability blocks this adapter. References: TRS §§1.1,9.2,17; D-01/15.

**Approved G1 constraints:** GUT/Compatibility/standard Godot direction is already approved. The named v4.9 candidate still requires exact artifact/fingerprint/license review and real WAL/FULL, backup, failure and export evidence. Do not infer that approving candidate evaluation proves compatibility or adopts DEC-015 cadence.

**Approved G4 constraints:** Qualify the approved DEC-015 WAL/FULL policy and coherent-economic-commit latency; policy approval does not name or verify the addon/native pins. Sync relaxation requires explicit amended approval.

**Approved G5 constraints:** Record compute/commit/backup timings separately with actual named machine/build/driver data under DEC-023/G5. Until baseline selection, label exploratory observations as such rather than universal or final performance passes.

**Approved G6 constraints:** Approved DEC-027/G6 requires a standalone ZIP packaging spike with the selected export/native architecture, required libraries and honest missing-dependency diagnostics. Verify clean-user launch outside the editor; save paths are per-user and survive application-file replacement. No installer/Steam dependency or actual passing result is inferred.

**Approved C1 constraints:** Evaluate exact approved candidate godot-sqlite v4.9, reportedSQLite 3.51.0, on standard Godot 4.7.2 Windows x86_64. Record exact release/native artifacts and checksums/licenses; verifyWAL/FULL/backup/export/error behavior before adoption. No silent fallback to older engine/addon or ARM target.

### M03-T02 — Define repository contract and fault seams

**Applied A1 task constraints:** AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01. Implement load/latest/previous, commit checkpoint, create backup, migrate, acquire/release ownership and error categories. Define COMMITTED / NOT_COMMITTED / UNKNOWN receipts with unique coordinator commit ID, expected parent durable revision and resulting revision; settle/read-back the primary before resuming from UNKNOWN. Checkpoint metadata never consumes the gameplay entity allocator; known success is published only after durability. In-memory/fault repository implements same contract, with injection before/after transaction writes, commit and backup. Deliver adapter conformance suite without gameplay SQL. References: TRS §§5,9.1; ARCH-004.

**Approved G1 constraints:** The repository contract must support durable startup writer-epoch establishment plus atomic outcome/replay-high-water/interval-summary/anchor commits. It exposes structured failures and bounded response metadata without requiring SQLite imports in core; C1 already selects godot-sqlite v4.9 for evaluation; actual artifact/adoption and empirical adapter validation remain open.

### M03-T03 — Define lossless snapshot/schema codec

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B, AUD-DEC-006 A, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02. Serialize every TRS §3/9.4 field, settings, pending-event metadata and content version. Use lossless integers; no JSON float round-trip of 64-bit amounts/IDs/timestamps, especially future web tooling. Restore validated data, not Resource references. Define default handling and explicit unknown versions. Deliver round-trip fixture containing all 32 plots, upgrades/research, future contract/config fields and min/max valid integers. References: FRS §13; TRS §§3,9.4; D-21.

**Approved G1 constraints:** Serialize/validate/deep-copy current writer UUID epoch, successful-command high-water, bounded response metadata, credited anchor and bounded accounted-interval/reconciliation summaries. Preserve signed 64-bit values losslessly. G4 now defines profile-owned GameSettings and simulation-time bucket mapping under TRS §§9.4,10.

**Approved G2 constraints:** Round-trip G2's approved zero/Empty initial state, fixed eight-column plot ownership and 1..N unlock prefix, plus level/skill-point/prerequisite data from the approved through-30 definitions. Exact content/schema versions remain implementation deliverables, not asserted existing saves.

**Approved G3 constraints:** Round-trip G3 farm-only R/p/toggle, accepted fallback/armed purchase plan, inactive rules, cursor and original research-paid/timing/boost-used fields. Validate inactive advanced defaults separately from enabled capabilities; no independently overridable plot/group wallet fields.

**Approved G4 constraints:** Implement profile-owned versioned GameSettings, no persisted debug speed, contract offer versions/instance snapshots/claimed-offer eligibility and simulation buckets/live totals/segment/state-time fields under TRS §9.4. Deep-copy/round-trip all records; no exact contract content is inferred.

**Approved C1 constraints:** Round-trip lossless XP/level/points on both sides of31/32/35 and near int64-boundary fixtures using option B content version. Named versions are approved; actual artifact/native license inventory remains verification work.

**Approved C2 constraints:** Persist/deep-copy definition version/ID, acceptance instance and time/order, objective/reward snapshots, independent progress and claimed-offer eligibility for C2. Same-timestamp order is preserved across restore. M03 remains generic protocol testing; no M05 gameplay completion claim.

### M03-T04 — Implement Windows schema and exclusive ownership

**Applied A1 task constraints:** AUD-DEC-001 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03. Create DB schema/constraints/indexes and one-writer profile locking spanning whole load→catch-up→active→shutdown lifecycle; SQLite transaction locking alone is insufficient ownership. Use per-user `user://` path, separate normal/debug profiles and lock-recovery semantics after crash. A second process must refuse mutation or safely report read-only. Deliver real two-process test and disk schema validation. References: TRS §§9.2–9.4; FRS §13; T-028.

**Approved G1 constraints:** Acquire exclusive profile ownership before establishing a fresh persisted UUID writer epoch. Accept no active input until that startup epoch and required startup/catch-up state are durable. Backup recovery also retires prior input epochs; no old payload may recreate a claim/cycle.

**Approved G2 constraints:** State/constraint validation must reject hole-bearing unlocked sets and locked active crops, not silently unlock missing predecessors. Empty unlocked plots are legitimate. Profile ownership/replay rules from G1 remain unchanged.

### M03-T05 — Implement atomic economic commits and durable idempotency

**Applied A1 task constraints:** AUD-DEC-002 B, AUD-DEC-004 B, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T04. Persist state revision, wallet/XP, consumed/new cycles, research, skills, claims, statistics, dedupe marks and anchor coherently. Stage working state until receipt; on failure keep previous durable authoritative outcome and block irreversible commands. Implement approved DEC-016 bounded replay: profile/writer-UUID-epoch/increasing-counter identities, durable successful-command high-water, old-epoch/stale rejection and bounded cached responses under TRS §4.1. No unsafe key pruning or unlimited detailed transaction log. Validate crashes around COMMIT including committed-but-reply-lost retries. References: FRS §13; TRS §§4.1,9.2–9.3; T-018/020.

**Approved G1 constraints:** Follow TRS §4.1 exactly: current counters at/below success high-water and all retired epochs cannot re-execute; higher counters validate normally; rejection changes no authoritative gameplay state/counters. Test response-cache eviction, successful higher-counter gap retirement, committed reply loss and crash before first success. Full old response availability is optional; exactly-once economic effect is not.

**Approved G3 constraints:** Crash injection spans accepted subset, boost debit/reschedule/flag and seed/fixed/Smart cycle charges as coherent durable outcomes. A failed member or commit never leaves a partial cycle/extra boost; replay marks still prevent duplicate success.

**Approved G4 constraints:** Commit economic success before exposure, including accounting/anchor/replay/contract eligibility; settings drafts may remain cosmetic/unsaved but cannot falsely acknowledge economic durability. Generic claim fixtures do not prove final contract content.

**Approved C2 constraints:** Generic fixtures keep harvest+accepted-contract progress in one atomic outcome and claim reward+offer closure/XP/accounting/replay together. Concurrent objectives cannot charge/consume crops or count a cycle twice. Real twelve-offer crash evidence remains M05.

### M03-T06 — Implement save cadence and safe lifecycle orchestration

**Applied A1 task constraints:** AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T05. Important commands and each coherent auto event batch commit before exposure; apply approved 30-real-second time-only checkpoints, final shutdown checkpoint and serialization of pending batches. Add GameController lifecycle states loading/recovering/catching-up/active/reconciling-unknown-commit/save-error/shutting-down. Stop commands on storage failure and prevent notifications claiming success. Do not merge timestamps merely to reduce writes. Deliver fault-tested lifecycle sequence including final commit failure. References: TRS §§9.2,12; D-15.

**Approved G1 constraints:** Approved atomicity/phase boundaries plus G4 30-real-second time-only cadence and two-generation/10-real-minute backup policy are binding initial engineering defaults. Persist state/replay marks/anchor/interval summary coherently before publishing success; distinguish this future test obligation from documentation approval.

**Approved G4 constraints:** Apply 30-real-second time-only checkpoints and final accounted shutdown checkpoint under DEC-015. Use real-time scheduling at 1×/60×; private catch-up is one complete result+anchor commit, not per-historical-event fsync. Restore settings before audio and start session only after successful startup catch-up.

### M03-T07 — Measure and wrap Windows clock sources

Dependencies: T02. Observe pinned Godot UTC/tick APIs under active runtime, sleep and hibernate on Windows. Record clock resolution, suspend inclusion, process/reboot limits and float UTC conversion error. If needed isolate sleep-inclusive native source inside WindowsTimeProvider with portable fallback contract. Return observation metadata to reconciler; never treat boot-dependent ticks as cross-boot trusted time. Deliver measurement report plus fake provider reproducing observations. References: TRS §§7.1,17; D-14.

**Approved G1 constraints:** DEC-013 chooses the accounted-interval ledger, not a native API. Measure provider inclusion/resolution and lifecycle partition under still-open DEC-014; no host-clock edits or assumed suspend behavior.

**Approved G4 constraints:** Measure Godot tick/lifecycle observations first across active/sleep/hibernate/resume-unfocused/restart/reboot. Adopt engine-only only if duration and active/suspended partition are proven; otherwise isolate the needed Windows adapter. Record exact API/limits and equivalent fake model for explicit selection review; no assumed or fabricated result. DEC-014 parent remains Open pending actual selection/evidence.

### M03-T08 — Implement credited-through interval reconciliation

Dependencies: T03,T07. Specify interval accounting traces before coding: active at 1×/60×, wall jump forward/backward, save/exit, reopen below anchor, restored wall time. Advance anchor by actual accounted real delta, not simulated delta or arbitrary current UTC; preserve high-water on rollback. At reopen use max(0, nowUTC−anchor), respecting overflow checks. Define how active segment baseline and already-accounted durations prevent duplicate correction. Deliver formal trace fixtures and checkpointed diagnostics. References: FRS §9.1; TRS §7.2; T-013–016; D-13/26.

**Approved G1 constraints:** Implement approved DEC-013 rather than selecting a competing anchor algorithm. Separate actual real elapsed from active debug-scaled simulation time. Include live forward edit→restart positive interval, rollback→future preserved anchor→normal restoration, and no duplicate sleep correction traces.

### M03-T09 — Implement suspend/resume separation

Dependencies: T06–T08. Record pre-suspend accounted tick and lifecycle observations; reconcile suspended portion once at 1× and active portion at selected debug rate. Avoid counting sleep twice when the timing source already includes it; do not infer suspend from a slow frame alone. Handle missing lifecycle notifications through measured provider semantics and documented uncertainty. Preserve anchor with state; test suspend followed by crash/restart. Deliver Windows sleep/hibernate and fake-time evidence. References: FRS §9.1; TRS §§7.1–7.4; T-017; D-14.

**Approved G1 constraints:** An already counted suspended portion receives no second correction. Use the 10-active-seconds-at-60× plus one-hour-sleep = 4,200 simulated seconds oracle. Native source/notification adequacy must be demonstrated; a slow frame alone is not proof of sleep.

**Approved G4 constraints:** No slow-frame or foreground-inactivity heuristic may stand in for OS suspension. Test inclusive/exclusive sources and missing notifications; resolve measurement gaps instead of multiplying uncertain suspended time by debug speed.

### M03-T10 — Implement recovery generations and migrations

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B, AUD-DEC-006 A, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T04–T06. Use SQLite-consistent backup APIs, initially two rotating valid recovery generations. Validate checkpoint structure/invariants/reference integrity before selecting latest or prior. Backup before migrations; maintain schema/content migrations preserving planted snapshots and earned progress. Unknown versions/corruption never trigger silent new farm. Deliver compatible older fixture, failed-migration rollback, active-WAL backup and alternate recovery tests. References: FRS §13; TRS §9.3; T-026/027.

**Approved G1 constraints:** Recovery/migration retains replay metadata and starts a fresh owned writer epoch before input; closed/unknown claim IDs are rejected. G4 separately approves the initial two-generation/10-real-minute backup policy; replay approval alone was not its basis.

**Approved G2 constraints:** Refresh coordinate-bearing development fixtures explicitly for the eight-column map without renumbering plot/cycle/stat IDs. Existing recoverable invalid-save behavior applies to prefix holes; do not grant free plots or silently reset. No application saves have been produced by this planning task.

**Approved G4 constraints:** Keep two validated consistent recovery generations; rotate every 10 real minutes after a validated successful checkpoint, and at validated startup/load, pre-migration and successful clean shutdown. Failed/corrupt/tentative backups never overwrite good generations; report older recovery-point age and test backup-failure retention.

### M03-T11 — Implement durable base accounting and time mapping

Dependencies: T03,T05,T08. Record committed harvest/expense/cash-flow categories, cycle-attributed costs, XP/counts, plot idle/stall duration and lifetime crop/plot totals. Implement minute/hour bucket keys and segment metadata before catch-up. Implement approved D-17/18 simulation/UTC/session mapping, half-open completed-minute windows and session start after catch-up. Preserve debug normalization and distinguish expenses paid now from costs attributed at harvest. Deliver ledger reconciliation and cross-period crop fixture; M05 adds full queries/charts/retention refinement. References: FRS §11; TRS §10; T-025.

**Approved G1 constraints:** Persist the approved interval/replay summaries with accounting. G4 separately defines historical completed-minute windows, UTC segment mapping, growing-only utilization and post-catch-up session denominators under DEC-017/018.

**Approved G4 constraints:** Use approved TRS §10 simulation timeline, half-open completed-minute buckets and separate live partial minute; last 60/1440 completed minutes with as-of label. Start session after startup catch-up, retain separate real/UTC/debug/offline segments; disjoint Growing/Ready-waiting/Empty-not-stalled/Empty-stalled and integrated purchase-time unlocked capacity. Preserve lifetime totals and cycle costs.

**Approved G5 constraints:** Retain separate real-open/foreground/simulated/suspended-offline/debug provenance needed for DEC-024 reports. Foreground/meaningful-input observations are injected from lifecycle/presentation test adapters outside the headless kernel; their five-real-minute indicator never affects farming or authoritative economic time.

### M03-T12 — Implement isolated reference catch-up

**Applied A1 task constraints:** AUD-DEC-003 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T06,T08–T11. On startup lock/load/migrate/validate, clone state, reconstruct scheduler, compute eligible 1× interval and advance same engine. Include automation expenses/gains/levels/research/base stats; future accepted contracts use hook once implemented. No new point spending, research starts, crop choices or unapproved purchases. Return report containing elapsed time/harvests/gross/seed/fertilizer/net operating income/XP/levels/research/stalls and future contract progress field. Deliver 8-hour/7-day fixtures without committing or exposing working state. References: FRS §§9,13; TRS §§8,12.1; T-009/010/012.

**Approved G1 constraints:** Catch-up consumes only unaccounted eligible 1× elapsed time on the isolated clone. It respects the research-first phase order and cannot initiate new commands/skills/projects from offline progress. Preserve approved writer/replay boundaries without generating live epochs inside forecast/reference clones.

**Approved G2 constraints:** Offline level/point assertions use the approved through-30 table and one-point rank policy. A real production scenario crossing the configured curve cannot assume a tail/cap; C1 now resolves the continuation choice; qualify exact option B behavior.

**Approved G3 constraints:** Resume only enabled valid authorized loops, unchanged authorized stalls and existing active boosted/unboosted research at offline 1×. Never buy a boost/new project, spend skill points or rearm an inactive reset configuration during catch-up.

**Approved G4 constraints:** Offline history uses original simulation bucket times, not reopen payout time. Startup offline earnings stay outside the fresh process-session counters but within lifetime/rolling history. Preserve accepted future-harvest contract snapshot/claim eligibility without inventing content or auto-claiming.

**Approved C1 constraints:** Run full production beyond level 30 with approved option B; awards/unused points persist and no cap/XP dropping is permitted. Test8h/7d with actual enabled rules and one result+anchor commit.

**Approved C2 constraints:** Closed-time qualifying harvests may progress already accepted C2 snapshots; no retrospective pre-acceptance credit, auto-accept, auto-claim or authorization of new farming. Actual manual/auto source and same-order boundary remain exact.

### M03-T13 — Add proven stable-cycle aggregation

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T12. Keep event-by-event engine as correctness oracle. Detect safe repeated stable cycles; aggregate only when affordability/config/modifiers/research/XP decisions/contracts/buckets cannot change outcome. Break at all relevant boundaries including depletion, reserve thresholds, new levels, research completion and later contract completion. Bound queue/history/report memory and suppress presentation events. Use checked arithmetic/chunking for long intervals with no arbitrary gameplay cap. Deliver differential tests for random deterministic fixtures and 30-day/year cases; full performance qualification is M06. References: TRS §§8,14; T-029; D-26.

**Approved G1 constraints:** Use safe integer reduction/quotient arithmetic so representable final results survive large intermediates. Only genuine representation failure takes DEC-026's recoverable path: no partial payout, checkpoint or anchor advance. Computation chunks are not separately exposed catch-up payouts.

**Approved G2 constraints:** Early long-interval math/reference probes may use explicitly labeled controlled fixtures whose earned XP remains within configured thresholds (including test-only zero-XP definitions if needed). They are not production progression/beyond-30 validation. Full production 30-day/year qualification in M06 must use an approved continuation policy; no silently dropped XP or improvised cap.

**Approved G3 constraints:** Differential aggregation preserves one C per logical timestamp batch, mixed-mode order, authorization changes and successful-plant cursor advancement. Do not apply the protection fraction once to pooled offline income or recompute it per member.

**Approved G4 constraints:** Aggregation preserves minute boundaries/current partial totals, retention rollups, integrated state/capacity time, acceptance/completion predicates and durable claimed-offer eligibility. Compare independent aligned-window/session/utilization ledgers as well as money/XP.

**Approved G5 constraints:** Record actual hardware/build/scenario and separate calculation/commit cost for 30-day/year probes; provisional five-second stable target is not promised for every changing configuration. DEC-002/C1 now supplies increasing option B; use it without dropping XP or capping offline time.

**Approved C1 constraints:** 30-day/year production/reference paths now include approved increasing continuation and correct threshold breaks/point accounting. Controlled zero-XP fixtures may still isolate math, but cannot replace full production qualification.

**Approved C2 constraints:** Aggregation preserves C2 mixed AND/gross/actual-auto predicates, independent progress of concurrently accepted instances and post-acceptance boundaries; claims remain outside crop gross. Stop or algebraically account exactly at completion/other outcome-changing transitions.

### M03-T14 — Commit catch-up and anchor atomically

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T05,T12,T13. Prepare state+updated anchor+statistics+report metadata as one logical checkpoint. If canceled/crashed/fails before commit, reopen prior complete checkpoint and recompute; if commit succeeds but UI not shown, do not pay again. Surface long-work progress based on processed time without publishing tentative rewards; yielding keeps one authoritative owner. Validate no separate additive offline payout. Deliver crash-injection matrix around calculation, commit and startup exposure. References: FRS §§9,13; TRS §§8,9.3,12.1; T-019.

**Approved G1 constraints:** Commit authoritative result, time anchor, accounted-interval summary, replay metadata and stats together. Persist a fresh startup writer epoch before active input, potentially in this startup checkpoint. On pre-commit failure, preserve the old complete checkpoint; on committed response loss, never add the result again.

**Approved G4 constraints:** Successful startup catch-up atomically persists all result/anchor/statistics/claim/replay metadata before session initialization, settings restoration and presentation. Backup a validated committed startup state; failed commit exposes no new-session earnings.

### M03-T15 — Implement recoverable storage/time error routes

**Applied A1 task constraints:** AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T06,T10,T14. Expose typed errors/actions for disk-full/denied access/corruption/unsupported version/owned profile/overflow/catch-up commit failure. Preserve evidence and memory state where safe, offer valid recovery/retry/exit, block further irreversible actions if persistence unavailable. Time rollback is a diagnostic with zero extra offline time, not data erasure or network requirement. Deliver lifecycle integration tests and user-facing message contract for M04. References: FRS §§9.1,13; TRS §§9.3,12.

**Approved G1 constraints:** A true numeric-limit error retains previous state/anchor and requires deliberate recovery/version handling; never wrap, saturate or add an arbitrary offline cap. A clock rollback remains a non-destructive diagnostic, not a numeric failure or network-verification requirement.

**Approved G4 constraints:** Expose economic-save versus cosmetic-settings-unsaved and backup-failure status accurately; preserve known-good backups; a definite NOT_COMMITTED outcome retains the parent, while UNKNOWN settles/read-backs the primary under TRS §20.2 before any write. Exact provider uncertainty stays an unresolved validation issue, never false elapsed-time credit.

### M03-T16 — Exercise recovery, time and equivalence matrix

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T15. Run real SQLite subprocess crashes plus fake provider/fault repository tests. Include sleep at 60×, UTC forward/backward/restoration, duplicate commands after restart, generic claim identity and all supported migration fixtures. Compare gameplay/aggregate fields for identical simulated durations across active/debug/offline, documenting intentional diagnostic differences. Actual contract claim behavior remains M05-T06. Deliver machine-readable dossier and unresolved hardware observations. References: TRS §15; T-009/010/012–021/025–029.

**Approved G1 constraints:** Extend T-020 to cache eviction, old writer epochs, rejected/gap counters, crash before first success and backup-restored fresh epochs. Inject fixed writer tokens for deterministic comparable simulations; separately verify production startup rotation and bound metadata growth.

**Approved G2 constraints:** Add prefix-hole rejection, no-gap purchase recovery and approved rank/point/XP snapshots to the migration/crash corpus. Preserve valid scattered Empty/Growing/Ready occupancy; do not confuse geometry approval with a completed migration or test run.

**Approved G4 constraints:** Add measured clock selection traces, real-time cadence/backup triggers at 60×, settings profile round-trips, completed-minute/live totals, state-time denominator and post-catch-up session fixtures. Actual authored contract content remains M05.

### M03-T18 — Run the minimal browser compatibility probe

Dependencies: T03,T06,T09,T12,T16 and M01-T15. Preserve stable task IDs: this newly added probe runs before the existing T17 handoff. Export a tiny Compatibility scene that initializes the same headless GDScript core without Windows SQLite/native imports. Use a test-only browser repository to round-trip a versioned snapshot, inject denied/unavailable storage and exercise lifecycle suspend/resume reconciliation with controlled observations. Verify a rendered frame and core invariants; do not implement a full game, production browser durability, audio or import/export. Capture pinned engine/browser/export settings, commands, assertions, results and limitations. Record actual pass/partial/fail for T-030; shared-core native leakage must be fixed, while browser-specific future limitations get explicit findings. Deliver probe fixture/recipe and evidence dossier. References: FRS §14; TRS §§1.1,9.5,15 T-030,16; DEC-022.

### M03-T17 — Close durable simulation gate

**Applied A1 task constraints:** AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M03-V19 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T16,T18. Validate class/schema versions, backup policy, clock traces, ownership and catch-up statistics. Supply M04 stable controller snapshots, offline report, error routes and post-commit presentation stream (live vs historical). Document native dependencies/future web adapter contract. Deliver reproducible save/resume script and M05 extension migration checklist. References: TRS §§16 M03,18.

**Approved G3 constraints:** M03 persists validated advanced interfaces/defaults under approved DEC-012; M05 completes behavior/UI. Handoff explicit farm-wide controls versus inherited farming settings and research-boost/loop state to M04/M05. G4 now defines storage cadence, settings ownership and statistics windows; measure their implementation.

**Approved G4 constraints:** Require M03-T18 minimal probe dossier and honest T-030 assertions/findings before handoff; no optional-M06-only deferral. Hand off approved G4 schemas/rules, actual provider/durability evidence and C2's approved exact content with M05 implementation ownership.

**Approved G5 constraints:** Carry approved DEC-023/024 methods with measured-versus-pending evidence labels. No hardware/sample selection or human engagement claim follows from storage/headless tests; deferred families remain absent.

**Approved G6 constraints:** Handoff the G6 per-user save path/backup/native-dependency and normal-user package contract to M06. Delivery choice is settled; actual artifact/fingerprint verification and empirical packaging proof remain separate; C1 selects x86_64.

**Approved C1 constraints:** Handoff verified artifact identities only when actually checked and approved option B snapshots/fixtures. Exact release architecture is Windows x86_64; no longer label it unselected. Hardware/provider/art/content evidence remains separate.

**Approved C2 constraints:** DEC-019 table/guards/rewards are settled; hand off typed schema/order/progress/claim-state coverage with M05 real-content/test ownership. Actual storage/code tests remain future work.

## Automated tests and validation procedures

Each automated run uses isolated temporary profile paths and deterministic UTC/tick fixtures. Test DB faults at every important write boundary; repeat selected cases with actual process termination, because in-memory mocks alone do not demonstrate SQLite durability. Record application/schema/content versions and last durable revision.

| ID | Procedure / expected outcome |
|---|---|
| M03-V01 | Snapshot round-trip every field; unknown versions/missing IDs/negative funds/invalid cycle/claim/reference rejected. No lossy 64-bit conversion. |
| M03-V02 | T-018/020: kill before/after planting/harvest COMMIT and retry same command after reload. Exactly old or new state; never partial charge/reward. Lost commit response does not duplicate. |
| M03-V03 | T-019: interrupt catch-up calculation and DB commit; restart from last durable revision. Compare final state+anchor+stats to uninterrupted run. |
| M03-V04 | T-013/014/015/016: fake UTC rollback, reopen below anchor, large positive cross-session interval, DST/time-zone changes. No negative progress; preserve anchor; active clock independent; positive intervals honored within representable range. |
| M03-V05 | T-017: 10 seconds active at 60× plus 1 hour suspended advances 600 + 3,600 simulation seconds, not 216,600. Resume/crash/reopen cannot credit the hour twice. Repeat with both suspend-inclusive and exclusive fake tick models. |
| M03-V06 | T-009/010/012: offline active research completes, multiple levels yield unallocated points, 8 hours/7 days execute only enabled automation. Costs, gross/XP and stalled plots match event reference. |
| M03-V07 | T-021: same state, commands and simulated duration through 1×/60×/offline have equivalent authoritative gameplay/accounting totals; compare temporal buckets under documented segment normalization. |
| M03-V08 | T-025: plant just before window at seed/fertilizer cost, harvest inside window. Completed-cycle profit includes those costs; period cash flow contains harvest only. Report planting-period spending separately. |
| M03-V09 | T-026/027: backup active WAL consistently, migrate older fixture, simulate migration failure/corruption/disk-full/permission denial. No overwritten unsupported save, silent reset or reported successful failed save. |
| M03-V10 | T-028: two actual processes target same save. One writer only; stale lock recoverable after owner dies; profiles separate and normal/debug paths distinct. |
| M03-V11 | T-029: 30 days and one year, stable and shortage/boundary-rich farms. Differential totals exact, queue/history bounded, memory/time/commit costs recorded. Five-second target remains provisional until reference hardware fixed. |
| M03-V12 | Time-only checkpoint/shutdown/crash with no economic event; active real elapsed and anchor remain consistent, debug multiplier reset on new session. Live notifications occur after commit only; catch-up produces no historical effect stream. |
| M03-V13 | G1 durable edge cases: crash before first accepted success, retired-epoch and pruned-response retries, higher-success counter gaps and fresh epochs after backup restore. True arithmetic failure leaves previous checkpoint/anchor/stats untouched; safe representable quotients succeed. Bounded interval/replay summaries round-trip and cloned/forecast runs never rotate live epochs. |
| M03-V14 | G3 recovery: boost-paid/used/timing and farm-budget/authorization/cursor records survive save/crash/replay; no second boost or resumed refunded loop. Offline reference versus aggregation preserves per-batch C and fixed/Smart order; failed subset commit rolls back all accepted changes. |
| M03-V15 | G4 storage: 30-real-second checkpoints and 10-real-minute/two-generation backups at 1×/60×; validated startup/pre-migration/clean-shutdown triggers. Failed backup preserves good generations; economic success waits for commit, cosmetic settings failure reports unsaved and speed resets. |
| M03-V16 | G4 accounting: events immediately below/at minute boundary, 60/1440 completed buckets and separate live totals/as-of; UTC edits do not rekey; 48-sim-hour/90-sim-day rollups conserve totals. Post-catch-up session excludes startup payout; ready waiting, stalled subset and mid-period expansion denominators match an independent state-time ledger. |
| M03-V17 | T-030/M03-T18: minimal Compatibility browser export boots shared core, renders, writes/reads test snapshot, handles denied storage and reconciles suspend/resume without Windows SQLite. Record actual/partial/fail evidence and platform limits; fix native shared-core leakage. No complete production web or audio/import-export acceptance implied. |
| M03-V18 | C1: real production beyond level 30 under option B across8h/7d/30d/year reference and aggregation, correct level/unused-point grants after restart/replay and lossless int64 snapshot. No zero-XP/within30 fixture substitutes for production qualification; no false failure from an unrepresentable hypothetical next threshold. |
| M03-V19 | Audit A1: AV-001-01–04; AV-002-01–05 on the actual Windows adapter; AV-003-01–05 for supported schema/version cases; AV-004 replay/commit integration; AV-005 offline/reference parity; AV-006/007 schema, reference and atomicity fixtures. M03 generic claims never replace real M05 T-011. |

## Acceptance criteria and definition of done

- M01/M02 affected regressions and M03-V01–V19 pass, with native suspend measurements recorded separately.
- Save/exit/reopen preserves all current systems; backup/migration/recovery and one-writer tests demonstrate real adapter behavior.
- State/anchor/statistics commit together. No duplicate harvest/charge/reward across retry/crash and no partly exposed catch-up.
- Active monotonic time, UTC, simulation/debug time and suspended/closed time are distinct and tested through wall-clock restoration sequences.
- Base accounting survives offline catch-up before M05 UI exists; event aggregation is differentially proven and bounded.
- Contract gameplay coverage remains explicitly pending M05. Required M03-T18/T-030 probe is executed with actual/partial findings; full browser durability is not claimed from Windows tests; no network time or arbitrary offline cap is introduced.

## Expected deliverables

Future outputs: verified SQLite adapter/lock, schema/codec, migrations and two-generation backups, lifecycle controller, native/fake time providers and interval reconciliation, reference/optimized catch-up, durable base stats/report, fault/crash/time results, save path documentation, minimal browser-probe dossier and M04/M05 API handoff. Current output is this plan only.

## Audit A1 task and validation corrections

These are required constraints on existing tasks, with their original dependency order retained. Source contracts: TRS §§20.1–20.7 (AUD-R-001–007), FRS FR-AUD-001–007; exact test oracles are TRS §15.1 AV-001–009. Historical approval notes describe their original scope; the explicitly applied A1 additions define the current selected clarification. No test is marked passed by this document update.

| Issue / selected decision | Existing task / validation target | Required correction | Exact acceptance extension |
|---|---|---|---|
| AUD-001 / AUD-DEC-001 B | T03/T04/T10/T14/T16; V01/V13 | Round-trip startup namespace/counters; distinguish backup rollback; preserve pending identity during unknown commit. | AV-001-01–04; actual recovery/codec tests later; M03-V19 |
| AUD-002 / AUD-DEC-002 B | T02/T03/T05/T06/T10/T14/T15/T16; V02/V03/V13/V15 | Implement commit identity, expected parent, safe read-back, blocked write routes and time-ledger reconciliation. | AV-002-01–05; actual adapter faults later; M03-V19 |
| AUD-003 / AUD-DEC-003 B | T03/T10/T12/T13/T16; V01/V09/V18 | Validate supported manifests, preserve binding during schema migration and run catch-up in that context. | AV-003-01–05; T-026/029; M03-V19 |
| AUD-004 / AUD-DEC-004 B | T05; V02/V13 | Keep command identity/accepted result coherent with commit uncertainty/replay. | AV-004-05 + AV-002; M03-V19 |
| AUD-005 / AUD-DEC-005 A | T13; V14 | Aggregation preserves every logical batch’s exclusion outcome and one final cap. | AV-005-04/05; event-reference differential; M03-V19 |
| AUD-006 / AUD-DEC-006 A | T03/T10 content/version validation | Preserve selected upgrade definitions/ranks through supported snapshots/migrations. | AV-006-01/03 + AV-003; M03-V19 |
| AUD-007 / AUD-DEC-007 B | T03/T05/T10/T17; V01/V14 | Persist/reference-validate group revisions and plan consent atomically; preserve unknown-version safety. | AV-007-05/06 + AV-002; M03-V19 |

**Additional exit condition:** complete the task-level A1 obligations above and M03-V19 at the stage owned by this milestone. Later-runtime cases may be specified with fakes now only where the staging explicitly permits it; they remain required for their real integration milestone. No new mandatory gameplay family, final balance value or earlier native/UI implementation follows from A1.
