# M06 — Validation, performance and Windows release

> **Audit corrections A1 — 2026-10-28:** Apply the approved contracts in [TRS §§15.1/20](../architecture/IdleFarmer_Technical_v1.5.md), [FRS audit requirements](../requirements/IdleFarmer_Functional_v1.0.md) and the [Audit Decision Register](../decisions/Audit_Decision_Register.md). The task crosswalk below is normative for the listed existing tasks; it does not add gameplay or implement later-stage features. [Correction changelog](../audit/round_01/Audit_Correction_Changelog.md) preserves before/after references. Existing provisional values and Open/Deferred evidence remain unchanged.

**Approved closeout C3 — 2026-10-28:** Owner: “DEC-023 - agreed with option A.” **Clean illustrated** is the selected visual direction: crisp silhouettes, restrained outlines, simple smooth shading and natural greens/browns/golden Wheat, guided by column A of the [planning comparison](../decisions/visuals/Art_Direction_Comparison_v1.png). Style selection is settled; M04 specifies and validates the production art bible/sample pipeline, M05 audits catalog consistency and M06 qualifies actual assets/audio/performance. The comparison is not a production sprite set or a change to the approved eight-column farm geometry. No game implementation or empirical pass is implied.

Priority P1 · Planning only · Depends on M01–M05 · Outcome: Windows release candidate

**Approved foundation update — 2026-10-26:** The [Decision Register Group 1](../decisions/Decision_Register.md) / TRS G1 contracts are requirements to validate, not test evidence. DEC-001 toolchain direction is approved while exact pins remain open; DEC-005/006/013/016/026 are approved. G3 now fixes optimizer strategy/policies; hardware, cadence, final pacing and web-probe timing choices remain unconfirmed until their own decisions. **Historical scope:** reservations in this dated approval describe that revision; current C1–C3/A1 rules and original remaining evidence obligations govern.

**Approved G2 update — 2026-10-27:** Apply [Decision Register Group 2](../decisions/Decision_Register.md) and TRS clarification G2: zero/Empty start, one-point/minimum-rank skill prerequisites, fixed eight-column 8×3 starting layout and next-ID-only fourth-row 25→32 unlocking. The through-30 XP table is approved provisional development data; C1 now defines beyond level 30; genuinely unconfirmed policies/evidence remain pending. G1 safety contracts remain binding; no game implementation is claimed.

**Approved G3 update — 2026-10-27:** Apply [Decision Register Group 3](../decisions/Decision_Register.md) / TRS G3 for shared budgets/cap, research boost, optimizer/priority, lifecycle/batches and staged advanced features (DEC-007/009/010/011/012/025). Numeric defaults remain provisional for balance; G4 policy is subsequently approved below; partial selections/evidence remain pending. Earlier pending-G3 notes are superseded by these synchronized source contracts; no implementation/evidence is claimed.

**Approved G4 update — 2026-10-27:** Project owner: “Group4 approved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G4 binds DEC-015/017/018/021/022 durability/cadences, completed-minute statistics, session/productive utilization, profile-owned settings and end-M03 minimal browser probe. DEC-014 measurement-first policy and DEC-019 authored lifecycle/schema are approved; provider/API evidence remains pending; C2 now approves the exact twelve contract rows/guards/rewards. All earlier pending-G4 statements are updated below; no application tests or implementation are claimed.

**Approved G5 update — 2026-10-27:** Project owner: “group 5 aapproved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G5 approves DEC-023 qualification/sample-review policy (named hardware/art still Open), defers DEC-008 Seed Efficiency/Research Facilities/Growth Booster, and approves DEC-024 costed economy plus normal-speed human evidence with the provisional five-real-minute/diary indicator. Preserve v1 research acceleration; no new balance values, hardware, assets or empirical results are inferred.

**Approved G6 update — 2026-10-27:** [Decision Register](../decisions/Decision_Register.md) / TRS G6 records “Group 6 approved as recommended”: standalone versioned Windows ZIP/executable, required dependencies/licenses/checksums and per-user save preservation. Installer/signing optional by separate selection; Steam/cloud/storefront integration deferred beyond v1. This changes future delivery requirements, not the current milestone's game scope or implementation status.

**Approved closeout C1 — 2026-10-27:** Owner: “DEC-001 - approved, DEC-002 - use option B.” [Decision Register](../decisions/Decision_Register.md) / TRS C1 selects standard Godot 4.7.2/matching templates, GUT v9.7.1, godot-sqlite v4.9 evaluation/reportedSQLite 3.51.0, Compatibility/Windows x86_64. Actual artifacts/hashes/licenses/integration remain unverified. Increasing option B beyond level 30 is approved provisional data: first step57,500; subsequent steps ceil(previous×110/100), one point/level with retained surplus and no arbitrary cap. All existing levels 1–30 values remain unchanged; no code/test result is claimed.

**Approved closeout C2 — synchronized 2026-10-28:** Owner: “Closeout B option A - approved.” [Decision Register](../decisions/Decision_Register.md) / TRS C2 makes FRS §§10.2–10.4's twelve authored offers, exact guards/predicates and frozen provisional rewards binding. Existing optional/manual/three-slot/one-time/offline lifecycle remains intact. This settles DEC-019 content; actual game implementation and balance evidence remain future work.

[Master roadmap / D-xx decisions](00_IdleFarmer_Master_Roadmap.md) · [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md) · [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md)

## Objectives and scope

Qualify the integrated game for Windows 11 release consideration. Close correctness, persistence, timekeeping and presentation regressions; benchmark 32 plots at 60× and long offline intervals; validate economic pacing with scripted strategies and human active-engagement evidence; package a reproducible Windows build with documented saves/recovery and known limitations.

This milestone produces a release candidate and readiness evidence, not automatic publication or Steam integration. Core web-compatible architecture remains required; minimal browser proof is tracked separately from full web delivery. Do not reduce uncapped offline rewards, add mandatory contracts or invent features to make pacing numbers appear satisfied.

Primary references: entire FRS, especially §§2,9–16 and §15 acceptance checklist; entire TRS, especially §§7–12,14–18 and all T-001–T-030. Verify requirements, not only that tests are green.

## Prerequisites and dependencies

- M05 feature-complete inventory, real contract crash tests, isolated forecast checks and complete content/curve decisions accepted.
- M01–M05 fixtures, migration corpus, API/schema/content versions and deterministic scenarios reproducible from a clean checkout.
- No unresolved mandatory gameplay/durability decisions. Provisional balancing/performance targets have an owner and explicit evaluation/disposition criteria.
- Actual representative baseline was selected/reviewed before M04; confirm its configuration and freeze final vendor/OS/driver/build coverage in T01 under DEC-023/G5. No unspecified GPU/driver/engine is assumed.
- Final build excludes debug speed/diagnostic entry points and uses normal profile; debug remains a separate test build/profile.

## Required classes and suggested file structure

Prefer validation, harness and packaging work over new gameplay classes. Extend existing services only to fix measured issues. Harness scenario records are typed `RefCounted`; any hardware/UI test bridge is a test-only `Node`.

| Suggested path | Required classes / artifacts |
|---|---|
| `tests/support/{acceptance_runner,scenario_manifest,state_comparator}.gd` | `AcceptanceRunner`, `ScenarioManifest`, `StateComparator`; source test tracking and deterministic equivalence |
| `tests/performance/{benchmark_runner,benchmark_result}.gd` | `BenchmarkRunner`, `BenchmarkResult`; repeated times, memory/queue/history and commit measurements |
| `tests/recovery/`, `tests/persistence/`, `tests/fixtures/saves/` | Final fault/crash/two-process/migration corpus with full systems enabled |
| `tests/balancing/`, `debug/diagnostics/{engagement_observer,engagement_record}.gd` | Existing strategy harness; test/dev-only `EngagementObserver` Node gathers foreground/input outside core, typed RefCounted `EngagementRecord` preserves real/simulated/offline/debug provenance |
| `tools/release/`, `export_presets.cfg` | Reproducible export/package validation, dependency/license inventory and checksum manifest |
| `docs/release/`, `artifacts/M06/` | Hardware matrix, acceptance dossier, benchmark/playtest reports, save/recovery guide, release notes |
| `tests/portability/` | Required M03 minimal probe corpus and evidence review; no production web implementation |

Distribution output location is chosen during implementation; never store runtime saves in the install folder. No application scripts, binary packages or tests are produced by the current documentation task.

## Detailed implementation tasks

### M06-T01 — Freeze qualification matrix and release inputs

Dependencies: M01–M05. Record pinned engine/templates/addon/content/schema versions, export architecture, Windows 11 build, CPU/GPU/RAM/storage/display/driver for reference hardware. Define supported GPU feature baseline and NVIDIA/AMD/Intel coverage devices, benchmark scenarios and repeated-run method. Freeze target interpretations: 60 FPS at 1080p, provisional <3 ms simulation/update, provisional stable 30-day catch-up <5 s, one-year correctness/boundedness with no 5 s promise. Deliver qualification manifest. References: FR-GFX-02/03; TRS §§1.1,14,17; D-23.

**Approved G1 constraints:** Qualification must use reviewed exact pins consistent with standard Godot/Compatibility/GUT/isolated SQLite evaluation direction; do not reselect frameworks silently. Actual reference hardware and provisional target dispositions remain DEC-023 work.

**Approved G5 constraints:** Confirm the baseline selected before M04; freeze actual engine/build/content/checksum/hardware/OS/driver/vendor matrix and repeatable method. DEC-023 protocol is approved, named hardware/art and actual performance proof remain separate. Do not move initial baseline selection back to M06.

**Approved C1 constraints:** Qualification manifest uses approvedGodot 4.7.2/templates/GUT 9.7.1/x86_64 and verified exact nativev4.9 candidate artifacts after successful adoption checks; preserve real hashes/licenses/build metadata.

### M06-T02 — Assemble source acceptance evidence map

**Applied A1 task constraints:** AUD-DEC-008 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01. Map every FRS §15 and TRS §18 checklist entry plus all T-001–030 to test command/scenario, build, expected result, actual result and evidence path. Include manual art/audio/hardware and human pacing checks; trace T-030 to M03-T18 actual/partial/failure evidence and any explicit approved exception. Differentiate required condition, provisional target and approved exception; no unexecuted test labeled pass. Deliver acceptance dossier skeleton and coverage gap list. References: FRS §§15–16; TRS §§15,18; D-22.

**Approved G1 constraints:** Add explicit evidence for each approved G1 rule and DEC-001's approved C1 names and still-open actual artifact/fingerprint/integration verification. Keep source acceptance checkboxes incomplete until real game/hardware/test evidence exists.

**Approved G2 constraints:** Trace new FR-FARM-08 and amended FR-FARM-01/02, approved DEC-003/004 defaults/edges, and DEC-002's through-30 development table to real evidence. C1 has selected increasing option B beyond 30; map its exact rounded recurrence/points/finite-representation cases to future evidence rather than reopening the policy.

**Approved G3 constraints:** Trace approved DEC-007/009/010/011/012/025 to actual test/UX evidence; initial default approval is not benchmark success or final balance. G4 policy is confirmed; keep only its exact provider/artifact verification subparts and actual artifact/fingerprint verification pending; C1 names/target/curve are settled.

**Approved G4 constraints:** Trace G4 approved policy to actual durability/cadence, clock, completed-minute/session/utilization, settings and contract evidence. T-030 belongs to M03-T18; record actual pass/partial/fail and any explicit exception, not automatic future/P2 deferral.

**Approved G5 constraints:** Trace DEC-008 explicit deferral, DEC-023 method-versus-actual hardware/assets and DEC-024 economic-versus-human evidence to source acceptance. FRS §15 no longer permits automated production hours to stand in for human engagement.

**Approved C1 constraints:** Trace C1 exact per-step recurrence, below/at/above thresholds, multi-level/surplus points and actual named artifacts to evidence. Selection approval is not integration/test passage.

**Approved C2 constraints:** DEC-019 is fully approved for initial provisional content; map all twelve data rows, guards and predicate/reward/lifecycle cases to actual implementation evidence. No missing-data or blanket real-contract pass from generic fixtures.

### M06-T03 — Run complete deterministic economic regression

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-004 B, AUD-DEC-005 A, AUD-DEC-006 A, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02. Rerun source formula/gate/skill/reset/research/contract/budget cases with final content. Replay 24/32-plot simultaneous events, mixed priorities/fertilizers, stalls, research completion, rotation and presets across active/debug/offline paths at equal simulated durations. Compare all gameplay/aggregate fields with documented clock metadata normalization only. Fix failures in owning modules with focused regression fixtures. Deliver T-001–012/020–025 evidence. References: FRS §§3–11; TRS §§4–6,15.

**Approved G1 constraints:** Include research-first phase ties, serial same-time manual batches, ceil-duration arithmetic and safe large intermediates. Inject fixed command writer tokens for deterministic replay; never normalize away crop/event ordering IDs, economy or missing replay guards.

**Approved G2 constraints:** Include sufficient-coins/high-level skipped plot rejection, strict 25→32 sequence, invalid hole-bearing snapshot rejection, valid scattered Empty/Growing/Ready occupancy, every XP threshold and one-rank predecessor success. No full-tier prerequisite may be silently imposed.

**Approved G3 constraints:** Run exact small oracles for Maximum Profit/Budget Protection; known marginal-ROI/tie cases for Capital Efficiency; all-mode priority/fixed-first groups with one shared C. Include 0/100%, R>W with free seeds, no unauthorized fallback and subset all-or-nothing commit behavior.

**Approved C2 constraints:** Final regression covers every C2 row and all four families: research/owned-skill acceptance, same-time post-acceptance, actual auto-origin, mixed AND, modified gross excluding claims, independent concurrent progress and fixed rewards through C1 XP/point boundaries.

### M06-T04 — Qualify real save durability and recovery

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03. Use exported Windows build or equivalent native adapter process, not just mocks. Kill during planting/harvest/research/upgrade/reset/contract claim/catch-up; retry committed-but-response-lost commands. Test FULL/WAL configuration, active-WAL consistent backups, two processes, disk-full/denied writes/corruption, every supported migration and unknown version. Verify no partial rewards/charges/progress/anchor/stats or silent reset. Deliver crash matrix, recovered revision/digest and backup restore instructions. References: FRS §13; TRS §§9,12; T-018–020/026–028.

**Approved G1 constraints:** T-020 covers response-cache eviction, counter gaps after rejection, old writer epochs, crash before first success, lost committed replies and backup-restored fresh epochs. Reject closed/unknown claim payloads without reconstructing them. Bound replay storage while retaining exactly-once effects.

**Approved G2 constraints:** Crash/reload around expansion preserves exactly the previous or new contiguous prefix with its cost, never a charged-but-Locked plot or free missing predecessor. Recovery/migration preserves stable IDs and does not fill holes as a repair shortcut.

**Approved G3 constraints:** Crash/retry one-boost cost/timing/used flag, accepted batch subset/cycles, loop authorization/inactive settings and rotation. No second boost, charged failed member or resumed refunded loop is permitted.

**Approved G4 constraints:** Qualify economic acknowledgements, real-time checkpoints/backups and all validated lifecycle backup triggers on Windows. Inject backup failure/corruption and preserve known-good generations; verify cosmetic unsaved settings cannot imply saved gameplay.

**Approved C2 constraints:** Crash-recovery qualification includes combined harvest+multiple-contract progress and frozen claim/offer-closure/accounting/anchor/replay states, content version changes and abandon/reaccept. No duplicate reward or retroactive eligibility.

### M06-T05 — Qualify clocks and extreme elapsed intervals

Dependencies: T04. Run fake-time forward/backward/restore/DST/restart cases, then measured Windows sleep/hibernate/resume at 1×/60× on reference OS. Validate active monotonic delta, suspended 1×, preserved high-water and no double credit after save/crash/reopen. Honor large valid positive offline intervals; test near-limit arithmetic returns recoverable error with prior checkpoint intact rather than wrapping/saturating/partial payout. Document accepted forward-clock manipulation limits and no required time service. Deliver clock trace dossier. References: FRS §9.1; TRS §7; T-013–017; D-13/14/26.

**Approved G1 constraints:** Demonstrate approved accounted-interval ledger/high-water consequences, including forward wall edit during play then restart, rollback/restoration, and 4,200-second active-60×/one-hour-sleep trace. Verify exact provider behavior under DEC-014 evidence. True unrepresentable output preserves state/anchor; safe representable quotient calculations must not falsely fail.

**Approved G4 constraints:** Measure actual DEC-014 selected API/provider and notification partition under Godot-first/native-if-needed policy; include no-focus resume, reboot and missing notification traces. A planning approval never substitutes for evidence.

**Approved C1 constraints:** Extreme valid XP lookup cannot fail merely because a hypothetical next threshold is outside int64; genuine state overflow still preserves the prior full checkpoint. No hidden gameplay cap.

### M06-T06 — Benchmark offline simulation and optimizer

**Applied A1 task constraints:** AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03,T05. Measure stable 32-plot 30-day and one-year runs, plus shortages, reserve-limited fertilizer, research/level changes, contract thresholds and rotation. Compare optimized totals to event reference where feasible and analytic known stable cases for long runs. Record compute/DB commit/total wall time, memory peak, queue size, bucket counts and optimizer frontier/work bounds. Use repeated warm runs and at least one cold/import-separated run. Fix measured bottlenecks without bypassing event boundaries; rerun exactness checks after each optimization. Deliver benchmark report and provisional target disposition. References: TRS §§6,8,14; T-024/029.

**Approved G1 constraints:** 30-day/year released-content scenarios must actually succeed; DEC-026 is not a cap or performance escape. Record bounded ledger/replay metadata as well as queue/statistics memory, and preserve approved phase boundaries when optimizing.

**Approved G2 constraints:** C1 increasing option B is the approved continuation for full production30-day/year scenarios. Early controlled within-domain fixtures are math/performance probes, not proof of released-content progression. Do not silently clamp levels/XP.

**Approved G3 constraints:** Measure exact 32-plot solver work/frontier and long-offline aggregation with per-batch C/priority/rotation thresholds. If strategy fails performance, reopen DEC-009 for explicit approximation approval; no silent downgrade or false optimum claim.

**Approved G5 constraints:** Compare repeated warm and import-separated observations on named hardware. Preserve 60 FPS and provisional <3ms / stable30days<5s meanings; one-year correctness/boundedness is not a five-second promise. Record shortages/configuration-rich cases separately without scope/guarantee changes.

**Approved C1 constraints:** Full production30-day/year qualification uses approved option B, not within30/zero-XP substitutes. Record exact totals/point grants and bounded queue/cache behavior; no invented linear tail or arithmetic escape.

### M06-T07 — Profile active frame/simulation/storage cost

Dependencies: T06. Profile normal and 60× 32-plot farms with panels/charts/effects and background saving. Separate rendering, simulation, optimizer, storage and UI costs; report frame distribution/p95/p99 and stall episodes, not only average FPS. Aim for ~16.7 ms frame budget at 60 FPS and provisional <3 ms simulation work in representative active frames. Fix attributable bottlenecks while preserving immediate durability/post-commit notifications; do not change WAL/FULL silently. Deliver before/after metrics. References: FR-GFX-03; TRS §§9.2,14; D-15/23.

**Approved G4 constraints:** Measure commit/backup latency separately under approved WAL/FULL and real-time cadences; optimize implementation before proposing weaker synchronization. Debug cannot accelerate checkpoint/backup timers.

**Approved G5 constraints:** Use named baseline/pinned build; report frame distributions/stalls separately from simulation/optimizer/DB/backup costs. Any provisional target miss gets explicit disposition, not silent durability relaxation or fabricated hardware-independent performance.

### M06-T08 — Qualify GPU, visual, input and audio behavior

**Applied A1 task constraints:** AUD-DEC-004 B, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T07. Run actual Windows game on selected NVIDIA/AMD/Intel hardware, checking Compatibility renderer, 1080p/scaling, depth sorting, all 75 crop stages against the approved Clean illustrated direction/art bible at actual gameplay size, varied sway, mouse hit-testing and farm visibility with panels. Check music toggle/all 0–100% buses, zero mute, settings restart and 250 ms/two-group real-second aggregation under 60×. Confirm no offline sound backlog, unchanged pitch/ambient speed and debug controls absent in production. Deliver device matrix, screenshots/listening records and issues. References: FRS §2; TRS §11; T-002.

**Approved G2 constraints:** Qualify the initial 8×3 + Locked fourth row and partially/completely unlocked row prefixes on GPU/scaling checks. Confirm the next eligible purchase is obvious and prior plants never move.

**Approved G3 constraints:** Check user-facing farm-wide controls, cap≠funding label, fixed/Smart priority, exact research boost preview and ordinary confirmation/start/rearm behavior. No repeated session/cycle prompts for valid authorized loops.

**Approved G4 constraints:** Verify profile-owned audio restore ordering, separate normal/debug settings, persisted mute/music and honest unsaved drafts; keep final artwork/hardware qualification under DEC-023.

**Approved G5 constraints:** Qualify actual NVIDIA/AMD/Intel coverage, sample/stage readability/provenance and real audio tuning. C3 explicitly approves Clean illustrated; that selection does not establish production-stage readability, audio tuning or measured vendor performance.

### M06-T09 — Validate economy and 3–5-hour automation goal

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03,T08. Rerun final strategy suite with all seed/fertilizer/research/upgrade costs and actual skill gates, then conduct focused normal-speed active play sessions. Record real open/foreground/meaningful interaction/simulated/offline/debug time separately; no-debug/no-free-unlock progression evidence. Report time to four basic automation nodes and continuous harvest+replant, including weak/strong strategies. Tune provisional content only through versioned decisions and targeted reruns. Deliver pacing report; disclose misses rather than granting hidden currency or forcing a cap. References: FRS §§1,5.4,12; TRS §14; D-24.

**Approved G2 constraints:** Normal-speed pacing starts at zero coins/XP with Empty plots and uses approved rank costs/edges, source level gates, through-30 curve and sequential expansion costs. C1 resolves beyond level 30; any final coefficient retuning remains a separate recorded balance decision.

**Approved G3 constraints:** Use one-project/one-boost half-cost/half-remaining initial policy and explicit purchase decisions in costed strategies. The C-based 50% price and p=25% default are provisional balance data, not permission for unrecorded retuning.

**Approved G5 constraints:** Use approved no-grant zero/Empty start and all real purchases/skills/research/boost costs. Automated and actual normal-speed human automation observations are separate; disclose weak/strong strategies, actual sample and target met/missed/insufficient evidence without forced waits or offline caps.

**Approved C1 constraints:** Normal-speed and headless strategies share option B with exact ceil-per-increment rounding. Final pacing tuning remains explicit; source levels 1–30 table and one-point-per-level accounting stay unchanged.

**Approved C2 constraints:** Pacing uses exactly approved provisional rewards/guards, real costs and an independent no-contract path. Numeric retuning requires recorded review; finite content is not proof of the human ~48-hour target.

### M06-T10 — Evaluate additional 48 active hours of engagement

Dependencies: T09. Execute the normal-speed human protocol prepared before M05 closure, with the approved initial provisional five-real-minute recent-meaningful-input indicator supplemented by decision diaries and milestone/crop/research/build-choice observations. Track post-automation engagement separately from automatic production/offline hours; include multiple play styles and optional-contract avoidance. Report observed duration, choice quality, content exhaustion/repetition and remaining sample limitations. If target unsupported, record content/balance findings and release decision; do not fabricate evidence from accelerated runs or add unauthorized systems. Deliver human engagement dossier and approved target disposition. References: FRS §§1,12.1,16; TRS §14; D-24.

**Approved G5 constraints:** Execute the human protocol prepared before M05 handoff. Use initial provisional foreground+meaningful-input-within-five-real-minutes indicator plus decision diaries; test below/at/above300s, foreground loss and debug independence. Reading/planning is not judged solely by click count. Report actual participants, observed normal-speed post-automation duration, decisions/repetition/content exhaustion and limitations; no simulated/offline-hour substitution or invented results.

### M06-T11 — Audit web portability and M03 T-030 evidence

Dependencies: T03,T08 and M03-T18. Audit shared-core native/storage/scene/audio boundaries and review the required end-M03 probe dossier. Rerun affected boot/render/test snapshot/error/resume assertions after relevant changes. Record T-030 actual pass/partial/fail and browser-specific future findings; repair native leakage in the shared core. Do not defer the required minimal probe silently to P2 or build a full browser game. Deliver audit and current probe evidence. References: ARCH-004/006; TRS §§1.1,9.5,15–16; DEC-022.

**Approved G1 constraints:** DEC-001 approves core/renderer direction only; DEC-022/G4 now requires the end-M03 minimal probe and honest M06 evidence review. No full web release is implied and no unrun T-030 may be marked passed.

**Approved G4 constraints:** Review/rerun affected M03-T18 evidence as needed after changes. Audit boot/render/test storage/denial/resume without native SQLite, label partial platform findings and require shared-core native leaks fixed. Full web release/audio/import-export remain future.

**Approved C1 constraints:** Verify browser/native boundary under selected4.7.2/GUT 9.7.1 toolchain; Windows x86_64/native candidate selection never imports a Windows extension into shared browser/headless core.

### M06-T12 — Build reproducible Windows distribution

Dependencies: T04,T08,T11. Apply approved DEC-027 standalone ZIP/executable selection and produce release export using pinned templates/dependencies/assets. Include required SQLite binaries, content, licenses/credits, version and checksum manifest; exclude debug tools/test assets/internal profiles and any runtime image-generation dependency. Verify saves resolve per user under `user://`, not installation path. Installer/signing remains optional by separate concrete selection, never a v1 requirement; Steam/cloud/storefront integration deferred beyond v1. Deliver installable/runnable candidate and clean-build recipe. References: FR-PLAT-01; FRS §§13–14; TRS §§9.2,16–17; D-27.

**Approved G1 constraints:** Ship only the reviewed/pinned native integration and required assets. GUT/harness infrastructure is development/test tooling, not a reason to import test scenes or SQLite into the shared core; exclude test/debug artifacts from release.

**Approved G6 constraints:** Build approved G6 versioned standalone ZIP/executable package with required data/native libraries/licenses/checksums. Record actual selected architecture and matching binaries; exclude test/debug/runtime generation tools. Installer/signing requires a separately selected concrete addition and is not a release prerequisite; Steam/cloud integration deferred beyond v1.

**Approved C1 constraints:** Package selected Windows x86_64 export and successfully qualified matching native artifacts. Verify exact URLs/full commits/hashes/licenses recorded; no silent alternate engine/templates/architecture.

### M06-T13 — Test clean install, upgrade and offline operation

Dependencies: T12. On clean Windows account/machine with no Godot editor, run normal user launch, farming, save/exit, offline reopen, settings restore, upgrade/migrate existing profile and restore backup. Test installation path read-only/spaces, per-user profiles and distribution removal/update preserving saves under documented policy. Run with network unavailable and no login; native adapter dependency loading must succeed. Deliver packaged smoke and migration results tied to artifact checksum. References: FRS §§2,9,13; TRS §§9,12; T-026–028 packaged coverage.

**Approved G2 constraints:** Fresh-install smoke checks approved 0/Empty start and fixed eight-column layout; save/update/reopen retains each fourth-row prefix and existing planted-cycle ownership.

**Approved G6 constraints:** Exercise extraction/launch on clean normal-user Windows without editor/network/login, read-only/space-containing application paths, upgrade by replacing application files and application-file removal while preserving separate per-user farm/backups. Test absent/mismatched native libraries with clear failure and profile safety; no silent new-save reset.

### M06-T14 — Complete release documentation and recovery UX review

**Applied A1 task constraints:** AUD-DEC-001 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M06-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T10,T13. Document controls, saved-data location, backup/recovery/export procedure where supported, migration compatibility, offline-clock policy, known forward-clock limitation, system requirements and audio/settings behavior. Provide release notes, limitations and asset/addon notices. Use clear recoverable save failure messages rather than silent reset. Disclose target misses, actual/partial M03 probe evidence and separately future production-web scope accurately. Deliver player/support docs and final known-issue list. References: FRS §§9.1,13–16; TRS §§9.3,17–18.

**Approved G1 constraints:** Document approved clock consequences, stale/uncached-retry semantics and true numeric-limit recovery accurately. Retain all ordinary uncapped offline and no-login guarantees; document approved G3 budgets separately from still-pending final pacing and actual artifact/provider/hardware/art evidence; C2 contract data is approved.

**Approved G3 constraints:** Document actual approved authorization/fallback/smart-group/seed-toggle/boost behavior with concrete player examples. Present approved G4 policy accurately; do not claim provider evidence or actual contract implementation from C2 approval alone.

**Approved G4 constraints:** Document approved save/backup intervals and possible older recovery point, completed-minute as-of lag, session/utilization distinction, one-time contract abandonment/reacceptance and profile-owned preferences accurately.

**Approved G6 constraints:** Document exact ZIP contents/version/checksums, extraction/update instructions, packaged dependency/architecture requirements and per-user save/backup/recovery location. Explain application-file replacement/removal preserves the farm; installer/signing/Steam are not included unless separately selected.

**Approved C2 constraints:** Describe actual C2 eligibility, one-cycle quantity, mixed AND, actual automatic origin, any-crop gross targets, independent concurrent progress and manual one-time rewards. Do not present settled catalog as unapproved or design-reference rewards as runtime repricing.

### M06-T15 — Run final release gate and handoff

Dependencies: T02–T14. Rerun affected regression suites after final fixes and clean-export smoke; reconcile evidence map against exact candidate checksum. Required gameplay/integrity failures block readiness. Approved exceptions must name requirement, severity, evidence, rationale, owner and follow-up; absent human target evidence remains pending/limited, never manufactured. Record readiness decision and remaining non-launch future items. Deliver signed-off acceptance dossier and reproducible release candidate for review, without automatically publishing. References: FRS §15; TRS §§16 M06,18.

**Approved G1 constraints:** Trace the release's tested requirements to the synchronized G1 source revision and current decision register; policy approval and empirical test passage are separate records.

**Approved G5 constraints:** Readiness distinguishes confirmed policy, Deferred optional families, named hardware/art approval and actually observed economic/human evidence. Missing human engagement evidence remains insufficient/pending with explicit owner disposition; no automatic waiver, undocumented feature addition or silent target change.

**Approved G6 constraints:** Readiness requires actual standalone packaged launch/update/save-preservation evidence with matching checksum, not a merely selected delivery policy. Approval of G6 is no publication, passing export or inferred installer/store integration.

**Approved C1 constraints:** Record C1 decisions as approved while distinguishing actual artifact/provider/content/hardware/art evidence. Continuation selection is resolved and future measurements remain honest.

## Automated tests and validation procedures

The final run uses frozen scenario manifests and exact build checksums. Use machine-readable results plus named manual evidence. Rerun focused affected checks after changes; do not use unrelated repeated testing as a substitute for closing a known failure.

| Validation ID | Procedure / pass or disposition condition |
|---|---|
| M06-V01 | T-001–008/020/023/024: all formula, snapshot, seed-first, fixed/Smart modes, duplicate and stall assertions exact using final content. Whole-state replay stable. |
| M06-V02 | T-009–012/021: same simulated duration through active/debug/offline yields equivalent production/research/levels/contracts/statistics, with only approved clock/session metadata differences. |
| M06-V03 | T-013–017: time traces and native sleep/hibernate demonstrate no active wall-clock acceleration, no double-credit, normal suspended rate and accepted positive cross-session elapsed policy. |
| M06-V04 | T-018–020/026–028: real crash/fault/process/migration matrix produces whole durable states; claim/crop charges once; unknown/corrupt saves preserved/recoverable. |
| M06-V05 | T-022/025: forecast original state/repository unchanged; period operating vs cash-flow accounting exact; bounded retention maintains totals and documented window accuracy. |
| M06-V06 | T-029: stable 30-day target evaluated against 5 s provisional threshold on named hardware; one-year exact totals and bounded memory/storage. Boundary-heavy scenarios reported separately. |
| M06-V07 | 32 plots at 1×/60×: FPS/frame timings and <3 ms provisional simulation target measured; audio/animation natural. All vendor coverage and scaling results explicitly recorded. |
| M06-V08 | 3–5-hour focused strategy and additional ~48 active-hour human engagement evidence separate. Production-duration estimates never reported as player engagement; misses have recorded disposition. |
| M06-V09 | Required M03 T-030 probe evidence reviewed/rerun after affected changes; actual/partial/fail status explicit, unrun work not passed or automatically P2 deferred. Shared core has no native leaks; full browser release remains future. |
| M06-V10 | Approved G6 ZIP extraction/normal-user offline launch/update and application-file removal preserve separate per-user profiles/backups. Missing/mismatched native dependencies fail clearly without resetting saves; packaged assets/licenses/checksums and release debug exclusion verified. Installer/store tooling is not required. |
| M06-V11 | Each FRS §15 and TRS §18 checkbox links to real evidence or a documented approved exception; required integrity/gameplay failures unresolved means release readiness fails. |
| M06-V12 | Approved G1 regressions: research-before-harvest/serial-input batch order, ceil microsecond duration, safe large intermediate arithmetic, bounded response eviction/retired epochs, first-success crash/backup epoch rotation, accounted real-time ledger and checkpoint-preserving true numeric-limit failures. Required ordinary long-offline cases still succeed. |
| M06-V13 | G3 final evidence: exact/ROI mode guarantees and mixed-mode order; one shared protection cap, farm-only controls, fallback/seed reserve edge cases; one paid boost; explicit lifecycle/eligible-subset persistence; advanced-stage completion and zero unauthorized offline/reopen purchases. |
| M06-V14 | G4 final evidence: exact clock-provider selection/partition, approved real-time save/backup/WAL-FULL policy, preserved recovery generations, aligned statistics/session/utilization, profile-owned settings and approved contract lifecycle. Review M03 T-030 actual/partial status; unrun work cannot become a pass or silent P2 deferral. |
| M06-V15 | G5 evidence: named baseline/OS/driver/build and actual vendor measurements; scoped catalog excludes Deferred additions. Test local five-real-minute indicator below/at/above300s, focus loss and 1×/60× independence; diaries supplement reading/planning. Actual human count/duration/findings establish met/missed/insufficient status; no automated/offline hours are human engagement proof. |
| M06-V16 | C1: actual artifact/commit/hash/license manifest and Windows x86_64 package use selectedGodot 4.7.2/templates/GUT 9.7.1 and qualified sqlite v4.9 candidate with no silent fallback. Exact increasing option B, per-step ceilings, point retention and production long-offline/forecast equivalence have actual evidence; selection approval alone never passes checks. |
| M06-V17 | Audit A1: All AV-001–007 with integrated build/adapter and approved milestone staging, plus AV-008/009 documentation evidence. Include live-process receipt loss as well as restart faults; exact 32-plot and long-offline measurements remain required. Planning/document checks never count as runtime or human evidence. |

## Acceptance criteria and definition of done

- All implemented source tests have final evidence tied to the release candidate. T-030 M03 probe has actual/partial/failure evidence and explicit findings; no unrun assertion is labeled passed.
- Deterministic core, uncapped valid offline progression, shared-budget safety, immutable snapshots, contract claims, statistical accounting and copy-isolated forecasts are correct.
- Crash recovery, one-writer policy, backups/migrations and clock reconciliation pass on actual Windows integration; no silent save success/reset or duplicate economic effect.
- 60 FPS and provisional engineering targets measured on defined hardware; any miss has documented approved disposition. One-year correctness/boundedness demonstrated without false 5-second claim.
- Pacing and engagement conclusions match actual evidence. Required gameplay decisions closed; no out-of-scope feature was added to compensate for content gaps.
- Production Windows package launches without editor/network/login, includes native dependencies/assets/licenses, excludes debug controls and preserves saves across documented update/recovery paths.
- Release candidate is ready for release consideration. Publishing/distribution to users remains a separate authorized action.

## Expected deliverables

Future outputs: frozen qualification/scenario manifests; completed requirement/test evidence map; regression/crash/time/migration/performance reports; GPU/audio/visual records; normal-speed and human engagement findings; web portability audit/M03 probe evidence review; versioned standalone Windows ZIP/executable/checksums; any installer only by separate selection; save/recovery/user/release documentation; final readiness/known-limitations decision. Current output is this plan only.

## Audit A1 task and validation corrections

These are required constraints on existing tasks, with their original dependency order retained. Source contracts: TRS §§20.1–20.7 (AUD-R-001–007), FRS FR-AUD-001–007; exact test oracles are TRS §15.1 AV-001–009. Historical approval notes describe their original scope; the explicitly applied A1 additions define the current selected clarification. No test is marked passed by this document update.

| Issue / selected decision | Existing task / validation target | Required correction | Exact acceptance extension |
|---|---|---|---|
| AUD-001 / AUD-DEC-001 B | T04/T14; V04/V12 | Qualify full identity/recovery scope and disclose older generations accurately. | AV-001; T-018–020/026/027; M06-V17 |
| AUD-002 / AUD-DEC-002 B | T04; V04/V12/V14 | Test receipt loss with process alive, not only restart recovery, on the exact adapter/build. | AV-002-01–05; preserve candidate-specific evidence; M06-V17 |
| AUD-003 / AUD-DEC-003 B | T03/T04/T09; V01/V04/V16 | Qualify declared supported content/migration matrix; do not claim absent mappings passed. | AV-003; actual supported migration corpus later; M06-V17 |
| AUD-004 / AUD-DEC-004 B | T03/T08; V12/V13 | Qualify queued input/boost/reset/override cases with current durable state. | AV-004; replay and consent evidence; M06-V17 |
| AUD-005 / AUD-DEC-005 A | T03/T06; V01/V13 | Qualify cascade correctness and bounded seed/fixed work without hiding optimizer time. | AV-005; 32-plot measured regression later; M06-V17 |
| AUD-006 / AUD-DEC-006 A | T03/T09; V01/V08 | Re-evaluate upgrade-using pacing without treating guard selection as balance validation. | AV-006; normal-speed human/strategy evidence later; M06-V17 |
| AUD-007 / AUD-DEC-007 B | T03/T04/T08; V04/V13 | Qualify indirect configuration consent, graph crash safety and no locked-plot bypass. | AV-007; actual integrated evidence later; M06-V17 |
| AUD-008 / AUD-DEC-008 A | T02 L75 | Replace obsolete beyond-30 selection gate with required optionB evidence. | AV-008-01/02; M06-V17 |

**Additional exit condition:** complete the task-level A1 obligations above and M06-V17 at the stage owned by this milestone. Later-runtime cases may be specified with fakes now only where the staging explicitly permits it; they remain required for their real integration milestone. No new mandatory gameplay family, final balance value or earlier native/UI implementation follows from A1.
