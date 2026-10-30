# Idle Farmer — Audit Decision Register

> **Current verification amendment R2-C1 — 2026-10-29:** The metadata, options, approval log and Applied fields below preserve their dated A1 record. Current documentation-only outcomes are in §11 and the [R2 correction changelog](../audit/round_02/R2_Correction_Changelog.md): AUD-001–008 are Verified Resolved; DOC-001 remains Partially Resolved only for independently unavailable pre-A1 baseline-byte evidence. All three Round 2 cleanup findings are addressed; no approval choice, parent decision status or runtime validation is changed.

**Document ID:** IF-AUD-DEC  
**Revision:** 6 — 2026-10-28 (America/New_York); all approved corrections applied  
**Scope:** Findings, approved resolutions and completed documentation application; game implementation excluded  
**Decision state:** **All nine audit decisions are Approved: AUD-DEC-001 B, 002 B, 003 B, 004 B, 005 A, 006 A, 007 B, 008 A and 009 A. All nine are Applied to documentation. None is marked Verified; game implementation/runtime tests remain unrun.**  
**Owner/approver:** Project owner; Group 1 approved on 2026-10-28, exact confirmation **“Approve Group 1 recommended”**; Group 2 approved on 2026-10-28, exact confirmation **“Group 2 Approved recommended”**; Group 3 approved on 2026-10-28, exact confirmation **“agreed with group 3 recommendations”**; Group 4 approved on 2026-10-28, exact confirmation **“group 4 approved as recommended”**  
**Reviewed pre-A1 baseline:** FRS v1.0, TRS v1.5/C3, original Decision Register revision 14, pre-correction roadmap/M01–M06  
**Current applied baseline:** FRS v1.0 with A1, TRS v1.5/A1, original Decision Register revision 15 and A1 roadmap/M01–M06  
**Implementation:** Approved documentation corrections applied across source specifications, roadmap, all six plans and audit evidence. Game implementation not started; no runtime verification claimed.

## 1. Review basis and authority

This register responds to the attached “Audit Findings Resolution and Decision Review” request. It reviews all eight original audit findings independently and adds one separate Low documentation-quality finding discovered while reading the saved audit outputs. The latter is not a new gameplay decision or a rewritten original finding. The options were initially proposed for review. Revision 2 recorded approval of Group 1’s three recommended B options. Revision 3 recorded approval of Group 2’s recommended AUD-DEC-004 B. Revision 4 recorded approval of Group 3’s AUD-DEC-005 A, AUD-DEC-006 A and AUD-DEC-007 B. Revision 5 records approval of Group 4’s AUD-DEC-008 A and AUD-DEC-009 A; all nine audit selections are now Approved. Unselected alternatives are retained for history and are not approved.

The four audit files were read, their findings compared with the current requirements and source tasks, and the original source fingerprints recomputed. At the resolution-analysis baseline, all ten authoritative planning documents and the reference image were byte-identical to the original audited baseline. A1 now amends the planning documents as logged; the reference image remains unchanged. The complete source package had already been read during the audit; this review rechecked that exact baseline and revisited its affected sections and all six owning milestone plans. The original 27-topic register actually records **23 Approved, 3 Open with approved subparts and 1 Deferred**; it does not record 27 fully Approved parents. See [DR decision index, L54](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:54) and [DR remaining facts/evidence, L1234](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:1234). This review preserves those statuses and all existing provisional balance boundaries.

FRS owns gameplay; TRS owns technical contracts. The original DR records the approvals; this audit register records proposed corrections and any explicitly required amendment/clarification. A recommendation here never overrides an original approval. Approved exceptions, if later selected, must name exactly which wording changes. Rejected alternatives and historical approvals remain history, not executable competing requirements.

| Alias | Exact document |
|---|---|
| FRS | [IdleFarmer_Functional_v1.0.md](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) |
| TRS | [IdleFarmer_Technical_v1.5.md](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) |
| DR | [Decision_Register.md](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) |
| RM | [00_IdleFarmer_Master_Roadmap.md](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) |
| M01 | [01_M01_Headless_Simulation_Foundation.md](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md) |
| M02 | [02_M02_Economy_Skills_Research_Automation.md](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) |
| M03 | [03_M03_Saves_Time_Offline_Farming.md](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) |
| M04 | [04_M04_Visual_Farm_Art_UI_Audio.md](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) |
| M05 | [05_M05_Contracts_Statistics_Complete_Progression.md](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) |
| M06 | [06_M06_Validation_Performance_Windows_Release.md](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) |
| AR | [PreDevelopment_Audit_Report.md](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md) |
| TM | [Requirements_Traceability_Matrix.md](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md) |
| VS | [Design_Validation_Scenarios.md](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md) |
| RD | [PreDevelopment_Readiness.md](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Readiness.md) |

Historical evidence locations in the analysis entries below cite the frozen pre-A1 files by section/task and one-based line; source edits have shifted current lines. The correction changelog gives exact before/after references and current file/section locations. A task range is inclusive; abbreviated suffixes inherit the preceding milestone prefix. Proposed `AV-nnn-nn` labels are this register’s acceptance criteria, not existing implementation test IDs or passed tests.

## 2. Decision lifecycle and approval boundary

| State | Required evidence / meaning |
|---|---|
| Proposed | Alternatives and exact recommended rule are reviewable. No choice has owner approval and no authoritative change is authorized by this state. **No current audit decision remains in this state; unselected alternatives are not approved.** |
| Approved | Record the owner’s explicit option/scope, exact confirmation, date and any dependencies. A group approval must resolve to the listed per-decision option letters; an ambiguous choice remains Proposed. |
| Applied | In a later authorized documentation update, synchronize the selected rule across affected FRS/TRS/DR/RM/plans and acceptance scenarios. Record exact file/section diff and hashes. Approval alone is not application. |
| Verified | Independently check the applied documents and exact test oracles against the approved choice. Record the verification scope. Pre-development verification can close a **documentation** correction; it never means the still-unwritten game passed runtime tests. |
| Deferred | Only by explicit owner disposition, with reason, owner, revisit trigger and latest safe milestone. A blocker cannot be called safe to defer merely because work has not started. |
| Rejected | Record rejected option/scope and rationale. An unresolved finding remains open unless another selected resolution or explicit disposition covers it. |

There are separate fields for **source-document application**, **game implementation** and **runtime verification**. Source-document application was completed as A1; game implementation and runtime verification have not started. The dated R2-C1 amendment below records the current documentation-only verification outcomes. Validating that a finding exists, verifying its documented correction and validating its runtime implementation are separate claims. Earlier Applied/verification fields retain their dated A1 scope.

The original eight retain their audit classifications: **0 Critical, 3 High, 4 Medium, 1 Low**. DOC-001 is a separate Low audit-evidence formatting defect. Approval alone did not establish application or verification; A1 subsequently applied the selected documentation corrections, and the R2-C1 amendment below records their current verification scope. No original severity or approved choice is changed, and no game/runtime pass follows from documentation closure.

## 3. Organized approval groups and revalidation results

| Review group | Decision / original finding | Revalidated result | Recommended option | Latest safe decision point |
|---|---|---|---|---|
| 1 | [AUD-DEC-001](#aud-dec-001) / AUD-001 — High | Recovery scope/identity mismatch remains; not a demonstrated extra-money exploit. | **B — Applied** | M01 interface freeze |
| 1 | [AUD-DEC-002](#aud-dec-002) / AUD-002 — High | Unknown same-process commit outcome still lacks a complete contract. | **B — Applied** | M01 interface freeze |
| 1 | [AUD-DEC-003](#aud-dec-003) / AUD-003 — High | Current curve is complete; future changed-rule migration policy is not. | **B — Applied** | M01 interface freeze |
| 2 | [AUD-DEC-004](#aud-dec-004) / AUD-004 — Medium | Controller authority exists; intent/accepted-time/quote binding needs precision. | **B — Applied** | M01 interface freeze |
| 3 | [AUD-DEC-005](#aud-dec-005) / AUD-005 — Medium | Seed/fixed stages exist; removal/re-entry/termination oracle is missing. | **A — Applied** | M02 contracts/behavior |
| 3 | [AUD-DEC-006](#aud-dec-006) / AUD-006 — Medium | Required equipment gates are explicitly still unspecified. | **A — Applied** | M02 contracts/behavior |
| 3 | [AUD-DEC-007](#aud-dec-007) / AUD-007 — Medium | Required groups lack lifecycle/reference/indirect-consent rules. | **B — Applied** | M02 contracts/behavior |
| 4 | [AUD-DEC-008](#aud-dec-008) / AUD-008 — Low | Obsolete operative reservations still contradict current approval summaries. | **A — Applied** | Documentation synchronization; no game blocker |
| 4 | [AUD-DEC-009](#aud-dec-009) / DOC-001 (additional review finding; not one of the original eight) — Low | Audit formatting corrupted hashes, one URL and some technical tokens; sources intact. | **A — Applied** | Documentation synchronization; no game blocker |

### Group 1 — High foundation decisions

**Approved: AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B.** Owner confirmation on 2026-10-28: **“Approve Group 1 recommended”**. The selected rules and coordinated Group 1 behavior are approved; source synchronization is Applied; game/runtime verification remains pending. Optional journals and grandfather-migration alternatives are not selected. Namespaced dynamic identities plus honest whole-timeline rollback; typed commit outcomes with read-back reconciliation; immutable profile-bound progression definitions. Minimal alternatives either narrow guarantees, force protected restart or refuse unsupported versions. Comprehensive journal/grandfather-migration alternatives are feasible but substantially enlarge architecture and may amend current invariants. Coordinate identity and commit recovery first. **All three need a written outcome before dependent M01 state/command/progression interfaces.** Full SQLite recovery and content migration are still M03 work.

### Group 2 — Remaining M01 input contract

**Approved: AUD-DEC-004 B.** Owner confirmation on 2026-10-28: **“Group 2 Approved recommended”**. This approval includes the as-of research-preview clarification and the manual override’s ending-balance minimum. Source synchronization is Applied; game/runtime verification remains pending; alternatives A/C are not selected. The controller stamps accepted time after due work; typed semantic confirmation protects purchase terms. Research time previews have an explicit as-of meaning and the approved formula executes at accepted time. Strict whole-revision quotes are simpler but can reject ordinary busy-farm clicks; a general dependency framework is unnecessary now. Depends on Group 1’s identity, content and uncertain-commit contracts. **Resolve before M01-T06/T13**, without implementing M04 early.

### Group 3 — M02/M03 prerequisite details

**Approved: AUD-DEC-005 A, AUD-DEC-006 A, AUD-DEC-007 B.** Owner confirmation on 2026-10-28: **“agreed with group 3 recommendations”**. Source synchronization is Applied; game/runtime verification remains pending; alternative allocator policies, additional equipment level gates and the generalized group dependency service are not selected. Terminating monotone fixed-request exclusions; sequential equipment ranks with coins and no extra level/research gates; single-membership group edits with effective-plan previews and explicit deletion destinations. More elaborate allocation or gating choices materially alter outcomes/pacing and need their own selected wording. These can wait beyond corrected M01, but must be defined before their M02 behavior/schema handoffs. Group consent uses Group 2; every outcome persists through Group 1’s coordinator.

### Group 4 — Documentation accuracy

**Approved: AUD-DEC-008 A and AUD-DEC-009 A.** Owner confirmation on 2026-10-28: **“group 4 approved as recommended”**. Documentation corrections are Applied; runtime verification remains pending. Correct stale current-action clauses without erasing history, and repair exact technical strings in the audit outputs. There is only one meaningful corrective approach for each; leaving errors, deleting history or reorganizing every document is not a genuine substitute. Both are Applied to documentation, not marked Verified. Neither is a game architecture blocker. They require separate entries because incorrect approval wording and corrupted hash/URL evidence have different causes and checks.

### Approval shorthand

You may select a whole group’s listed recommendations, or individual alternatives by full decision ID and letter. “Group 1 recommended” maps only to 001 B /002 B /003 B; it does not select the optional journals. The complete recommended set is **001 B, 002 B, 003 B, 004 B, 005 A, 006 A, 007 B, 008 A, 009 A**. The owner’s explicit “Approve Group 1 recommended” confirmation has selected only 001 B /002 B /003 B. Group 2’s subsequent explicit “Group 2 Approved recommended” confirmation selects 004 B. Group 3’s explicit “agreed with group 3 recommendations” confirmation selects 005 A /006 A /007 B. Group 4’s explicit “group 4 approved as recommended” confirmation selects 008 A /009 A. Final-approved fields for all nine decisions are populated below. These four explicit confirmations approve the listed choices; they do not mark source changes Applied or Verified.

## 4. Detailed decision entries

Complexity labels are relative engineering scope, not calendar promises. Options are judged against the current 32-plot, single-threaded, scene-independent GDScript design. Platform statements are design feasibility assessments; no engine/native/browser integration has been run in this analysis.

<a id="aud-dec-001"></a>

### AUD-DEC-001 — Define recovery history and identities across an older-backup restore

| Field | Current value |
|---|---|
| Original finding | AUD-001 |
| Severity / category | **High** / Recovery / identity / contract permanence |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option B**, selected by owner |
| Final approved decision | **Option B — namespaced dynamic IDs and coherent recovered-timeline rollback, including the explicit DEC-019 claim-permanence scope clarification.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“Approve Group 1 recommended”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Before M01-T05/T06 freezes entity identity and references. Real backup recovery remains M03; real contract tests remain M05. The full recovery implementation is not required before M01 begins. |

**Validity and problem.** Confirmed, with a scope qualification. The literal no-reuse rule and backup-recovery claim wording exceed what a restored old snapshot alone can establish. This is a documentation/identity mismatch, not proof that restoring a backup creates extra coins in that recovered balance: the lost branch’s claim credit is rolled back too.

**Root cause.** Command epochs were made recovery-safe, but the same treatment was not specified for dynamically allocated entities. The claim guarantee was not explicitly bounded to the authoritative history that actually survives recovery.

**Exact evidence.** [AR AUD-001, L65](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:65); [VS DVS-018, L288](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:288); [TM recovery coverage gap, L251](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:251); [RD M01 blockers, L28](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Readiness.md:28); [DR DEC-016 protocol, L231](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:231); [DR DEC-016 identity rule, L233](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:233); [TRS §3.1 allocator, L119](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:119); [TRS §3.5 contract eligibility, L179](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:179); [TRS §4.1 identity, L205](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:205); [TRS §9.3 backups, L434](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:434).

**Affected requirements and documents.** FRS §§10.1/13; TRS §§3.1/3.4/3.5/4.1/4.2/8/9.3/9.4; DR DEC-015/016/019; RM §§3/4/6; M01-T05/T06/T07/T14, M03-T03/T04/T10/T14/T16, M04-T13, M05-T04/T06/T07/T15, M06-T04/T14; all four audit files after source synchronization.

**Original decision compliance / conflict.** DEC-016’s command protocol is retained. Option A explicitly narrows its absolute entity no-reuse wording. Recommended B preserves full dynamic identity uniqueness using a namespace, but explicitly bounds DEC-019’s backup claim permanence to the recovered authoritative timeline. That interpretation/amendment is explicitly included in the owner’s Group 1 approval recorded here; the original source wording is now synchronized by A1. DEC-015’s two-generation cadence and bounded DEC-016 history remain unchanged.

#### Option A — Minimal: scope all guarantees to the restored timeline

| Review dimension | Assessment |
|---|---|
| Detailed description | Keep the checkpointed int64 allocator. Define entities as unique only within the chosen recovered history; IDs from discarded branches may be reused. All state—including coins, XP and claimed-offer eligibility—rolls back coherently to that history. Retired command epochs remain rejected. |
| Advantages | Smallest data-model change; no extra storage; recovery behavior is easy to explain. |
| Disadvantages | Explicitly weakens the original within-profile identity promise. External logs or cached views can confuse a new entity with a lost-branch entity unless they are cleared or qualified by recovery session. |
| Implementation complexity | Low documentation and implementation complexity. |
| Impact on existing requirements | Amend DEC-016/TRS no-reuse scope and clarify FRS contract rollback. No crop, reward, cap or purchase rule changes. |
| Impact on architecture | Retains numeric IDs, adds a documented recovery boundary and clears external references on restore. |
| Impact on milestone tasks | M01 validators/comparators scope identities; M03 recovery and M04 messages disclose rollback; M05 uses restored claim state. |
| Potential risks | Unqualified IDs copied outside the checkpoint remain ambiguous; a later integration may require a namespace retrofit. |
| Required testing changes | AV-001-01/02 plus stale-reference rejection after restoring a counter. Assert only the narrower identity promise. |
| Windows compatibility | Compatible with the existing local SQLite/backup approach; no new native dependency. |
| Future web implications | Portable plain integers and records. Browser recovery has the same retained-history limitation. |

#### Option B — Balanced: namespaced dynamic IDs and coherent timeline rollback

| Review dimension | Assessment |
|---|---|
| Detailed description | Keep stable plot IDs 1–32 and authored content/offer IDs unchanged. Qualify each newly allocated cycle/event/transaction/contract-instance/claim identity by save_id, an injected startup allocation namespace and a checked local counter. Reuse the already-required fresh writer UUID as the startup namespace rather than add another native ID service. Existing stored IDs never change. Restore older snapshots as complete timelines; claims absent from the restored timeline may become eligible again, together with rollback of their old credit. |
| Advantages | Preserves distinct identities across recovery branches without a permanent event journal; builds on approved UUID injection; keeps one authoritative economic history. |
| Disadvantages | Dynamic references become composite/string keys rather than unqualified counters. Recovery cannot preserve facts that no surviving artifact contains. |
| Implementation complexity | Moderate: typed ID/codec/comparator changes, one identity context and recovery wording. |
| Impact on existing requirements | Clarifies/extends DEC-016 entity keys. Explicitly scopes DEC-019 claim permanence during older-generation rollback. Existing active-cycle guards and intact-primary exactly-once guarantees remain binding. |
| Impact on architecture | Identity allocation is data-driven inside the core; UUID generation stays outside. The namespace is an input, not a gameplay random choice. No second database or log is needed. |
| Impact on milestone tasks | Freeze logical ID fields in M01; round-trip and ownership in M03; recovery UI in M04; authored claim replay in M05; final M06 corpus. |
| Potential risks | Random namespaces provide practical UUID uniqueness, not mathematical immunity to collision or user-edited saves. Scheduler order must not accidentally change when string encodings change. |
| Required testing changes | AV-001-01–04: lost-branch allocations/claims, preserved old IDs, deterministic injected namespaces, scheduler restore and old-epoch rejection. Never normalize mismatching economic IDs out of replay tests. |
| Windows compatibility | Works with GDScript primitive records and SQLite text/integer fields. Verify composite key encoding in the selected adapter; no additional Windows API in core. |
| Future web implications | The same canonical ID encoding works in snapshots. Preserve counters as lossless integers/decimal strings at any JavaScript boundary; browser storage durability stays separately qualified. |

#### Option C — Comprehensive: namespace IDs plus replayable recovery journal

| Review dimension | Assessment |
|---|---|
| Detailed description | Use B’s namespaced identities and add a bounded, independently validated durable outcome journal covering changes newer than recoverable checkpoints. Recovery replays complete economic outcomes and anchors from a surviving checkpoint/journal pair. Prune only when validated recovery generations cover the journal prefix. If required artifacts are lost, report an explicit rollback limitation rather than promise universal claim permanence. |
| Advantages | Can reconstruct more recent committed history than an older checkpoint alone, including claims and their paired credits; supports deeper recovery diagnostics. |
| Disadvantages | Creates another durable artifact, retention protocol, corruption validator and commit/recovery coordination problem. An audit log of claim IDs alone would be insufficient. |
| Implementation complexity | High. Requires a separate reviewed journal/acknowledgement protocol and additional fault testing before adoption. |
| Impact on existing requirements | Extends DEC-015’s persistence design and DEC-016 compaction contract; no unlimited claim/transaction history is authorized. Does not guarantee survival of all local-storage loss. |
| Impact on architecture | Application-level journal and checkpoint coverage tracking behind SaveRepository. Must not rely on two WAL databases committing atomically together. |
| Impact on milestone tasks | Expand M03 repository/backup/catch-up scope materially; M05 contract recovery and M06 packaging/corruption tests become larger. |
| Potential risks | A journal acknowledged out of order could duplicate or erase rewards. Partial artifact survival and pruning must have explicit supported recovery points. |
| Required testing changes | All B tests plus failures between journal/DB writes, journal truncation, corrupt prefixes, compaction, backup coverage and replay of state+anchor+claim outcomes once. |
| Windows compatibility | Feasible with a qualified local adapter and file durability design, but no current integration is verified. |
| Future web implications | Requires a distinct browser journal/storage strategy; do not infer Windows crash durability from IndexedDB or introduce a server requirement. |

#### Selected resolution — Option B (Applied to documentation)

Use B. A restored checkpoint and its replayed surviving history are the authoritative timeline. One-time offer protection applies within that timeline; any discarded-branch claim credit is discarded with its claim flag. New dynamic entities use the injected startup namespace plus checked counter; existing entities, plot IDs and authored IDs retain their identities. Recovery messages state the recovered time/revision and possible lost progress. No claim-only ledger or global anti-rollback promise is introduced.

**Required implementation/design detail after approval.** Create the fresh namespace under owned-profile startup before catch-up allocations and include it in the startup result checkpoint before active input. A failed pre-commit attempt may restart with a new injected namespace; the external input changed, so production entity IDs need not match that abandoned attempt. Mode-equivalence and deterministic retry tests use the same injected namespace/input stream. During an uncertain commit, keep the pending identity context until AUD-DEC-002 resolves it; do not rotate or issue replacements early. Preserve the original scheduler’s logical counter/phase ordering explicitly: do not use UUID lexical order as an accidental new priority. Counter overflow follows DEC-026.

**Why this recommendation.** B retains the useful no-reuse property with small, bounded metadata and states the honest rollback limit. A gives up a valuable identity invariant; C adds a second persistence protocol without a demonstrated product need.

**Dependencies and coordinated decisions.** Coordinate with AUD-DEC-002 for unknown startup/commit outcomes, AUD-DEC-003 for identity-preserving migrations, and AUD-DEC-009 for trustworthy displayed evidence. This is not dependent on new equipment or group rules.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-001-01 | Restore a checkpoint before an allocation: the new full dynamic identity differs while the restored old entities retain their IDs; retired command payloads are stale. |
| AV-001-02 | Restore before Q01’s claim: old reward and closure both roll back; eligibility follows the recovered timeline, with no separate additive payout. |
| AV-001-03 | Fixed injected namespace and identical accepted inputs produce identical IDs, scheduler order and aggregation/reference state across active/debug/offline/forecast. |
| AV-001-04 | Round-trip composite references and counters at valid integer bounds; reject collisions/malformed references before mutation; preserve namespace during receipt reconciliation. |

**Current disposition:** selected AUD-DEC-001 B is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-002"></a>

### AUD-DEC-002 — Resolve a commit whose success response is lost

| Field | Current value |
|---|---|
| Original finding | AUD-002 |
| Severity / category | **High** / Transaction atomicity / uncertain commit |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option B**, selected by owner |
| Final approved decision | **Option B — typed commit outcomes, unique checkpoint identity/expected parent durable revision, blocked writes on UNKNOWN and complete read-back reconciliation.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“Approve Group 1 recommended”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Reserve the typed outcome and stopped/reconcile boundary before M01-T06/T13. Actual DB reconciliation is M03. A fake sink can exercise the contract in M01. |

**Validity and problem.** Confirmed as a missing explicit contract, not a demonstrated DB bug. Existing plans already require lost-response tests. They do not specify a safe same-process route before retry, settings save, checkpoint, backup or shutdown can write again.

**Root cause.** The repository/controller boundary describes success versus failure, although a failure to receive a receipt is not proof that COMMIT rolled back. Durable replay metadata can be ahead of the controller’s old copy.

**Exact evidence.** [AR AUD-002, L86](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:86); [VS DVS-017, L274](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:274); [TM commit gap, L252](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:252); [TRS §4.1 result, L197](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:197); [TRS §4.1 replay, L203](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:203); [TRS §5 repository, L272](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:272); [M01 T06, L94](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:94); [M03 T02, L73](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:73); [M03 T05, L103](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:103); [M03 T15, L207](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:207).

**Affected requirements and documents.** TRS §§4.1/5/8/9.2/9.3/12; DR DEC-015/016/013 implementation notes; RM architecture/test ownership; M01-T06/T13/T14, M03-T02/T03/T05/T06/T10/T14/T15/T16, M04-T08/T13/T15, M05-T06/T15, M06-T04; relevant audit scenarios/readiness.

**Original decision compliance / conflict.** No weaker durability or new reward rule is proposed. Recommended B implements DEC-015/016 and the DEC-013 anchor contract. A failed economic validation remains rejection without mutation; an unknown persistence outcome is a different lifecycle condition, not a falsely rejected economic command.

#### Option A — Minimal: fail closed and reload before any further save

| Review dimension | Assessment |
|---|---|
| Detailed description | On any potentially ambiguous commit failure, stop all writes and require closing/reloading the owned profile. Close/settle the connection without writing an old shutdown snapshot; startup reads the latest valid primary and applies normal stale/replay rules. If the primary cannot be verified, stay in recovery mode. |
| Advantages | Small lifecycle surface; prevents stale memory from overwriting a successful commit; uses existing startup recovery. |
| Disadvantages | Disruptive restart for recoverable errors; original command may be reported only as stale/unknown rather than restoring its full response. |
| Implementation complexity | Low to moderate: protected stop route, safe connection teardown and startup verification. |
| Impact on existing requirements | Complies with DEC-015/016’s optional old-response caching and mandatory once-only effects. Adds explicit “no final save on uncertainty” behavior. |
| Impact on architecture | No new persistence artifact; error routes reuse load/validation and fresh-epoch startup. |
| Impact on milestone tasks | M01 models a terminal unresolved sink result; M03-T06/T15 routes to protected reload; M04 offers honest recovery/exit. |
| Potential risks | A supposedly graceful exit must not perform the normal old-memory shutdown save or rotate backups over the primary. |
| Required testing changes | AV-002-01/02/04 via restart; test failure of reload and connection teardown with no stale writes. |
| Windows compatibility | Compatible with SQLite and local profile ownership; adapter must distinguish safe closing from an active operation still running. |
| Future web implications | Same principle works with asynchronous browser saves, but reload must wait for pending operations or report unresolved status; no synchronous-durability claim. |

#### Option B — Balanced: typed commit outcomes and read-back reconciliation

| Review dimension | Assessment |
|---|---|
| Detailed description | Represent COMMITTED, NOT_COMMITTED and UNKNOWN outcomes at the repository boundary. Give every checkpoint—including auto, time-only and settings commits—a unique commit identity and expected prior durable revision. On UNKNOWN, keep ownership and enter a stopped reconciling state. Settle the write/connection, then validate primary identity/revision to determine whether the prepared outcome committed. Rehydrate the chosen complete state before any write resumes. |
| Advantages | Handles transient errors without forcing restart; protects all save paths; keeps one DB and bounded receipt metadata. |
| Disadvantages | Requires explicit receipt/state transitions, revision validation and tests for unknown outcomes rather than a boolean-only API. |
| Implementation complexity | Moderate. Small commit contract plus a controller reconciliation state; no second economic engine. |
| Impact on existing requirements | Preserves WAL/FULL, commit-before-success and atomic state/anchor/accounting/replay. Does not automatically retry a new purchase or reinterpret UNKNOWN as gameplay rejection. |
| Impact on architecture | One commit coordinator under GameController/SaveManager. Core returns a candidate batch; adapter owns transaction state. Durable revision and current in-memory simulation revision are explicitly distinguished. |
| Impact on milestone tasks | Reserve contract in M01; implement identity/revision codec and coordinator in M03; route UI/recovery in M04; rerun real contract cases in M05/M06. |
| Potential risks | A read through an old transaction can show a stale snapshot. Reading after quiescence/connection reset and validating commit identity are required. Unexpected revisions or unreadable primary remain blocked. |
| Required testing changes | AV-002-01–05, including live receipt loss after successful COMMIT and after genuine rollback, all write entry points, and fake/browser asynchronous completion. |
| Windows compatibility | Feasible with SQLite under exclusive profile ownership; adapter must prove its error/connection semantics. No native transaction introspection call is mandated in core. |
| Future web implications | Expose UNKNOWN/pending and read-back through the browser adapter using actual completion semantics. The interface is portable; the durability guarantee remains platform-specific. |

#### Option C — Comprehensive: coordinator plus bounded recovery journal

| Review dimension | Assessment |
|---|---|
| Detailed description | Add B’s coordinator and an application-level durable outcome/receipt journal tied to checkpoint coverage, shared with AUD-DEC-001 C if selected. Reconcile from surviving authoritative artifacts and retain a bounded audit trail of outcomes for diagnosis. |
| Advantages | More forensic and recovery evidence when the main DB receipt/state cannot be read; supports reconstructing recent complete outcomes. |
| Disadvantages | Substantially expands failure states, pruning and acknowledgement ordering; duplicates work if DB read-back already solves the requirement. |
| Implementation complexity | High. Coordinated journal protocol and separate corruption/compaction qualification. |
| Impact on existing requirements | Requires an explicit extension to DEC-015 and bounded-history rules; neither WAL/FULL nor once-only effects may be weakened. |
| Impact on architecture | Additional repository artifact and coverage metadata; no direct core file access or unsafe cross-database atomicity assumption. |
| Impact on milestone tasks | Large M03-T02/T05/T10/T14/T16 expansion; combined M05/M06 fault corpus and packaging evidence. |
| Potential risks | Journal and DB may disagree after crashes; the protocol must resolve this before any success acknowledgement or pruning. |
| Required testing changes | All B tests plus journal-before/after-DB failures, torn entries, coverage pruning and loss of each artifact. |
| Windows compatibility | Feasible behind qualified storage APIs but not currently validated. Do not promise recovery after all local artifacts are lost. |
| Future web implications | Needs a separately qualified browser implementation; cannot port file-sync assumptions directly. |

#### Selected resolution — Option B (Applied to documentation)

Use B. Every save attempt has a unique commit identity, expected parent durable revision and prepared complete result. Unknown outcomes block all repository writes and economic input until the settled primary is verified. A matching result restores the complete committed outcome; a verified unchanged parent allows a definite not-committed result. Any other/unreadable state remains a recoverable stopped condition. Never replace the original operation with a fresh purchase.

**Required implementation/design detail after approval.** Block economic commands, time-only/settings checkpoint writes, migration, backup rotation and normal shutdown save while UNKNOWN. Cosmetic audio drafts may remain local with unsaved indication. Resolve open statements/transactions and in-flight operations before read-back; autocommit/transaction-state observations alone do not prove which logical result committed. After reconciliation rebuild scheduler, replay high-water, interval ledger and anchor from the selected state. Preserve pending real-time observations and reconcile them exactly once before active play resumes. A rollback is not permission to replay already credited time. Startup namespace rotation obeys AUD-DEC-001. Expected-parent checks and commit identity operate on a dedicated durable revision, avoiding conflation with unsaved time advancement.

**Why this recommendation.** B provides the missing reliable outcome boundary without a new durable subsystem. A is safe but unnecessarily forces restart. C is only justified if the larger recovery-journal option is independently selected.

**Dependencies and coordinated decisions.** AUD-DEC-001 fixes identity context; AUD-DEC-003 defines valid content contexts; AUD-DEC-004 prevents duplicate UI replacement intents. AUD-DEC-007 structural/group saves and cosmetic settings commits use this same coordinator.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-002-01 | DB commits revision 41 but receipt is lost while memory is 40: all write routes remain blocked until read-back selects 41; no second debit or stale overwrite. |
| AV-002-02 | A definitely rolled-back operation verifies the unchanged parent and can report not committed; an unsettled/failed read cannot be treated as rollback. |
| AV-002-03 | Exercise auto, catch-up, time-only, settings, migration and startup receipts, not only manually identified economic commands. |
| AV-002-04 | Try retry, new purchase, settings save, backup and shutdown during UNKNOWN; preserve good backups and fail closed without an old snapshot save. |
| AV-002-05 | After reconciliation/crash, compare full state, replay marks, accepted IDs and state+anchor/real-interval accounting against uninterrupted execution; inject equivalent asynchronous outcomes through portable fakes. |

**Current disposition:** selected AUD-DEC-002 B is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-003"></a>

### AUD-DEC-003 — Keep earned levels and points valid when progression data changes

| Field | Current value |
|---|---|
| Original finding | AUD-003 |
| Severity / category | **High** / Progression / version compatibility / migration |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option B**, selected by owner |
| Final approved decision | **Option B — immutable supported profile-bound progression/content manifests; no implicit incompatible migration or altered current balance.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“Approve Group 1 recommended”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Before M01-T03/T05/T12 fixes the saved rule reference and invariant. Implement migration support in M03; final balance validation stays M05/M06. A full migration engine is not an M01 prerequisite. |

**Validity and problem.** Confirmed for future changed-rule compatibility. The present through-30 curve, increasing tail and point arithmetic are fully defined and need no retuning. The audit counterexample concerns a later approved incompatible curve/rank change, not a failure of the current curve.

**Root cause.** The package records content_version but does not define how saved progression binds to immutable rule definitions or how a changed curve preserves the derived-level/earned-point invariant.

**Exact evidence.** [AR AUD-003, L107](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:107); [VS DVS-019, L302](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:302); [TM migration gap, L253](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:253); [FRS §5.1.1 tuning, L229](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:229); [FRS §5.5 retention, L270](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:270); [FRS §12.1 change control, L546](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:546); [TRS §3.2 invariant, L132](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:132); [TRS §5 lookup, L278](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:278); [TRS §9.4 versions, L470](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:470); [M03 T10, L147](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:147); [M05 T13, L163](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:163).

**Affected requirements and documents.** FRS §§5/12.1/13/16; TRS §§3.1/3.2/3.5/5/9.3/9.4; DR DEC-002/004/024; RM §§3/4/6; M01-T02/T03/T05/T12/T14, M02-T01/T04/T05, M03-T03/T10/T12/T13/T16, M04-T11, M05-T13/T15, M06-T03/T04/T09; audit progression/migration/readiness coverage.

**Original decision compliance / conflict.** A/B preserve current DEC-002 option B and DEC-004 point/prerequisite rules by applying one internally consistent version per profile. No XP, level, skill or economic number changes in this proposal. C would explicitly amend the rule that current level is simply the highest reached threshold of the active curve, and add grandfathered validation exceptions. All later numeric tuning still needs separate owner approval.

#### Option A — Minimal: freeze v1 progression and reject incompatible versions

| Review dimension | Assessment |
|---|---|
| Detailed description | Freeze the current progression bundle for v1. Recognize that version explicitly in saves. Permit schema migrations that preserve its semantics; refuse a different unsupported curve/skill version without overwriting the profile. A future incompatible tuning change must bring its own separately approved migration or support decision. |
| Advantages | Very small implementation; current lookup and level−1 point conservation remain untouched; no invented mapping. |
| Disadvantages | An updated build that does not retain the old rules may leave an older profile safely blocked until compatibility work is supplied. |
| Implementation complexity | Low: version guard and failure route. |
| Impact on existing requirements | Preserves all current numbers and awards. Defines unsupported content changes as recoverable incompatibility rather than silent migration. |
| Impact on architecture | One progression definition and a strict version check; no legacy registry beyond currently supported content. |
| Impact on milestone tasks | M01 records/fixes the version; M03 validates/refuses unsupported profiles; future tuning adds an explicit compatibility task. |
| Potential risks | If developers retune data in place without changing version, the guard cannot protect old profiles. Version immutability must be enforced. |
| Required testing changes | AV-003-01/02/04 using unchanged v1 plus unknown version and no overwrite; no raised/lowered-curve mapping is claimed. |
| Windows compatibility | Fully compatible with current GDScript and SQLite primitives. |
| Future web implications | Portable version strings and exact integers; browser import must also refuse unsupported content safely. |

#### Option B — Balanced: immutable profile-bound rules and explicit migration only

| Review dimension | Assessment |
|---|---|
| Detailed description | Make the saved content/progression reference resolve to a complete immutable supported manifest, including the curve and skill point prices/maxima/prerequisites/level guards. A profile continues on that manifest until an explicit compatible migration is approved. Package needed legacy manifests for supported saves; identify the progression bundle by stable ID/fingerprint within content_version. New profiles may use a separately approved newer manifest. Never mutate a published manifest in place. |
| Advantages | Preserves earned XP, derived levels, allocated nodes and point conservation without grandfather exceptions; old profiles can keep working while new balance is evaluated. |
| Disadvantages | Requires retaining supported definitions and testing more than one content context. Existing profiles do not silently receive incompatible progression tuning. |
| Implementation complexity | Moderate: immutable registry lookup, manifest binding/validation, and compatibility matrix. Current v1 needs only its one baseline. |
| Impact on existing requirements | Keeps DEC-002/004 semantics for every supported profile. Does not approve any new curve or guarantee support for every hypothetical historic format. |
| Impact on architecture | One rule context per engine/forecast/quote. Existing content_version can select the manifest; add an explicit progression_rules_id only if necessary for unambiguous binding. Do not combine a legacy curve with new incompatible rank definitions. |
| Impact on milestone tasks | M01 content/state/lookup bind the manifest; M02 quotes/skills use it; M03 loads/migrates by declared compatibility; M04/M05 show that profile’s correct thresholds; M06 tests supported contexts. |
| Potential risks | Missing legacy resources or accidental mixing with global latest data would invalidate guarantees. Pinning only XP while silently changing prerequisites would not resolve the finding. |
| Required testing changes | AV-003-01–05: raised/lowered alternative manifests, allocated nodes/rank maxima, surplus points, repeat migrations and copy/offline equivalence per profile. |
| Windows compatibility | Ordinary typed data/Resource definitions with stable primitive references; no Windows-specific behavior. |
| Future web implications | The same packaged manifest registry and lossless snapshot reference work in the minimal probe/future web adapter; browser caches must not substitute a different manifest under the same version. |

#### Option C — Comprehensive: explicit migration mappings and earned-level watermark

| Review dimension | Assessment |
|---|---|
| Detailed description | Allow profiles to adopt incompatible new progression through approved per-version mappings. Persist the highest level/point entitlement already awarded; level becomes at least that watermark and otherwise follows the new curve. Specify legacy allocated-rank/prerequisite handling, effects, eligibility and point accounting for every changed definition; do not erase XP or silently refund/revoke skills. |
| Advantages | Existing profiles can receive newer tuning while retaining explicit earned entitlements; supports extensive future progression redesigns. |
| Disadvantages | Changes the present pure XP-derived level invariant and introduces legacy exceptions. A watermark alone does not solve removed nodes or rank-maximum changes. |
| Implementation complexity | High: authoritative entitlement metadata, mapping versions, validators and a broad migration corpus. |
| Impact on existing requirements | Requires explicit amendments to DEC-002/004 and FRS progression semantics. No new content or altered numeric curve is approved by selecting this infrastructure option. |
| Impact on architecture | Adds migration-specific entitlement state and compatibility rules; ordinary lookup and skill validators must understand grandfathered allocations. |
| Impact on milestone tasks | M01 reserves award history/legacy fields; M03 migration engine expands; M02/M04/M05 must handle preserved legacy abilities accurately; M06 tests every mapping. |
| Potential risks | Double-awarding on repeated migration, inconsistent legacy bonuses, and old profiles gaining unintended advantages. Generic automatic mapping is unsafe. |
| Required testing changes | All B compatibility tests plus exact old→new XP/level/points/skills mapping, lowered maxima, changed edges, crash/retry and post-migration future awards. |
| Windows compatibility | Technically feasible with existing integer/SQLite design, but significantly more validation work. |
| Future web implications | Portable if mappings are pure data/functions in the shared core. More state and supported mapping versions increase future web import complexity. |

#### Selected resolution — Option B (Applied to documentation)

Use B. Resolve each save to its immutable supported progression/content manifest before validation, catch-up, quotes or input. Keep level as the highest threshold reached under that manifest and earned points as level−1, partitioned into unspent plus allocated one-point ranks/nodes. Unsupported references produce a recoverable no-overwrite error. Incompatible progression migration requires a separate approved mapping; absent that mapping, the profile remains on its supported old manifest.

**Required implementation/design detail after approval.** This is not a balance change and does not force permanent support for arbitrary formats. Record the set of supported manifest versions in each build. Retain all definitions needed to interpret a supported profile’s curve and allocations; keep its quotes, UI, offline run, forecast and save validation on the same context. Pure schema migrations preserve the manifest binding. Economic data retuning outside progression also remains versioned and separately approved; existing planted/research/contract snapshots remain immutable. No extra awarded-level watermark is required under the unchanged pinned-curve invariant. Test changed-curve examples as separate manifests, not by silently editing the current approved one.

**Why this recommendation.** B prevents the unsafe implicit migration and preserves all current invariants with a small versioned registry. A is safe but can unnecessarily block supported profiles. C solves an unrequested future redesign at the cost of weakening simple current invariants.

**Dependencies and coordinated decisions.** AUD-DEC-001 preserves dynamic IDs across migration/recovery; AUD-DEC-002 commits migration and manifest binding atomically; AUD-DEC-004 includes content/progression identity in quote validation. AUD-DEC-006’s eventual equipment guards belong to the appropriate declared content manifest.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-003-01 | A level-7/5,200-XP profile with Auto Replant remains valid on its original immutable manifest when a different manifest raises level 7 to 6,000. |
| AV-003-02 | Lowered thresholds and changed rank maxima/prerequisites in a new manifest never apply implicitly to an old profile; unsupported/missing definitions preserve its save. |
| AV-003-03 | Validate level−1=unspent+allocated and one-point awards/surplus for current and supported legacy contexts across active/offline/forecast/restart. |
| AV-003-04 | Supported schema migration preserves manifest reference, XP, allocation, cycle/research/contract snapshots and IDs; fail/interrupt/retry with a valid backup and no duplicate award. |
| AV-003-05 | A separately approved content migration, if later supplied, must have a version-specific exact mapping and idempotent commit tests before it is enabled; no such mapping is approved here. |

**Current disposition:** selected AUD-DEC-003 B is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-004"></a>

### AUD-DEC-004 — Stamp accepted input centrally and bind confirmation to actual terms

| Field | Current value |
|---|---|
| Original finding | AUD-004 |
| Severity / category | **Medium** / Input ordering / quote authorization |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option B**, selected by owner |
| Final approved decision | **Option B — semantic quote terms with controller-owned acceptance, including as-of research timing previews and the manual override’s ending-balance minimum.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“Group 2 Approved recommended”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Before M01-T06/T13 defines accepted commands and replay. Quote implementation is M02 and UI is M04. This is a small boundary decision, not a requirement to build UI before M01. |

**Validity and problem.** Confirmed as an underspecified interface boundary. The controlling documents already make the controller the ordering authority, so ordinary stale UI clicks are a risk to prevent, not evidence that they currently fail. No change to due-event-before-command order is needed.

**Root cause.** Preview time, raw UI intent, accepted engine envelope and quoted purchase authorization are described as if they were one moment. Strict timestamp rejection and continuously changing state require those boundaries to be explicit.

**Exact evidence.** [AR AUD-004, L128](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:128); [VS DVS-020, L316](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:316); [TM input gap, L254](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:254); [DR DEC-006, L181](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:181); [TRS §4.1 envelope, L193](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:193); [TRS §6.2 override, L313](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:313); [TRS §12.2 loop, L546](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:546); [M01 T06, L96](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:96); [M02 T05, L90](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:90); [M04 T08, L104](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:104); [M04 T09, L112](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:112); [FRS §8 preview, L366](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:366).

**Affected requirements and documents.** FRS §§6.3/7.1/8/9.2 confirmation wording if clarified; TRS §§4.1/4.2/5/6.2/12.2; DR DEC-006/007/010/016/025; RM command/quote boundary; M01-T06/T13/T14, M02-T02/T05/T07/T08/T10, M03-T05, M04-T08/T09/T11/T12, M05-T11, M06-T03/T08; audit DVS-020/rejection cases.

**Original decision compliance / conflict.** Controller stamping and strict rejection of stale/future accepted envelopes implement DEC-006/016 rather than backdating input. Recommended B explicitly clarifies DEC-007’s “exact saved time/new completion” preview as exact at its displayed as-of time, with the approved half-remaining formula executed at accepted time. It also clarifies the manual override ending-balance bound under DEC-010. Those precision/authorization clarifications are explicitly included in the owner’s Group 2 approval recorded here; the original source wording is now synchronized by A1; no new recurring consent, reserved wallet or paused gameplay is proposed.

#### Option A — Minimal: controller time plus strict whole-revision quotes

| Review dimension | Assessment |
|---|---|
| Detailed description | UI sends an intent and quote revision. The controller drains due work, stamps current accepted simulation time/sequence and validates the quote against the exact quoted authoritative revision. Any intervening authoritative change rejects/refreshes the quote and requires a new explicit confirmation. Accepted replay envelopes are never restamped. |
| Advantages | Simple and conservative; easy expected-result tests; no changed terms can slip through. |
| Disadvantages | Unrelated automation may invalidate otherwise identical purchases. Research time advances continuously, making exact-time quotes difficult without repeated refresh; does not pause simulation to rescue them. |
| Implementation complexity | Low to moderate: clear two-stage input model and strict quote token. |
| Impact on existing requirements | Retains DEC-006 ordering and original exact quote wording, but makes strict expiry behavior explicit. No hidden purchase retry. |
| Impact on architecture | One acceptance path; quote keyed by whole relevant state revision/time. |
| Impact on milestone tasks | M01 acceptance/replay contract; M02 quote/boost/reset tokens; M04 refresh and stale feedback. |
| Potential risks | Can be technically correct but frustrating at 60× or on frequently harvesting farms. If exact boost-time matching is unusable, this option must be revisited rather than freezing game time. |
| Required testing changes | AV-004-01/02/03; expect stale rejection after any relevant revision/time drift and no automatic resubmission. |
| Windows compatibility | Compatible with the single-threaded controller and pinned GDScript; no Windows API needed. |
| Future web implications | Portable, although slower browser/UI queues can increase rejection frequency. |

#### Option B — Balanced: semantic quote terms with controller-owned acceptance

| Review dimension | Assessment |
|---|---|
| Detailed description | Separate unaccepted UI intent from the accepted command. After due work, the controller validates identity/capabilities and the confirmed semantic terms, then records current time/order. Quotes bind target cycle/project, content context, crop/fertilizer/fallback, costs, modifier result and recurring plan revision as applicable. Ignore unrelated changes only if terms remain authorized. For continuously elapsing research, confirm the fixed boost charge and half-remaining formula, show an as-of time estimate, and report the exact accepted-time result. |
| Advantages | Normal clicks survive harmless unrelated harvests while changed charges/plans still require refresh. Preserves deterministic replay and avoids a permanent stale-boost loop. |
| Disadvantages | Each action needs an explicit set of bound terms; preview wording must distinguish estimates caused solely by natural elapsed time. |
| Implementation complexity | Moderate: shared typed Quote/Authorization data and per-command semantic validators. |
| Impact on existing requirements | Clarifies DEC-006/007/010/025 at the input/preview boundary. Keeps all current cost formulas, batch order and recurring authorization rules. |
| Impact on architecture | One controller stamping point and one quote/execution calculation path; no wallet reservation or live-time pause. Raw intents are not replayable accepted commands. |
| Impact on milestone tasks | M01 defines envelope timing; M02 implements validators; M04 shows as-of previews and changed-term rejections; M05 group/preset applies reuse them. |
| Potential risks | Overly broad equivalence could accept changed rewards, budgets or plans. Do not treat a different target cycle, content version or fertilizer as “the same purchase.” |
| Required testing changes | AV-004-01–05, especially unrelated revision changes, exact charge changes, elapsed boost estimates, duplicate pending input and same-time accepted order. |
| Windows compatibility | Uses typed primitive records and shared arithmetic; no platform-specific coupling. |
| Future web implications | Same semantic validation and accepted log work in the browser; UI latency changes timing estimates, not permission to alter a charge or replay order. |

#### Option C — Comprehensive: declarative quote dependencies and replayable validation evidence

| Review dimension | Assessment |
|---|---|
| Detailed description | Use B’s user semantics but describe quote dependencies in a typed shared policy layer. Canonical dependency fingerprints/read sets identify changed targets, rule contexts and plan versions for every action. Keep bounded validation diagnostics and generated compatibility tests; do not add a permanent input log or wallet reservations. |
| Advantages | More uniform coverage as commands grow; reusable invalidation diagnostics and systematic test generation. |
| Disadvantages | Larger framework and maintenance surface than a small game needs; the policy schema itself can become a second rules engine. |
| Implementation complexity | High relative to B; bounded metadata avoids lifetime growth but policy completeness still needs review. |
| Impact on existing requirements | Same explicit preview/authorization clarifications as B, with no new gameplay behavior. |
| Impact on architecture | General quote-dependency model around the existing command engine; shared economic routines remain authoritative. |
| Impact on milestone tasks | Additional M01/M02 quote framework and M04 diagnostic integration; M06 broader policy coverage checks. |
| Potential risks | Automatic dependency discovery can miss semantic requirements. Keep explicit validators and known-answer tests; do not claim generated tests prove consent. |
| Required testing changes | All B tests plus dependency field mutation, canonical fingerprint parity, invalidation completeness and bounded diagnostics. |
| Windows compatibility | Feasible in typed GDScript but more code and review effort; no required native component. |
| Future web implications | Portable canonical records, provided exact integers and stable version hashes are maintained. |

#### Selected resolution — Option B (Applied to documentation)

Use B. Unaccepted UI intents carry their target and confirmation terms, not an authoritative past simulation timestamp. The controller completes due work, forms the accepted envelope at current simulation time, and records serial order. Once formed, an accepted envelope is immutable and stale/future envelopes are rejected by the engine; replay advances to recorded accepted times. Confirmed purchases execute only under unchanged authorized semantic terms, or return a refreshed rejection. No automatic replacement operation is issued after lost acknowledgement.

**Required implementation/design detail after approval.** For manual planting/override, preserve crop/fertilizer/fallback and quoted economic results/cost; the confirmed ending balance is a minimum bound, so an unrelated extra harvest may leave more coins but never authorize a lower balance or greater charge. If modifiers/terms change, refresh rather than infer that the player prefers the change. Reset quotes bind level and its derived exact price. Research boost quotes bind project identity, original paid C, fixed charge, boost-unused state and the rule “halve remaining time when accepted”; time saved/new completion are explicitly as-of preview values, recomputed at accepted time and shown in the result. Reject completed/no-time-saved/already-used/unaffordable boosts unchanged. Quote refresh is not acceptance. Rejection equality is measured after independently due work; rejecting input cannot undo a due economic batch. IDs for repeated pending UI delivery are reused/deduplicated through the controller protocol, not regenerated as fresh purchases.

**Why this recommendation.** B addresses the concrete timing problem and preserves purchase consent with less machinery than C. A is a safe fallback but can reject nearly every live research boost preview or busy-farm confirmation. B’s preview-time distinction is explicitly included in the Group 2 approval; its source wording is synchronized by A1; runtime implementation remains future.

**Dependencies and coordinated decisions.** AUD-DEC-002 resolves persistence uncertainty before accepting more intent; AUD-DEC-003 supplies the manifest identity; AUD-DEC-007 uses the same effective-plan diff/authorization. No dependency on equipment gate choice, but quotes must later include those guards.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-004-01 | A click crosses a due harvest: that batch commits first, the controller stamps current time, and unchanged authorized terms may execute without backdating. |
| AV-004-02 | Change target cycle/project, exact cost, modifier result, content context or recurring plan: reject/refresh with no charge or automatic replacement purchase. |
| AV-004-03 | Boost preview ages naturally: fixed charge/formula stay authorized; accepted-time result uses ceil(remaining/2), and completed/1-μs/no-time-saved cases reject uncharged. |
| AV-004-04 | Unrelated extra income can increase ending wallet but never lower the confirmed minimum or increase cost; reset level/price change requires refresh. |
| AV-004-05 | Duplicate pending intent and lost acknowledgement cannot become a fresh purchase; accepted logs replay exact ordering, while rejected gameplay equality excludes independently committed due work. |

**Current disposition:** selected AUD-DEC-004 B is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-005"></a>

### AUD-DEC-005 — Define a terminating seed/fixed-fertilizer replan

| Field | Current value |
|---|---|
| Original finding | AUD-005 |
| Severity / category | **Medium** / Shared-wallet planning / determinism / termination |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option A**, selected by owner |
| Final approved decision | **Option A — Monotone fixed-request exclusion and deterministic seed/fixed replanning within each logical batch; bounded termination, explicit fallback and unchanged conditional Smart guarantees.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“agreed with group 3 recommendations”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Before M02-T11/T12/T15 acceptance. Does not block the manual/XP M01 kernel; the planning contract should be settled before offline aggregation M03. |

**Validity and problem.** Confirmed as missing deterministic subset/termination detail. Seed-first, fixed-before-Smart and explicit fallback are already approved. The sources do not promise maximum planted-plot count or globally optimal fixed-request selection; the correction must not invent such a guarantee.

**Root cause.** “Release reservations and replan” has no defined candidate-removal/re-entry rule or decreasing progress measure. A generic no-progress guard is not a unique allocation oracle.

**Exact evidence.** [AR AUD-005, L149](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:149); [VS DVS-009, L162](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:162); [TM allocator gap, L255](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:255); [DR DEC-010 stages, L443](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:443); [FRS §7.1 replan, L323](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:323); [TRS §6.2 seed/fixed, L316](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:316); [M02 T11, L128](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:128); [M02 T12, L136](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:136); [M02 T15, L154](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:154).

**Affected requirements and documents.** FRS §7.1 if observable subset is clarified; TRS §§4.2/6.2/8; DR DEC-010/009 implementation boundary; RM budget contract/coverage; M02-T11/T12/T14/T15/V04/V13, M03-T13/V14, M04-T12 stall reasons, M05-T09/T11/T15, M06-T03/T06; audit DVS-009 and allocator trace.

**Original decision compliance / conflict.** Recommended A fills DEC-010’s unspecified replan detail and preserves seed protection, fixed priority, fallback consent, one shared C and DEC-009’s exact Smart objective conditional on the final seed/fixed commitments. It does not claim global optimality of the accepted fixed-request subset. Alternative B deliberately changes the final subset selection policy; C adds a stronger optimization guarantee requiring explicit amended wording.

#### Option A — Minimal, recommended: monotone exclusion within one logical batch

| Review dimension | Assessment |
|---|---|
| Detailed description | Use a canonical request list ordered by effective priority then plot ID. Reserve seeds, then process fixed fertilizer in the approved order. On the first fixed failure without accepted no-fertilizer fallback, remove that request for the remainder of this logical batch, release/rebuild all provisional reservations and replan remaining candidates. Never reinsert removed requests in that batch; stop when no fixed failure remains. Unfunded seeds may be reconsidered as other requests are removed. Smart runs only after the final plan. |
| Advantages | Simple termination proof: at most N exclusions and N+1 seed/fixed passes, N≤32. Exact budgets and conditional Smart guarantees are preserved. |
| Disadvantages | May leave a request stalled even if later removals would make it affordable in isolation; it waits for a relevant later balance/configuration event. No maximum-utilization promise. |
| Implementation complexity | Low to moderate; O(N²) seed/fixed planning with N≤32, separate from the already required Smart solver. |
| Impact on existing requirements | Supplies an observable accepted-subset rule under DEC-010 without replacing seed-first with a package optimizer. Keeps consent and current price/default tables. |
| Impact on architecture | Pure read-only planning and one final atomic StateChangeBatch; a finite excluded set/progress counter, not a persistent work queue. |
| Impact on milestone tasks | Sharpen M02-T11/T12/T15 and reference oracle; M03 aggregation preserves per-batch exclusions; M04 shows an honest fixed-policy stall reason. |
| Potential risks | Unnecessary repeated retry events could loop after the planning pass if a stall-reason change itself is treated as a funding event. Retry must require an actual relevant external change. |
| Required testing changes | AV-005-01–05, including exact W=100 case, cascading drops, permutation equivalence and a fixture exposing the deliberate non-maximal outcome. |
| Windows compatibility | No native dependency; bounded 32-plot data processing fits the chosen architecture, with measured runtime still required. |
| Future web implications | Portable shared-core algorithm; no browser-specific storage or timing call. |

#### Option B — Balanced alternative: preserve a feasible plan, then one ordered repair pass

| Review dimension | Assessment |
|---|---|
| Detailed description | First obtain A’s feasible plan. Before Smart, visit excluded fixed requests once in canonical order and tentatively add one request’s complete authorized seed/fixed commitment only if the whole final plan remains feasible without evicting any accepted seeds/fixed commitments. Accept feasible additions monotonically; never revisit a rejected repair candidate in that pass. All accepted seeds are still reserved before any final debit. |
| Advantages | Can recover otherwise idle affordable requests while keeping bounded deterministic work and no oscillating set. |
| Disadvantages | Changes which requests win relative to pure seed-first elimination. A complete seed+fixed repair can consume funds that would otherwise remain available to a later excluded seed request. |
| Implementation complexity | Moderate: a second feasibility path and explicit subset-policy exception, still bounded to one pass over≤32 exclusions. |
| Impact on existing requirements | Needs explicit DEC-010 clarification permitting this package-based repair policy; does not automatically inherit approval from seed-first wording. Smart objective remains conditional on the chosen commitments. |
| Impact on architecture | Adds a bounded monotone repair planner to the same engine, not a second wallet or recurring authorization. |
| Impact on milestone tasks | M02 reference/oracles and M03 differential aggregation must implement the same repair ordering; M04 labels and M05 forecasts must match it. |
| Potential risks | If developers recompute the initial seed pass after every repair and allow removals/re-entry, oscillation can return. Repair never evicts accepted commitments. |
| Required testing changes | All A safety tests plus exact repair eligibility, priority ties and non-eviction; independent feasibility validation of every addition. |
| Windows compatibility | Feasible in GDScript with small N and exact arithmetic; benchmark with existing allocator/optimizer. |
| Future web implications | Portable deterministic records; slightly more replay/forecast work, no new adapter. |

#### Option C — Comprehensive: exact deterministic accepted-subset selection

| Review dimension | Assessment |
|---|---|
| Detailed description | Select a feasible seed/fixed set that maximizes the number of accepted requests in the highest priority tier, then each lower tier; among equal count vectors, prefer the ascending-plot-ID acceptance vector. Enforce authorized package costs, reserves and fallback rules. Then reserve all final seeds, honor final fixed commitments and run unchanged Smart. Use an exact bounded-content search/Pareto strategy, with no hidden heuristic fallback. This is an additional acceptance objective, not an interpretation of the existing Smart objective. |
| Advantages | Provides an explicit priority-tier utilization guarantee and a unique stable tie-break; can reconsider requests that A permanently excludes from this batch. |
| Disadvantages | Adds a second exact combinatorial problem before fertilizer optimization and a new policy for acceptance; it is not required by the current documents. |
| Implementation complexity | High relative to the scope. Worst-case work requires measurement/proof and a separately approved response if unsuitable. |
| Impact on existing requirements | Explicitly extends DEC-010 with a subset optimization guarantee; cannot silently reinterpret DEC-009’s conditional fertilizer optimum as this guarantee. |
| Impact on architecture | New exact planner/oracle over request packages, sharing checked arithmetic and atomic commit boundaries. |
| Impact on milestone tasks | Material M02 scope increase, repeated M03/M05 catch-up/forecast work and M06 performance qualification. |
| Potential risks | Unreasonable exact-search costs or a silent fallback would recreate unapproved nondeterminism/performance semantics. |
| Required testing changes | Small exhaustive accepted-subset oracle, exact per-tier count objective and plot-ID ties, 32-plot bounds and all budget/fallback/aggregation regressions. |
| Windows compatibility | Technically feasible for bounded current content but no acceptable runtime is yet established. |
| Future web implications | Shared-core portability is possible; browser single-thread performance makes proof/measurement especially important. |

#### Selected resolution — Option A (Applied to documentation)

Use A. Exclude a failed no-fallback fixed request permanently for the current logical batch, recompute the remaining seed/fixed plan in canonical order, and never reinsert it in that batch. Run at most N+1 seed/fixed passes after at most N removals. Apply accepted fallback explicitly. Only after the final feasible plan compute M and the single C, then run the already approved Smart groups. Charge only cycles actually planted.

**Required implementation/design detail after approval.** Snapshot W, effective priorities, crop/plan/authorization and farm budget for the logical batch. On a restart discard all tentative seed/fixed reservations and recompute from the remaining universe; do not carry partial spending. Seed-unfunded candidates stay eligible for a later replan if a removal frees seed capacity. A request excluded for refused/unaffordable fixed fertilizer stays out until a later genuine relevant funds/configuration change, not merely a changed blocked_reason. For W=100 with plot 1 Corn (18)+Premium (75)/no fallback and plot 2 Corn (18)+None, plot 1 is removed and plot 2 plants, ending at 82. A non-maximal final subset is permitted and disclosed; no crop/fertilizer substitution occurs. Limits here bound planning work, not elapsed time or rewards.

**Why this recommendation.** A is enough to meet the approved guarantees and avoids a new optimization objective. Its bounded, possibly non-maximal result is a visible policy choice stated for approval. B improves utilization at the cost of a new accepted-subset exception; C adds unjustified exact-search work.

**Dependencies and coordinated decisions.** AUD-DEC-004/AUD-DEC-007 supply stable accepted plan identities; AUD-DEC-002 commits the final coherent batch; AUD-DEC-003 chooses content/pricing context. Does not alter DEC-009’s exact rate objective.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-005-01 | W=100/R=0: Corn (18)+Premium (75) without fallback on plot 1, Corn (18)+None on plot 2. Plant plot 2 only, spend 18, end at 82; plot 1 stalls uncharged. |
| AV-005-02 | Cascading exclusions and newly affordable seed candidates terminate with≤N exclusions/≤N+1 passes; input permutation leaves the same canonical plan. |
| AV-005-03 | Under the approved current Corn prices, W=100 with plot 1 Corn (18)+Basic (20), plot 2 Corn (18)+Premium (75), plot 3 Corn (18)+None starts with S=54/A=46: Basic fits but Premium fails; exclusion/replan yields a defined stable subset. Add a labeled synthetic package fixture to demonstrate allowed non-maximality without calling it production balance. |
| AV-005-04 | Fallback accepted/declined, R>W, advanced seed protection, zero-cost seeds, priorities and fixed-before-Smart all preserve no negative balance and one final shared C. |
| AV-005-05 | A planning/stall-reason event cannot self-trigger unbounded zero-time retries. Offline aggregation and forecast match the event reference at each actual logical batch, including full failed-commit rollback. |

**Current disposition:** selected AUD-DEC-005 A is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-006"></a>

### AUD-DEC-006 — Specify every required equipment rank’s purchase guards

| Field | Current value |
|---|---|
| Original finding | AUD-006 |
| Severity / category | **Medium** / Equipment / incomplete unlock manifest |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option A**, selected by owner |
| Final approved decision | **Option A — Required equipment uses sufficient coins and sequential family ranks only, with no extra player-level/research/skill/contract guards; existing prices/effects remain provisional.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“agreed with group 3 recommendations”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Before M02-T01/T06 completion and any upgrade-using progression evidence. Does not block M01 manual farming/XP. Once approved, include the exact manifest in the profile/version policy from AUD-DEC-003. |

**Validity and problem.** Confirmed and explicitly acknowledged by the current FRS/register. Prices/effects exist, but unspecified equipment unlock gates remain open. The reviewed source baseline contains no approved additional level or research prerequisites for these ranks. Group 3 selects no additional gates, now synchronized by A1.

**Root cause.** Equipment tables were treated as sufficient executable content even though purchase eligibility was left for a later manifest. The completed parent decision totals obscure this remaining data choice.

**Exact evidence.** [AR AUD-006, L170](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:170); [TM equipment gap, L256](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:256); [VS DVS-033 limits, L498](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:498); [FRS §6.1 equipment, L280](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:280); [FRS unlock display, L285](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:285); [FRS §16 open gates, L601](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:601); [DR DEC-004 scope, L349](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:349); [DR equipment guards, L361](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:361); [RM D-04, L87](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md:87); [M02 T06, L98](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:98).

**Affected requirements and documents.** FRS §§6.1/16 and acceptance references; TRS §§3.5/5/17 content validation; DR DEC-004/024; RM D-04/coverage; M02-T01/T06/T17/V09/V14, M03 content/version validation, M04-T10, M05-T02/T13/T14, M06-T03/T09; audit equipment/pacing caveats.

**Original decision compliance / conflict.** Selected A fills a guard rule that was expressly unapproved in the reviewed source baseline. The owner’s Group 3 approval now selects coins and sequential ranks only; A1 applies the source correction without retroactively changing the original approval record. It leaves all existing crop/skill/plot gates, equipment prices/effects and the DEC-008 deferral unchanged. B adds explicit provisional level gates and changes pacing; no calculation currently validates those new gates.

#### Option A — Minimal, recommended: coins and sequential ranks only

| Review dimension | Assessment |
|---|---|
| Detailed description | For both required families, rank I requires ownership of rank 0 (no purchase yet) and sufficient coins; each later rank requires exactly the preceding rank and sufficient coins. Declare no additional player-level, crop-research, skill or contract guard. Purchases remain manual, one next rank per command, future cycles only. |
| Advantages | Adds no unsubstantiated balance gate; smallest complete executable rule; keeps coin investment as the existing tradeoff. |
| Disadvantages | Players may buy expensive ranks earlier than a gated design if they earn enough coins. The 3–5-hour goal still needs upgrade-using simulations. |
| Implementation complexity | Low: explicit guard fields and ordinary rank/cost tests. |
| Impact on existing requirements | Makes the previously missing unlock policy explicit; does not finalize or change listed provisional prices/effects. |
| Impact on architecture | Normal versioned UpgradeDefinition guards in the existing PurchaseUpgrade service. No new research or progression subsystem. |
| Impact on milestone tasks | M02 content/guards and progression traces; M04 exact Store eligibility; M05 catalog audit; M06 pacing/regression. |
| Potential risks | Do not confuse no level gate with automatic purchase, free purchase or a second rank at the same command. Growth-cap waste must still be shown. |
| Required testing changes | AV-006-01–04: all 11 next-rank guards, exact/insufficient funds, skipped/duplicate/max rank, future-only effect and costed progression. |
| Windows compatibility | Standard typed manifest and integer economy; no platform-specific requirement. |
| Future web implications | Same data and rules in browser/headless/forecast; no portability cost. |

#### Option B — Balanced alternative: sequential ranks plus explicit provisional level gates

| Review dimension | Assessment |
|---|---|
| Detailed description | Retain A’s manual, cost and predecessor rules and add the exact level rows below. Irrigation I–VI: levels 2/7/12/18/22/26. Improved Soil I–V: levels 2/10/15/18/26. These are a concrete unapproved candidate, aligned to existing progression tiers, not a proven balance recommendation or a modification applied now. |
| Advantages | Spreads equipment eligibility across known tiers; easy data-driven level checks and clear Store previews. |
| Disadvantages | Adds level restrictions beyond current coin affordability and could delay focused builds. The chosen numbers have no playtest/simulation validation. |
| Implementation complexity | Low to moderate implementation; materially more balancing and migration work than A. |
| Impact on existing requirements | Explicitly fills the open equipment guard policy with new provisional numbers. All listed prices/effects remain unchanged; owner approval is required before using these gates in evidence. |
| Impact on architecture | Adds level_guard fields to existing definitions, with the same one next-rank command path. |
| Impact on milestone tasks | M02/M05 content/strategy fixtures and M04 previews must use the new level rows; M03/AUD-DEC-003 handles later supported changes; M06 re-evaluates pacing. |
| Potential risks | May force idle waiting or make coin investment less useful. No offline caps or forced purchases may be used to compensate. |
| Required testing changes | All A tests plus immediately below/at every proposed level gate and comparisons of A/B full-cost normal/offline strategies. |
| Windows compatibility | No native dependency; ordinary integer guard checks. |
| Future web implications | Fully portable definitions, but profile content versions must preserve whichever guard table was actually selected. |

#### Selected resolution — Option A (Applied to documentation)

Use A: Irrigation and Improved Soil purchases require sufficient coins, an available next rank, and the immediately preceding owned rank only. No additional player-level, research, skill or contract prerequisite applies. Keep the existing six/five rank prices and per-rank effects provisional and unchanged. Purchase previews show the exact marginal effect and cap interaction, and apply only to future plantings.

**Required implementation/design detail after approval.** Manifest rows, recommended A: Irrigation I–VI cost 650/2100/12000/60000/300000/1500000, each adds −5% base growth time; Improved Soil I–V cost 900/3000/20000/110000/650000 and add +10/+10/+15/+15/+20% gross respectively. All rank rows use minimum player level 1 (meaning no extra level restriction), research guard None, contract guard None, skill guard None and previous family rank n−1. A valid wallet still matters; no starter grant is implied. This table supplies guards, not final numerical balance. Any later tuning/gate revision must be approved and versioned, with old-profile treatment under AUD-DEC-003.

**Why this recommendation.** A resolves the missing rule without adding arbitrary progression restrictions. B is a genuine design alternative but lacks evidence that additional gates improve the existing goals. There is no need for a third option: tying upgrades to new research, contracts, elapsed-time locks or invented metrics would add unsupported dependencies rather than resolve this narrow gap. Deferral alone would not produce an executable manifest.

**Dependencies and coordinated decisions.** AUD-DEC-003 binds guards to content versions; AUD-DEC-004 validates Store quotes; DEC-024 still requires full-cost upgrade-using and no-contract pacing evidence. DEC-008’s three optional families remain excluded.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-006-01 | For each of 11 required ranks assert predecessor, exact cost, insufficient funds, duplicate/skipped/max-rank rejection and no partial state/ID drift. |
| AV-006-02 | Under A, an explicitly funded valid level-1 fixture may buy rankI and later ranks sequentially without invented research/skill/contract gates. This is an isolated guard fixture, not a new-game cash grant. |
| AV-006-03 | Existing crop duration/reward snapshots remain unchanged; next planting uses additive equipment effects and the growth cap, with exact quote/execution parity. |
| AV-006-04 | Run actual full-cost upgrade-using strategies and the existing no-equipment/no-contract path. Report pacing outcomes without changing prices or gates silently; deferred families remain absent. |

**Current disposition:** selected AUD-DEC-006 A is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-007"></a>

### AUD-DEC-007 — Specify group membership, deletion and effective-plan consent

| Field | Current value |
|---|---|
| Original finding | AUD-007 |
| Severity / category | **Medium** / Plot-group ownership / inherited configuration / authorization |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option B**, selected by owner |
| Final approved decision | **Option B — Single group membership, atomic structural edits, effective-plan authorization and explicit deletion destinations with valid references; no implicit paid starts or new capability gate.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“agreed with group 3 recommendations”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Define group/plan/reference contracts in M02-T10/T16 before M03 schema. Full management UI/advanced behavior remains M05 per DEC-012; this is not an M01 implementation blocker while group records are inert. |

**Validity and problem.** Confirmed as missing lifecycle/task acceptance detail for existing plot groups. One group_id per plot already implies a single group slot; no need to invent overlapping/nested groups. Existing DEC-025 consent rules should cover these indirect configuration changes.

**Root cause.** The documents define inheritance precedence and presets but not the commands/reference behavior that create, assign or remove a group, nor how those operations invalidate an armed plan.

**Exact evidence.** [AR AUD-007, L191](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:191); [VS DVS-011, L190](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md:190); [TM group gap, L257](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:257); [FRS §7.1 inheritance, L317](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:317); [FRS §9.2 authorization, L420](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:420); [TRS §3.3 group_id, L141](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:141); [TRS §3.5 config, L176](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:176); [M02 T10, L124](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:124); [M05 group commands, L47](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:47); [M05 T11, L151](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:151).

**Affected requirements and documents.** FRS §§7.1/9.2 if behavior is clarified; TRS §§3.3/3.5/4.1/5/6/9.4; DR DEC-010/012/025; RM staging/coverage; M02-T10/T16/T18, M03-T03/T05/T10/T17, M04-T12 handoff, M05-T11/T12/T15, M06-T03/T04/T08; audit group/consent cases.

**Original decision compliance / conflict.** B preserves Plot>Group>Farm, explicit unset versus false/zero, farm-only R/p/seed toggle, capability checks, future-cycle immutability and explicit changed-stall/new-loop/rearm consent. Group management adds the missing commands for an existing feature; it does not grant Farm Presets, advanced priorities, ownership or a new spending mechanic. No additional group-level skill/level gate is invented.

#### Option A — Minimal: single membership, explicit reassignment, delete empty groups only

| Review dimension | Assessment |
|---|---|
| Detailed description | Define Create/Rename/EditGroup, Assign/UnassignPlot and DeleteEmptyGroup. A plot has zero or one group; deletion is rejected until membership/reference obligations are explicitly removed. Every effective plan change uses the existing future-settings authorization route. No implicit paid start follows a membership edit. |
| Advantages | Smallest lifecycle with safe references; avoids implicit cascade deletion behavior. |
| Disadvantages | Users may need several explicit operations to dissolve a group or fix its presets. The command contract must still define blocked deletion reasons. |
| Implementation complexity | Low to moderate: basic CRUD, reference validation and reuse of current configuration authorization. |
| Impact on existing requirements | Completes existing group scope; preserves approved inheritance, farm budget and consent rules. |
| Impact on architecture | Simple group table/map, nullable group_id and existing plan validator; no generalized dependency graph. |
| Impact on milestone tasks | M02 contracts, M03 codec/reference tests, M05 management UI and current group routes. |
| Potential risks | A raw Assign command that bypasses the ordinary plan authorization would still be unsafe. Metadata rename should not invalidate a valid economic plan. |
| Required testing changes | AV-007-01/02/03/05; deletion with remaining members/references must reject without partial changes. |
| Windows compatibility | Works as primitive records and atomic SQLite state changes. |
| Future web implications | Portable state graph and command validation; no new native/storage dependency. |

#### Option B — Balanced: atomic group edits with effective-plan diff and explicit deletion destination

| Review dimension | Assessment |
|---|---|
| Detailed description | Use a single membership slot and typed group CRUD/assignment commands. Before applying a membership or rule edit, compute a bounded effective-settings/authorization diff for affected plots. Preview and explicitly apply those future changes through the existing configuration/consent path. Delete a nonempty group only with an explicit valid destination group or ungroup-to-farm choice and a fresh preview; never silently adopt a paid farm default. |
| Advantages | Maintains usability without dangling references or silent recurring purchases; only 32 plots need diffing; reuses existing authorization rules. |
| Disadvantages | Requires clear deletion/preset-reference behavior and structural-command atomicity distinct from an action batch’s eligible-subset result. |
| Implementation complexity | Moderate: bounded settings diff, graph validation, coherent commands and UI preview. |
| Impact on existing requirements | Clarifies existing DEC-010/025 behavior for indirect group changes. Does not add overlapping membership, nested groups, sub-wallets or new capability gates. |
| Impact on architecture | Shared SettingsResolver/plan validator computes old/new effective rules. Structural membership edits persist coherently; economic starts still use existing Plant/ApplyAndStart semantics. |
| Impact on milestone tasks | M02 reserves group/plan versions and commands; M03 persists them; M05 implements complete management UI/behavior; M04 has a stable basic settings handoff. |
| Potential risks | Deleting group references from saved presets without telling the user could change future behavior. Reject deletion while unresolved references exist rather than silently rewrite them. |
| Required testing changes | AV-007-01–06: reference validity, deletion destination, occupied/stalled/new/Locked states, unchanged plans, false/zero inheritance and atomic failure/recovery. |
| Windows compatibility | Bounded typed computation and the existing SQLite coordinator; no Windows API leakage. |
| Future web implications | Portable canonical state and≤32-plot diff; browser asynchronous commits use the same logical command/result boundary. |

#### Option C — Comprehensive: centralized configuration dependency/version service

| Review dimension | Assessment |
|---|---|
| Detailed description | Provide B’s same user behavior, with a shared dependency/index service for farm defaults, groups, presets and plot overrides. Track which effective plan fingerprints depend on each definition and generate change previews, invalidation and migration validation centrally. Still allow at most one group and no new inheritance layer. |
| Advantages | Uniform indirect-change handling across all settings routes; reduces missed invalidations when more configuration paths are later added. |
| Disadvantages | Larger framework for a32-plot game; introduces an index/version system whose correctness also needs testing. |
| Implementation complexity | High relative to B: dependency cache/index, invalidation and schema changes, without additional gameplay. |
| Impact on existing requirements | Same observable rules as B; infrastructure only. Scope must explicitly exclude nested/overlapping groups and autonomous purchase suggestions. |
| Impact on architecture | Central dependency service around SettingsResolver; authoritative plan results remain reproducible from saved primitives, not only the cache. |
| Impact on milestone tasks | Expanded M02 interfaces/M03 persistence or rebuild index contract; M05 all configuration routes; M06 invalidation coverage/performance. |
| Potential risks | A stale cache could authorize the wrong plan; always revalidate before commit and test full recomputation parity. |
| Required testing changes | All B tests plus dependency invalidation permutations, index reconstruction and cache-versus-full-diff equality. |
| Windows compatibility | Feasible pure GDScript plus normal persistence, but more maintenance than the current farm size requires. |
| Future web implications | Portable if caches are reconstructible and core-only; do not depend on native observer callbacks. |

#### Selected resolution — Option B (Applied to documentation)

Use B. A plot references at most one existing group or none. Group mutations validate the entire structural result and use the same effective-plan/quote/capability checks as direct configuration. Rename-only changes leave economic authorization intact. Effective changes to occupied plots require explicit future-settings Apply; current cycles stay immutable. New Empty starts, changed stalled plans and rearming require explicit Plant/ApplyAndStart. Deleting a group requires an explicit destination or ungroup choice, preview, and resolution of all preset references; no silent fallback to paid defaults.

**Required implementation/design detail after approval.** Define stable group IDs and group/settings revisions; dynamic group identities use AUD-DEC-001. Only economic semantic changes invalidate plan authorization, not a display rename or an overridden group field that leaves a plot’s resolved plan unchanged. Pending UI selection is a draft; execution revalidates the effective diff. Structural membership/deletion is all-or-nothing: reject invalid destinations/dangling references with no partial graph update. A separate/combined explicit farming-action intent still uses DEC-025 eligible-subset results and one coherent durable commit. It never turns a rejected structural edit into a partly deleted group. If Apply explicitly enables Auto Harvest on Ready, preview that existing immediate-harvest consequence and reuse the normal engine transition. Skill-ineligible rules remain inactive; rebuy never rearms them. Locked plot IDs may hold inactive group settings, but grouping cannot unlock or plant them; purchase still requires N+1 and later explicit start. No new administrative level gate is added; saving/applying named farm presets retains its owned level-12 node, and every field retains its original capability gate. M02 only defines these advanced contracts/default records; full UI/advanced behavior stays M05.

**Why this recommendation.** B is a small bounded extension of the current resolver and consent model, supports ordinary deletion/reassignment, and avoids C’s generalized framework. A is safe but makes group management unnecessarily awkward. B does not invent another automation unlock.

**Dependencies and coordinated decisions.** AUD-DEC-004 supplies semantic diff/quote acceptance; AUD-DEC-001 supplies group identity; AUD-DEC-002 persists structure+authorized consequences coherently; AUD-DEC-003 binds saved definitions. AUD-DEC-005 governs resulting automated spending.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-007-01 | Create/rename/assign/unassign/delete with unique group IDs, zero/one membership and valid destinations; malformed/missing references reject unchanged. |
| AV-007-02 | Moving a stalled None plan to paid Advanced, or deleting its group to a paid farm default, cannot spend or silently arm without the existing explicit changed-plan start authorization. |
| AV-007-03 | Occupied cycles remain immutable; explicit future Apply and Ready-on-enable effects are previewed; new Empty/Locked plots never auto-start/unlock from membership. |
| AV-007-04 | A rename or overridden field leaving the effective purchase plan unchanged preserves existing valid loop authorization; explicit false/zero remains an override. |
| AV-007-05 | A failed structural mutation rolls back all graph changes; separately requested eligible action subsets still follow DEC-025 and commit coherently, with no charged failed member. |
| AV-007-06 | Unresolved preset references block deletion; save/reopen/backup/forecast preserve graph, versions and plan authorization. No live forecast writes or hidden group budget overrides. |

**Current disposition:** selected AUD-DEC-007 B is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-008"></a>

### AUD-DEC-008 — Remove stale approval gates while preserving decision history

| Field | Current value |
|---|---|
| Original finding | AUD-008 |
| Severity / category | **Low** / Decision synchronization / obsolete operative wording |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option A**, selected by owner |
| Final approved decision | **Option A — Targeted correction of obsolete operative approval wording while preserving historical records, genuine outstanding evidence obligations and provisional balance boundaries.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“group 4 approved as recommended”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | Does not block unrelated M01 preparation. Correct as part of the authorized documentation synchronization before affected task execution; no reapproval of settled choices is needed. |

**Validity and problem.** Confirmed. The register §3 introduction says both entries are Proposed even though the current DEC-008/027 statuses differ; operative task clauses still describe settled C1/C2 choices as missing. Clearly dated historical states are not themselves defects and must be retained.

**Root cause.** Cumulative approval notes were appended, but several earlier operative sentences were not explicitly superseded at their point of use.

**Exact evidence.** [AR AUD-008, L212](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:212); [TM stale wording gap, L258](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:258); [DR §3 status intro, L786](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:786); [TRS §13 versions, L604](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:604); [M01 T05 G4 clause, L90](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:90); [M02 T01 G2 clause, L64](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:64); [M06 T02 G2 clause, L75](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:75); [DR current remaining facts, L1234](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:1234).

**Affected requirements and documents.** DR §3 intro and any operative reservations; TRS §13/other current-action wording; RM current architecture text/hash inventory; M01-T05, M02-T01, M06-T02; FRS only if a matching operative stale sentence is found; audit traceability/readiness after substantive edits.

**Original decision compliance / conflict.** No original DEC choice changes. Preserve the actual current count 23 Approved/3 Open/1 Deferred, C1 named versions/increasing tail, C2 catalog, C3 style and DEC-027 delivery. Do not promote outstanding artifact/provider/production evidence to Approved/Verified.

#### Option A — Targeted correction with explicit historical labels

| Review dimension | Assessment |
|---|---|
| Detailed description | Replace stale current-action claims with the current remaining verification obligation; label any retained old operative clause explicitly historical/superseded. Preserve approval logs, dates, quotations, rejected alternatives and provisional labels. Refresh RM source hashes only after the final authorized source edits. |
| Advantages | Directly fixes the issue with minimal churn and no new authority hierarchy. |
| Disadvantages | Requires careful scoped searching to avoid deleting genuine history or hiding still-open evidence. |
| Implementation complexity | Low documentation-only work. |
| Impact on existing requirements | No gameplay, architecture or approval-state change. The owner’s Group 4 selection approves this correction; source application is now complete in A1. |
| Impact on architecture | No runtime/class/save change. |
| Impact on milestone tasks | Edit the cited operative clauses and source/reference inventory; do not create new game tasks solely for wording. |
| Potential risks | A global “Open→Approved” replacement would falsely close DEC-001/014/023 evidence and is expressly forbidden. |
| Required testing changes | AV-008-01/02: scoped status/authority review, links/IDs/counts and final byte-exact source hashes. |
| Windows compatibility | No compatibility impact. |
| Future web implications | No portability impact. |

#### Selected resolution — Option A (Applied to documentation)

Use A. Make each current task state the settled selection and its still-pending implementation/evidence duty. Preserve historical approval states as dated history, not active gates. Keep the original register’s current actual parent statuses and all provisional balance boundaries.

**Required implementation/design detail after approval.** Inspect at least DR L786, TRS L604, RM L64, M01-T05 L90, M02-T01 L64 and M06-T02 L75. Current DEC-002 continuation, C2 catalog and DEC-027 policy are settled; actual artifact adoption, clock provider and production qualification remain open as documented. Recompute final hashes from actual bytes after any future authorized edits; do not reuse the spaced audit-rendered values. Do not change source approval quotations.

**Why this recommendation.** Only one substantive resolution is appropriate: correct inaccurate operative wording while keeping historical records. Merely leaving it, deleting all history, or reorganizing the whole package are not necessary alternative solutions to this finding.

**Dependencies and coordinated decisions.** Apply substantive approved AUD-DEC-001–007 changes first, then perform this cleanup and final fingerprint/traceability check. AUD-DEC-009 separately corrects technical strings in the audit artifacts; it is not a prerequisite for reading the intact authoritative sources.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-008-01 | Every operative Open/Proposed/missing approval claim about C1/C2/C3/DEC-027 is either genuinely pending or explicitly labeled historical; no settled choice is reopened. |
| AV-008-02 | After authorized edits, cross-check original decision status, source sections, task/test IDs, links, current hashes and preserved dated approval evidence. Runtime test status remains pending. |

**Current disposition:** selected AUD-DEC-008 A is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

<a id="aud-dec-009"></a>

### AUD-DEC-009 — Restore exact hash strings, link targets and technical tokens in the audit files

| Field | Current value |
|---|---|
| Original finding | DOC-001 (additional review finding; not one of the original eight) |
| Severity / category | **Low** / Audit evidence formatting / exact technical references |
| Approval status / lifecycle | **Applied** |
| Recommended selection | **Option A**, selected by owner |
| Final approved decision | **Option A — Dated audit erratum and byte-exact restoration of hashes, URL targets and technical identifiers, preserving substantive findings and separate historical/current baselines.** The complete selected rule and implementation details below define the approved scope. |
| Approved by / date / confirmation | Project owner / 2026-10-28 (America/New_York) / **“group 4 approved as recommended”** |
| Source-document application | **Applied — A1, 2026-10-28**; complete per-issue file/section/test inventory in [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) |
| Game implementation status | Not started; no game code authorized by this analysis |
| Verification status | Documentation consistency checks recorded in the changelog; lifecycle **Verified not assigned**. Game/runtime/adapter/human tests not run. |
| Earliest affected gate | No M01 gameplay blocker. Correct before treating the old audit’s displayed hash/URL table as a literal reproducibility artifact. Source conclusions can still be evaluated against the intact saved documents. |

**Validity and problem.** Confirmed directly in the saved audit artifacts. PreDevelopment_Audit_Report.md L291–301 contains spaces inside every displayed SHA-256; L283 has a malformed URL with “2 shady4 u”. The traceability matrix also changes 7600X3D to “7600 X3 D” and 2.5D to “2.5 D”. These are audit-output formatting defects, not changes to the underlying source files.

**Root cause.** The prior audit’s broad prose-spacing cleanup also transformed hashes, URLs and technical identifiers. Its local-link/line checks did not protect those exact strings or validate external URL syntax. I introduced this formatting error in the prior audit; the original specifications and plans remain byte-identical.

**Exact evidence.** [AR external URL, L283](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:283); [AR fingerprint table, L287](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:287); [AR spaced TRS hash, L291](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md:291); [TM CPU token, L50](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:50); [TM 2.5D token, L66](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md:66); [RM intact source fingerprints, L32](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md:32); [DR intact image fingerprint, L1293](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:1293).

**Affected requirements and documents.** The four audit deliverables only where their exact tokens were corrupted; their formatting/verification procedure. No FRS/TRS/DR/RM/milestone semantic edit is required by this additional finding. This new proposed register supplies exact independently recomputed fingerprints now, without modifying those audit files.

**Original decision compliance / conflict.** No original decision or provisional balance value changes. This is separate from AUD-008’s stale approval wording and is not folded into that finding to reduce the count.

#### Option A — Restore exact tokens from trusted sources and protect them from prose transforms

| Review dimension | Assessment |
|---|---|
| Detailed description | After approval, recompute file hashes directly from the preserved source bytes; restore the exact release URL and hardware/graphics tokens from the authoritative documents. Preserve substantive finding text and the audit’s historical baseline. Exclude code spans, URLs, file paths, IDs and hash fields from any prose cleanup. Verify technical strings after final rendering/writing. |
| Advantages | Restores verifiable evidence without changing requirements or conclusions; small and reproducible. |
| Disadvantages | Requires checking all four audit outputs for similar token changes rather than fixing only the first example. |
| Implementation complexity | Low documentation/data validation work. |
| Impact on existing requirements | No gameplay or source requirement change. Record a dated audit erratum rather than silently pretending the original output was exact. |
| Impact on architecture | No game architecture or persistence change; tooling/authoring correction only. |
| Impact on milestone tasks | No new milestone implementation task. Use the audit documentation verification step and M06-style evidence discipline without marking any game test passed. |
| Potential risks | Do not overwrite the historical baseline with future source hashes after other approved changes: distinguish “audited original” from “corrected current” manifests. |
| Required testing changes | AV-009-01–03: 64 hexadecimal fields and byte equality, exact URL targets/no injected whitespace, preserved substantive text and separate old/current fingerprints. |
| Windows compatibility | Ordinary local-file hashing; no change to Windows support or selected binaries. |
| Future web implications | Canonical text preservation also protects future web/import references; no browser storage claim. |

#### Selected resolution — Option A (Applied to documentation)

Use A. Add a dated audit erratum and restore byte-exact hashes/URL/identifiers without changing finding dispositions or source specifications. Keep the original audited-baseline manifest separate from any future corrected-source manifest. Apply no blanket spacing substitutions to structured technical fields.

**Required implementation/design detail after approval.** The valid URL is https://github.com/2shady4u/godot-sqlite/releases/tag/v4.9, copied from the original register. The current source fingerprints recomputed in this review match the original pre-audit manifest; see the exact appendix in this file. The dated A1 erratum repairs the audit tokens, preserving original findings and baseline fingerprints.

**Why this recommendation.** There is one genuine corrective action. Rewriting technical strings by hand from memory or deleting reproducibility evidence are not useful alternative resolutions. This decision remains separate and is now Approved; the prior audit files now contain the dated A1 erratum without substantive finding changes.

**Dependencies and coordinated decisions.** Independent documentation correction. Coordinate with AUD-DEC-008 and later audit status refresh so the historical audit baseline is not confused with newly amended specifications.

**Required test changes and exact closure criteria (all future).**

| Proposed criterion | Required result / evidence |
|---|---|
| AV-009-01 | Every displayed SHA-256 has exactly 64 hexadecimal characters and equals the hash of the specifically named baseline bytes; preserve original and amended manifests separately. |
| AV-009-02 | All local links resolve and line numbers exist; all HTTP(S) targets contain no whitespace; compare the corrected release URL and CPU/2.5D tokens byte-for-byte with authoritative sources. |
| AV-009-03 | Review the erratum/diff: only intended technical-token/format repairs and explicit status notes change; original findings and approval evidence are not silently rewritten. |

**Current disposition:** selected AUD-DEC-009 A is **Applied to documentation — A1, 2026-10-28**, after completion of its full source/task/test-reference crosswalk. Original findings/approval history and provisional balance boundaries are retained. See the changelog for exact modifications and checks. No game implementation or runtime verification; lifecycle Verified is not assigned.

## 5. Coordinated decisions, amendments and non-goals

| Coordination | Required combined behavior |
|---|---|
| 001 +002 | Startup writer/allocation identity is injected before tentative catch-up allocations. Unknown startup commit retains the pending identity and reconciles before epoch rotation, input or old-state writes. An abandoned pre-commit attempt is not a committed history. |
| 001 scheduler/authorization | Full identities gain a namespace, but retained-history numeric allocation order remains the scheduler’s logical identity ordering; canonical serialization must not accidentally make UUID lexical order the new priority. Existing saved plan/group/cycle references are not rewritten on every launch. Fresh writer namespace alone does not invalidate an unchanged authorized loop. |
| 002 +003 | Content/schema migration, its rule reference, replay/ID metadata, state and anchor form one coherent commit. Unknown migration outcomes reconcile; never retry from a guessed parent or use a backup as proof that the primary did not commit. |
| 003 +004 +006 | Quotes, upgrade guards, skill eligibility, UI thresholds, forecast and offline simulation resolve the same profile manifest. Unknown content cannot be silently interpreted with the latest global rules. |
| 004 +007 | Group/default/preset edits compare effective semantic plans, not only direct field changes. Metadata-only renames preserve consent; changed stalled/new/rearmed paid plans require the existing explicit action. |
| 005 +007 | Group priority/plan is frozen for each logical batch; after authorization, seed/fixed replanning uses the same content/priority snapshot. Group changes never authorize a replacement crop or a plot unlock. |
| 008 +009 | Preserve historical approval evidence and the original audited source hashes. After authorized semantic updates, publish a separate current hash set; never substitute it into a table claiming to describe the older audit baseline. |

The choices include two explicit precision/scope amendments, which must not be hidden as routine coding: approved 001 B scopes claim permanence to recovered authoritative history; approved 004 B defines as-of research previews and the manual override’s ending-balance minimum. Approved AUD-DEC-006 A selects the previously open equipment guards; source synchronization is complete and the existing balance values remain provisional. Current XP, prices, rewards, skill costs, crop gates, farm geometry, offline policy and growth cap are not retuned by these proposals.

No new currency, crop, consumable, research project, inventory, contract family, prestige, network clock, cloud service, authentication, overlapping/nested group, wallet reservation or mandatory contract is introduced. DEC-008 remains Deferred. Optional journal/migration alternatives must not be implemented if the recommended options are selected. In particular, a journal alternative cannot fsync every historical catch-up event: any later protocol must preserve the current one-logical-result catch-up contract and bounded retained data.

**Performance implications:** recommended 001 adds constant-size identity context and bounded live references;003 adds immutable supported content definitions rather than lifetime events;004 performs targeted validation;005 has at most 33 seed/fixed passes for 32 requests, plus the unchanged exact Smart solver;007 diffs at most 32 plots. None requires extra authoritative threads, per-frame disk writes or a table proportional to an uncapped wallet. These are complexity bounds/expectations, not measured Godot performance. Existing optimizer, WAL/FULL, 32-plot, long-offline and frame qualification remain mandatory future evidence.

## 6. Change-impact matrix — planning only

Requested chain: **Audit finding → Approved decision → Document → Requirement/task → Required change → Required test**. All nine entries now map to their approved selections (001–004 B, 005–006 A, 007 B, 008–009 A). A later approved change of option must update its change/test rows before application. Every required row below has been applied to the documentation. The [correction changelog](../audit/round_01/Audit_Correction_Changelog.md) records before/after requirements, exact files, current section locations and document checks; runtime tests remain future.

| Finding | Approved decision / candidate | Affected document | Exact requirement/task target | Required change after approval | Required test / verification |
|---|---|---|---|---|---|
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | §§10.1/13 | State coherent older-generation rollback and recovered-history claim eligibility; disclose lost progress. | AV-001-02; T-011/018–020; M04-V06/M05-V13 |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§3.1/3.4/3.5/4.1/4.2/8/9.3/9.4 | Define full dynamic identity, namespace injection/codec, retained IDs and scheduler numeric ordering; separate intact-primary recovery from lost-branch rollback. | AV-001-01–04; T-020/021; M03-V01/V13 |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-015/016/019 | Record selected clarification/amendment with original approvals retained; no global all-branches claim promise. | Owner confirmation scope + source diff + AV-001 |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §§3/4 D-16,D-19/6 | Carry identity/recovery scope and M01/M03/M05 evidence ownership. | Source/task crosswalk and no missing recovery oracle |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [M01](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md) | T05/T06/T07/T14; V03/V04/V07/V10 | Reserve namespaced identity in state/commands/clone; preserve scheduler order with fixed injected tokens. | AV-001-01/03/04; M01 replay/clone |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T03/T04/T10/T14/T16; V01/V13 | Round-trip startup namespace/counters; distinguish backup rollback; preserve pending identity during unknown commit. | AV-001-01–04; actual recovery/codec tests later |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T13; V06 | Show recovered revision/time/possible lost progress without claiming recovered lost-branch facts. | AV-001-02; recovery message fixture |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T04/T06/T07/T15; V03/V13/V16 | Use restored eligibility with paired wallet rollback and intact-history once-only guards; pruning preserves retained facts. | AV-001-02/04; real authored claim corpus |
| AUD-001 | [AUD-DEC-001](#aud-dec-001) **B — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T04/T14; V04/V12 | Qualify full identity/recovery scope and disclose older generations accurately. | AV-001; T-018–020/026/027 |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§4.1/5/8/9.2/9.3/12 | Add commit outcome categories, identity/expected-parent receipt, stopped reconciliation and no stale writes. | AV-002-01–05; T-018–020 |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-013/015/016 implementation notes | Record the safe uncertainty protocol without weakening durability or replay semantics. | Approval scope and state/anchor/replay audit |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §3 controller contract/§6 tests | Assign same-process unknown outcomes to M01 contract/M03 implementation and M06 rerun. | Coverage check for all checkpoint kinds |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [M01](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md) | T06/T13/T14; V03/V10 | Model candidate outcomes and stopped/unknown fake sink path; keep durable revision distinct from unsaved simulation state. | AV-002-01/02/05 with fakes |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T02/T03/T05/T06/T10/T14/T15/T16; V02/V03/V13/V15 | Implement commit identity, expected parent, safe read-back, blocked write routes and time-ledger reconciliation. | AV-002-01–05; actual adapter faults later |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T08/T13/T15; V05/V14 | Show unresolved/reconciling state; prevent duplicate replacement purchases and old shutdown/settings writes. | AV-002-04; latency/settings/recovery UI fixtures |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T06/T15; V03/V13/V16 | Repeat unknown-result tests for real contract progress/claims and full configuration. | AV-002; T-011/018–020 |
| AUD-002 | [AUD-DEC-002](#aud-dec-002) **B — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T04; V04/V12/V14 | Test receipt loss with process alive, not only restart recovery, on the exact adapter/build. | AV-002-01–05; preserve candidate-specific evidence |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | §§5/12.1/13/16 | Define profile-bound immutable progression and explicit unsupported-migration behavior; no retuning. | AV-003-01–05; T-008/010/026 |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§3.1/3.2/3.5/5/9.3/9.4 | Specify complete manifest binding, invariant validation and no implicit incompatible curve/skill migration. | AV-003; lossless version/snapshot fixtures |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-002/004/024 | Record compatibility policy while retaining approved current curve/one-point rules and later balance approval duty. | Approval/source comparison; exact current vectors |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §§3/4 D-02,D-04,D-24/6 | Add supported content-context and migration ownership across milestones. | Crosswalk and unsupported-version disposition |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [M01](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md) | T02/T03/T05/T12/T14; V05/V07/V13 | Bind state to immutable rules before lookup/validation; preserve derived level and point conservation. | AV-003-01–03; current option-B exactness |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [M02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) | T01/T04/T05; V01/V05/V12 | Skills/quotes/reset use the profile rules, not global latest definitions. | AV-003-02/03; rank/prerequisite/reset fixtures |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T03/T10/T12/T13/T16; V01/V09/V18 | Validate supported manifests, preserve binding during schema migration and run catch-up in that context. | AV-003-01–05; T-026/029 |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T11; V05 | Display correct profile thresholds/allocations; do not present a legacy rule as a new undefined curve. | AV-003-03; quote/display parity |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T13/T15; V09/V11 | Keep old-profile support and approved tuning separate; full forecast/offline/save parity per context. | AV-003-03–05; T-021/022/026 |
| AUD-003 | [AUD-DEC-003](#aud-dec-003) **B — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T03/T04/T09; V01/V04/V16 | Qualify declared supported content/migration matrix; do not claim absent mappings passed. | AV-003; actual supported migration corpus later |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | §§6.3/7.1/8/9.2 | Clarify as-of timing previews and ending-balance bound while preserving explicit plan/cost consent. | AV-004-02/03/04; T-009/023 |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§4.1/4.2/5/6.2/12.2 | Separate raw intent from immutable accepted envelope; stamp centrally after due work; define quote semantic terms. | AV-004-01–05; T-020/021 |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-006/007/010/016/025 | Record exactly the preview/acceptance clarification; no backdating or inferred replacement authorization. | Owner approval scope + current batch/lifecycle invariants |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §3 command/quote boundary; §6 | Carry accepted-log, quote and rejection-baseline ownership. | Replay/coverage check |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [M01](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md) | T06/T13/T14; V03/V04/V10 | Define accepted stamp/order, immutable replay envelope and post-due rejection baseline. | AV-004-01/02/05 with fakes |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [M02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) | T02/T05/T07/T08/T10; V05/V06/V13 | Implement shared quote/semantic validators and accepted-time boost result; bind recurring plans. | AV-004-02–05 |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T05; V02/V13 | Keep command identity/accepted result coherent with commit uncertainty/replay. | AV-004-05 + AV-002 |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T08/T09/T11/T12; V04/V05/V13 | Show precise as-of/accepted results and changed-term refresh; preserve pending intent identity. | AV-004-01–05; user-facing confirmation checks |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T11; V08/V12 | Group/preset changes use the same quote/authorization path. | AV-004-02/05 + AV-007 |
| AUD-004 | [AUD-DEC-004](#aud-dec-004) **B — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T03/T08; V12/V13 | Qualify queued input/boost/reset/override cases with current durable state. | AV-004; replay and consent evidence |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | §7.1 | State selected batch exclusion/retry subset outcome without inventing a fixed-request optimum. | AV-005-01/03/05 |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§4.2/6.2/8 | Define canonical removal,≤N+1 passes, fresh reservations and final M/C before Smart. | AV-005-01–05 |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-010; DEC-009 conditional objective note | Record A’s bounded non-maximal subset behavior and unchanged exact Smart guarantee. | Approval scope/source equations |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §3 budgets/§4 D-10/§6 | Carry deterministic exclusion and acceptance oracle into allocator/catch-up ownership. | Coverage and per-batch C trace |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [M02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) | T11/T12/T14/T15; V04/V13 | Implement/exhaustively validate seed/fixed replan, fallback, bounds and coherent final proposal. | AV-005-01–05; existing Smart oracle regressions |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T13; V14 | Aggregation preserves every logical batch’s exclusion outcome and one final cap. | AV-005-04/05; event-reference differential |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T12; V13 | Explain fixed-policy stalls without promising maximum planted count or authorized substitutions. | AV-005-01/03 user message fixtures |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T09/T11/T15; V06/V11/V12 | Forecast and advanced priority rules use the same planner. | AV-005-02/04/05; copy/reference parity |
| AUD-005 | [AUD-DEC-005](#aud-dec-005) **A — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T03/T06; V01/V13 | Qualify cascade correctness and bounded seed/fixed work without hiding optimizer time. | AV-005; 32-plot measured regression later |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | §§6.1/16 | Specify all 11 predecessor/cost guards and no extra level/research/skill/contract gates; preserve provisional values. | AV-006-01–04 |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§3.5/5/17 | Require complete upgrade guard manifests and future-cycle-only effects. | AV-006-01/03; content validator |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-004/024 | Close the open equipment-guard subpart only after explicit approval; retain final-balance evidence duty. | Approval scope + no silent numeric retuning |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | D-04 and equipment coverage | Replace missing-guard dependency with selected exact manifest and tests. | Cross-reference table/guard completeness |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [M02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) | T01/T06/T17; V09/V14 | Use selected 11-row guard manifest and pay all chosen upgrade costs in pacing traces. | AV-006-01–04; actual strategy results later |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T03/T10 content/version validation | Preserve selected upgrade definitions/ranks through supported snapshots/migrations. | AV-006-01/03 + AV-003 |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T10; V05 | Store shows only real rank/cost/cap guards, no invented level/research lock. | AV-006-01–03; preview/execution parity |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T02/T13/T14; V09/V10 | Audit all ranks, excluded optional families and full-cost balance consequences. | AV-006-04; no-contract/no-equipment comparisons |
| AUD-006 | [AUD-DEC-006](#aud-dec-006) **A — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T03/T09; V01/V08 | Re-evaluate upgrade-using pacing without treating guard selection as balance validation. | AV-006; normal-speed human/strategy evidence later |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | §§7.1/9.2 | Clarify single group and indirect future-plan/deletion consent without a new unlock. | AV-007-01–06 |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §§3.3/3.5/4.1/5/6/9.4 | Define group identity/revision, nullable membership, structural commands, effective-plan diff and references. | AV-007; lossless codec/atomic mutation checks |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | DEC-010/012/025 | Record the existing hierarchy/consent extension and unchanged M02/M03/M05 staging. | Scope review: no overlapping groups, wallet override or hidden start |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §§3/4 staging/coverage | Assign group contracts M02, schema M03 and full UI/behavior M05. | No premature implementation claim or missing schema prerequisite |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [M02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) | T10/T16/T18 | Reserve complete group/authorization command and state contracts with inactive advanced defaults. | AV-007-01/04 contract fixtures; intermediate commands unavailable |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [M03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md) | T03/T05/T10/T17; V01/V14 | Persist/reference-validate group revisions and plan consent atomically; preserve unknown-version safety. | AV-007-05/06 + AV-002 |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [M04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | T12/T18 handoff | Basic group settings route follows agreed capability/consent semantics; advanced management remains M05. | AV-007-02/03; correct UI staging |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [M05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | T11/T12/T15; V08/V12 | Implement complete single-membership CRUD, destination/deletion preview, reference guards and action-subset distinction. | AV-007-01–06 with real group/preset/rotation states |
| AUD-007 | [AUD-DEC-007](#aud-dec-007) **B — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T03/T04/T08; V04/V13 | Qualify indirect configuration consent, graph crash safety and no locked-plot bypass. | AV-007; actual integrated evidence later |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [DR](C:/_/IdleFarmer/docs/decisions/Decision_Register.md) | §3 L786/current-action reservations | Correct current statuses; preserve dated approval history and outstanding empirical obligations. | AV-008-01/02 |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [TRS](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md) | §13 L604 and equivalent operative notes | Describe selected names versus pending actual artifact/adoption checks accurately. | AV-008-01/02 |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [RM](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md) | §3 L64; source hashes after final edits | Update operative pin/resolution wording and exact current fingerprints only after synchronization. | AV-008-02 + AV-009-01 |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [M01](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md) | T05 L90 | Mark G4-only content reservation historical; C2 catalog is settled. | AV-008-01 |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [M02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md) | T01 L64 | Distinguish historical pre-C1 tail reservation from present selected option B; equipment guards follow AUD-DEC-006. | AV-008-01 |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [M06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md) | T02 L75 | Replace obsolete beyond-30 selection gate with required optionB evidence. | AV-008-01/02 |
| AUD-008 | [AUD-DEC-008](#aud-dec-008) **A — Applied** | [FRS](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md) | Current-action text only if a matching stale clause is found | Do not change accurate history or gameplay; avoid unnecessary edits. | AV-008 scoped search/source diff |
| DOC-001 (additional review finding; not one of the original eight) | [AUD-DEC-009](#aud-dec-009) **A — Applied** | [AR](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md) | L283; §§Frozen source fingerprints L287–301; any similar exact-token changes | Restore exact release URL/64hex baseline strings and add dated erratum; never silently replace historic baseline with future hashes. | AV-009-01–03 |
| DOC-001 (additional review finding; not one of the original eight) | [AUD-DEC-009](#aud-dec-009) **A — Applied** | [TM](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md) | L50/L66 and similar exact technical tokens | Restore7600X3D/2.5D and other identifiers from original sources; preserve task/requirement mapping. | AV-009-02/03 |
| DOC-001 (additional review finding; not one of the original eight) | [AUD-DEC-009](#aud-dec-009) **A — Applied** | [VS](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md) | Exact tokens only if affected | Audit/recover protected URLs/IDs/code spans; do not retune calculated numbers or change scenario claims. | AV-009-02/03 |
| DOC-001 (additional review finding; not one of the original eight) | [AUD-DEC-009](#aud-dec-009) **A — Applied** | [RD](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Readiness.md) | Audit evidence note/links if affected | Reference corrected audit evidence accurately without claiming game readiness changed merely from formatting. | AV-009-02/03 |

**Cross-cutting audit updates after authorized application:** for 001–007, append dated disposition/approval/application evidence in AR, refresh TM chains/reverse ownership, replace unresolved-oracle wording with the selected expected result in VS, and reassess RD’s M01 conditions. Preserve the original audit as dated evidence rather than retroactively claiming its original conclusions were different. For 008/009, record documentation verification separately from game evidence. Update this register’s Applied/Verified fields only with exact changed files and recorded checks. If an alternative option is chosen, revise its impact rows before edits begin.

## 7. Application sequence and acceptance gates (documentation applied; runtime future)

1. All four groups have explicit owner approvals recorded with option letters, exact confirmations/dates, dependencies and amendments. Unselected alternatives remain unapproved; recording approval does not apply the corrections. A selection that depends on an unselected alternative is returned as a concrete coordinated choice, not silently combined.
2. A1 has written the selected recovery/identity, commit, version and input contracts in FRS/TRS/original DR, and synchronized RM, all affected tasks and acceptance oracles. No game code was created.
3. Selected M02 allocator/equipment/group contracts and explicit deadlines are now documented. Their runtime behavior remains in the owning M02/M03/M05 tasks; M01 does not implement later advanced gameplay.
4. A1 has repaired the selected obsolete operative clauses and exact audit tokens, preserving separate historical/current manifests. The changelog records source diffs and the document/reference/ID/hash/preservation checks.
5. The A1 readiness addendum assesses the corrected documentation as Ready with Conditions for M01: concrete 001–004 contracts and synchronized acceptance cases exist. Separate implementation instruction and artifact verification remain required; no universal migration engine is added.
6. Only a later explicit implementation instruction starts game work. M01 artifact verification remains T01; SQLite/provider work M03; art/configuration proof M04; full contract/group behavior M05; final performance/human evidence M06.

**Safe deferrals:**005–007 until their specified M02 contract/behavior gates;008/009 until documentation synchronization before affected evidence is relied upon; actual DEC-001/014/023 evidence according to existing milestones. **Unsafe deferral:** coding a final M01 identity, command/commit boundary, progression binding or accepted-time contract before a selected 001–004 rule is written. This does not block unrelated read-only planning or toolchain inventory.

No option in this register validates final balance or 48 hours of engagement. Existing costed schedules remain plausibility calculations. Equipment gate selection changes which upgrade-using traces are legitimate, so later tests must state that manifest. No automatic product waiver, earnings cap or extra mechanic follows from a target miss.

## 8. Technical feasibility checks and limits

SQLite distinguishes statement/transaction errors and some failed commits can leave a transaction active; read transactions can also retain an earlier snapshot. These facts support settling the adapter/transaction before read-back. See [SQLite transaction/error documentation](https://www.sqlite.org/lang_transaction.html). Autocommit reports whether a transaction is active, not the identity of the logical game outcome; combine adapter state checks with the proposed checkpoint identity/revision read, as discussed in [SQLite autocommit API](https://www.sqlite.org/c3ref/get_autocommit.html). The coordinator proposed here is an architectural inference; no claim is made that the chosen addon already exposes every needed observation or passes this protocol.

GDScript provides 64-bit integers and strings, while mutable containers require deliberate copying; the proposed IDs/version references therefore fit plain typed records in principle. See [official GDScript type reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#built-in-types). Actual parsing/codec/adapter behavior remains pinned-toolchain validation. Do not use unsupported nested typed collection syntax merely because a logical record is nested.

The future web path retains shared-core logic and adapter separation. Browser persistence can be unavailable or cleared, and lifecycle/background behavior differs; see [official Godot web export limitations](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#limitations). These proposals retain the required minimal M03 probe and do not claim Windows durability in a browser. Primary references were consulted on 2026-10-28; no dependency installation, native test, export or game simulation was run.

## 9. Exact reviewed-baseline fingerprint appendix

These hashes were recomputed directly from the saved input bytes for this review and are intentionally unformatted inside their code spans. They identify the unchanged source baseline and the current audit files containing the separately documented DOC-001 formatting defects. Do not confuse the hash of an audit file with the source fingerprints displayed inside that file.

| File relative to `C:/_/IdleFarmer` | SHA-256 of reviewed bytes |
|---|---|
| `docs/architecture/IdleFarmer_Technical_v1.5.md` | `6189D7A6976A557D890ECC5C8CBED235B9A065B8B477707AA600C06BDCBF9277` |
| `docs/audit/Design_Validation_Scenarios.md` | `2B6D061CFFF2B88F31EFC0E9A34F62F73E5BF34DB27F88CE63924DC5C5539393` |
| `docs/audit/PreDevelopment_Audit_Report.md` | `3C103ED73A07BED7568959E543BD7CE9342F2536B33CF8F9A2B5E3C235FF7BCB` |
| `docs/audit/PreDevelopment_Readiness.md` | `4BB4CE1F5C2242C3BC2191C8C42B7EBC1F70128625482350B617EF72F78C9BBB` |
| `docs/audit/Requirements_Traceability_Matrix.md` | `970B648DAB984BBF4C08F3840BA9BCA9F55A22BC36B4BADD9DF5E73BA049C8F0` |
| `docs/decisions/Decision_Register.md` | `4346E401807B62388A44F3DA59E57BCD46B678F181E1307A946346B0D048D323` |
| `docs/decisions/visuals/Art_Direction_Comparison_v1.png` | `92F04DC1374A5C7EEAF01CE84785D09E36F1FC0935C99030688974499FC7C16F` |
| `docs/implementation/00_IdleFarmer_Master_Roadmap.md` | `BFEC6917FCE15E3739A7EE69D34132FA62326799A6E7A8B89863A518E4D8408A` |
| `docs/implementation/01_M01_Headless_Simulation_Foundation.md` | `E72EEC2ED865E899089E852156F2860AB24F4B9A43068F38380ED755E37D3B57` |
| `docs/implementation/02_M02_Economy_Skills_Research_Automation.md` | `F506D9B0CBB9A1F2D50FF8CE2E6FFDE6DB71219BDE86B4B11838394DD9C78CEB` |
| `docs/implementation/03_M03_Saves_Time_Offline_Farming.md` | `BAB1E1A9DE9CCE1AE4CB6B5FA199AEE81578D7C636841F7C9A48D1952E0CFF27` |
| `docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md` | `7E297B2E02B2CDB3412182E109E1DF414E0217305B51E8D7BACCAE4180F4314C` |
| `docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md` | `51E891A1C0F22A2097C74A22AD89471A2D9567D0A20FFEC1E325366645926067` |
| `docs/implementation/06_M06_Validation_Performance_Windows_Release.md` | `60A78FF6D8EBEA24D2A3B1ECBA01DFCA83670CEAD09EEA9C3BEB98E2FF4B065B` |
| `docs/requirements/IdleFarmer_Functional_v1.0.md` | `3BF9A9179232B516BE472189779CDF34D262EDE33B33D9DD5ECC99A5E2179E21` |

**Revision 1 verification record (historical):** All pre-existing input files were hash-compared again after this register was written. That analysis turn added only `docs/decisions/Audit_Decision_Register.md` to the project. No input document, original decision, audit artifact, reference image or implementation plan was edited. Proposal structure/link/hash checks are documentation checks; source corrections and runtime tests remain unapplied/unrun. Revisions 2–5 change only this register to record the four groups’ approvals; the other 15 project documents/reference artifacts were hash-checked again and remain unchanged.

## 10. Approval and verification log

| Date | Event | Decision outcome | Application / verification |
|---|---|---|---|
| 2026-10-28 | Resolution analysis and proposed options prepared | All AUD-DEC-001–009 **Proposed**; final approved choices empty | New register authored and proposal completeness/source preservation checked. No source corrections applied; no game implementation/runtime verification. |
| 2026-10-28 (America/New_York; 2026-10-29 00:28 UTC recorded) | Project owner confirmation: **“Approve Group 1 recommended”** | **AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B — Approved**; AUD-DEC-004–009 remain Proposed | Approval metadata, selected-rule labels and impact-matrix status synchronized in this register only. Source documents/plans/audits unchanged; no fix applied, game code or runtime verification. |
| 2026-10-28 (America/New_York; 2026-10-29 00:38 UTC recorded) | Project owner confirmation: **“Group 2 Approved recommended”** | **AUD-DEC-004 B — Approved**; 001–003 B remain Approved; AUD-DEC-005–009 remain Proposed | Approval metadata, selected-rule labels and impact-matrix status synchronized in this register only. Source documents/plans/audits unchanged; no fix applied, game code or runtime verification. |
| 2026-10-28 (America/New_York; 2026-10-29 00:55 UTC recorded) | Project owner confirmation: **“agreed with group 3 recommendations”** | **AUD-DEC-005 A, AUD-DEC-006 A, AUD-DEC-007 B — Approved**; 001–004 B remain Approved; AUD-DEC-008–009 remain Proposed | Approval metadata, selected-rule labels and impact-matrix status synchronized in this register only. Source documents/plans/audits unchanged; no fix applied, game code or runtime verification. |
| 2026-10-28 (America/New_York; 2026-10-29 00:58 UTC recorded) | Project owner confirmation: **“group 4 approved as recommended”** | **AUD-DEC-008 A, AUD-DEC-009 A — Approved**; all nine audit decisions now Approved | Approval metadata, selected-rule labels and impact-matrix status synchronized in this register only. Source specifications/plans/audits unchanged; no correction Applied or Verified, game code or runtime verification. |
| 2026-10-28 / A1 | Owner instructed applying all Approved resolutions | **All AUD-DEC-001–009 Applied** with selected 001–004 B, 005–006 A, 007 B, 008–009 A | Full source/task/test crosswalk synchronized; exact changes/document checks in Audit_Correction_Changelog.md. Original audit findings/approval history preserved. No game code, lifecycle Verified or runtime/human pass. |

**Documentation application complete — A1:** all nine approved resolutions are Applied to the sources, task plans and test references, with the original audit findings preserved. [Audit_Correction_Changelog.md](../audit/round_01/Audit_Correction_Changelog.md) gives exact before/after references and files. M01 is Ready with Conditions as a documentation baseline: a separate coding instruction and M01-T01 artifact verification are still required. Original Open/Deferred evidence, actual runtime/human testing and final balance remain pending. No decision is marked Verified.

## 11. R2-C1 documentation verification amendment — 2026-10-29

This follow-up records verification rather than rewriting the historical approval choices or the A1 status fields. The Round 2 audit verified the seven substantive source contracts; the authorized R2-C1 cleanup completes the stale-operative-wording and current-link corrections. No game implementation or runtime pass is inferred.

| Finding / approved choice | Current finding status | Verification scope / remaining evidence |
|---|---|---|
| AUD-001 / AUD-DEC-001 B | Verified Resolved | Round 2 verified the namespaced identity/recovered-timeline design and staged tasks/tests; R2-C1 changes no rule. Runtime recovery still unvalidated. |
| AUD-002 / AUD-DEC-002 B | Verified Resolved | Round 2 verified UNKNOWN coordination and all-write blocking design; real adapter faults still unvalidated. |
| AUD-003 / AUD-DEC-003 B | Verified Resolved | Round 2 verified immutable profile manifests and compatibility design; executable migration evidence still pending. |
| AUD-004 / AUD-DEC-004 B | Verified Resolved | Round 2 verified accepted time/order and semantic confirmation design; runtime queue/receipt tests still pending. |
| AUD-005 / AUD-DEC-005 A | Verified Resolved | Round 2 verified terminating canonical replan and exact oracles; optimizer/reference benchmarks still pending. |
| AUD-006 / AUD-DEC-006 A | Verified Resolved | Round 2 verified all eleven equipment guard rows; R2-C1 removes the remaining stale M02-T06 instruction without changing guards. |
| AUD-007 / AUD-DEC-007 B | Verified Resolved | Round 2 verified group graph/consent design and staged delivery; full M05 behavior still unvalidated. |
| AUD-008 / AUD-DEC-008 A | Verified Resolved | R2-002 corrects M02-T06 and §2; active instructions no longer reopen equipment gates or deny A1 application. AV-008 document checks recorded in R2-C1. |
| DOC-001 / AUD-DEC-009 A | Partially Resolved | R2-001 repairs all 91 stale current links; exact restored tokens and available current/A1 bytes are checked. Original full pre-A1 source bytes were not located, so independent reproduction of every older hash and the complete original erratum-preservation diff remains Unable to Verify under AV-009-01/03. No remaining broken-link defect is claimed. |

R2-001, R2-002 and R2-003 themselves are **Verified Resolved** as scoped documentation findings; DVS-013's current positive fixture is defined by its dated erratum and M05-T12. The original eight findings now total eight Verified Resolved; supplemental DOC-001 retains one explicitly bounded provenance limitation. This is not a new gameplay issue or an M01 design blocker. M01-T01 remains **Not Yet Verified**, with actual artifacts/runner evidence required before adoption; DEC-001/014/023 Open subparts, DEC-008 Deferred scope and all later runtime/human gates remain unchanged.
