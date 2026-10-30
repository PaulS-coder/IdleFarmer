# Idle Farmer — Technical Architecture & Pre-Development Specification

> **Audit corrections A1 — 2026-10-28:** Approved audit resolutions are incorporated in §§3–6/9/12/13/15 and normative §20. [Audit Decision Register](../decisions/Audit_Decision_Register.md) and [correction changelog](../audit/round_01/Audit_Correction_Changelog.md) record approval/application. Existing provisional tuning and original Open/Deferred evidence obligations are unchanged. No game implementation or runtime pass is claimed.

> **Approved closeout C3 — 2026-10-28:** Owner: “DEC-023 - agreed with option A.” **Clean illustrated** is the selected visual direction: crisp silhouettes, restrained outlines, simple smooth shading and natural greens/browns/golden Wheat, guided by column A of the [planning comparison](../decisions/visuals/Art_Direction_Comparison_v1.png). Style selection is settled; M04 specifies and validates the production art bible/sample pipeline, M05 audits catalog consistency and M06 qualifies actual assets/audio/performance. The comparison is not a production sprite set or a change to the approved eight-column farm geometry. No game implementation or empirical pass is implied.

**Document ID:** IF-TRS  
**Version:** 1.5 (consolidated pre-development baseline)  
**Approved clarification revision:** A1 — 2026-10-28 (cumulative G1–G6 + C1–C3, H1–H2 and applied audit corrections; filename/version family retained; see §§19–20)  
**Status:** Candidate development baseline; remaining dependencies and thresholds identified  
**Engine / language:** Godot 4.x / **GDScript**  
**Required release:** Windows 11  
**Future option:** Browser/web export  
**Companion document:** `IdleFarmer_Functional_v1.0.md`

> **Source-of-truth note:** This is a standalone, consolidated technical specification incorporating the confirmed **offline-first** time policy (v1.2), **Godot + GDScript and web-portability** direction (v1.3), GDScript module contracts (v1.4), and pre-development consistency/acceptance review (v1.5). See the functional file for gameplay/content definitions. Suggestions and not-yet-benchmarked targets are labeled *provisional*.

> **Group 1 approval:** The project owner confirmed “Approve Group 1” on 2026-10-26. DEC-005, DEC-006, DEC-013, DEC-016 and DEC-026 are approved; DEC-001's toolchain direction/candidate evaluation was approved at G1; C1 now selects version names/target while artifact verification remains open. The [Decision Register](../decisions/Decision_Register.md) records the scope. At this historical G1 approval, later choices remained open/proposed. Subsequent G2–G4 confirmations below resolve their stated policy scopes; actual artifact/provider/hardware/art verification and empirical evidence remain pending; C1–C2 settle named versions and authored content. No implementation or test execution is implied. **Historical scope:** reservations in this dated approval describe that revision; current C1–C3/A1 rules and original remaining evidence obligations govern.

> **Group 2 approval/amendment:** On 2026-10-27 the project owner confirmed the rest of Group 2 and amended DEC-020 to an initial **8×3** farm with sequential fourth-row unlocking. DEC-003 initial state, DEC-004 point/prerequisite policy and DEC-020's amended geometry/order are approved; DEC-002's complete through-30 curve is approved as provisional development data only. Beyond-30 behavior, exact dependency pins and other unconfirmed decisions remain open/proposed. No game implementation is authorized. **Historical scope:** reservations in this dated approval describe that revision; current C1–C3/A1 rules and original remaining evidence obligations govern.

> **Group 3 approval:** Project owner: “Approve Group 3” (2026-10-27). DEC-007/009/010/011/012/025 now govern one-boost research, shared farm budgets/inheritance exception, exact/ROI optimization, capability gates, lifecycle/batches and milestone staging. Defaults/coefficients remain provisional for balance; actual benchmarks are unverified. At G3, the later Group 4 choices remained unapproved; its explicit confirmation below now resolves their stated scope.

> **Group 4 approval:** Project owner: “Group4 approved as recommended” (2026-10-27). DEC-015/017/018/021/022 are Approved. DEC-014's measurement-first policy is Approved; exact provider/API/evidence remains Open. DEC-019's authored one-time lifecycle/schema and provisional level-7/three-slot defaults are Approved; at G4 exact authored content was Proposed; C2 now approves its twelve definitions/predicates/rewards. The following contracts are synchronized planning requirements, not executed tests or an implemented schema.

> **Group 5 approval:** Project owner: “group 5 aapproved as recommended” (2026-10-27). DEC-024 evidence policy is Approved; DEC-008's three optional additions are Deferred with the post-playtest scoped-proposal trigger. DEC-023 qualification/sample-review policy is Approved while named hardware, art/assets and final tuning remain Open. No unseen asset, baseline machine, balance change, installed dependency or empirical result is approved by this clarification.

> **Group 6 approval:** Project owner: “Group 6 approved as recommended” (2026-10-27). DEC-027 initial delivery is a versioned standalone Windows ZIP/executable package; installer/signing optional by separate selection, Steam/cloud/storefront integration deferred beyond v1. Per-user save/update/removal safety and packaged native-dependency qualification are mandatory. No artifact, architecture, exact unreviewed binary or publication result is inferred.

> **Approved closeout C1:** Project owner: “DEC-001 - approved, DEC-002 - use option B” (2026-10-27). Godot 4.7.2-stable/editor+standard templates, GUT v9.7.1, godot-sqlite v4.9 evaluation (reported SQLite 3.51.0), Compatibility and initial Windows x86_64 are selected. Actual artifact identities/fingerprints/license inventory and integration remain pending. Increasing post-30 XP option B is approved provisional development data; through-30 anchors remain unchanged. This is documentation synchronization, not installed dependencies or executed tests.

> **Approved closeout C2:** Owner: “Closeout B option A - approved” (synchronized 2026-10-28). DEC-019 exact twelve-offer catalog and predicates are approved provisional development content, canonical in FRS §§10.2–10.4. Implement all four families with existing atomic/manual/offline/one-time lifecycle; do not generate or reprice offers dynamically. Actual predicate/recovery/balance evidence is future work, not produced by this clarification.

## 1. Architectural objectives and constraints

The game shall implement the entire farming simulation independently of the scene tree and rendering frame rate. It must be possible to use the same simulation for:

1. Normal Windows gameplay at 1×.
2. Debug-speed gameplay from 1× through 60×.
3. Offline catch-up when reopening the game.
4. Headless economy and progression tests.
5. A future web port with platform-specific persistence and lifecycle adapters.

**Core invariants:** One authoritative state; deterministic event processing; integer currency/XP and fixed-point economic modifiers; no negative coin balances; atomic purchasing/reward transitions; no duplicate harvests or contract payouts; persistent state and time anchor committed consistently; graphics/audio are non-authoritative consumers of simulation events.

| ID | Design rule |
|---|---|
| ARCH-001 | Core gameplay depends on **GDScript data/services**, not scenes, camera nodes, audio players, or rendering. |
| ARCH-002 | Use typed GDScript where practical; `RefCounted` for runtime state/service classes, `Resource` for validated content definitions, `Node` only for presentation/lifecycle. |
| ARCH-003 | Core modules communicate through explicit commands, results, and events, not hidden mutations from UI handlers. |
| ARCH-004 | Storage and timing calls go through platform adapters; core gameplay never directly calls native Windows SQLite interfaces. |
| ARCH-005 | Game data and balance tables are versioned so tuning crops, skills and costs does not require changing engine algorithms. |
| ARCH-006 | Simulations and forecasts must run in headless mode without graphics or audio initialization. |
| ARCH-007 | The initial implementation should stay single-threaded and deterministic unless benchmarks show a need for further concurrency. |

### 1.1 Selected and open platform technology

| Area | Selected / recommended | Status |
|---|---|---|
| Engine | Standard non-.NET **Godot 4.7.2-stable**, matching **standard 4.7.2-stable export templates**, initial **Windows x86_64** | DEC-001/C1 named versions/target approved; actual artifact/commit/fingerprint verification pending |
| Language | **GDScript**, not C# | Confirmed |
| Visuals | Isometric layered 2D sprites/2.5D effects, Godot Compatibility renderer as initial baseline | DEC-001 renderer baseline approved; art direction/hardware qualification pending |
| Windows renderer | GPU accelerated; target compatible NVIDIA/AMD/Intel devices | Confirmed requirement |
| Future browser | Godot web export with compatibility-oriented assets; browser-specific storage adapter | Architecture target, **not** v1 release deliverable |
| Windows saves | Evaluate **2shady4u/godot-sqlite v4.9**, reported bundled **SQLite 3.51.0**, behind repository; verify Windows x86_64/native match, WAL/FULL, backup, licenses and packaged errors | DEC-001/C1 evaluation version approved, not an unverified native artifact; actual fingerprint/adoption/integration evidence pending; DEC-015 policy binding |
| Web saves | Versioned serialized snapshots through Godot/browser-backed `user://` storage, with export/import and recovery slots | Future design proposal |
| Automated tests | **GUT v9.7.1** plus project-owned headless scenario harnesses and fake time/storage | DEC-001/C1 version approved; tagged artifact/hash, parse/failure-exit and harness evidence pending |

A future browser export should not require C#, a Windows-only extension, or SQLite in core gameplay. WebGL/browser limitations and persistence behavior must be tested by the approved end-M03 minimal compatibility prototype (DEC-022); production browser durability remains future work. Required Windows release should not be blocked on a complete web version.

**C1 artifact/compatibility boundary:** use the named released versions/initial x86_64 target above. GUT v9.7.1's tagged compatibility table identifies Godot 4.7.x; godot-sqlite v4.9 reports build against Godot 4.7.1/SQLite 3.51.0, so actual4.7.2/native/WAL/backup behavior still needs verification. Record exact artifact URLs, full commit identities, SHA-256 values, publisher-manifest checks where available and complete license inventory before adoption. No fallback to older versions/other native targets is implicit. Official references and observations are retained in DEC-001's C1 review record; no archive was installed/hashed by this documentation update.

Pin released editor/templates/test dependencies rather than automatically tracking latest branches. A test runner may own a harness SceneTree, but gameplay classes remain RefCounted/data services and must not import presentation or native storage. Candidate SQLite adoption requires the compatibility/license/durability/export checks; approval of its evaluation is not approval of an unverified binary. No download, installation, exact dependency version or complete browser port is authorized by Group 1.

## 2. Logical components and ownership

| Component | Owns | May call / publish |
|---|---|---|
| `GameController` | Startup/shutdown, command orchestration, save lifecycle | Simulation, Repository, TimeProvider, presentation notifications |
| `GameState` | All authoritative runtime gameplay fields | Serialization and validation; no scene references |
| `SimulationEngine` | Command validation/execution and advancing scheduled events | Systems below, EventScheduler, GameState |
| `SimulationClock` | Simulation microsecond time and debug rate | TimeProvider, SimulationEngine |
| `TimeProvider` | Wall UTC and monotonic observations | Platform APIs through adapter |
| `EventScheduler` | Ordered future event queue | SimulationEngine |
| `FarmSystem` | Plot/plant/harvest state transitions | Economy, Progression, Contracts, Stats |
| `EconomySystem` | Coin/XP calculations and transaction results | Farm, Automation, SaveManager |
| `AutomationSystem` | Auto-harvest/replant and spending policies | Farm, FertilizerOptimizer, Economy |
| `FertilizerOptimizer` | Feasible fertilizer allocation proposals | Automation, content definitions |
| `ProgressionSystem` | Levels, skills, points, resets | GameState |
| `ResearchSystem` | Research states and scheduled completion | GameState, EventScheduler |
| `ContractSystem` | Accepted objectives, progress, manual claims | Committed harvest events |
| `StatisticsSystem` | Counters, time buckets, forecasts, reports | Transaction/event results, cloned GameState |
| `ContentRegistry` | Versioned crop/skill/research/upgrade definitions | Validation, all gameplay services |
| `SaveManager` / `SaveRepository` | Durable checkpoints, migration, backup, recovery | Storage adapters |
| Presentation scenes | Isometric graphics, UI and input | Read snapshots, submit commands |
| `AudioManager` | Music and aggregated effect playback | Presentation-only events |

One central controller owns ordering and data flow; avoid direct cross-service mutation that bypasses the SimulationEngine. The division above is logical; the final number of scripts may be smaller when clear module boundaries are retained.

## 3. Authoritative state model

### 3.1 Root `GameState`

| Field | Logical type | Semantics |
|---|---|---|
| `save_id` | String / stable UUID | Unique save profile |
| `schema_version` | int | Format migration |
| `content_version` | String | Immutable supported profile manifest binding, including complete progression/skill definitions (§20.3) |
| `state_sequence` | int64 | Increasing in-memory simulation revision; distinct from the last durable commit revision |
| `durable_revision` / `last_commit_id` | int64 / dynamic identity | Last validated controller checkpoint identity and durable revision, separate from gameplay entity allocation; each prepared commit also carries expected parent durable revision (§20.2) |
| `simulation_time_us` | int64 | Simulated timestamp (not persisted wall time) |
| `player` | PlayerState | Level, cumulative XP, coins, skill points/ranks |
| `plots` | ordered collection of PlotState | All **32** logical plots, IDs 1–32 |
| `upgrades` | UpgradeState | Purchased permanent ranks |
| `research` | ResearchState | Active/completed projects and timing |
| `contracts` | ContractState collection | Accepted and offered objectives; claim state |
| `automation` | AutomationConfiguration | Farm defaults, plot groups, reserves |
| `statistics` | StatisticsState | Simulation-time buckets, separate live/lifetime totals and real/UTC segment metadata (DEC-017/018) |
| `settings` | GameSettings | Profile-owned versioned preferences; restored before audio, debug speed excluded (DEC-021) |
| `time_anchor` | TimeAnchor | Credited-through UTC, bounded accounted-interval/reconciliation metadata and diagnostics (DEC-013) |
| `command_replay` | CommandReplayState | Current persisted writer epoch, committed success high-water and bounded response metadata (DEC-016) |
| `allocation_namespace` | injected UUID | Fresh owned-startup writer UUID used for new dynamic IDs; existing references retain their original namespace |
| `next_entity_id` | checked int64 | Retained-history numeric allocation/order counter, checkpointed and not reset merely because the namespace changes |
| `pending_events` | events or reconstructible metadata | Same ordering after restore |

All authoritative objects support **validation and deep copy**. Copies used in forecasts/test runs must not share mutable nested containers with live state. Do not persist scene `Node`, audio instances, GPU objects, or live references to mutable `Resource` instances. Store stable IDs and plain primitives.

**Approved new-game baseline (DEC-003/G2):** level 1, cumulative XP/coins/available and allocated skill points all zero; no purchased upgrades, active contracts, running research or completed post-start projects. Wheat is the only start unlock and needs no separate research purchase. All 32 plot records exist; IDs 1–24 are unlocked and Empty in the first three rows of the fixed eight-column map, IDs 25–32 are Locked in row 4. Do not preplant or automatically select a paid crop.

**AUD-R-001 identity integration:** newly allocated cycle/event/transaction/contract-instance/claim/group identities are `(save_id, allocation_namespace, checked_counter)`. Keep plot IDs 1–32 and authored content/offer IDs unchanged. Store components losslessly as plain primitives; compare scheduler identity ordering using the existing numeric allocation order, never UUID lexical order. Generate the fresh UUID outside the core before tentative startup catch-up allocations; persist it with the validated startup outcome before active input. During UNKNOWN retain the pending identity context. See §20.1.

### 3.2 `PlayerState`

`player_id`, `level`, `total_xp`, `coins`, `available_skill_points`, and allocated ranks/nodes. Use signed 64-bit integer-compatible values and check overflows; never permit negative coins, XP, counts, or skill points.

DEC-026 requires representable valid results to be honored without arbitrary caps. A genuinely unrepresentable result leaves the previous complete checkpoint/anchor intact and produces a recoverable error, never wrapped or saturated state. See §4.4 for safe intermediate arithmetic.

**Approved progression data/policy (DEC-002/004/G2):** read the complete level 1–30 cumulative XP table from FRS §5.1, preserving all supplied anchors and the approved integer-linear interpolated entries. The table remains provisional for balancing; do not substitute a new curve while implementing the lookup. Each gained level grants one point; each growth/profit rank and each automation node costs one point, so unspent points plus allocated rank/node points equal levels gained for a valid configured state. Exact prerequisite edges are FRS §§5.2–5.4 (preceding growth/profit tier rank ≥1; immediate-predecessor automation chain and listed level gates). C1 now approves DEC-002 option B: T(30)=520,000, I(31)=57,500, I(L)=ceil(I(L−1)×110/100) for L≥32 and T(L)=T(L−1)+I(L). Use FRS §5.1.1 exact provisional vectors, preserving one point per gained level and surplus unused points. No constant-increment tail, arbitrary cap or discarded XP is allowed; final balance remains separately reviewable.

**AUD-R-003 manifest integration:** validate level/XP and level−1=unspent+allocated using the profile’s complete immutable supported manifest, not global latest data. Keep curve, point costs, rank maxima, prerequisite/level guards, quotes, offline runs and forecasts in the same context. Schema migration preserves that binding; an incompatible content migration needs its own separately approved mapping. Missing/unsupported definitions fail recoverably without overwrite. See §20.3.

### 3.3 `PlotState`

- `plot_id` stable integer 1–32.
- `unlocked` boolean (1–24 unlocked at new game; IDs 25–32 unlock in strict ascending order across row 4).
- `crop_cycle` nullable current planted cycle.
- `selected_crop_id` configuration for next planting.
- `auto_harvest`, `auto_replant` (effective only if relevant skills unlocked).
- Nullable `group_id` references at most one existing group; group/settings revisions support effective-plan diffs and atomic structural commands (§20.7). Inheritable `spending_priority` and fertilizer/accepted-fallback configuration. Default priorities are equal; plot ID breaks seed/equivalent-choice ties.
- `automation_authorization`: valid recurring purchase-plan identity/revision and armed/inactive loop state, sufficient to distinguish a previously authorized Stalled loop from a newly Empty plot that has never been started (DEC-025).
- `blocked_reason` enum (none, lacking seeds, policy restriction, missing unlock, etc.).

A locked plot has no active crop. Unlocked plots contain **zero or one** active cycle. Visual stage is derived and is not an independent authority.

**Approved geometry/order (DEC-020/G2; FR-FARM-01/02/08):** use a fixed eight-column row-major ID map from new game through full expansion:

| Logical row (1-based) | Columns 1–8 / plot IDs | New-game unlock state |
|---|---|---|
| 1 | 1–8 | Unlocked / Empty |
| 2 | 9–16 | Unlocked / Empty |
| 3 | 17–24 | Unlocked / Empty |
| 4 | 25–32 | Locked |

Row is 1 plus the integer quotient of `(plot_id−1)/8`; column is 1 plus its remainder. Width never changes and purchasing never renumbers/moves a plot. For N unlocked plots, 24≤N≤32, the unlocked set must be exactly IDs 1..N; every higher ID remains Locked. Only ID N+1 is purchasable (if N<32), with its existing minimum-level and coin cost as additional guards. Reject out-of-order/duplicate/unaffordable purchases before any charge, unlock, ID allocation or other partial gameplay mutation. No command silently skips/fills locked gaps. This prefix invariant applies only to unlock state: arbitrary Empty/Growing/Ready combinations among unlocked plots remain valid. Expansion order does not choose automated seed/fertilizer spending priorities; those remain separate budget decisions.

### 3.4 `CropDefinition` and `CropCycle`

**Definition (versioned content):** ID, name, class, level, research gate, seed cost, base duration, base coins, base XP, art references and animation metadata.

**Planted cycle (persistent runtime):**

- `cycle_id`, `plot_id`, `crop_id`, `status` (Growing, ReadyForHarvest, Harvested terminal).
- `planted_at_sim_us`, `matures_at_sim_us`, `effective_growth_us`.
- `seed_cost_paid`, `fertilizer_id`, `fertilizer_cost_paid`.
- `gross_coin_reward`, `xp_reward`, `applied_modifier_snapshot`, `content_version`.

At planting, record immutable economics and maturity. Later upgrade purchases/skill resets may change **future** cycles only. Store harvest transaction identity as needed to prevent replayed claims.

### 3.5 Other logical data records

- `SkillState`: skill IDs, current ranks, prerequisites; one point per gained level and one point per rank/node under approved DEC-004. Validate FRS minimum-rank prerequisite edges and level gates; full prior-tier ranking is not required.
- `UpgradeState`: permanent upgrade IDs/ranks. Required Irrigation/Improved Soil guards are coins plus immediately preceding family rank only (rank I needs none), minimum level 1, no additional research/skill/contract gate; manual next-rank purchases affect future cycles only (§20.6). DEC-008/G5 excludes Seed Efficiency/Research Facilities/Growth Booster from saleable v1 definitions/commands; keep the versioned content model extensible without executable placeholders.
- `ResearchState`: project ID, status, snapshotted research cost actually paid/original timing, scheduled completion or remaining duration, permanent unlocks and `boost_used` (initially false). Approved DEC-007 allows one active project and one manual half-cost/half-remaining boost; reloading never resets it.
- `AutomationConfiguration`: inheritable farm/group/plot crop, auto actions, fixed/Smart fertilizer policy, accepted fallback and eligible priorities; explicit unset differs from false/zero. Approved DEC-010 excludes wallet controls from these overrides.
- `FarmBudgetConfiguration`: one farm-wide nonnegative reserve, 0–100% Budget Protection percentage and optional automated-seed protection toggle. Approved initial defaults: 0 coins, 25%, Off. Controls require the corresponding skills (DEC-011).
- `AutomationAuthorization`: accepted recurring purchase-plan identity/revision, armed/inactive state and any retained inactive configuration needed for explicit start/rearm and safe restart; `RotationState` holds approved entries/cursor. These are logical typed records, not implemented schema/code.
- `ContractState`: stable authored offer ID/version, unique acceptance instance/claim ID, acceptance timestamp/sequence, snapshotted objective/reward, progress and accepted/completed/claimed/abandoned state. Preserve one-time claimed-offer eligibility across reacceptance and intact-primary recovery; older-backup recovery restores flags and their paired credit together within the recovered authoritative timeline (§20.1); C2 now approves the exact catalog and guards in FRS §§10.2–10.4; actual implementation evidence remains pending.
- `EconomicTransaction`: immutable transaction ID, timestamp, type, related IDs, coin/XP deltas, expense category, crop cycle.
- `StatisticsAggregate`: simulation bucket start/end, crop/plot IDs, gross/expenses/XP/counts/cash-flow categories, disjoint state-time and integrated unlocked capacity. `AccountingSegment` records real/UTC/offline/debug correspondence; `SessionStatistics` starts after startup catch-up and is distinct from historical offline totals.
- `GameSettings`: profile-owned versioned sound enable/volumes and existing supported display/input preferences; defaults only for genuinely new profiles or validated migrations. Exclude debug speed; reset it to 1× every launch. Restore before audio. Immediate cosmetic draft changes with an unsaved indication never advance economic state on write failure.
- `SimulationCheckpoint`: unique commit ID, expected parent durable revision for a prepared result, resulting durable revision, in-memory state revision, immutable manifest reference, authoritative state, credited-through UTC, identity/replay/interval metadata and diagnostics. Repository result is COMMITTED / NOT_COMMITTED / UNKNOWN (§20.2).
- `CommandReplayState` (DEC-016): current UUID writer epoch, highest committed successful in-epoch command counter, bounded cached responses; no unlimited processed-key journal.
- `AccountedInterval` / reconciliation metadata (DEC-013): active/suspended/offline classification, real elapsed already credited, corresponding simulation advancement and provider diagnostics. Compact intervals already represented by the checkpoint/high-water; retain only the metadata needed to reconcile unaccounted observations, rather than an unlimited raw clock history.

## 4. Commands and event contracts

### 4.1 Command envelope

A raw UI intent carries target/confirmation terms and a stable pending-delivery identity; it is not an accepted replay command and supplies no authoritative past timestamp. After due work, the controller validates/stamps an immutable typed accepted command with `command_id`, `type`, accepted simulation time/order (the legacy `requested_sim_time_us` field, if retained, contains this accepted time), and typed arguments. See §20.4. Examples:

**Approved identity/time envelope (DEC-006/016):** command identity is `(save_id, writer_epoch_uuid, in_epoch_counter)`. Generate the fresh writer UUID outside the core and inject fixed tokens in deterministic fixtures; persist it during owned-profile startup before accepting commands. On restart, crash recovery or backup restoration, retire earlier epochs and establish a fresh current epoch. The controller serializes input and records its accepted sequence/current simulation time. Strictly reject malformed, stale or future **accepted** envelopes; do not backdate raw input or restamp recorded commands. Replay advances to the recorded accepted time. Semantic confirmations bind target, content, costs/modifier results and plan; unrelated changes are ignored only when authorized terms remain unchanged (§20.4).

`PlantCrop`, `HarvestCrop`, `PurchasePlot`, `PurchaseUpgrade`, `StartResearch`, `AccelerateResearch`, `AllocateSkill`, `ResetSkills`, `ConfigureAutomation`, `ConfigureFertilizer`, `ConfigureBudget`, `SetSpendingPriority`, `AcceptContract`, `ClaimContract`, `AbandonContract`, `BatchPlant`, `BatchHarvest`, `ApplyAndStart`, `SavePreset`, `ApplyPreset`, `DeletePreset`, `ConfigureRotation`, `CreateGroup`, `RenameGroup`, `EditGroup`, `AssignPlotGroup`, `UnassignPlotGroup`, `DeleteGroup` (explicit destination/reference checks under §20.7).

Commands return structured `CommandResult` with `success`, failure code, affected entity IDs, generated authoritative events/transactions, and resulting state revision. Typical failures: `INSUFFICIENT_COINS`, `PLOT_LOCKED`, `PLOT_UNLOCK_ORDER_REQUIRED`, `PLOT_OCCUPIED`, `CROP_NOT_READY`, `LEVEL_REQUIRED`, `RESEARCH_REQUIRED`, `SKILL_NOT_UNLOCKED`, `INVALID_CONFIGURATION`, `DUPLICATE_COMMAND`, `STALE_COMMAND`, `INVALID_COMMAND_TIME`, `PERSISTENCE_UNAVAILABLE`.

**M01 implementation note — 2026-10-30 (non-normative):**

- **Additional failure codes in use:** `UNKNOWN_PLOT`, `UNKNOWN_CROP`, `NO_CYCLE`, `CYCLE_MISMATCH`, `MALFORMED_ENVELOPE`, `STALE_TERMS` and `NUMERIC_LIMIT`. `INVALID_CONFIGURATION` and `SKILL_NOT_UNLOCKED` are reserved for M02 commands.
- **Check precedence (the first failure is reported):** `MALFORMED_ENVELOPE` → `INVALID_COMMAND_TIME` → `STALE_COMMAND` → `DUPLICATE_COMMAND` → `PERSISTENCE_UNAVAILABLE` → `UNKNOWN_PLOT` / `UNKNOWN_CROP` → `PLOT_LOCKED` → `PLOT_OCCUPIED` / `NO_CYCLE` / `CYCLE_MISMATCH` / `CROP_NOT_READY` → `LEVEL_REQUIRED` / `RESEARCH_REQUIRED` → `STALE_TERMS` → `INSUFFICIENT_COINS` → `NUMERIC_LIMIT`.

This lists the implemented set (M01 build plan P11) so later commands stay consistent; it adds no gameplay rule.

**M02 implementation note — 2026-10-30 (non-normative):**

- **Failure codes added in M02:** `FEATURE_UNAVAILABLE`, `UNKNOWN_FERTILIZER`, `UNKNOWN_SKILL`, `UNKNOWN_UPGRADE`, `UNKNOWN_RESEARCH`, `PLOTS_FULL`, `SKILL_MAX_RANK`, `UPGRADE_MAX_RANK`, `UPGRADE_PREDECESSOR_REQUIRED`, `RESEARCH_ACTIVE`, `RESEARCH_DONE`, `NO_ACTIVE_RESEARCH`, `BOOST_USED`, `NO_TIME_SAVED`, `NOTHING_TO_RESET`, `SKILL_PREREQUISITE_REQUIRED` and `INSUFFICIENT_POINTS`. `INVALID_CONFIGURATION` and `SKILL_NOT_UNLOCKED` are now in use.
- **Check precedence (the first failure is reported):** envelope and replay (`MALFORMED_ENVELOPE` → `INVALID_COMMAND_TIME` → `STALE_COMMAND` → `DUPLICATE_COMMAND` → `PERSISTENCE_UNAVAILABLE`) → `FEATURE_UNAVAILABLE` → unknown targets (`UNKNOWN_PLOT` / `UNKNOWN_CROP` / `UNKNOWN_FERTILIZER` / `UNKNOWN_SKILL` / `UNKNOWN_UPGRADE` / `UNKNOWN_RESEARCH`) → target state (plot, cycle, rank, research and reset states, `INVALID_CONFIGURATION`) → gates (`LEVEL_REQUIRED` / `RESEARCH_REQUIRED` / `SKILL_PREREQUISITE_REQUIRED` / `SKILL_NOT_UNLOCKED` / `INSUFFICIENT_POINTS`) → `STALE_TERMS` → `INSUFFICIENT_COINS` → `NUMERIC_LIMIT`. The full ordered list is `FailureCode.PRECEDENCE` in `core/simulation/failure_code.gd`.
- **Batch commands** check the skill capability for the whole envelope before any per-member check, then report a typed outcome per member (DEC-025).

This records the implemented set (M02 build plan §3.3); it adds no gameplay rule.

**Rule:** Scheduled events due at the command's simulation timestamp are processed **before** an input command at that timestamp. Rejected commands produce no authoritative partial changes. Idempotency keys prevent duplicate economic effects if the same command is retried.

**Approved manual batch contract (DEC-025):** prevalidate the command envelope/capabilities, then report typed per-plot outcomes. Ineligible members are skipped without partial manual charge/state mutation; authorized eligible members execute in stable order and their accepted subset commits as one coherent outcome. Each accepted planting remains all-or-nothing. All successful BatchHarvest credits precede that command's replant costs. A wholly rejected/all-invalid command changes no gameplay state measured after independently due work. A definitely NOT_COMMITTED candidate is not published. UNKNOWN is not rejection/rollback: stop and reconcile under §20.2; never overwrite a possibly committed primary from stale memory. Partial selection is not partial persistence or permission to bypass a Locked plot.

**Approved replay protocol (DEC-016):** for the current epoch, a command counter at/below the durable successful-command high-water cannot execute again; a greater counter is validated normally. Commit a successful outcome and its new high-water atomically. A rejection changes no authoritative gameplay state/counters; a subsequent higher successful counter permanently retires earlier gaps. Counter issuance belongs to controller input metadata, not a rejected gameplay mutation. Old-epoch commands are stale: return a cached status if available or a structured stale/duplicate result, never re-execute them. The result cache is bounded; eviction never restores execution eligibility. A crash before the first success must not allow ID reuse in the next epoch.

Cycle/entity/transaction identities must not be reused for new outcomes, and harvest must reference a currently active unconsumed cycle. A contract claim must reference a currently accepted, completed, unclaimed instance; unknown/closed IDs are rejected rather than recreated from command payloads. DEC-019/G4 now defines lifecycle/schema in §5; C2 now approves exact authored objectives/quantities/rewards in FRS §10; no actual claim tests have run. Profile ownership covers this protocol; no concurrent command writer is allowed.

### 4.2 Scheduler and event ordering

Use a deterministic priority queue or equivalent ordered scheduler. Event sort tuple:

`(simulation_timestamp_us, event_phase, configured_priority, numeric_entity_order, insertion_sequence)`.

`numeric_entity_order` is the prior `entity_id` tie-break’s retained-history numeric allocation/plot order, not the composite dynamic identity’s UUID/string ordering. Full identities still guard references; preserve numeric/insertion order during serialization/reconstruction (§20.1).

Initial event types: CropMatured, AutomaticHarvest, AutomaticReplant, ResearchCompleted, AutomationRetry, StatisticsBoundary (periodic aggregation can alternatively be derived at events). **Gameplay events are authoritative; presentation notifications are not.**

**Approved due-event phases at one simulated timestamp (DEC-006):**

1. Complete due research projects; do not start new projects or assign crops.
2. Find mature crops and complete eligible automatic harvests.
3. Credit coins and XP exactly once for each crop cycle.
4. Apply level increases, accepted-contract progress, and accounting totals.
5. Collect eligible replant and relevant coalesced retry requests.
6. Allocate mandatory seed funds in stable plot priority.
7. Optimize/allocate *optional* fertilizer spending from remaining permitted budget.
8. Atomically apply the coherent outcome, create planted cycles and schedule future maturity; persist through the repository boundary before exposure.
9. Publish coalesced UI/audio notifications *after* durable state application.

After the due batch is complete, execute manual commands in recorded controller acceptance order, each as a separate logical batch. A BatchHarvest command credits all its selected successful harvests before its own replant expenditures; a later command cannot be retroactively pooled with an automatic batch already processed at the same timestamp. Manual harvesting uses the **same** harvest transition. Approved DEC-025 applies enabled/authorized Auto Replant after either manual or automatic success, under the same automatic reserve/seed/fertilizer rules. Coalesce immediate retries and stop when no state progress occurs; do not spin forever at one timestamp. Preserve phase/priority/entity/insertion order across restore and platforms.

### 4.3 Crop state machine and invariants

| Transition | Preconditions | Effects |
|---|---|---|
| Locked → Empty | Requested plot is exactly N+1, all preceding IDs unlocked, minimum level and coin cost satisfied | Atomically pay that plot's expansion cost and extend unlocked prefix; fixed coordinates and existing cycles unchanged; no automatic planting |
| Empty → Growing | Unlocked, eligible crop, sufficient funds, valid consumable authorization | Charge seed/fertilizer, snapshot modifiers, create unique cycle and maturity event |
| Growing → ReadyForHarvest | Simulation time ≥ maturity timestamp | Mark mature, publish at most one ready notification (subject to batching), **no reward yet** |
| ReadyForHarvest → Harvested → Empty | Manual command or valid auto-harvest; cycle not previously harvested | Credit snapshotted coins/XP, contracts, stats; terminate cycle; optionally queue replant |
| Empty → Stalled | Auto-replant configured but cannot pay mandatory seeds | Retain selected crop and rules; no charge; retry upon relevant balance change |

Mature crops never spoil, and no extra coins accrue just for remaining mature. Automation retries must not create infinitely recurring zero-time events. All crop durations must be **strictly positive** even at the growth cap.

**Approved lifecycle (DEC-025):** explicit Auto Harvest enable may immediately harvest an already-Ready crop after due work; show that consequence. A new Empty loop needs Plant/ApplyAndStart authorization; a previously authorized Stalled loop retries its unchanged accepted plan on relevant events. Plan changes while Stalled and rearming after refunded/rebought abilities need explicit authorization. Settings applied to an occupied crop authorize future cycles only, preserving its snapshot. Reopen/offline processing resumes already enabled/authorized valid loops without per-cycle/session prompts. Missing refunded capabilities make retained config inactive, never an unapproved substitute plan.

Presets contain settings, not wallet/XP/research/skill/plot ownership; no locked/unpurchased slot becomes planted automatically. Rotation advances the cursor only after successful planting of the current approved entry; failure retains cursor/selection and stalls rather than skipping to an unapproved crop. Loop/fallback authorization and cursor state are validated/deep-copied/persisted atomically.

### 4.4 Integer economics

**Approved arithmetic (DEC-005):** use signed checked 64-bit integer-compatible state, `10_000` basis points = 100%, whole coins/XP, and integer microsecond simulation durations/timestamps. The exact rounding rules are:

- `gross_coins = floor(base_coins × (10_000 + coin_bonus_bp) / 10_000)`.
- `fertilizer_cost = max(minimum_cost, ceil(base_coins × pricing_rate_bp / 10_000))`.
- `effective_growth_us = max(1, ceil(base_growth_us × (10_000 − capped_reduction_bp) / 10_000))`.

Provisional combined growth-speed cap is **60%**; Group 1 does not finalize this cap or other balance coefficients. Guard additions, multiplication, counters, timestamps and aggregation before application. Use quotient/remainder, checked factor reduction or equivalent integer-safe operations so a representable final quotient is not rejected merely because a naive multiplication would overflow. Never use uncontrolled floating-point conversion or trust wraparound for authoritative economics. Unit-test the identical arithmetic/rounding on Windows and the portable core, including the positive 1 μs duration minimum.

**Approved finite-representation policy (DEC-026):** process valid representable offline intervals/results without an arbitrary day/reward cap. Computation may be chunked and identical cycles aggregated, while catch-up remains one logical atomic result+anchor commit. For an actually unrepresentable result, leave the previous complete checkpoint, credited-through anchor and accounting intact; expose a recoverable diagnostic requiring a deliberate recovery/version decision. Do not partially publish rewards, wrap, silently saturate balances, or discard earned time. The released content's ordinary 30-day/year cases must succeed; numeric-limit failure is not a shortcut around required performance/correctness testing.

## 5. Gameplay service APIs (design contracts, not code)

| Service | Required operations |
|---|---|
| `SimulationEngine` | `initialize(state, registry)`, `submit_command(command)`, `advance_to(target_us)`, `get_state_snapshot()`, `get_next_event_time()`, `validate_state()` |
| `SimulationClock` | `advance_real_time(real_us)`, `advance_offline(offline_us)`, `set_speed_multiplier(1..60)`, `get_simulation_time_us()` |
| `TimeProvider` | `get_utc_unix_time_us()`, `get_monotonic_time_us()`, `get_resume_elapsed_us()` (best available platform semantics) |
| `FarmSystem` | `can_plant`, `plant`, `mark_mature`, `harvest`, `collect_replant_requests` |
| `EconomySystem` | `planting_cost`, `harvest_reward`, `effective_growth`, `validate_purchase`, `completed_cycle_profit` |
| `FertilizerOptimizer` | `plan_batch(eligible_plots, budget, rules, content) → validated feasible allocation proposal` |
| `ProgressionSystem` | `add_xp`, `get_level_for_xp`, `can_allocate_skill`, `allocate_skill`, `reset_skills` |
| `ResearchSystem` | `can_start`, `start_research`, `accelerate_research`, `complete_research` |
| `AutomationSystem` | Resolve inheritable settings versus farm budget, validate/authorize start/rearm, disable removed capabilities, collect valid retries and replant requests |
| `ContractSystem` | `process_committed_harvest`, `accept`, `claim`, `abandon` |
| `StatisticsSystem` | `record_committed_result`, `get_summary`, `get_crop_report`, `get_plot_report`, `forecast_on_copy` |
| `SaveRepository` | `load_game`, `commit_checkpoint(prepared_result, commit_id, expected_parent_durable_revision) → COMMITTED / NOT_COMMITTED / UNKNOWN`, `settle_and_read_commit_identity`, `load_previous_checkpoint`, `create_backup`, `migrate_save`; all write routes share the commit coordinator (§20.2) |

Signatures are logical contracts. Exact GDScript parameter types and script filenames may be refined during development, without violating observable behavior.

The DEC-013 clock contract distinguishes accounted active and suspended intervals; TimeProvider supplies sufficient observations for reconciliation without leaking platform calls into the core. DEC-014/G4 approves verified Godot observations first, otherwise an isolated Windows provider; exact selection and empirical suspend evidence remain Open. The engine command API enforces §4.1 identity/time rules and §4.2 phase boundaries; adapter/clock/ID observations must be injectable for deterministic tests.

**ProgressionSystem continuation (DEC-002/C1):** validate/cache strictly increasing thresholds from the source table plus approved integer recurrence, rather than fitting an exponential float formula. Round each increment upward before adding it to cumulative XP. A safe equivalent recurrence is previous increment +ceil(previous increment/10); use checked quotient/remainder arithmetic so a naive ×110 intermediate cannot reject a representable result. Determine the highest reached threshold, grant the complete level difference once and retain unused points. Repeated/replayed grants are forbidden.

When the **next mathematical threshold** exceeds signed-int64 representation while current earned XP is valid, stop finite threshold generation and compare within the representable domain; do not fail the valid lookup, silently clamp earned XP or call that an arbitrary gameplay level cap. Genuine unrepresentable state updates retain the prior full checkpoint under DEC-026. Independent test vectors: level 31=577,500;32=640,750;33=710,325;34=786,858;35=871,045;40=1,436,418. The largest representable threshold in this recurrence is level 349 at9,203,731,170,706,289,434; its next threshold is10,124,104,287,776,924,021, beyond int64 max9,223,372,036,854,775,807. These are representation-boundary oracles, not released content/level caps.

PurchasePlot must enforce §3.3's next-ID prefix rule as well as level/payment checks; response previews and command execution use the same eligibility calculation. ProgressionSystem uses the approved FRS through-30 table and minimum-rank prerequisite graph. Point/rank validation and non-planting unlock transitions must be testable headlessly without UI geometry ownership.

ResearchSystem quotes/executes approved DEC-007: C is cost actually paid at project start; boost charge ceil(C/2), new remaining time ceil(remaining_us/2), at most once, never zero. Reject a completed/already-boosted/no-time-saved/unaffordable request without charge; reschedule completion with stale-event invalidation. Preview exact charge/formula with saved-time/new-completion values labeled as-of the preview time; execute/recompute the exact half-remaining result at controller acceptance and return it (§20.4). Commit cost, timing, flag and accounting atomically. Snapshot C/original timing; no offline auto-boost or repricing of an active project.

**Approved ContractSystem lifecycle (DEC-019/G4):** versioned authored one-time offers; provisional Board level 7 and three accepted/unclaimed slots. Accept manually, snapshot definitions and start progress only from later qualifying committed harvest events in engine phase/sequence order. Crop/mixed targets count named crops; gross revenue counts harvest coins only; automation predicates use actual harvest origin, not UI/audio events. Completion sets claimable without reward and still uses a slot. Claim manually, atomically persist coin/XP/accounting and claimed-offer eligibility once. Confirm abandon with discarded progress/no reward/refund; an unclaimed abandoned offer may be reaccepted under a new instance with zero progress. Claimed offers never pay again within the authoritative retained timeline; older-backup rollback discards the lost credit and claim flag together (§20.1). No expiry/procedural refresh is introduced. Keep claimed-offer protection when pruning history. C2 now supplies the approved exact target/predicate/reward table in FRS §§10.2–10.4. M03 establishes valid schemas/generic protocol fixtures; M05 implements the real twelve definitions and all source families.


### 5.1 Exact contract definitions and evaluation — DEC-019/C2

`ContractDefinition` is versioned typed content: stable offer ID, family, minimum level, required target crop IDs, AutoHarvest-ownership guard where applicable, objective counts/gross target and exact fixed coin/XP rewards. Resolve crop IDs via ContentRegistry; FRS §10.2 is canonical for all twelve rows. Preserve accepted definition/reward snapshots and unique instance/claim IDs; do not reprice from current crop/upgrades/player state.

Acceptance checks level7 Board/row level/three occupied accepted-unclaimed slots/unclaimed offer. Quantity/mixed/automation rows also require all named crops unlocked; automation additionally requires owned AutoHarvest, not AutoReplant. Gross targets accept any crop and have no design-reference research requirement. Refund/disable retains contract progress; future automatic counts require actual automatic harvest origin.

Evaluate committed-harvest semantics inside the same authoritative working batch as harvest/accounting, **not** a second save or UI listener. Use simulation timestamp plus deterministic phase/accepted sequence to exclude pre-acceptance events; equal timestamps alone are insufficient. A crop planted before acceptance can count when harvested later. Count one per distinct qualifying cycle, batch N as N, mixed counters with AND completion and gross actual harvest credits excluding claims/other categories. One event may advance every independently matching accepted instance once; no exclusive crop allocation/inventory is introduced.

Store objective snapshots, acceptance boundary, progress and claimed-offer eligibility atomically with state/XP/accounting/replay/anchor. No unlimited per-contract UI-event or processed-harvest journal is required; use authoritative once-only cycle processing, checkpointed progress and existing replay guarantees. Offline aggregation must preserve accepted boundaries, actual auto/manual origin, mixed/gross thresholds and independent concurrent progress; stop/aggregate exactly at any outcome-changing boundary.

Claim pays the frozen row through the shared Economy/Progression path (C1 increasing optionB included), records a single claim and reports it outside crop gross. No auto-claim. Abandon/reaccept/one-time offer guards stay as in FRS §10.1. M05 owns full authored gameplay; M03's generic claim/replay fixtures never constitute T-011 completion.

## 6. Fertilizer optimizer, shared spending and authorization — approved G3

### 6.1 Field scope and capability gates (DEC-010/011)

One shared wallet; no per-plot sub-wallets. Crop/auto actions/fertilizer policy/accepted fallback/eligible priorities resolve **Plot > Group > Farm**, respecting explicit false/zero. **Farm reserve, protection percentage and seed-protection toggle are shared farm controls and cannot be overridden per plot/group.** Reject invalid override attempts rather than pretend they were applied. This is the approved exception to the previous broad inheritance wording.

Approved initial development defaults (provisional for balance): reserve R=0, protection percentage=25 (editable 0–100), seed-protection Off, equal priorities. Smart Fertilizer at its level-9 gate enables the three modes and basic reserve/percentage controls. Enhanced Budget Management at level 15 adds custom priorities and a toggle applying the same R to automatic seeds. Fixed recurring fertilizer requires no Smart skill. Stored fields remain inactive when their capability is absent; no silently substituted Smart/crop plan.

Without advanced seed protection, mandatory seeds can spend below R; R restricts optional automated fertilizer. With it enabled, paid automatic seed costs fit max(0,W−R); zero-cost seeds remain affordable even if R>W. Direct manual farming overrides need semantic cost/plan confirmation with displayed ending balance as a minimum (unrelated income may increase it, never lower it or increase the authorized charge); normal explicit confirmation may suffice. Refresh changed terms under §20.4. Automatic replant after a manual harvest still uses automatic budgets; Store/research/expansion/reset purchases are not restricted by this farming reserve.

### 6.2 Coherent batch funding (DEC-006/010)

The automatic allocator/non-overridden Smart path uses these limits. A direct manual override validates and executes only its explicitly quoted cycle; it does not change persisted farm R or pass permission to automatic replant/other later groups.

1. Process due research/harvest/XP/contracts/accounting under §4.2; build eligible planting requests using validated accepted authorizations.
2. Reserve accepted required seeds in effective-priority then stable plot-ID order. Respect the advanced seed limit only when enabled; optional fertilizer never consumes committed seed funds.
3. Honor affordable explicitly fixed fertilizer first. Without accepted no-fertilizer fallback, an unaffordable fixed request stalls with no charge; preserve selected config. Use §20.5: at the first unaffordable no-fallback fixed request, exclude it for this batch, discard tentative reservations and replan the remaining universe; no excluded re-entry, ≤N exclusions/≤N+1 passes, seed-unfunded candidates reconsidered after removals. Retry a final stall only on a genuine relevant funds/configuration event. This policy need not maximize planted count.
4. From that final feasible seed/fixed plan, define W=post-harvest wallet, S=accepted seed costs, R=reserve, F=fixed fertilizer spend, A=max(0,W−S−R). Require F≤A. Remaining Smart funds are M=A−F.
5. Compute **one batch-wide** protection ceiling C=floor(M×protection_percent/100). Across every Budget Protection group combined, spend≤C; across all Smart groups, spend≤M.
6. Smart groups run by custom priority, highest first; at equal priority mode order is **Maximum Profit → Capital Efficiency → Budget Protection**. All plots initially share equal priority, so a uniform-mode farm is optimized as a batch. Stable IDs break equivalent allocations; default plot ID is not a distinct priority group per plot.
7. Each group sees remaining funds and remaining C where applicable. C is a ceiling, not money reserved against earlier groups: later groups can receive zero. Never recompute the percentage per group/plot.
8. Revalidate budget/authorization against state revision; commit accepted costs/cycles/rewards/accounting/replay/anchor coherently and emit only post-commit live notifications.

Example W=1,000, S=200, R=100, F=100 yields M=600 and C=150 at 25%. If all Smart requests are Budget Protection, total fertilizer spend≤250 and wallet≥550. Other earlier Smart modes may reduce actual protection-mode spend below 150. This example changes no crop price table.

### 6.3 Objective and solver guarantees (DEC-009)

- **Maximum Profit:** exact multiple-choice allocation, initially Pareto-pruned, maximizing the sum of incremental net coin rates for its same-priority/same-mode group under remaining authorized funds. Its optimum is conditional on seed/fixed/higher-priority commitments, not a claim across conflicting player policies.
- **Budget Protection:** same exact rate objective, additionally bounded by remaining shared C.
- **Capital Efficiency:** deterministic greedy preference among affordable positive marginal purchases/upgrades by additional net profit / additional fertilizer cost; refresh the plot's upgrade candidates after each selection. No global-optimality claim for this preference mode.
- **None** always remains a candidate, with no zero-cost ROI division. Smart zero/negative-gain choices lose to None. A manual/fixed explicit fertilizer choice may be unprofitable; that is not an automatic optimizer choice.
- Equivalent exact-rate solutions prefer lower spend then stable plot/fertilizer IDs. Capital Efficiency ratio ties prefer higher additional net rate, then lower spend, then stable IDs. Use exact safe integer/rational comparisons from §4.4.
- Use an independent small exhaustive oracle, adversarial cases and 32-plot runtime/frontier/memory measurements. Do not enumerate all 4^32 combinations or allocate a table proportional to an uncapped wallet.
- Exact strategy approval is not proof of performance. If unsuitable, reopen DEC-009 for explicit approval of approximation/changed labels before production acceptance; no hidden fallback or weakened optimum claim is approved.

### 6.4 Fixed rules, fallbacks and staged advanced behavior (DEC-012/025)

Apply exactly one authorized yield fertilizer per planted cycle and charge each cycle. Accepted no-fertilizer fallback is explicit, may inherit through valid settings scopes, and does not permit another crop/fertilizer substitution. A refused fallback makes the request stall uncharged. Per-plot failures do not permit a partial cycle or partial durable batch.

M02 implements basic auto-harvest/replant, fixed/Smart rules and basic budgets; defines advanced record/interfaces and unlock guards. M03 serializes validated inactive/default advanced records plus authorizations. M05 completes presets, custom priorities/seed reserve, approved rotation and UI/recovery. Unimplemented intermediate operations are unavailable, not claimed working; all agreed first-release systems still must be complete before release.

Existing owned/enabled/authorized loops resume normally offline/reopen; only new starts, changed stalled purchase plans and post-respec rearming need explicit authorization. Presets/rotation cannot mutate current snapshots or bypass G2's sequential fourth row.

**AUD-R-007 integration:** group structural commands validate the entire membership/reference graph and effective economic diff before applying. At most one group per plot; occupied cycles remain immutable; no implicit new/stalled/rearmed paid start. Delete only with an explicit existing destination/ungroup choice, preview and resolved preset references. Rename or fully overridden unchanged plans retain authorization. Structural edits are all-or-nothing; associated explicit farming subsets retain DEC-025 semantics, committed coherently. Full group management is M05; M02 contracts/M03 schema are prerequisites. See §20.7.

## 7. Timekeeping: offline-first policy (confirmed)

### 7.1 Distinct clocks

- **UTC wall time:** persisted cross-session reference, may be manipulated by a user or adjusted by OS.
- **Monotonic elapsed time:** controls progress while game is running, independent of Windows calendar edits.
- **Simulation time:** monotonic gameplay timeline. At speed `s`, active simulated delta = `real_delta × s`.
- **Real active engagement time:** player interaction/foreground metric, not multiplied by debug speed.
- **Offline duration:** elapsed real-world time between the stored credited-through UTC anchor and current UTC at restart.

Recommended Godot adapter: `Time.get_ticks_usec()` for in-session monotonic observations and `Time.get_unix_time_from_system()` converted carefully to integer microseconds for UTC. **Verify whether the selected Godot timing source includes Windows sleep/hibernate time**; a Windows-specific sleep-inclusive source may be required and must be isolated inside a TimeProvider. QPC is high-resolution and process/boot sensitive; `GetTickCount64` is sleep-inclusive but must not be treated as trusted across reboots. Never rely on local time zone for progression.

**Approved selection procedure (DEC-014/G4):** measure the pinned engine/Windows combination first. Use Godot-only tick plus lifecycle observations if they prove sufficient duration **and active/suspended partition**; otherwise isolate the missing Windows observations behind TimeProvider with equivalent fakes. Exercise active 1×/60×, sleep, hibernate, resume without focus, restart and reboot; report inclusion, resolution and lifecycle gaps. A slow frame or foreground inactivity is not proof of OS suspension, and one sleep-inclusive elapsed counter does not partition active debug time. Do not silently use live UTC edits as elapsed time. Exact API/provider selection and successful measurements remain Open; this policy approval is not evidence.

### 7.2 Credited-through high-water time anchor

Maintain a persisted `credited_through_utc_us` representing the real-time interval already accounted for in authoritative state. Persist it **atomically** with the corresponding state revision.

- On normal reopen at UTC `now >= anchor`, derive `offline_delta = now − anchor`; run catch-up at **1×**; only after committing its results set new anchor to the processed-through UTC instant.
- On reopen at UTC `now < anchor`, use **zero** additional offline delta, preserve state and anchor, log an anomaly, allow monotonic active progression, and do not erase prior progress.
- While actively running, advance simulation with monotonic real elapsed time; the credited-through UTC high-water advances by **actual real elapsed time**, **not debug-scaled time**. If wall clock is moved backward, do not move the anchor backward.
- For resume from sleep/hibernate, reconcile sleep-inclusive real elapsed time **once** (at normal elapsed-time rate for the suspended portion). The debug speed selected before suspension must not multiply a sleep interval.
- On a large positive cross-session clock jump, follow offline-first policy: honor the positive interval after overflow/format checks, optionally log a nonblocking diagnostic. This allows determined forward-clock manipulation and is explicitly accepted.
- Time-zone changes/DST affect display, not UTC-based progress.

**Edge-case requirement:** The time reconciliation algorithm must track accounted intervals so active clocks, wake-from-sleep corrections, and next-launch catch-up never credit the *same elapsed interval twice*. Tests shall cover sudden wall-clock forward/backward changes during a running session, subsequent save/exit, and normal time restoration.

**Approved interval ledger (DEC-013):** persist a bounded summary of already-accounted active/suspended/offline intervals with state and anchor. Record real elapsed versus debug-scaled simulation advancement separately, and do not copy observed system UTC into the anchor merely because a frame/setting/save occurs. Compact reconciled intervals into the checkpoint/high-water while retaining the observations needed for the next correction. Suspended elapsed already included by a provider must not be credited again on resume. Exact native clock inclusion/notification behavior is still to be measured under DEC-014.

A live forward wall edit changes no active simulation delta, but a positive UTC difference at a later restart can be honored by the existing cross-session policy. A rollback can leave the anchor ahead of wall UTC and therefore suppress additional offline time until UTC exceeds it. These approved consequences do not authorize backward anchor rebasing, time caps, destructive progress correction or a false trusted-time claim. In the controlled trace 10 real active seconds at 60× plus one real hour suspended yields 600 + 3,600 = 4,200 simulated seconds, with the suspended interval accounted once.

### 7.3 No false security claims

Do not require an online time authority, anti-cheat kernel driver, TPM attestation, or mandated connection. An offline game **cannot reliably prove elapsed real time across shutdown/reboot**; do not claim that this mechanism blocks deliberate forward clock changes, speedhacks, or save tampering. Mitigate accidental timing inconsistencies and duplicate rewards instead.

### 7.4 Debug speed

In debug builds only, expose 1×–60× slider, integer increments; default/reset to 1× each launch. Implement this in **SimulationClock**, **not** by changing Godot global `Engine.time_scale` for all systems. Simulation time advances faster while app runs; music, UI input, visual ambient animations, physics/render FPS and sound pitch remain natural. Closed intervals are always 1×. Use integer/fraction accumulation to avoid systematic fractional-time loss over many frames.

## 8. Offline catch-up algorithm and concurrency

At startup:

1. Acquire exclusive save profile ownership; initialize content and TimeProvider.
2. Load the latest valid checkpoint and resolve its immutable supported profile manifest before invariant validation. Apply only supported binding-preserving schema migrations; incompatible content mappings require separate explicit approval. Inject a fresh owned writer/allocation namespace before tentative allocations/catch-up, preserving existing full entity IDs.
3. Rebuild pending events deterministically from saved state (or use serialized queue with stable ordering).
4. Calculate eligible offline elapsed time using credited-through UTC.
5. Clone/prepare isolated working state, then advance **the same** SimulationEngine to the target time.
6. Complete all eligible automatic harvests/replants, XP/level changes, accepted-contract progress and active research (no auto skill allocation or new research/crop unlock purchases).
7. Aggregate statistics in correct time buckets; prepare offline report, including stalled plots.
8. Prepare a unique coordinator commit identity/expected parent durable revision and atomically commit updated state, replay/identity/interval metadata and the new anchor. UNKNOWN stops for settled-primary read-back under §20.2; do not expose tentative state or write from stale memory.
9. Initialize UI using committed state; present the offline summary and start active timing.

If catch-up is definitely interrupted before commit, restart from the last validated checkpoint. If the receipt is uncertain, first reconcile the settled primary; never infer rollback or rotate its pending namespace from missing acknowledgement alone. Do **not** add an offline payout to previously committed balances separately. Economic events are deterministic and must not be duplicated.

Before active commands are accepted, the owned profile's fresh writer epoch is persisted as part of startup checkpoint/lifecycle handling (§4.1); forecasts and reference simulations inject fixed identities and never rotate a live writer epoch. Result, anchor and interval metadata commit together. DEC-026 failures leave the prior complete checkpoint/anchor unchanged and produce no partial offline payout.

**Efficiency requirements:** Event-driven chronological advancement with safe algebraic aggregation of identical cycles. Break aggregation at any resource shortage, changing crop/bonus/configuration, research completion, accepted-contract threshold, XP/level-dependent decision, statistics boundary, or other event that can change outcome. Do not materialize every offline UI/audio event, and do not retain unlimited in-memory event histories.

C2 contract aggregation preserves future-after-acceptance boundaries, actual automatic-harvest origin, per-cycle counts, mixed AND counters, actual gross excluding claims and progress of all independently qualifying accepted instances. It does not allocate/consume crops or auto-claim rewards.

G3 aggregation also preserves per-logical-batch seed/fixed/mode-group order and the once-per-batch protection ceiling, loop authorization and successful-plant-only rotation position. Do not pool all offline receipts first or apply one percentage to the entire closed interval. Include only enabled valid authorized loops, running research/its saved boost state and the same economic rules; never auto-buy boosts or rearm refunded skills.

**Threads:** Start with a single authoritative simulation context, avoiding concurrent writes to GameState. Background I/O or parallel simulation can be evaluated only if profiling shows need and strict ownership/transaction rules are maintained. Future Godot web export should work with a single-thread-friendly architecture.

## 9. Persistence: Windows, web portability, and crash safety

### 9.1 Repository boundary

`SaveManager` talks only to a logical `SaveRepository` with load, checkpoint commit, backup, migration and recovery operations. Gameplay modules do not execute raw SQL or depend on a native DLL. Windows and browser may have distinct adapters with common logical schema and invariants.

### 9.2 Windows storage — approved initial policy DEC-015/G4

- Use a Godot-compatible **SQLite** integration (extension/library licensing, Godot version, Windows packaging and maintenance require verification).
- DEC-001 approves evaluating `2shady4u/godot-sqlite` first behind SaveRepository, not adopting an unnamed addon/native binary. C1 selects v4.9 for evaluation; verify its exact artifact/native fingerprints, full license inventory and behavior before Windows persistence adoption; keep the core headless and free of addon imports.
- Approved initial mode: SQLite **WAL** and **`synchronous=FULL`**; verify actual adapter/export behavior. Optimize payload/index/backup scheduling first; changing synchronization or economic durability requires an explicit amended decision.
- Commit important economic commands and coherent automatic timestamp batches **before publishing success**; time-only checkpoints every **30 real seconds**, independent of debug acceleration. Never merge distinct logical timestamps just to reduce writes.
- A successful transaction must commit authoritative data, balance, consumed crop cycles, new crop cycles, XP, contract progress, and accounting totals consistently.
- WAL checkpoint/backup operations must use SQLite-consistent APIs. Do not copy an active database file naively while WAL data is outstanding.
- A save profile allows **one authoritative writer** at a time; second process must refuse or open read-only where safe.
- Store under a per-user Windows application-data location (`user://` resolved appropriately), not the game's installation directory. DEC-027/G6 delivers a standalone ZIP/executable package; application replacement/removal preserves this profile location and backup generations. Include required native libraries/game data/licenses/checksums and verify matching selected export architecture; no editor, installer, login or network is required for normal operation.

**Transaction rule:** each harvest/plant/research/upgrade/skill-reset/contract-claim is all-or-nothing. Use unique command, cycle, transaction and claim identifiers so retrying cannot double-pay. A logical outcome should not be described to the player as durably saved if its required commit failed.

Persist the §4.1 writer epoch/success high-water with each successful outcome. Response-cache pruning or history rollup must never make a successful/retired command executable again. DEC-015/G4 approves the 30-real-second cadence and initial two-generation/10-real-minute backup policy in §9.3. Actual disk/commit latency and packaged durability still need qualification. Compute offline history privately and commit its single result+anchor checkpoint; do not fsync every simulated historical event.

**AUD-R-002 commit coordinator:** all economic, automatic, catch-up, startup, time-only, settings and migration checkpoints carry unique commit ID/expected parent durable revision. On UNKNOWN retain ownership, block economic input and all repository writes including backup rotation/shutdown; settle active operations/transactions before validated read-back. Matching new identity/revision rehydrates the complete committed outcome; a verified unchanged parent permits NOT_COMMITTED; unexpected/unreadable state stays stopped. Reconcile scheduler, replay high-water, anchor and pending real intervals once. Cosmetic drafts may remain unsaved; transaction/autocommit state alone is not logical outcome proof. See §20.2 and AV-002-01–05.

### 9.3 Recovery and backups

- On crash mid-commit, load the latest complete valid primary checkpoint and replay only uncredited future events. For a same-process lost receipt, settle/read-back the primary under §20.2 before any write; never infer rollback merely from an error or older backup.
- For offline catch-up, commit the *new anchor and simulated results together*. NOT_COMMITTED retains the prior checkpoint; UNKNOWN reconciles the settled primary before retry, namespace rotation or any other write.
- Maintain **two rotating validated recovery generations** with consistent database backup APIs. Initial approved cadence: every **10 real minutes** after a successful validated checkpoint, also after validated startup/load, before migration and after successful clean shutdown. Backup scheduling follows real time, not simulated/debug time; backups may be older than the primary.
- Validate schema version, stable IDs, foreign-key/reference integrity, balances, crop states, skill ranks/prerequisites/point totals, timers, and claim flags before exposing a recovered state. DEC-020 requires exactly 32 plot records and an unlocked contiguous prefix 1..N (24≤N≤32), with no active crop in the Locked fourth-row suffix.
- Create a validated consistent backup before potentially destructive migration. Never rotate a corrupt/unvalidated/tentative working copy over known-good generations; failed backup creation must preserve existing recoverable generations and expose its failure. Unknown/unsupported save versions are **not** silently overwritten.
- On corruption, explicitly offer recovery if possible; never quietly replace the player's farm with a new save.
- On disk-full, permission failure, or corrupt storage, notify and preserve in-memory state if possible; do not keep accepting irreversible transactions with no reliable persistence path.
- Debug profiles must be separate from normal player progression.

**AUD-R-001 older-generation recovery:** the chosen checkpoint plus surviving replayed history is the authoritative timeline. Lost-branch credits and flags roll back together; newly allocated full identities use a fresh injected namespace and cannot reuse old branch identities. Existing references remain unchanged. Disclose recovered time/revision and possible progress loss. No claim-only secondary ledger or cross-lost-branch permanence is promised (§20.1). Validate complete supported manifest/group graph/claim state before exposure (§§20.3/20.7).

### 9.4 Serialization schema (logical)

```text
SaveSnapshot
  metadata: save_id, app_version, schema_version, immutable_content_manifest,
            state_sequence, durable_revision, last_commit_id
  identities: allocation_namespace, next_entity_id_numeric_order
  # prepared write envelope also carries expected_parent_durable_revision
  timing: simulation_time_us, credited_through_utc_us, clock_diagnostics
          accounted_interval_summary, pending_reconciliation_metadata
  command_replay: current_writer_epoch_uuid, committed_success_counter,
                  bounded_response_cache_metadata
  player: level, total_xp, coins, unspent_points, skill_ranks
  farm: plots[1..32] with nullable group_id, crop_cycles,
        stable_group_ids/settings_revisions, validated_group/preset_references, priorities
  upgrades: purchased_rank_by_id
  research: project_states, active_project, scheduled_completion,
            original_paid/timing_snapshot, boost_used
  contracts: authored_offer_versions, acceptance_instances/snapshots,
             objective_targets/frozen_rewards, acceptance_time/sequence,
             per_objective_progress, completed_unclaimed, abandoned,
             claimed_offer/claim_ids
  automation: inheritable_default/group/plot_farming_settings,
              farm_budget(reserve, protection_percent, seed_protection),
              accepted_fallback/loop_authorization, inactive_rules, rotation_cursor
  settings: profile_owned_versioned_GameSettings (no persisted debug_speed)
  statistics: lifetime/crop/plot_totals, simulation_minute/hour_buckets,
              current_partial/live_totals, accounting_segments,
              disjoint_state_time, integrated_unlocked_capacity
  scheduling: serialized events OR deterministically reconstructible state
  integrity: state_revision, validation metadata, optional checksums
```

Keep scene and GPU objects out of persistent schema. An immutable supported content/progression manifest reference is required; pure schema migration preserves its binding and all paid snapshots. Incompatible content mappings require separate approval; missing/unsupported manifests are recoverable no-overwrite errors (§20.3).

**M01 implementation note — 2026-10-30 (non-normative):** M01 selected a canonical primitive codec for state digests and in-memory snapshots:

- **Accepted values:** null, bool, int, String, Array, and Dictionary with String keys.
- **Encoding:** type tags, integers as exact decimal, length-prefixed UTF-8 strings, dictionary keys in sorted order.
- **Rejected values:** floats, objects and packed arrays.
- **Digests:** SHA-256 of the encoded bytes, with separate gameplay and durable/clock-metadata projections (§20.2).
- **Godot `JSON`:** excluded for authoritative state, because it converts integers to floats and would corrupt int64 values.

This is the M01 in-memory and digest format, not an approved durable schema version. M03 decides the durable encoding and its migrations.

The Group 1 fields above are logical contracts, not an implemented schema version or selected serialization codec. Validate/deep-copy them with the rest of state. Raw clock intervals and processed-command detail must not grow without bound; preserve reconciliation/replay guarantees when compacting. Subsequent G4 clauses now define settings ownership and statistics windows explicitly; other unconfirmed decisions remain separate.

**G2 fixture/compatibility boundary:** the eight-column coordinate map is stable layout/content metadata; plot IDs remain the authoritative link for cycles, groups, contracts and statistics. Refresh any coordinate-bearing development fixture explicitly without renumbering IDs or silently unlocking gaps. Invalid hole-bearing snapshots require the existing recoverable validation/migration path, not free plot grants or a silent reset. No game/save format has been implemented or shipped by these planning changes; they do not assert a migration has run.

G3 budget/authorization/research-boost fields are new logical contracts, not proof of an existing schema migration. Validate/deep-copy them and preserve them in checkpoint/recovery/forecast fixtures. Do not persist independently overridable plot/group wallet budgets or a half-applied allocation plan. G4 adds profile-owned settings, authored contract lifecycle and simulation-time completed-minute/session/utilization records; all require validation/deep copy and compatible schema handling. These planning edits claim no existing or migrated saves.

### 9.5 Minimal M03 browser probe and future production web adapter

A future Godot web export should use browser-compatible storage, potentially versioned serialized snapshots through Godot `user://` backed by browser facilities such as IndexedDB. Browser persistence can fail, be denied or cleared; provide save import/export and recoverable alternate slots. **Do not promise SQLite durability guarantees in a browser.** DEC-022/G4 schedules the **minimal** Compatibility-rendered browser prototype by end M03, after the M01 boundary audit. Exercise GDScript shared-core boot, rendering, test snapshot storage, denied/unavailable storage handling and suspend/resume reconciliation without Windows SQLite/native imports. Record T-030 as passed only for assertions actually exercised; partial evidence is labeled partial. Browser-specific limitations may be nonblocking Windows findings; native leakage into the shared core must be corrected. A complete production web port, production import/export/audio integration and browser-durability equivalence remain future/P2.

## 10. Statistics, accounting, and projections — approved DEC-017/018/G4

**Accounting source:** committed economic/harvest/contract outcomes, never graphical animations. Keep harvest gross, seeds/fertilizer, completed-cycle operating profit, categorized cash flow, XP/counts and crop/plot breakdowns separate. Attach a completed cycle's costs at its harvest for operating profit; cash flow records the actual payment/collection timestamp. Research, equipment, expansion, resets and claimed contracts are distinct categories.

C2 claim rewards remain a separate cash-flow/XP category; a claim cannot advance a gross-crop objective. Forecast copies may advance qualifying accepted contract progress, but never auto-claim or mutate live snapshots/eligibility.

### 10.1 Timeline, buckets and windows

Production keys use monotonic **simulation time**. Preserve bounded real/UTC/active/suspended/offline/debug correspondence segments for display/analysis; wall-clock edits never rewrite past bucket keys. Normal/offline 1× simulation maps one-for-one to eligible elapsed time. Debug productivity rates divide by simulated hours and explicitly label simulated-hour/day views; actual real-time accrual, if shown, has a different label.

Historical hour/day windows use **60 / 1,440 completed simulated-minute buckets** ending at the last completed simulated minute, with displayed as-of time. Use consistent half-open [start,end) event attribution; keep current partial-minute/live totals separately. Do not claim arbitrary-second rolling exactness. At new profile/short history, report the available simulated coverage, including zero-duration guards, without fabricating pre-profile production.

Approved initial retention: minute buckets for 48 simulated hours, hourly buckets for 90 simulated days, lifetime crop/plot totals. Roll up/prune without double counting or losing active-cycle cost attribution, claimed-offer eligibility or DEC-016 replay protection. Aggregate offline events at their historic simulation times, not one reopen payout time; retain no unlimited detailed harvest log.

### 10.2 Sessions, utilization and occupancy

Start process-session counters **after successful startup catch-up commit**, before active simulation. Present startup offline report separately while retaining its history in rolling/lifetime views. An in-process OS suspension remains in that process session, labeled suspended/offline-like rather than meaningful active engagement. Forecast clones never start or mutate the live session.

Productive utilization = Growing plot-time / unlocked plot-time. Instantaneous occupancy = (Growing + Ready plots) / current unlocked plots. Track disjoint Growing, Ready-waiting, Empty-not-stalled and Empty-stalled durations; displayed Empty total includes its Stalled subset, never an additional disjoint count. Integrate capacity only from each plot purchase onward; handle zero elapsed/capacity safely. Ready waiting is occupied but not productive growth.

### 10.3 Forecast isolation and validation

Advance a deep copy one simulated hour at 1× with the same scheduler, current wallet/policies/authorization and immutable cycle snapshots. Simulated research/contract progress may advance **on the copy**; no live reward, completion, repository/settings/statistics/ID mutation or UI/audio callback is allowed. Display historical actuals, next-hour forecast and optional steady-state rates separately.

Validate minute boundaries/as-of/live totals, retention transitions, costs across windows, UTC edits, debug denominators, offline segmentation, ready-waiting, purchase-time capacity and post-catch-up session start against independent ledgers. Statistics and economic transitions commit together.

## 11. Presentation, art, graphics, and audio

### 11.1 Graphics and assets

- Target **1920 × 1080** initial Windows window and **60 FPS** on the named representative Windows 11 baseline under DEC-023/G5; select exact hardware before M04 and finalize vendor coverage before M06. Support sensible window/display scaling.
- Godot isometric layout shows **8 columns × 3 initially unlocked rows** (IDs 1–24), plus the initially Locked fourth row (IDs 25–32). Unlock that row left to right only, ID N+1 next, reaching 8×4. All cells use a fixed eight-column map; stable plot ID maps scene view ↔ `PlotState`. Only the next plot may offer an eligible purchase; later Locked cells can explain prior-plot/level/cost gates without permitting skipped unlocks.
- Use dynamically rendered sprites/layers from **development-generated artwork** in the approved **Clean illustrated** direction (DEC-023/C3): crisp silhouettes, restrained outlines, simple smooth shading and natural crop/soil colors, guided by column A of the planning comparison. Preserve five distinct visual stages for every crop, correct isometric depth ordering and subtle varying wind sway. M04-T02 translates the selected direction into an art bible and small production sample before bulk generation: specify sprite scale, tile footprint/isometric angle, precise palette/lighting/outline rules, layers/transparency, naming, export/import/filtering/atlas and wind implementation. Validate gameplay-size readability/provenance and Compatibility behavior; the static board does not validate a production asset pipeline. Its typeface/ready glyph and patch counts are not final UI or geometry requirements; final audio/aggregation tuning remains separate.
- Target compatibility-oriented shaders and texture effects for future web export. The Compatibility renderer is the recommended baseline; exact renderer settings should be validated with Godot pinned release.
- `PlotView`, farm scene, menus, crop-selection/store/skill/research/contract/statistics/settings panels and offline summary read state snapshots and **submit commands**. Destroying/rebuilding a visual node must never erase a crop.
- UI input must not directly credit coins, complete research, change XP, or manipulate saved crop timestamps.
- Show farm-wide reserve/percentage separately from inheritable crop/fertilizer rules; disclose mode priority and that the protection cap is not guaranteed funding. Preview direct manual reserve overrides, recurring start/rearm/ready-harvest consequences, one research boost's cost/saved time, future-only preset changes and skipped batch-member reasons without exposing solver internals as product decisions.

### 11.2 Audio

- Independent volume buses/classes Master, Music, Crop Ready, Harvest/Coins and UI; 0–100% sliders with **0 = muted**, music On/Off switch.
- Crop maturity notification once per event subject to throttling; short positive coin effect at harvest; reasonable UI feedback.
- Group rapid harvests into one coordinated sound. Initial aggregator: **250 ms** and max **two groups per real-world second** (provisional tuning). No backlog of sounds from offline catch-up.
- Audio and ambient wind run in natural real time, not debug-accelerated simulation time.
- DEC-021/G4: restore profile-owned versioned GameSettings before AudioManager starts playback; normal/debug settings stay separate. Apply sliders immediately as cosmetic drafts, but report unsaved changes on write failure without advancing/acknowledging an economic outcome. Exclude debug speed from persistence and reset it to 1× every launch; numeric volume/aggregation defaults remain provisional.

## 12. Application lifecycle and failure states

### 12.1 Startup sequence

1. Initialize configuration, logging, and content registry.
2. Construct TimeProvider and repository adapter.
3. Acquire exclusive save ownership and load the latest valid checkpoint. Resolve its immutable supported manifest before validation/catch-up; perform only supported binding-preserving schema migration. Inject a fresh writer/allocation namespace before tentative catch-up allocation.
4. Validate authoritative GameState; reconstruct scheduled events.
5. Compute offline elapsed time and simulate on isolated working state.
6. Atomically commit catch-up with updated credited-through UTC anchor, bounded accounted-interval/reconciliation metadata and the owned profile's fresh writer epoch/replay state before accepting commands (DEC-013/016).
7. After successful startup/catch-up commit, start fresh process-session counters; establish the validated startup backup under §9.3 before normal backup rotation.
8. Restore profile-owned settings before audio; initialize farm scenes/UI and render committed state.
9. Show the separate startup offline report; begin monotonic active simulation. Reset debug speed to 1×.

If save recovery/catch-up cannot commit, show a recoverable error/restricted state. UNKNOWN retains the pending namespace and reconciles the settled primary before rotation, new input, backup or other writes (§20.2).

### 12.2 During gameplay

- Collect monotonic elapsed delta; SimulationClock scales by debug multiplier only while active.
- Advance authoritative scheduled events; then accept queued commands in deterministic order.
- Persist important logical outcomes before acknowledgement; use 30-real-second time-only checkpoints and 10-real-minute validated backup scheduling, never accelerated simulation time.
- Publish **post-commit** game state changes and coalesced notifications to UI/audio.
- Render at independent frame rate and respond to input.

### 12.3 Shutdown

Stop accepting new transactions; process/abort pending logical batches consistently. If any outcome is UNKNOWN, first settle/reconcile under §20.2 or close without an old-memory final save/backup. Otherwise account and commit the final checkpoint, then create a validated clean-shutdown backup on known success; release database lock/renderer/audio resources. Unexpected termination shall be recoverable from durable checkpoints.

## 13. Recommended Godot project organization

```text
idle_farmer/
  project.godot
  core/
    state/                   # GameState, PlayerState, PlotState, CropCycle
    simulation/              # SimulationEngine, commands, events, EventScheduler
    time/                    # TimeProvider, SimulationClock
    farming/                 # FarmSystem, AutomationSystem
    economy/                 # EconomySystem, FertilizerOptimizer
    progression/             # Levels, XP, skills
    research/
    contracts/
    statistics/
  data/
    crops/                   # Godot Resources or validated versioned data
    skills/
    research/
    upgrades/
    contracts/
  persistence/
    repositories/            # Repository boundary and platform adapters
    migrations/
    backups/
  scenes/
    farm/
    plots/
    ui/
    menus/
  assets/
    crops/
    environment/
    interface/
    audio/
  debug/
    speed_controls/
    diagnostics/
  tests/
    unit/
    simulation/
    persistence/
    recovery/
    balancing/
```

Core modules must not import scenes or audio classes. Configurable balance data is versioned and validated before starting a game.

DEC-001 places GUT and project-owned scenario/fixture infrastructure in the test/tooling boundary, outside authoritative core imports. Pin standard Godot/matching templates and the compatible GUT release through M01-T01; evaluate the isolated SQLite candidate through M03-T01. C1 already selects Godot 4.7.2/templates, GUT v9.7.1, godot-sqlite v4.9 evaluation and Windows x86_64. Only actual artifact/commit/checksum/license/adoption verification remains pending; the folder recommendation does not reopen settled version choices.

## 14. Nonfunctional targets and monitoring

| Requirement | Proposed engineering target / mandatory condition |
|---|---|
| Frame rate | **60 FPS** at 1920 × 1080 on a **to-be-defined** reference Windows machine; ~16.7 ms full frame budget. |
| Simulation update | Normal simulation processing **<3 ms/frame** in representative active gameplay (*provisional* budget; verify). |
| Farm size | Stable normal and debug operation with **32** plots. |
| Debug | **60×** without changing graphics FPS or audio pitch. |
| Offline efficiency | Process **30 days** of stable 32-plot automated production within **5 seconds** on defined reference hardware (*provisional*). Test a **one-year** interval for correctness and bounded resource use, without promising all configurations meet 5s. |
| Memory and history | Bounded event queue, bounded detailed reporting, aggregate old history. |
| Currency/timing safety | Approved DEC-005 rounding/1 μs minimum and DEC-026 checked arithmetic; genuinely unrepresentable results preserve the prior complete checkpoint/anchor without silent caps. |
| Save integrity | Atomic commits, idempotent rewards, valid backups and migrations, one writer/profile. |
| Offline policy | Full uncapped eligible elapsed progression; accepted limits on tamper resistance. |
| Network | Game works offline, without login or trusted time verification. |
| Web | M01 boundary audit and end-M03 minimal probe required (DEC-022); full production browser build/storage/audio remain future work. |

### 14.1 Approved qualification protocol — DEC-023/G5

Use a named representative Windows 11 reference baseline plus additional NVIDIA/AMD/Intel compatibility devices. Record CPU/GPU/RAM/storage, OS build, driver, display mode and pinned engine/templates/addon/build/content/scenario/checksum. Inventory candidates in M01, review/select the baseline before M04 and freeze the final coverage matrix in M06. No hardware or performance result is inferred from policy approval.

Exercise 32 plots at 1×/60× and 1920×1080, separating frame distributions/stalls, simulation/optimizer work and DB commit/backup time. Record repeatable warm runs and import/startup-separated observations. The 60 FPS target remains; <3 ms simulation/update and stable 30-day catch-up <5 s remain provisional engineering targets. One-year cases require correctness/boundedness and recorded duration, never an implied five-second promise. Record actual target disposition; no universal Windows/NVIDIA-only claim. Review sample art/stage readability/provenance before bulk generation and audio/aggregation tuning with actual evidence.

**Owner-confirmed reference target H2 — 2026-10-28:** **AMD Ryzen 5 7600X3D**, **RAM≥16 GB**, **SSD**, **NVIDIA GeForce RTX 2080 or better, or an AMD card with similar/higher specifications**. Preserve this target envelope without inventing an exact installed machine. Benchmark evidence names the actual GPU/RAM/storage/OS/driver; an AMD equivalence claim requires representative graphics/compute measurements, not numerical model-name ranking. Do not implement hardware gating or change existing compatible Intel coverage. The earlier “2800+” input was explicitly clarified by the owner; GPU label clarification is complete, while actual machine/asset/tuning qualification remains pending.

### 14.2 Approved economic and human evidence — DEC-024/G5

Automated costed scenarios and normal-speed human playtests provide different evidence. Script focused four-node automation, mixed growth/profit, coin/XP, low/high reserve and active-only/mixed-offline strategies with all real costs and explicit decisions; include no-contract progression. Exclude DEC-008 deferred content. Preserve snapshots and version separately approved numerical changes.

Local telemetry distinguishes real-open, foreground, simulated, suspended/offline and debug intervals. Collect foreground/input/lifecycle observations outside the scene-independent core; automated production itself never counts as meaningful interaction. Initial provisional indicator: foreground with a meaningful input/decision no more than five **real** minutes ago; test below/at/above 300 seconds. Supplement it with human decision diaries so reading/planning is not equated with absent clicks. Do not multiply this real-time indicator by debug speed, infer human engagement from closed/suspended time or claim short pilots establish ~48 additional active hours.

Define varied human play styles/sample and observation/diary protocol before M05 completion; M06 reports actual participant count, observed normal-speed duration, decisions, repetition/content exhaustion and limits. Keep met/missed/insufficient-evidence outcomes explicit for both 3–5-hour automation and ~48 further engaging active hours. Headless production hours are never human-engagement proof. Target misses require a recorded owner decision; no automatic offline cap, forced waiting/mandatory contracts, deferred feature inclusion or unapproved economic retuning.

## 15. Mandatory test matrix

| ID | Test / controlled scenario | Expected outcome |
|---|---|---|
| T-001 | Fresh G2 new-game state, then an Empty unlocked plot plants Wheat | 0 coins/XP, level 1, 24 Empty unlocked plots in 8×3 and 8 Locked in row 4; free seed; 8 min baseline; 16 coins/6 XP **on harvest** |
| T-002 | Wheat at 60× | 8-min game interval in ~8 sec real; same reward; music and animation not pitched/accelerated |
| T-003 | Corn planting at base | Seed cost 18, growth 30 min, eventual 110 gross coins/32 XP |
| T-004 | Tomatoes + Basic fertilizer | Seed 55, fertilizer **41** (`ceil(270×0.15)`), gross 337, net completed-cycle profit **241** |
| T-005 | Multiple mature crops same instant | All rewards before replant budget allocation; stable plot order; no duplicated spending. Audit A1: AV-001 identity order; AV-004 accepted command boundary; AV-005 final feasible plan |
| T-006 | Too few coins for seeds | Plot stays empty and configured, no charge; retries on relevant funds change. Audit A1: AV-005 monotone exclusions/relevant-event retry; AV-007 changed-plan consent |
| T-007 | Optional fertilizer unaffordable | Only authorized fallback, e.g. no fertilizer; do not silently switch crop. Audit A1: AV-004 semantic terms; AV-005 fallback/no re-entry |
| T-008 | Skill reset during growing crop | Existing snapshot unchanged; future plantings use new skill modifiers. Audit A1: AV-003 immutable manifest; AV-006 future-only equipment effects |
| T-009 | Research finishes offline | Unlock completed, no automatic next project/crop assignment. Audit A1: AV-004-03 as-of boost preview/accepted-time result |
| T-010 | Several levels earned offline | Proper XP and unspent points; no automatic skills allocated. Audit A1: AV-003-01–05 manifest-bound level−1 point conservation |
| T-011 | Accepted contract progresses offline and recovers | Objective advances; manual claim once within the retained timeline; older-backup lost credit/flag roll back together; new instance identities are distinct. AV-001-02, AV-002, AV-007 reference/copy cases |
| T-012 | Eight-hour and seven-day offline cases | Correct full catch-up, expenses, XP, contracts and report, no arbitrary cap |
| T-013 | Clock moved backward while running | Monotonic active progression; no negative growth |
| T-014 | Reopen before credited-through UTC anchor | Zero **additional offline** time; committed progress retained; diagnostic raised |
| T-015 | Forward clock jump across shutdown | Positive interval honored per offline-first policy, with overflow checks |
| T-016 | DST/time-zone change | No incorrect progression change |
| T-017 | Windows sleep/hibernate/resume | Elapsed sleep accounted once; **not** multiplied by stored debug rate |
| T-018 | Crash or live-process receipt loss during planting/harvesting | Known complete outcome or stopped UNKNOWN reconciliation; no stale overwrite/second debit. Exercise every write path and state+anchor recovery. AV-001/002 |
| T-019 | Crash during offline catch-up commit | Previous complete checkpoint recovered, rerun yields correct single outcome. Audit A1: AV-001/002 pending namespace and unknown catch-up receipt reconciliation |
| T-020 | Same command ID retried before/after restart, response-cache eviction and writer-epoch retirement | No duplicate effect; stale/duplicate result permitted when old full response is uncached; test crash before first success and fresh epoch after backup restore. Audit A1: AV-001-01/03/04; AV-002-01–05; AV-004-05 pending intent reuse and immutable accepted logs |
| T-021 | Same initial state/commands at 1×, offline, 60× | Equivalent authoritative state after **same simulated duration**, with explicitly comparable timestamps. Audit A1: AV-001-03 injected namespace/numeric ordering; AV-003 per-profile manifests; AV-004 accepted logs; AV-005 per-batch parity |
| T-022 | Forecast of next hour | Uses cloned state, live coins/XP/crops/contracts unchanged. Audit A1: AV-003 supported profile context; AV-005 same planner; AV-007 deep-copy/reference preservation |
| T-023 | Smart Fertilizer modes, small known batch | Respect feasibility, ROI definitions, spending budget and deterministic ties. Audit A1: AV-005-01–05 seed/fixed feasibility before conditional Smart optimization |
| T-024 | Large 32-plot fertilizer batch | Bounded deterministic processing; no double-spend. Audit A1: AV-005 ≤33 seed/fixed passes for 32 candidates plus separately measured unchanged Smart solver |
| T-025 | Statistics report for plant before/harvest inside period | Completed-cycle expenses attached to crop; cash flow reflects original payment time |
| T-026 | Schema/content compatibility and migration | Backup-protected supported schema migration preserves immutable manifest/IDs/snapshots; missing/unsupported manifests are recoverable without overwrite; no implicit changed-curve/rank migration. AV-003-01–05 |
| T-027 | SQLite corruption or disk-full | Recovery/error clearly shown; no silent reset or claimed durable save. Audit A1: AV-002 unknown-versus-definite failure and no stale settings/shutdown/backup write |
| T-028 | Two processes same profile | Exclusive authoritative writer; second prevented from unsafe concurrent mutation. Audit A1: AV-001/002 exclusive owned startup namespace and reconciliation |
| T-029 | 30-day and one-year headless offline simulations | Correct totals, bounded memory, recorded performance. Audit A1: AV-003 manifest-bound progress; AV-005 batch parity; AV-007 reference/authorization preservation |
| T-030 | End-M03 minimal browser compatibility probe | Shared GDScript core/Compatibility rendering, test snapshot storage/unavailable-storage errors and resume reconciliation exercised without Windows SQLite; partial evidence labeled honestly; full web release future |

Include unit tests for all crop formulas, growth cap/rounding, complete XP curve, skill ranks/prerequisites, research gates, contract event predicates, budget fallbacks, save validation, and time-anomaly handling. Use fake TimeProvider and in-memory/fault-injection repository adapters to test without changing the real Windows clock.

G2-specific cases: all 30 configured XP thresholds and interpolated values; first rank versus full-tier skill prerequisites; four-point automation reachable at level 7; all eight fourth-row expansion costs/gates in strict ID order; reject skipped IDs even with sufficient level/funds; failed purchase leaves prefix/wallet unchanged; save/clone/presentation preserve eight-column coordinates. “No unlock gaps” must not reject legitimately Empty unlocked plots. C1 resolves that choice with increasing option B; qualify full production beyond level 30 using exact per-step ceilings, surplus-point retention and real long-offline cases rather than an inferred constant tail/cap or numeric-error shortcut.

G3-specific cases: fixed rules versus mixed Smart modes, equal default priorities, one shared C across different protection groups, 0/100% bounds, free seeds below R and optional advanced seed protection; accepted/refused fallback and no charged failed cycles; exact oracle/ROI tie tests; one-boost flag/timing/charge across crash/reopen; ready-on-enable, reset/rebuy rearm, normal authorized offline resume; eligible-subset manual batches with full rollback on definite NOT_COMMITTED, stopped reconciliation on UNKNOWN; preset/cursor/authorization deep-copy and recovery.

C2-specific cases: all twelve exact offer IDs/targets/rewards, eligibility before/at row level and research guards, AutoHarvest ownership versus actual automatic source, manual harvest on auto-enabled plot, mixed AND/one-per-cycle/batchN, one event across multiple accepted instances, pre-acceptance and same-timestamp ordered cases, modified gross excluding claims, static accepted rewards across content changes, manual one-time claims/abandon/reaccept and combined harvest-progress/claim crash/replay. Test claimXP through C1 increasing progression and retained points; generic fixtures are not real catalog evidence.

G4-specific cases: measured Godot-first/native-if-needed active/suspended partition; 30-real-second checkpoint/10-real-minute backup cadence at 1× and 60×; validated backup rotation/lifecycle triggers and failure retention; completed-minute as-of/live totals and 48-hour/90-day simulated retention; session starts after committed catch-up; ready-waiting versus growth and expansion-time capacity; profile-owned settings restored before audio with unsaved cosmetic failure; authored one-time future-harvest contract lifecycle, abandon/reaccept fresh instance, completed-unclaimed slots and durable claimed-offer protection. M03 generic fixtures do not prove implementation of the now-approved C2 M05 contract content. T-030 is an M03 probe, not optional M06-only work.

### 15.1 Audit A1 acceptance extensions (future runtime checks)

The existing T-001–030 remain binding. AV criteria below are source-level extensions, not passed tests. Each milestone’s A1 task crosswalk and new validation row own their staged execution. “Failed-commit rollback” in an existing criterion means a definitely NOT_COMMITTED attempt; an uncertain receipt follows AV-002 reconciliation rather than an assumed rollback. AV-008/009 are document checks; they do not imply game execution.

| Criterion | Exact required result |
|---|---|
| AV-001-01 | Restore a checkpoint before an allocation: the new full dynamic identity differs while the restored old entities retain their IDs; retired command payloads are stale. |
| AV-001-02 | Restore before Q01’s claim: old reward and closure both roll back; eligibility follows the recovered timeline, with no separate additive payout. |
| AV-001-03 | Fixed injected namespace and identical accepted inputs produce identical IDs, scheduler order and aggregation/reference state across active/debug/offline/forecast. |
| AV-001-04 | Round-trip composite references and counters at valid integer bounds; reject collisions/malformed references before mutation; preserve namespace during receipt reconciliation. |
| AV-002-01 | DB commits revision 41 but receipt is lost while memory is 40: all write routes remain blocked until read-back selects 41; no second debit or stale overwrite. |
| AV-002-02 | A definitely rolled-back operation verifies the unchanged parent and can report not committed; an unsettled/failed read cannot be treated as rollback. |
| AV-002-03 | Exercise auto, catch-up, time-only, settings, migration and startup receipts, not only manually identified economic commands. |
| AV-002-04 | Try retry, new purchase, settings save, backup and shutdown during UNKNOWN; preserve good backups and fail closed without an old snapshot save. |
| AV-002-05 | After reconciliation/crash, compare full state, replay marks, accepted IDs and state+anchor/real-interval accounting against uninterrupted execution; inject equivalent asynchronous outcomes through portable fakes. |
| AV-003-01 | A level-7/5,200-XP profile with Auto Replant remains valid on its original immutable manifest when a different manifest raises level 7 to 6,000. |
| AV-003-02 | Lowered thresholds and changed rank maxima/prerequisites in a new manifest never apply implicitly to an old profile; unsupported/missing definitions preserve its save. |
| AV-003-03 | Validate level−1=unspent+allocated and one-point awards/surplus for current and supported legacy contexts across active/offline/forecast/restart. |
| AV-003-04 | Supported schema migration preserves manifest reference, XP, allocation, cycle/research/contract snapshots and IDs; fail/interrupt/retry with a valid backup and no duplicate award. |
| AV-003-05 | A separately approved content migration, if later supplied, must have a version-specific exact mapping and idempotent commit tests before it is enabled; no such mapping is approved here. |
| AV-004-01 | A click crosses a due harvest: that batch commits first, the controller stamps current time, and unchanged authorized terms may execute without backdating. |
| AV-004-02 | Change target cycle/project, exact cost, modifier result, content context or recurring plan: reject/refresh with no charge or automatic replacement purchase. |
| AV-004-03 | Boost preview ages naturally: fixed charge/formula stay authorized; accepted-time result uses ceil(remaining/2), and completed/1-μs/no-time-saved cases reject uncharged. |
| AV-004-04 | Unrelated extra income can increase ending wallet but never lower the confirmed minimum or increase cost; reset level/price change requires refresh. |
| AV-004-05 | Duplicate pending intent and lost acknowledgement cannot become a fresh purchase; accepted logs replay exact ordering, while rejected gameplay equality excludes independently committed due work. |
| AV-005-01 | W=100/R=0: Corn (18)+Premium (75) without fallback on plot 1, Corn (18)+None on plot 2. Plant plot 2 only, spend 18, end at 82; plot 1 stalls uncharged. |
| AV-005-02 | Cascading exclusions and newly affordable seed candidates terminate with≤N exclusions/≤N+1 passes; input permutation leaves the same canonical plan. |
| AV-005-03 | Under the approved current Corn prices, W=100 with plot 1 Corn (18)+Basic (20), plot 2 Corn (18)+Premium (75), plot 3 Corn (18)+None starts with S=54/A=46: Basic fits but Premium fails; exclusion/replan yields a defined stable subset. Add a labeled synthetic package fixture to demonstrate allowed non-maximality without calling it production balance. |
| AV-005-04 | Fallback accepted/declined, R>W, advanced seed protection, zero-cost seeds, priorities and fixed-before-Smart all preserve no negative balance and one final shared C. |
| AV-005-05 | A planning/stall-reason event cannot self-trigger unbounded zero-time retries. Offline aggregation and forecast match the event reference at each actual logical batch, including full failed-commit rollback. |
| AV-006-01 | For each of 11 required ranks assert predecessor, exact cost, insufficient funds, duplicate/skipped/max-rank rejection and no partial state/ID drift. |
| AV-006-02 | Under A, an explicitly funded valid level-1 fixture may buy rankI and later ranks sequentially without invented research/skill/contract gates. This is an isolated guard fixture, not a new-game cash grant. |
| AV-006-03 | Existing crop duration/reward snapshots remain unchanged; next planting uses additive equipment effects and the growth cap, with exact quote/execution parity. |
| AV-006-04 | Run actual full-cost upgrade-using strategies and the existing no-equipment/no-contract path. Report pacing outcomes without changing prices or gates silently; deferred families remain absent. |
| AV-007-01 | Create/rename/assign/unassign/delete with unique group IDs, zero/one membership and valid destinations; malformed/missing references reject unchanged. |
| AV-007-02 | Moving a stalled None plan to paid Advanced, or deleting its group to a paid farm default, cannot spend or silently arm without the existing explicit changed-plan start authorization. |
| AV-007-03 | Occupied cycles remain immutable; explicit future Apply and Ready-on-enable effects are previewed; new Empty/Locked plots never auto-start/unlock from membership. |
| AV-007-04 | A rename or overridden field leaving the effective purchase plan unchanged preserves existing valid loop authorization; explicit false/zero remains an override. |
| AV-007-05 | A failed structural mutation rolls back all graph changes; separately requested eligible action subsets still follow DEC-025 and commit coherently, with no charged failed member. |
| AV-007-06 | Unresolved preset references block deletion; save/reopen/backup/forecast preserve graph, versions and plan authorization. No live forecast writes or hidden group budget overrides. |
| AV-008-01 | Every operative Open/Proposed/missing approval claim about C1/C2/C3/DEC-027 is either genuinely pending or explicitly labeled historical; no settled choice is reopened. |
| AV-008-02 | After authorized edits, cross-check original decision status, source sections, task/test IDs, links, current hashes and preserved dated approval evidence. Runtime test status remains pending. |
| AV-009-01 | Every displayed SHA-256 has exactly 64 hexadecimal characters and equals the hash of the specifically named baseline bytes; preserve original and amended manifests separately. |
| AV-009-02 | All local links resolve and line numbers exist; all HTTP(S) targets contain no whitespace; compare the corrected release URL and CPU/2.5D tokens byte-for-byte with authoritative sources. |
| AV-009-03 | Review the erratum/diff: only intended technical-token/format repairs and explicit status notes change; original findings and approval evidence are not silently rewritten. |

## 16. Prioritized implementation backlog and milestone completion

**No game implementation is assumed to have been performed.** This is the agreed execution sequence and deliverable expectation, to be expanded into one plan per milestone.

### M01 — Headless simulation foundation (**P0**)

**Depends on:** Pinned Godot 4.x/GDScript project and content convention.

Tasks:
- Define GameState, PlayerState, PlotState, CropDefinition, CropCycle, ContentRegistry.
- Define typed command/result and event types.
- Implement SimulationClock, injectable TimeProvider, deterministic EventScheduler.
- Implement planting, maturity, manual harvest, coins/XP and levels.
- Create headless test runner and reproducible fixtures.

**Definition of done:** 32 plots, independent crop timing, normal and accelerated simulation, exact base rewards, and deterministic headless replay; no graphics needed.

### M02 — Economy, skills, research, and automation (**P0**)

**Depends on:** M01.

Tasks:
- Implement all three skill branches, prerequisites, caps and paid resets.
- Add required Irrigation/Improved Soil purchases, level + research crop unlocking, one active research project and the approved single half-cost/half-remaining boost. Exclude deferred Seed Efficiency/Research Facilities/Growth Booster under DEC-008/G5.
- Implement auto-harvest, auto-replant, simultaneous batch ordering, stalled plot retries.
- Add fertilizer pricing, fixed recurring purchases, exact/ROI Smart modes, inheritable farming rules, farm-wide wallet controls and the single batch-wide protection ceiling. Define advanced preset/priority/rotation record interfaces/gates now; complete their behavior/UI in M05.
- Add full-cost economy strategy traces under DEC-024/G5 for the 3–5-hour automation target; do not claim automated engagement evidence.

**Definition of done:** Automated farming/economy work in headless tests, shared coins never overspent, fixed/smart fertilizer policies correctly applied, research and skills unlock correctly.

### M03 — Saves, clock integrity and offline farming (**P0**)

**Depends on:** M01/M02 and a verified SQLite integration.

Tasks:
- Implement repository boundary, Windows SQLite adapter, schema versions, checkpoints, backups and migrations.
- Implement TimeProvider and credited-through UTC high-water policy, sleep/resume reconciliation, debug/offline distinction.
- Implement isolated offline catch-up, atomic result+anchor commit, retry/recovery.
- Add clock anomaly, crash/fault injection, duplicate claim/harvest, long-offline tests.
- Implement durable base statistics under approved G4 timeline/window/session/utilization contracts, profile-owned settings and approved authored contract lifecycle records, plus G3 budget/authorization/rotation/boost fields.
- Run the minimal browser boot/render/storage-error/resume probe and record T-030 evidence or explicit findings; retain native-free shared-core boundaries.

**Definition of done:** Save/exit/reopen and offline progression correct; approved durability/cadences and accounting/settings records validated; clock provider adequacy measured; minimal T-030 probe performed with honest results; interrupted operations cannot duplicate/partly charge. Full web release and exact contract content remain separate.

### M04 — Visual farming game, art, and UI (**P1**)

**Depends on:** Stable M01–M03 gameplay contract.

Tasks:
- Implement isometric 1920 × 1080 farm scene; 24 active/8 locked plots; mouse interactions and state updates.
- Generate and integrate consistent crop-stage artwork and idle swaying.
- Implement crop selection, Store, Skills, Research, Settings and offline summary panels.
- Integrate AudioManager, music/volume settings, ready/harvest aggregation.
- Implement dev-only 1×–60× slider and diagnostics (gameplay still controlled by simulation).

**Definition of done:** The visual game displays authoritative state, performs normal farming interactions, keeps audio/render separate, and does not change simulation economics.

### M05 — Contracts, statistics, complete progression (**P1**)

**Depends on:** M01–M04.

Tasks:
- Implement all twelve C2 authored definitions/guards/predicates/frozen rewards from FRS §10, optional Board, independent concurrent progress and existing manual accept/claim/confirmed abandonment workflow.
- Build Level-1 accessible Statistics & Profitability panel with historical and projected metrics.
- Finish higher-tier crops/research and required Irrigation/Improved Soil content plus complete preset CRUD/apply, custom priorities/seed reserve, approved rotation and advanced automation UI/recovery; retain all first-release skill gates. DEC-008 deferred families remain excluded; no inclusion decision is needed to finish M05.
- Finalize time-bucket aggregation and forecast copy-isolation.
- Perform active/offline strategy balancing with full economy including fertilizer and research costs; prepare the varied normal-speed human protocol/sample/diaries for M06 under DEC-024, without treating simulated output as engagement.

**Definition of done:** All agreed first-release systems integrated; historical and forecast reporting accurate; contracts never mandatory; progression test scenarios recorded.

### M06 — Validation, performance and Windows release (**P1**)

**Depends on:** M01–M05.

Tasks:
- Close unit/integration/recovery/performance regressions and save migration tests.
- Benchmark 32-plot 60× and 30-day/year catch-up on identified reference hardware.
- Qualify 3–5-hour automation using full-cost strategies and normal-speed human observations; evaluate ~48 further engaging active hours using actual extended human findings, five-real-minute provisional indicator plus diaries and explicit sample/evidence limitations.
- Verify GPU rendering, scaling, audio controls and asset consistency on supported Windows hardware.
- Produce the approved versioned standalone Windows ZIP/executable package with data/native libraries/licenses/checksums and documented per-user save/update/recovery paths. Installer/signing is optional by separate concrete selection; Steam/cloud integration stays beyond v1. Verify clean-user offline launch and save preservation on application replacement/removal.

**Definition of done:** Acceptance matrix passes or has documented approved exceptions; deterministic economy and saves verified; first Windows build ready for release consideration.

**Future/P2 exploratory work:** full production browser release/storage migration/import/export/audio integration and broader browser qualification, prestige-compatible migration and optional Steam integration. The approved minimal end-M03 boot/render/storage-error/resume probe is **not deferred** to this future list. Seed Efficiency, Research Facilities and Growth Booster are explicitly Deferred beyond current v1 scope (DEC-008/G5), revisited only after playtest findings and a separately approved scoped content/impact proposal; the required research boost stays in v1.

## 17. Explicit unresolved decisions and risk register

| Topic | Current decision or next action | Risk if ignored |
|---|---|---|
| Godot version | DEC-001/C1 Godot 4.7.2-standard/editor+templates, GUT 9.7.1 and x86_64 selected; verify actual artifact identities/hashes/licenses/APIs before adoption | Nonreproducible builds |
| SQLite integration | DEC-001/C1 evaluates isolated godot-sqlite v4.9/reported SQLite 3.51.0; exact artifact/native fingerprints/license inventory and WAL/backup/export adoption evidence still open | Deployment, corruption or unsupported plugin |
| Pinned renderer | DEC-001 Compatibility baseline approved; verify chosen Windows GPUs and future minimal web behavior | Unsupported shaders or browser port if not validated |
| Reference hardware | DEC-023/G5 protocol and H2 target envelope approved: Ryzen 5 7600X3D/≥16 GB/SSD, RTX 2080-or-better or AMD similar/higher specifications. Record actual selected configuration/OS/driver before M04 and qualify final vendor matrix in M06 | Unmeasurable performance targets |
| Growth-time rounding | DEC-005 approved: ceil to whole microseconds, minimum 1 μs; implement exact checked integer tests | Inconsistent simulation outcomes if not implemented |
| Same-timestamp manual inputs | DEC-006/016 approved: due phases before serialized commands; profile/epoch/counter replay protocol | Determinism/replay failures if not implemented |
| Save commit cadence | DEC-015/G4 approved economic commit-before-success, WAL/FULL, 30-real-second time checkpoints, two backups/10-real-minute rotation plus validated lifecycle points; measure latency without silently weakening durability | Excess disk writes / lost progress |
| Credited anchor, sleep | DEC-013 ledger and DEC-014/G4 Godot-first/native-if-needed procedure approved; exact provider/API and measured evidence remain Open | Lost/double offline time if observations or reconciliation are wrong |
| Optimizer algorithm | DEC-009/G3 exact Pareto-pruned rate strategy + ROI greedy preference approved; oracle/32-plot benchmarks still required; approximation needs a new explicit decision | Slow or misleading Smart Fertilizer if strategy is not validated |
| XP curve / continuation | DEC-002/G2 through level 30 + C1 increasing option B approved as provisional data; implement exact rounded recurrence/points with full long-offline validation. Final pacing/balance remains provisional | Implicit cap, lost XP or broken 3–5/48h pacing |
| Starting state / plot layout | DEC-003/020 approved: zero funds/XP, 8×3 Empty start, fixed eight-column IDs, fourth-row 25→32 sequence with no unlock gaps | Invalid initial fixtures, skipped expansion purchases or shifted plot ownership |
| Skill rank/prerequisite policy | DEC-004 approved: one point/rank/node, preceding growth/profit tier rank ≥1, immediate-predecessor automation chain; effects/maxima/cap retain provisional status | Unreachable automation, unwanted full-tier costs or invalid point totals |
| Research acceleration | DEC-007/G3 approved initial one-project/one-boost policy: ceil(C/2) cost and ceil(remaining/2), using actual paid snapshot; coefficients remain provisional and need tests | Unbalanced timing/duplicate charges if not validated |
| Economic content | DEC-024/G5 full-cost automated + normal-speed human evidence policy approved; separately approve any tuning, preserving snapshots. DEC-008 optional families Deferred; no invented rules/placeholders | Dominant crop/consumable strategies |
| Generated art pipeline | DEC-023/C3 Clean illustrated direction approved from column A; M04-T02 specifies production art bible/sample parameters and validates readability/provenance before bulk assets. Qualify all 75 stages and final visual/audio tuning in M04–M06; style selection is settled, production results remain unverified | Inconsistent visuals and asset overhead |
| Browser persistence | DEC-022/G4 end-M03 minimal probe approved; production adapter remains future; fix native leakage and label actual/partial evidence | Future port difficulty |
| Statistics/settings/contracts | DEC-017/018/021 policy and DEC-019 C2 twelve-offer catalog/guards/rewards are approved; qualify actual metadata/evaluation/recovery/balance evidence | Misleading reports, lost settings or duplicate claims |
| Distribution | DEC-027/G6 standalone versioned ZIP selected for v1; optional installer/signing needs separate selection; Steam/cloud/storefront integration deferred. Qualify clean launch/update/native dependencies/per-user save preservation in M03/M06 | Missing DLLs, accidental save loss or scope creep |

No further major gameplay systems should be added to the first-release scope without reviewing impact on progression, economy, persistence, UI, implementation effort, and tests. Changes to persistent fields require migration and content-version policy.

## 18. Technical baseline acceptance checklist

- [ ] Gameplay logic is independent of the Godot scene tree and supports headless execution.
- [ ] Root state, crop cycle snapshots, stable IDs, and command/event contracts are defined.
- [ ] Integer and fixed-point computations are consistent and bounded.
- [ ] Manual, automated, debug, and offline gameplay share one simulation implementation.
- [ ] Simultaneous harvests and coordinated planting budgets are deterministic.
- [ ] Smart Fertilizer, settings inheritance, reserve and fallback rules are testable.
- [ ] Active monotonic time, UTC offline anchor and 1×–60× simulation time are separated.
- [ ] Clock rollback, sleep/resume, DST and known forward-clock limitation are documented and tested.
- [ ] Offline catch-up is isolated, efficient and committed with its time anchor.
- [ ] Save transaction semantics, one-writer rule, backup and migration requirements are defined.
- [ ] Statistics/forecast produce consistent accounting and do not mutate live state.
- [ ] UI and audio consume post-commit state/events and never independently modify rewards.
- [ ] Test matrix covers crashes, duplicates, long offline periods, and debug equivalence.
- [ ] Milestone deliverables and definitions of done are documented.
- [ ] Open third-party, hardware, and balance decisions are tracked rather than silently assumed resolved.

---

**Change control:** Update this document when *technical contracts, lifecycle, data model, timekeeping, persistence, testability, performance, or deployment architecture* changes. Gameplay content/feature decisions belong in `IdleFarmer_Functional_v1.0.md`. This specification describes requirements and implementation architecture only; **no game code has been created**.

## 19. Approved clarification history

| Date / revision | Approval evidence | Incorporated requirements | Still open |
|---|---|---|---|
| 2026-10-26 / G1 | Project owner: “Approve Group 1” | DEC-001 toolchain/framework/renderer direction and SQLite evaluation candidate; DEC-005 checked arithmetic/rounding; DEC-006 phase/command ordering; DEC-013 interval ledger/high-water consequences; DEC-016 bounded replay/epoch protocol; DEC-026 finite-representation recovery | Exact editor/templates/GUT/addon/native pins; empirical clock source; all unconfirmed decisions, including cadence, optimizer, progression and budget policy |
| 2026-10-27 / G2 | Project owner: “Enforce sequential unlocking, i.e. no holes between unlocked plots.” and “The rest of Group 2 - approved” | DEC-020 amended initial 8×3/fixed eight-column geometry and sequential fourth-row 25–32 unlocking; DEC-003 zero/Empty initial state; DEC-004 one-point/minimum-rank/automation-chain policy; DEC-002 through-30 provisional development table only | Beyond-30 policy; exact dependency pins; final economic balancing and all other unconfirmed decisions |
| 2026-10-27 / G3 | Project owner: “Approve Group 3” | DEC-007 one-project/one-boost policy; DEC-009 exact/ROI guarantees and mixed-mode order; DEC-010 farm-wide controls/cap/fallback; DEC-011 skill gates/seed toggle; DEC-012 staged advanced work; DEC-025 explicit lifecycle and eligible-subset batches | Group 4 choices, exact pins, beyond-30, final balancing and empirical benchmarks remain unapproved/unverified |
| 2026-10-27 / G4 | Project owner: “Group4 approved as recommended” | DEC-015 durability/cadences; DEC-017 minute-window timeline; DEC-018 sessions/productive utilization; DEC-021 profile settings; DEC-022 M03 probe; DEC-014 measurement-first policy; DEC-019 authored lifecycle/schema and provisional gates | Exact provider/API/evidence; exact authored contract objectives/quantities/challenges/rewards; other unconfirmed groups, pins, beyond-30 and empirical qualification |
| 2026-10-27 / G5 | Project owner: “group 5 aapproved as recommended” | DEC-023 representative baseline/vendor/sample-review protocol; DEC-008 three optional families Deferred; DEC-024 automated economy + normal-speed human evidence and provisional five-real-minute/diary indicator | Named hardware/art/assets/tuning; actual participant protocol/sample/findings and all empirical qualification; exact pins/provider/contract content/beyond-30; Group 6 packaging |
| 2026-10-27 / G6 | Project owner: “Group 6 approved as recommended” | DEC-027 standalone versioned Windows ZIP policy, packaged dependencies/licenses/checksums, per-user save preservation; optional installer/signing and deferred Steam/cloud/storefront integration | Exact dependency/provider/architecture/hardware/art/content selections and empirical qualification; no published or tested release is claimed |
| 2026-10-27 / C1 | Project owner: “DEC-001 - approved, DEC-002 - use option B” | Named Godot 4.7.2/templates/GUT 9.7.1/SQLite-v4.9 evaluation/x86_64 choices; increasing10% post30 increment recurrence and one-point/surplus retention, source anchors preserved | Actual artifact/checksum/license/adoption evidence, empirical provider, authored contract content, hardware/art selections and final balance; no game code/test result |
| 2026-10-28 / C2 | Owner: “Closeout B option A - approved” | DEC-019 twelve exact authored offers, availability/auto-source/mixed/gross/post-acceptance/concurrent predicates, frozen rewards and canonical FRS table; one-time manual lifecycle preserved | Actual artifact/provider/hardware/art verification and all game/predicate/recovery/balance evidence remain pending; no implementation/test result |
| 2026-10-28 / H1 input | Owner supplied Ryzen 5 7600X3D, 16+GB RAM, SSD, “Nvidia RTX 2800+” | CPU/RAM/storage reference-target components recorded; GPU retained as unresolved literal, clarification requested | Exact GPU/“+”, actual measured configuration/OS/driver and art/assets/tuning remain Open; no complete hardware baseline or benchmark is claimed |
| 2026-10-28 / H2 clarification | Owner: “GeForce RTX 2080 or better or any AMD videoboards with similar or higher specs” | Reference-target GPU clarified; Ryzen 5 7600X3D, ≥16 GB RAM and SSD retained; compatible Intel policy unchanged | Exact qualification configuration/results and concrete art/assets/tuning remain pending; no universal performance or model-number equivalence claim |
| 2026-10-28 / C3 | Owner: “DEC-023 - agreed with option A.” | Clean illustrated direction selected from column A; FRS §§2.1/16 and TRS §11.1 own the style/art-pipeline requirements; H2 hardware target retained | Production art-bible parameters/sample validation, all 75 stage assets, actual configuration/results and final audio/aggregation tuning remain future work; no game code/test pass |

**A1 audit application — 2026-10-28:** Audit Groups 1–4 explicitly approved 001–004 B, 005–006 A, 007 B, 008–009 A; owner then instructed applying all Approved resolutions | Scoped recovery identity/claims, UNKNOWN commit protocol, immutable profile manifests, semantic accepted input, monotone replanning, exact equipment guards, group lifecycle; source/task/test synchronization and audit erratum | Game implementation/runtime tests, actual artifact/provider/production evidence and final balancing remain pending; original Open/Deferred choices unchanged

Version family 1.5 and its filename are retained explicitly for approved clarifications so companion links remain stable; G1–G6 and C1–C3 identify dated cumulative changes. This is a requirements update, not an engine/schema release or proof that any application code/tests exist.

## 20. Applied audit contracts — A1 (2026-10-28)

These are the selected approved rules, synchronized into the operative contracts above. They add precision to existing features without retuning provisional content or authorizing deferred mechanics. All future game/runtime evidence remains unexecuted.

### 20.1 AUD-R-001 — Recovery identity and authoritative timeline

Approval: AUD-DEC-001 B; functional counterpart FR-AUD-001; exact criteria AV-001-01–04.

Use B. A restored checkpoint and its replayed surviving history are the authoritative timeline. One-time offer protection applies within that timeline; any discarded-branch claim credit is discarded with its claim flag. New dynamic entities use the injected startup namespace plus checked counter; existing entities, plot IDs and authored IDs retain their identities. Recovery messages state the recovered time/revision and possible lost progress. No claim-only ledger or global anti-rollback promise is introduced.

**Implementation contract.** Create the fresh namespace under owned-profile startup before catch-up allocations and include it in the startup result checkpoint before active input. A failed pre-commit attempt may restart with a new injected namespace; the external input changed, so production entity IDs need not match that abandoned attempt. Mode-equivalence and deterministic retry tests use the same injected namespace/input stream. During an uncertain commit, keep the pending identity context until AUD-DEC-002 resolves it; do not rotate or issue replacements early. Preserve the original scheduler’s logical counter/phase ordering explicitly: do not use UUID lexical order as an accidental new priority. Counter overflow follows DEC-026.

### 20.2 AUD-R-002 — Commit outcome reconciliation

Approval: AUD-DEC-002 B; functional counterpart FR-AUD-002; exact criteria AV-002-01–05.

Use B. Every save attempt has a unique commit identity, expected parent durable revision and prepared complete result. Unknown outcomes block all repository writes and economic input until the settled primary is verified. A matching result restores the complete committed outcome; a verified unchanged parent allows a definite not-committed result. Any other/unreadable state remains a recoverable stopped condition. Never replace the original operation with a fresh purchase.

**Implementation contract.** Block economic commands, time-only/settings checkpoint writes, migration, backup rotation and normal shutdown save while UNKNOWN. Cosmetic audio drafts may remain local with unsaved indication. Resolve open statements/transactions and in-flight operations before read-back; autocommit/transaction-state observations alone do not prove which logical result committed. After reconciliation rebuild scheduler, replay high-water, interval ledger and anchor from the selected state. Preserve pending real-time observations and reconcile them exactly once before active play resumes. A rollback is not permission to replay already credited time. Startup namespace rotation obeys AUD-DEC-001. Expected-parent checks and commit identity operate on a dedicated durable revision, avoiding conflation with unsaved time advancement.

**Checkpoint identity ownership:** checkpoint commit IDs are coordinator metadata, issued uniquely outside gameplay entity allocation (for example profile/writer epoch/commit-attempt counter). They must not consume `next_entity_id` or change crop/event/transaction identity order merely because time-only/settings checkpoint cadence differs. Keep the same pending ID during UNKNOWN reconciliation. Compare economic identities exactly across mode tests; separately validate each run’s expected durable revision/receipt metadata, whose checkpoint schedule can differ. This implements the already-approved separation of durable and simulation revisions.

### 20.3 AUD-R-003 — Immutable supported progression manifests

Approval: AUD-DEC-003 B; functional counterpart FR-AUD-003; exact criteria AV-003-01–05.

Use B. Resolve each save to its immutable supported progression/content manifest before validation, catch-up, quotes or input. Keep level as the highest threshold reached under that manifest and earned points as level−1, partitioned into unspent plus allocated one-point ranks/nodes. Unsupported references produce a recoverable no-overwrite error. Incompatible progression migration requires a separate approved mapping; absent that mapping, the profile remains on its supported old manifest.

**Implementation contract.** This is not a balance change and does not force permanent support for arbitrary formats. Record the set of supported manifest versions in each build. Retain all definitions needed to interpret a supported profile’s curve and allocations; keep its quotes, UI, offline run, forecast and save validation on the same context. Pure schema migrations preserve the manifest binding. Economic data retuning outside progression also remains versioned and separately approved; existing planted/research/contract snapshots remain immutable. No extra awarded-level watermark is required under the unchanged pinned-curve invariant. Test changed-curve examples as separate manifests, not by silently editing the current approved one.

**M02 implementation note — 2026-10-30 (non-normative):** `content_m02_v1` was frozen at M02-T18. Both supported manifests (`content_m01_v1` and `content_m02_v1`) are pinned by a canonical content digest in `tests/unit/test_manifest_freeze.gd`, so an in-place edit to either fails the test suite. A content change therefore needs a new manifest version.

### 20.4 AUD-R-004 — Accepted input and semantic confirmations

Approval: AUD-DEC-004 B; functional counterpart FR-AUD-004; exact criteria AV-004-01–05.

Use B. Unaccepted UI intents carry their target and confirmation terms, not an authoritative past simulation timestamp. The controller completes due work, forms the accepted envelope at current simulation time, and records serial order. Once formed, an accepted envelope is immutable and stale/future envelopes are rejected by the engine; replay advances to recorded accepted times. Confirmed purchases execute only under unchanged authorized semantic terms, or return a refreshed rejection. No automatic replacement operation is issued after lost acknowledgement.

**Implementation contract.** For manual planting/override, preserve crop/fertilizer/fallback and quoted economic results/cost; the confirmed ending balance is a minimum bound, so an unrelated extra harvest may leave more coins but never authorize a lower balance or greater charge. If modifiers/terms change, refresh rather than infer that the player prefers the change. Reset quotes bind level and its derived exact price. Research boost quotes bind project identity, original paid C, fixed charge, boost-unused state and the rule “halve remaining time when accepted”; time saved/new completion are explicitly as-of preview values, recomputed at accepted time and shown in the result. Reject completed/no-time-saved/already-used/unaffordable boosts unchanged. Quote refresh is not acceptance. Rejection equality is measured after independently due work; rejecting input cannot undo a due economic batch. IDs for repeated pending UI delivery are reused/deduplicated through the controller protocol, not regenerated as fresh purchases.

### 20.5 AUD-R-005 — Terminating seed/fixed-fertilizer replanning

Approval: AUD-DEC-005 A; functional counterpart FR-AUD-005; exact criteria AV-005-01–05.

Use A. Exclude a failed no-fallback fixed request permanently for the current logical batch, recompute the remaining seed/fixed plan in canonical order, and never reinsert it in that batch. Run at most N+1 seed/fixed passes after at most N removals. Apply accepted fallback explicitly. Only after the final feasible plan compute M and the single C, then run the already approved Smart groups. Charge only cycles actually planted.

**Implementation contract.** Snapshot W, effective priorities, crop/plan/authorization and farm budget for the logical batch. On a restart discard all tentative seed/fixed reservations and recompute from the remaining universe; do not carry partial spending. Seed-unfunded candidates stay eligible for a later replan if a removal frees seed capacity. A request excluded for refused/unaffordable fixed fertilizer stays out until a later genuine relevant funds/configuration change, not merely a changed blocked_reason. For W=100 with plot 1 Corn (18)+Premium (75)/no fallback and plot 2 Corn (18)+None, plot 1 is removed and plot 2 plants, ending at 82. A non-maximal final subset is permitted and disclosed; no crop/fertilizer substitution occurs. Limits here bound planning work, not elapsed time or rewards.

### 20.6 AUD-R-006 — Required equipment purchase guards

Approval: AUD-DEC-006 A; functional counterpart FR-AUD-006; exact criteria AV-006-01–04.

Use A: Irrigation and Improved Soil purchases require sufficient coins, an available next rank, and the immediately preceding owned rank only. No additional player-level, research, skill or contract prerequisite applies. Keep the existing six/five rank prices and per-rank effects provisional and unchanged. Purchase previews show the exact marginal effect and cap interaction, and apply only to future plantings.

**Implementation contract.** Manifest rows, recommended A: Irrigation I–VI cost 650/2100/12000/60000/300000/1500000, each adds −5% base growth time; Improved Soil I–V cost 900/3000/20000/110000/650000 and add +10/+10/+15/+15/+20% gross respectively. All rank rows use minimum player level 1 (meaning no extra level restriction), research guard None, contract guard None, skill guard None and previous family rank n−1. A valid wallet still matters; no starter grant is implied. This table supplies guards, not final numerical balance. Any later tuning/gate revision must be approved and versioned, with old-profile treatment under AUD-DEC-003.

### 20.7 AUD-R-007 — Plot-group lifecycle and effective-plan consent

Approval: AUD-DEC-007 B; functional counterpart FR-AUD-007; exact criteria AV-007-01–06.

Use B. A plot references at most one existing group or none. Group mutations validate the entire structural result and use the same effective-plan/quote/capability checks as direct configuration. Rename-only changes leave economic authorization intact. Effective changes to occupied plots require explicit future-settings Apply; current cycles stay immutable. New Empty starts, changed stalled plans and rearming require explicit Plant/ApplyAndStart. Deleting a group requires an explicit destination or ungroup choice, preview, and resolution of all preset references; no silent fallback to paid defaults.

**Implementation contract.** Define stable group IDs and group/settings revisions; dynamic group identities use AUD-DEC-001. Only economic semantic changes invalidate plan authorization, not a display rename or an overridden group field that leaves a plot’s resolved plan unchanged. Pending UI selection is a draft; execution revalidates the effective diff. Structural membership/deletion is all-or-nothing: reject invalid destinations/dangling references with no partial graph update. A separate/combined explicit farming-action intent still uses DEC-025 eligible-subset results and one coherent durable commit. It never turns a rejected structural edit into a partly deleted group. If Apply explicitly enables Auto Harvest on Ready, preview that existing immediate-harvest consequence and reuse the normal engine transition. Skill-ineligible rules remain inactive; rebuy never rearms them. Locked plot IDs may hold inactive group settings, but grouping cannot unlock or plant them; purchase still requires N+1 and later explicit start. No new administrative level gate is added; saving/applying named farm presets retains its owned level-12 node, and every field retains its original capability gate. M02 only defines these advanced contracts/default records; full UI/advanced behavior stays M05.
