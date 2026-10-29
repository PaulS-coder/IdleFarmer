# Idle Farmer — Independent Pre-Development Audit Report

> **Dated audit erratum and application addendum A1 — 2026-10-28:** The original audit below (findings, severities, scenarios, calculations and pre-correction assessment) is preserved as historical evidence. Its source line citations identify the frozen pre-A1 baseline, not shifted current lines. Approved corrections are tracked in the appended A1 addendum and [Audit_Correction_Changelog.md](Audit_Correction_Changelog.md), with current before/after references. DOC-001 repairs only exact technical strings; it does not rewrite substantive findings. Decisions are Applied to documentation, not runtime-verified. Original DEC-001/014/023 evidence remains Open and DEC-008 remains Deferred.

Audit date: **2026-10-28 (America/New_York)**. Baseline: current saved files in `C:/_/IdleFarmer`; FRS v1.0, TRS v1.5 clarification C3, Decision Register revision 14. This is a documentation audit. No game code, source-specification edits, engine installation or game-test execution was performed. Line numbers refer to this frozen baseline.

| Alias | Exact source file |
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

## Assessment

**Not Ready for unrestricted M01 gameplay implementation.** The package is unusually explicit about ordering, budgets, snapshots and future evidence, and most approved choices are propagated correctly. Four narrow foundation contracts still need correction or clarification before they become M01 interfaces: recovery identity scope, uncertain-commit reconciliation, progression migration invariants and input/quote acceptance. These are targeted design changes; they do not justify replacing Godot, SQLite, the single simulation model or the six-milestone sequence.

| Severity | Count |
|---|---:|
| Critical | 0 |
| High | 3 |
| Medium | 4 |
| Low | 1 |
| Total | 8 |

There is no demonstrated catastrophic game bug because no game exists. Findings distinguish a literal contract incompatibility, missing contracts, explicitly unresolved content and low-risk stale wording. **Unperformed future tests are not counted as implementation defects.** Existing formal decision status is **23 Approved, 3 Open with approved subparts, 1 Deferred** ([DR decision index, L54](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:54)); the premise that all 27 are fully resolved is not supported by the saved register. There are also unclosed policy/data details inside otherwise settled topics, especially equipment gates. Counts here are audit findings, not new DEC approvals.

## Scope, source selection and revision comparison

Read all ten current Markdown files completely, including all six plans and the full 1,344-line decision history, and inspected the referenced comparison image. Checked local links, task/validation IDs, declared task dependencies, source fingerprints, numeric examples and cited technology references. No conversations were used to fill gaps. Recorded approval quotations are treated as the project's documentary approval evidence; this audit does not independently authenticate prior conversations.

The active documentation is in `C:/_/IdleFarmer/docs`, last saved through October 28. The chat working folder `C:/Users/pslep/OneDrive/Documents/ChatGPT/Idle Farmer/docs/planning` contains ten October 25 **incomplete DRAFT** documents. All ten were read. The ZIP beside them contains byte-identical copies of those ten drafts. They describe source recovery and a proposed M00–M04 structure, not an earlier full numeric version of the current six-milestone design. Their confirmed Godot/GDScript, offline-first and future-web boundaries survive; their missing-content placeholders and proposed five-stage plan were replaced by the fuller current package. The current register explicitly records the later six-milestone baseline and approved geometry/progression amendments.

Git has no commits (the current docs are untracked), and no earlier complete FRS/TRS/M01–M06 revisions were found. Consequently **an unintended numeric or textual regression across the actual approval revisions cannot be ruled out**. The synchronization histories identify intended changes, but cannot substitute for a prior snapshot diff. This is a revision-evidence limitation, not proof that an approved rule was lost. The old drafts' inaccessible conversation references were not treated as missing current specifications or consulted for gameplay assumptions. The image-generation skill link was read as provenance only; no image generation was performed.

Current FRS/TRS/image SHA-256 values match the roadmap/register. All linked local project files exist. Full fingerprint inventory appears below, so this audit can be matched to an exact saved baseline.

## Pass 1 — Decision and requirement traceability

The companion `Requirements_Traceability_Matrix.md` gives all **27** decision chains (FRS → TRS → task → validation), explicit partial/deferred status, decision intersections and non-decision requirement coverage. There are **101 unique implementation tasks**, **92 unique validation IDs**, all **30** source test IDs, and no undefined fully qualified task/validation reference. Coarse requirement families have implementation and test owners; this does **not** mean each behavioral edge has a complete oracle.

Key decision interactions checked:

| Decision intersection | Audit result |
|---|---|
| DEC-002/003/004/020 | Zero/Empty start, 8-column prefix, exact XP curve and six points at level 7 agree. Four automation nodes cost four points. Future curve migrations need AUD-003. |
| DEC-005/026 | Rounding, positive duration, safe intermediates and checkpoint preservation agree. No artificial cap is inferred from finite integers. |
| DEC-006/025 | Due research and auto batch before serial commands; manual harvest replant and eligible-subset batches agree. Controller envelope/authorization detail needs AUD-004. |
| DEC-009/010/011 | Same-mode/priority exact objective, fixed-before-Smart order, global cap C and level 9/15 controls agree. No singleton default priority or implicit approximation remains in controlling rules. Fixed-plan replanning needs AUD-005. |
| DEC-012/022 | Advanced behavior is M05 after M02 interfaces/M03 schema; the browser probe is required at M03-T18 before T17, not deferred to production-web work. |
| DEC-013/014/015 | Real anchor and active debug time are separated; measured provider remains open. Ordinary rollback/forward consequences are explicit and are not reported as new defects. |
| DEC-015/016/019 | Atomic state/anchor/accounting/claim commits and bounded replay agree within an intact history. Older-backup identity scope and uncertain receipt handling need AUD-001/002. |
| DEC-017/018/021 | Completed-minute windows, productive Growing time, post-catch-up session, separate settings and 1× forecast are synchronized. |
| DEC-008/024 | Deferred families remain excluded; no-contract paths and separate human evidence are required. No new mechanic is needed or authorized by this audit. |
| DEC-001/023/027 | Named versions/Compatibility/x86_64, chosen style/reference envelope and standalone ZIP agree. Artifact, provider, actual asset/hardware and qualification evidence remain staged obligations. |

No wholly orphan gameplay family or unrelated implementation task was established. Missing *executable detail* is concentrated in the eight findings; group lifecycle is the clearest task/acceptance decomposition gap. Existing tests broadly name the first three hazards but lack the exact expected recovery/migration outcome. AUD-008 identifies remaining obsolete action wording; historical unselected alternatives were not treated as current contradictions.

## Findings

### AUD-001 — Older-backup restoration cannot preserve unconditional identity and claim permanence from the lost branch

| Field | Finding |
|---|---|
| Severity | **High** |
| Category | Recovery / identity / contract permanence |
| Evidence classification | Proven contract incompatibility under literal rollback reading; recovery-policy clarification required |
| Earliest affected milestone | M01 |
| Blocks development? | Yes — define identity and rollback scope before M01-T05/T06; implementation of recovery remains M03/M05. |
| Exact source locations | [DR DEC-016; command-epoch solution, L231](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:231); [DR DEC-016; cycle/entity identities, L233](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:233); [TRS §3.1 next_entity_id, L119](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:119); [TRS §3.5 ContractState, L179](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:179); [TRS §4.1 identity invariants, L205](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:205); [TRS §9.3 recovery generations, L430](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:430); [M03 M03-T10, L145](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:145); [M05 M05-T04/G4, L91](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:91) |
| Affected documents / changes required | FRS §13 and contract recovery wording in §10; TRS §§3.1/3.4/3.5/4.1/9.3/9.4; DEC-016/019 recovery boundaries; M01-T05/T06/T14, M03-T03/T10/V13, M05-T04/T06/V13, M06-T04. |

**Issue.** The design restores an older complete checkpoint, restarts the command writer epoch, and also says cycle/entity/transaction identities never reuse within a profile and claimed offers remain protected after backup recovery. Only command identities include the new writer epoch. The entity allocator is a checkpointed next_entity_id; claimed-offer history is in that same checkpoint. A backup predating allocations or a claim cannot contain those later facts. Restarting the command epoch does not recover them. The package does not bound the permanence promise to the recovered timeline or define a new entity-allocation namespace after rollback.

**Why it matters.** This affects M01 identity shapes and later save validation, replay comparisons and contract recovery. A team could ship a counter-only allocator while tests assert a stronger impossible guarantee. This is not an accusation that restoring an old save creates extra coins in the recovered balance: the old claim credit is also rolled back.

**Counterexample.** Backup B has next_entity_id=100 and offer CON-Q01 unclaimed. The primary allocates cycle 100 and claims Q01, then becomes unrecoverable. Restore B and persist a fresh command epoch. Allocating from the restored counter reuses entity 100; the recovered contract state again permits Q01. The new command epoch prevents old command payload replay, but cannot supply the missing primary history.

**Recommended correction.** State explicitly what restoring an older generation rolls back, including earned balances and claim eligibility from the lost branch. Freeze an allocation identity scheme that cannot collide across recovery branches (for example an injected persisted allocation namespace plus counter), or explicitly revise the within-profile no-reuse promise. Decide whether one-time offers are guaranteed within the recovered authoritative timeline or across all historical branches; the latter requires surviving history beyond the rollback snapshot and a larger recovery design. Do not invent that extra storage silently or present it as anti-tampering.

**Missing or sharpened acceptance evidence.** Restore a backup predating both an allocation and a claim. Assert the selected namespace/identity behavior, display the rollback scope, reject retired command payloads, and verify contract eligibility according to the explicitly chosen recovered-history policy. Keep this distinct from crash recovery of an intact committed primary.
### AUD-002 — Commit-with-lost-response is tested but has no explicit safe in-process recovery protocol

| Field | Finding |
|---|---|
| Severity | **High** |
| Category | Transaction atomicity / uncertain commit |
| Evidence classification | Missing failure-state contract; concrete fault risk, not a demonstrated implementation bug |
| Earliest affected milestone | M01 |
| Blocks development? | Yes — reserve the outcome/reconciliation contract in M01-T06/T13 before the in-memory sink becomes the persistence boundary. |
| Exact source locations | [TRS §4.1 CommandResult, L197](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:197); [TRS §4.1 replay protocol, L203](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:203); [TRS §5 SaveRepository, L272](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:272); [TRS §9.3 storage failure, L438](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:438); [M01 M01-T06, L94](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:94); [M03 M03-T02, L75](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:75); [M03 M03-T05, L105](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:105); [M03 M03-T15, L209](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:209); [M06 M06-T04, L101](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:101) |
| Affected documents / changes required | TRS §§4.1/5/9.2/9.3/12; M01-T06/T13 sink contract; M03-T02/T05/T06/T14/T15 and V02/V03/V13; M04-T08/T13; M06-T04. Clarify DEC-015/016 implementation contract without changing their durability choice. |

**Issue.** The plans correctly demand committed-but-response-lost tests and commit-before-success. The repository has a success receipt and failure categories, and the failure rule keeps the previous in-memory durable outcome and offers retry/recovery. It never defines the third case: the caller cannot tell whether the database committed. Blindly treating that as rollback leaves memory/anchor/replay marks behind the database. Deduplication is durable, but the engine can still hold the old high-water until it reloads.

**Why it matters.** A successful economic batch must have one authoritative resolution even when its acknowledgement is lost. This is an API and lifecycle requirement, not a reason to weaken WAL/FULL. Existing test names identify the hazard but do not specify what a running controller must do before another action, retry, shutdown save or backup.

**Counterexample.** At revision 40 a planting batch commits revision 41, including a debit/new cycle/replay mark. The adapter loses the receipt. The controller retains revision 40. If Retry re-executes against old memory, or a shutdown/settings checkpoint writes it over revision 41, the database and engine can diverge or undo confirmed processing. A crash-and-reload path may work while this same-process path fails.

**Recommended correction.** Define definitely committed, definitely not committed, and outcome unknown (or an equivalent protocol). On uncertainty, keep exclusive profile ownership, block mutations/time checkpoints/settings checkpoint writes/backups, and read/validate the committed revision and transaction identity before continuing. Reconcile live state, scheduler, anchor, replay high-water and presentation from that receipt/state; resolve the original command without issuing a replacement purchase. Use expected-revision checks or equivalent protection against writing stale checkpoints. Failure to reconcile stays a recoverable stopped state.

**Missing or sharpened acceptance evidence.** Inject a receipt loss after an actual successful commit while the process remains alive; then try retry, settings save, time checkpoint, backup and shutdown. Each path must converge on revision 41 or remain blocked, never overwrite it with 40 or charge again. Also test a definitely rolled-back transaction.
### AUD-003 — XP-curve retuning has no policy for previously awarded levels and skill points

| Field | Finding |
|---|---|
| Severity | **High** |
| Category | Progression / content migration |
| Evidence classification | Unresolved migration policy; counterexample to unrestricted retuning with current invariants |
| Earliest affected milestone | M01 |
| Blocks development? | Yes — choose the invariant and version policy before M01-T03/T05/T12; migration execution is M03/M05. |
| Exact source locations | [FRS §5.1.1 versioned retuning, L229](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:229); [FRS §5.5 reset retention, L270](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:270); [FRS §12.1 balance review, L546](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:546); [TRS §3.2 level and point invariants, L132](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:132); [TRS §5 ProgressionSystem, L278](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:278); [TRS §9.4 content versions, L470](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:470); [M03 M03-T10, L147](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:147); [M05 M05-T13, L163](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:163) |
| Affected documents / changes required | FRS §§5/12.1/13/16; TRS §§3.2/3.5/5/9.3/9.4; DEC-002/004/024 compatibility notes; M01-T03/T05/T12, M03-T03/T10, M05-T13, M06 migration qualification. |

**Issue.** The current curve, recurrence and point awards are precise. The problem is the permitted future tuning/migration: level is looked up from cumulative XP and unspent+allocated points must equal levels gained. Tuning must preserve earned XP and paid/growing snapshots, but no rule says whether earned levels/points are grandfathered, remapped, revoked, or kept on a profile-specific curve. This is not solved by a content_version label alone.

**Why it matters.** Recomputing level after raising thresholds can invalidate allocated skills, point conservation, previously purchased plots and contract acceptance. Re-awarding levels after lowering thresholds can duplicate points if an awarded-level watermark is not defined. Choosing the wrong invariant now can force changes to M01 state and progression APIs.

**Counterexample.** A valid profile has XP=5,200, level 7, six earned points and owned Auto Replant. A separately approved balance update raises the level-7 threshold to 6,000. Keeping XP=5,200 and six points while deriving level 6 violates the current level−1 point invariant and an allocated level-7 node gate. Revoking a point/skill or inventing XP is not authorized by the current migration wording. This example is a counterfactual migration test, not a proposed tuning change.

**Recommended correction.** Freeze one compatibility policy before coding derived level/award state: retain each existing profile on its previous versioned curve until an explicit migration is approved, or define an approved earned-level/awarded-point mapping with its necessary persisted fields. Specify behavior for raised/lowered thresholds and changed rank maxima/prerequisites. Reject an unsupported content migration safely rather than infer it. Preserve the selected current option B; do not retune it during this audit.

**Missing or sharpened acceptance evidence.** Migration fixtures for thresholds raised/lowered around current XP, allocated level-gated skills, surplus points, changed rank maxima, accepted contracts and active crops. Assert the chosen earned-level/point invariant and no duplicate grants after restart or a second migration attempt.
### AUD-004 — The input-time and quote-validation boundary is underspecified for a continuously advancing UI

| Field | Finding |
|---|---|
| Severity | **Medium** |
| Category | Input ordering / quote authorization |
| Evidence classification | Missing interface detail; deterministic counterexample if UI time is stamped too early |
| Earliest affected milestone | M01 |
| Blocks development? | Yes — document controller acceptance/stamping and quote identity before M01-T06/T13. This is a small contract correction, not a new gameplay decision. |
| Exact source locations | [DR DEC-006, L181](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:181); [TRS §4.1 time envelope, L193](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:193); [TRS §6.2 manual quoted override, L313](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:313); [TRS §12.2 live ordering, L546](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:546); [M01 M01-T06, L96](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:96); [M02 M02-T05 confirmation token/version, L90](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:90); [M04 M04-T08, L104](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:104); [M04 M04-T09, L112](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:112) |
| Affected documents / changes required | TRS §§4.1/5/6.2/12.2; M01-T06/T13/T14, M02-T02/T05/T08, M04-T08/T09/T11. Reference DEC-006/025 without silently changing their batch order or purchase authorization. |

**Issue.** Commands reject stale/future simulation times, the UI routes current accepted time, and the controller advances scheduled work before queued commands. The package does not pin when the controller stamps time versus when a UI snapshot is read, or which quote fields/revision remain binding after intervening automatic work. Strict whole-state-revision rejection is safe but could invalidate a confirmation whenever an unrelated plot harvests.

**Why it matters.** Independent implementations can reject ordinary clicks as stale, or refresh a quote and execute a newly priced/changed plan under an earlier confirmation. This touches the M01 envelope and M02 quote model, so it should not be improvised in M04.

**Counterexample.** A panel displays state at simulation t=100.000 and forms a command/quote. Before it is dequeued, active progression reaches t=100.016 and another plot completes an automatic batch. Rejecting the UI-stamped time makes a normal click stale. Silently replacing a seed/fertilizer/recurring plan while restamping can exceed the confirmed authorization. An unchanged quote should have a defined route as well.

**Recommended correction.** Make controller acceptance the documented timestamp/sequence authority, with due work drained according to DEC-006 and the accepted envelope recorded for replay. Define expected cycle/plan/content/quote identity and when an intervening state change demands refresh/reconfirmation rather than execution. Preserve the approved stale/future-envelope rejection rule for already formed accepted envelopes; do not allow backdating. Set the rejection test baseline after independently due work, so rejecting the command does not undo a legitimate automatic batch.

**Missing or sharpened acceptance evidence.** Queue a click across a maturity boundary, a boost quote while research time elapses, a reset quote across a level-up, and a manual reserve override across another harvest. Assert current accepted timing, exact authorized plan or a clear refreshed rejection, replay equality and no replacement purchase after response loss.
### AUD-005 — Fixed-fertilizer reservation release needs a terminating selection rule and a known-answer test

| Field | Finding |
|---|---|
| Severity | **Medium** |
| Category | Shared-wallet allocator / termination |
| Evidence classification | Missing deterministic planning rule; no demonstrated double-spend |
| Earliest affected milestone | M02 |
| Blocks development? | No for M01; resolve before M02-T11/T12/T15 can pass. |
| Exact source locations | [DR DEC-010 approved spending steps, L443](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:443); [FRS §7.1 replanning, L323](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:323); [TRS §6.2 seed/fixed feasibility, L316](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:316); [M02 M02-T11, L128](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:128); [M02 M02-T12, L136](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:136); [M02 M02-T15, L154](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:154); [M02 M02-V13, L214](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:214) |
| Affected documents / changes required | TRS §6.2; clarify FRS §7 only if the selected observable subset requires a gameplay clarification; DEC-010 explanation as needed; M02-T11/T12/T15 and V04/V13; M03 aggregation differential fixtures; M06-T03. |

**Issue.** Seeds must be reserved before fixed fertilizer; failed fixed requests without fallback release reservations and cause deterministic replanning. The documents define order and a no-progress guard, but not whether removed requests can re-enter the same planning pass, what the progress measure is, or which final feasible subset is required when a released seed would make the removed request affordable in isolation. A stable ID order alone does not resolve that algorithm.

**Why it matters.** Repeated seed reservation can revisit the same infeasible set; alternatively, an implementation can let a high-priority fixed request displace another already committed seed, violating seed-first behavior. A guard that merely stops looping can return different accepted subsets depending on container traversal.

**Counterexample.** W=100, R=0, equal priority. Plot 1 requests Corn seed 18 + Premium 75, with no fallback. Plot 2 requests Corn seed 18 + None. Reserving both seeds leaves 64, so plot 1 fixed fertilizer fails. Dropping plot 1 frees 18. Plot 1 alone would cost 93, but reinserting it recreates the original 64-fertilizer budget. Document whether plot 2 alone plants (wallet 82) under seed-first monotonic rejection, rather than repeatedly reconsidering plot 1 or displacing plot 2.

**Recommended correction.** Specify a terminating deterministic planning procedure consistent with the approved seed-first/fixed-first stages, including whether excluded requests stay excluded for that logical batch and when a later relevant event may retry them. A monotone rejected-set/progress measure is one implementation option, not an audit-imposed gameplay change. Do not change custom priority or fallback consent silently. Add the exact two-plot case and a 32-plot cascade oracle.

**Missing or sharpened acceptance evidence.** The fixture has one approved expected accepted set, spends only for planted cycles, terminates with a documented decreasing measure, produces identical results under input permutation, and cannot spin again without a relevant external state change.
### AUD-006 — Required equipment unlock gates remain undefined outside the settled decision totals

| Field | Finding |
|---|---|
| Severity | **Medium** |
| Category | Equipment requirements coverage |
| Evidence classification | Explicit unresolved content choice already admitted by the sources |
| Earliest affected milestone | M02 |
| Blocks development? | No for M01; blocks completion of M02-T01/T06 and authentic upgrade-using progression evidence. |
| Exact source locations | [FRS §6.1 equipment ranks, L280](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:280); [FRS §6.1 unlock display, L285](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:285); [FRS §16 item 3, L601](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:601); [DR DEC-004 equipment gates, L361](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:361); [RM D-04, L87](C:/_/IdleFarmer/docs/implementation/00_IdleFarmer_Master_Roadmap.md:87); [M02 M02-T01, L60](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:60); [M02 M02-T06, L98](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:98); [M05 M05-T13, L163](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:163) |
| Affected documents / changes required | FRS §§6.1/16, TRS content validation references, DEC-004/024 manifest notes and RM D-04; M02-T01/T06/T17/V09, M04-T10, M05-T02/T13, M06-T09. |

**Issue.** Irrigation and Improved Soil have rank prices/effects but no complete unlock requirements. FRS §16 explicitly lists unspecified equipment unlock gates; DEC-004 says resolve them in the content manifest and do not invent them. Plans ask to read those gates from decision content that does not yet supply them. The 23/3/1 parent status count does not mean these data choices are resolved.

**Why it matters.** Buying Irrigation early materially changes time to automation; arbitrary level gates or an assumption of no level gates invalidates a full-cost balance trace even if all its arithmetic is correct.

**Counterexample.** At level 2 the farm has 650 coins and can afford Irrigation I. One implementation permits purchase with just coins and preceding-rank checks; another hides it until a chosen level. Both can follow the listed price table, but only one can match an approved unlock manifest. No source chooses between them.

**Recommended correction.** Publish explicit per-rank unlock guards, including an explicit statement if no player-level gate is intended, and predecessor-rank semantics. Record the selection under the existing equipment/progression decision scope instead of inventing a new gameplay family. Until then, use only no-equipment schedules for audit pacing claims or label an upgrade assumption as conditional.

**Missing or sharpened acceptance evidence.** Every required rank has a complete manifest row and below/at gate, previous-rank, exact funds, insufficient funds and maximum-rank cases. Progression traces pay those exact costs and observe those exact guards.
### AUD-007 — Plot-group lifecycle and membership changes lack an executable ownership contract

| Field | Finding |
|---|---|
| Severity | **Medium** |
| Category | Plot-group ownership / inherited authorization |
| Evidence classification | Incomplete task/acceptance decomposition for an existing required feature |
| Earliest affected milestone | M02 |
| Blocks development? | No for M01 if group records stay inert; settle group contracts in M02 before persistence schema M03. |
| Exact source locations | [FRS §7.1 Plot > Group > Farm, L317](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:317); [FRS §9.2 future settings authorization, L422](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:422); [TRS §3.3 group_id, L141](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:141); [TRS §3.5 inherited settings, L176](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:176); [M02 M02-T10, L124](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:124); [M05 required group commands, L47](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:47); [M05 M05-T11, L151](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:151); [M05 M05-V08, L234](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:234) |
| Affected documents / changes required | TRS §§3.3/3.5/4.1/6/9.4; FRS §7 only for observable clarification if needed; M02-T10/T16, M03-T03/T10, M05-T11/V08/V12, M04/M05 group settings UX. |

**Issue.** Groups are required for inheritance and presets, and PlotState has one group_id. The plans mention group commands but do not define creation/deletion/assignment, single membership validation, precedence during reassignment, or how moving/deleting a group changes an armed plot's accepted purchase-plan revision. Preset CRUD does not itself specify group membership behavior.

**Why it matters.** Moving a stalled plot from a None group to a paid fixed-fertilizer group can silently change its recurring purchases unless authorization is revalidated. Deleting a group can leave dangling references or accidentally treat false/zero as unset. This is missing implementation/acceptance detail for an approved feature, not a request for overlapping-group mechanics.

**Counterexample.** Plot 1 has no plot-level fertilizer override and is an authorized stalled member of group G (None). Reassign it to group H (Advanced, no fallback), or delete G so a paid farm default becomes effective. The sources require changed stalled plans to be explicitly authorized, but give no group-command outcome or test for this route.

**Recommended correction.** Define minimum group ownership/lifecycle commands within the current single-group model, reference validity and atomic membership edits. Recompute effective plan identity and apply existing DEC-025 consent/rearm rules to affected plots; preserve current cycles. Specify safe handling of group deletion and preset references. Assign focused tasks/acceptance cases in M02 contracts and M05 behavior; do not add overlapping priorities or new grouping mechanics.

**Missing or sharpened acceptance evidence.** Single membership, invalid/dangling group rejection, reassignment/deletion with occupied/new/stalled plots, inherited explicit false/zero, future-cycle snapshots, changed-plan consent, atomic save/reopen and forecast isolation.
### AUD-008 — Several operative task clauses still describe settled choices as missing

| Field | Finding |
|---|---|
| Severity | **Low** |
| Category | Decision synchronization / task wording |
| Evidence classification | Proven residual obsolete statements; controlling sources otherwise resolve the choices |
| Earliest affected milestone | M01 |
| Blocks development? | No. Correct alongside substantive source synchronization; do not reopen settled approvals. |
| Exact source locations | [DR §3 introductory status, L786](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:786); [TRS §13 toolchain paragraph, L604](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:604); [M01 M01-T05 G4 constraint, L90](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:90); [M02 M02-T01 G2 constraint, L64](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:64); [M06 M06-T02 G2 constraint, L75](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:75) |
| Affected documents / changes required | DR §3 intro, TRS §13, cited M01/M02/M06 task clauses and any equivalent active reservations; refresh RM hashes only after legitimate source edits. |

**Issue.** The register §3 says both deferrable entries are still Proposed, although DEC-008 is Deferred and DEC-027 Approved. TRS §13 says exact dependency versions remain open despite C1's named pins. M01-T05 still says exact contract content is not approved; M02-T01 cautions against final XP continuation without approval; M06-T02 calls beyond-30 a distinct required decision gate despite C1 and its own later constraint. Some are embedded historical-group clauses, but they remain inside operative tasks without a local superseded label.

**Why it matters.** These do not overturn current FRS/C1/C2 authority. They can nevertheless cause agents to stop for repeat approval or track obsolete missing requirements. The current high-level status is correct; the issue is residual actionable wording, not the dated approval history.

**Counterexample.** A developer follows M06-T02's G2 constraint and reports that beyond-30 selection blocks evidence mapping, even though the same task later traces approved option B. A reader of DR §3 reports two Proposed entries instead of zero.

**Recommended correction.** Mark these exact clauses historical/superseded or replace their current-action wording with remaining verification duties. Preserve approval history and provisional balance status. Recheck reference/hash inventories after edits.

**Missing or sharpened acceptance evidence.** Search current-action sections for still-open/proposed claims about C1 names/tail, C2 catalog and DEC-027 policy; each is either explicitly historical or matches revision 14's 23 Approved /3 Open /1 Deferred inventory.

## Pass 2 — Adversarial system assessment

| Area | Evidence-based assessment and remaining work |
|---|---|
| Crop state machine | Locked/Empty/Growing/Ready, no maturity reward, no spoilage and immutable cycles are coherent (FRS §§3–4; TRS §§3.4/4.3). Stalled is explicitly an Empty subset, not a fifth disjoint state. Test stale cycle/event IDs, simultaneous manual/auto attempts and reset/rearm. |
| Economy | Independent crop/fertilizer/expansion/contract and XP calculations pass the stated examples. Explicit fixed unprofitable fertilizer remains permitted; Smart must prefer None for nonpositive incremental gains. Equipment gates remain AUD-006. |
| Skills/research | Acyclic predecessor graph, one point per rank/node, four-node automation and one-project/one-boost formulas are implementable. Half remaining time must use current accepted time, ceil and no-time-saved rejection; content migration remains AUD-003. |
| Automation/budgets | Farm-wide R/p/toggle exception and Plot > Group > Farm inheritance agree. Paid seeds can consume basic reserve unless the advanced toggle is on; free seeds remain eligible below reserve. AUD-005/007 address remaining subset/group routes. |
| Smart optimizer | Exact Pareto pruning is feasible in principle but is not a worst-case time guarantee. 4^32 = 18,446,744,073,709,551,616 combinations, so brute force is unsuitable. A large wallet itself can be capped for *solver capacity* at total purchasable option cost without capping earnings; current maximum is 32 × 19,110=611,520 coins. This is an analysis bound, not a replacement algorithm. Benchmark actual GDScript frontier and exact-rate arithmetic as already required in M02-T13/T14 and M06-T06. |
| Exact rate arithmetic | Current base durations have LCM 3,600 minutes. Future batch candidates at one current growth reduction share that factor before ceiling; current minute durations and integer basis points divide cleanly into microseconds. This offers a possible integer objective scaling proof for current content. Arbitrary future content or mixed snapshotted durations still needs safe exact rational handling. No floating objective or silent approximation is justified. |
| Offline/event ordering | Research → harvest/credits/XP/contracts/accounting → seeds/fixed/Smart → cycles, then commands, is coherent. Aggregation must preserve logical batch caps and IDs, not just totals. Statistics boundaries, funding thresholds and rotations can prevent long jumps; event-driven alone is not proof of the provisional five-second target. |
| Clocks/debug/sleep | The 4,200-second example is correct. Forward-clock exploitation and future anchors after rollback are accepted policy, not defects. Actual Windows active/suspended partition is still unproven; DEC-014's measurement-first choice is a legitimate M03 gate. Catch-up-to-active cutover and periods spent computing/committing must be included in time traces. |
| Save/crash/recovery | WAL/FULL and consistent backups are a plausible durable foundation. Core must stage candidate outcomes and resolve commit uncertainty. A database transaction lock alone is insufficient profile ownership; M03-T04 already requires a separate whole-lifecycle lock. AUD-001/002 identify the uncovered recovery semantics. |
| Contracts | All 12 rows and their design-reference arithmetic agree. Named-crop/AutoHarvest acceptance, actual automatic origin, mixed AND, ordered post-acceptance progress, frozen rewards, three occupied slots and manual claim are specified. Test duplicate acceptance of the same active offer explicitly, as well as reaccepting only an abandoned unclaimed offer; existing offer-state guards should reject duplicate active acceptance. Older-generation guarantees need AUD-001. |
| Statistics/forecast | Half-open completed-minute buckets, operating versus payment-time cash flow, Growing-only utilization and separate occupancy are coherent. Test exact minute events and long unharvested cycles after detail pruning. A forecast may legitimately return zero harvests for a currently growing six-hour crop; never replace it with steady-state income. Ensure copy work is cancellable/yielded sufficiently for M05-T10's responsive UI; actual latency is future performance evidence. |
| Godot/GDScript | RefCounted services, validated Resources, typed primitives and a test-harness SceneTree are compatible conceptual boundaries. No irreconcilable class or public API conflict was found. Resource deep-copy ownership and native adapter import exclusion require tests; filenames are explicitly suggestions. |
| SQLite/web | SQLite is isolated from shared core; lossless int64 snapshot codecs and a test browser adapter are planned. Compatibility/single-thread-friendly web export is a credible future path, not proof of browser persistence equivalence. No production web port is required for Windows. |
| 32 plots/long offline | Render count is modest; work can still be dominated by exact solving, commits or reporting. Fastest current capped Wheat at 60× lasts 3.2 real seconds: staggering 32 cycles yields up to 10 distinct economic maturity batches/sec, versus 0.3125/sec if synchronized. Benchmark both. A365-day capped Wheat farm has 5,256,000 harvests; a minute-by-minute year has 525,600 boundaries. Memory must depend on retained data/pending work, not these event totals. |

The separate scenario file contains concrete steps, exact oracles and evidence classifications for these areas. No runtime or hardware result is claimed.

## Independent arithmetic and pacing conclusions

- Tomato + Basic: ceil(270×15/100)=41; floor(270×125/100)=337; completed-cycle profit 337−55−41=241. Expansion total 2×(250+1,000+4,000+12,000)=34,500.
- The rounded post-30 recurrence matches all source 31–40 examples and the largest representable threshold 349=9,203,731,170,706,289,434. Threshold 350=10,124,104,287,776,924,021 exceeds int64; max valid XP still maps to 349. This verifies arithmetic, not a running game.
- All 12 contract design references and floor 10% rewards check out. Total one-time rewards are 590,828 coins /54,099 XP. This finite reward pool does not prove engagement duration.
- Full listed research costs 974,750 coins; Irrigation 1,874,750; Improved Soil 783,900; expansion 34,500; combined 3,667,900 excluding all recurring seeds/fertilizer/boost/reset spending. Equipment gate uncertainty prevents an unconditional upgrade-using progression proof.
- A free-Wheat focused strategy with two growth ranks and four automation points reaches level 7/full basic automation at 278.08 minutes (4.635 h) under zero-latency synchronized harvest/plant assumptions. A prescribed Wheat→Corn route with real Corn research 800 and all seed payments reaches it at 239.68 minutes (3.995 h). Details and wallets are in the scenario file. They support *plausibility* of the 3–5-hour goal, not human pacing validation or all-strategy balance.
- There are 34 existing skill ranks/nodes, so all can be filled by level 35 at 871,045 XP. In a conditional already-funded 32-plot Saffron fixture starting level 26/290,000 XP at the growth cap, 17 synchronized 0.8-hour batches award 598,400 XP and reach 35 in 13.6 simulated hours. This excludes the cost/time to reach and fund that fixture, and measures no human engagement. At full coin modifiers, Saffron also beats Vanilla on continuous net/hour and XP/hour, while Vanilla retains a longer unattended harvest interval. The balance suite should examine strategy contraction rather than infer every crop has a useful late-game rate niche.

**3–5 hours:** plausible numerical schedules exist; further real decision/action-latency, equipment-gate, upgrade/research/boost and mixed-offline simulations plus normal-speed human observations are required. **48 further engaging active hours:** unvalidated. No actual participant sessions, diaries or complete end-to-end late-game costed progression traces exist in the package. The planned M05/M06 evidence protocol is appropriate, but a goal and finite catalog cannot establish that outcome. Neither a pass nor a proven failure is justified today. Do not delay M01 for 48 hours of nonexistent-game playtesting; preserve it as an explicit later product gate.

## Pass 3 — Implementation feasibility and dependency review

The declared local task graph has no cycle. The unusual M03-T18-before-T17 ordering is intentional, documented and valid. No task/reference ID is missing. Broad estimates of half-day to two days are explicitly indicative and splittable; optimizer, clock, crash and art tasks should be split based on observed work, not presumed to fit those estimates.

| Milestone | Feasibility / dependency assessment |
|---|---|
| M01 | Appropriate kernel scope. Fix AUD-001–004 in the documented contracts first; then state, arithmetic, scheduling, manual farming and progression can proceed without a wholesale redesign. Verify actual selected toolchain artifacts before adopting them in T01. SQLite/provider/art evidence is not an M01 prerequisite. |
| M02 | Skills, quotes, required equipment and research then allocation/automation are a sound sequence. T08/T09 can introduce preliminary behavior, but T15 is the coherent integration gate; do not mark replant allocation final before T11–T14. Freeze equipment gates and group/allocator contracts before their affected tasks. Advanced capability records/gates may be tested without claiming M05 commands work. |
| M03 | Repository/schema/ownership precede durability/catch-up; accounting precedes historical replay; optimized catch-up follows reference. Native adapter spike and clock selection are legitimate empirical prerequisites. T06's final time-cadence tests require T08/T09/T11 integration even though the skeleton can be written earlier. Explicitly capture that integration in T16, including unknown receipt recovery. |
| M04 | Depends appropriately on stable M03 lifecycle and M02 quotes. Production art proof precedes bulk 75 assets; selected style is not a new approval question. Mouse pending-response, quote and group-consent behavior must follow the corrected kernel contracts. |
| M05 | Real contract recovery is repeated correctly after generic M03 fixtures. Queries/forecast precede advanced rules, then T15 repeats integration with presets/rotation; this is staged extension, not a dependency cycle. Group lifecycle remains insufficiently decomposed. Migration policy cannot be invented at T13. |
| M06 | Final validation, hardware, human evidence and standalone candidate are appropriately owned. T12 may build a candidate while T10 human work is in progress, but T15 must wait for target disposition and candidate-specific evidence. Publishing remains separate. |

There is intentional repeated validation across milestones, not duplicate ownership of economic mutation. No platform API is mandated inside the simulation; the WindowsTimeProvider suggested path under core/time is acceptable only because imports/native observations stay behind the adapter and the browser composition omits it. No foundational graphical work is needed for M01; no code was created to test that assumption.

## External technical verification (read 2026-10-28)

Primary pages corroborate the named release metadata: [Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/), [GUT 9.7.1 tagged compatibility](https://raw.githubusercontent.com/bitwes/Gut/v9.7.1/README.md), [tagged plugin version](https://raw.githubusercontent.com/bitwes/Gut/v9.7.1/addons/gut/plugin.cfg), and [godot-sqlite 4.9 release](https://github.com/2shady4u/godot-sqlite/releases/tag/v4.9). These support candidate availability and documented version mappings; they do not verify local binaries, checksums or actual 4.7.2/native integration. Historical alternative pages 4.6.3/v4.8 and the two linked MIT license files were also read; the alternatives remain unselected.

[SQLite synchronous documentation](https://www.sqlite.org/pragma.html#pragma_synchronous) explains WAL/FULL commit synchronization, and [SQLite backup guidance](https://www.sqlite.org/backup.html) describes consistent online backup/VACUUM INTO paths. The planned wrapper must prove its chosen path rather than naively copy an active WAL database. [Godot web export guidance](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) supports the Compatibility/WebGL 2 and single-thread-oriented direction. No package installation or benchmark was performed. Complete future license and binary qualification remains the project's planned work.

## Frozen source fingerprints

| File relative to `C:/_/IdleFarmer` | SHA-256 |
|---|---|
| `docs/architecture/IdleFarmer_Technical_v1.5.md` | `6189D7A6976A557D890ECC5C8CBED235B9A065B8B477707AA600C06BDCBF9277` |
| `docs/decisions/Decision_Register.md` | `4346E401807B62388A44F3DA59E57BCD46B678F181E1307A946346B0D048D323` |
| `docs/implementation/00_IdleFarmer_Master_Roadmap.md` | `BFEC6917FCE15E3739A7EE69D34132FA62326799A6E7A8B89863A518E4D8408A` |
| `docs/implementation/01_M01_Headless_Simulation_Foundation.md` | `E72EEC2ED865E899089E852156F2860AB24F4B9A43068F38380ED755E37D3B57` |
| `docs/implementation/02_M02_Economy_Skills_Research_Automation.md` | `F506D9B0CBB9A1F2D50FF8CE2E6FFDE6DB71219BDE86B4B11838394DD9C78CEB` |
| `docs/implementation/03_M03_Saves_Time_Offline_Farming.md` | `BAB1E1A9DE9CCE1AE4CB6B5FA199AEE81578D7C636841F7C9A48D1952E0CFF27` |
| `docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md` | `7E297B2E02B2CDB3412182E109E1DF414E0217305B51E8D7BACCAE4180F4314C` |
| `docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md` | `51E891A1C0F22A2097C74A22AD89471A2D9567D0A20FFEC1E325366645926067` |
| `docs/implementation/06_M06_Validation_Performance_Windows_Release.md` | `60A78FF6D8EBEA24D2A3B1ECBA01DFCA83670CEAD09EEA9C3BEB98E2FF4B065B` |
| `docs/requirements/IdleFarmer_Functional_v1.0.md` | `3BF9A9179232B516BE472189779CDF34D262EDE33B33D9DD5ECC99A5E2179E21` |
| `docs/decisions/visuals/Art_Direction_Comparison_v1.png` | `92F04DC1374A5C7EEAF01CE84785D09E36F1FC0935C99030688974499FC7C16F` |

All original source hashes were rechecked after authoring the audit outputs. The audit writes only the four requested Markdown deliverables under `docs/audit` in the project. Analysis scratch files reside outside the project documentation package. Source preservation and documentation checks are audit evidence, not game-test passes.

## A1 correction application addendum — 2026-10-28

Original findings AUD-001–008 above remain the independent audit record. Their selected corrections are now **Applied to the documentation** as mapped below; no severity is retroactively deleted and no game defect is claimed fixed by an unwritten implementation. DOC-001 is the separately approved audit-output erratum. The changelog records exact changed files/sections and old/current hashes.

| Original finding / selected resolution | Applied documentation outcome | Current source / future criterion |
|---|---|---|
| AUD-001 / AUD-DEC-001 B — Applied | Namespaced full dynamic IDs and retained numeric order; lost-branch claim flags/credits roll back together. | FR-AUD-001; TRS §§20.1/15.1; AV-001 |
| AUD-002 / AUD-DEC-002 B — Applied | Every checkpoint has identity/expected parent; UNKNOWN blocks all writes and reconciles the settled primary. | FR-AUD-002; TRS §§20.2/15.1; AV-002 |
| AUD-003 / AUD-DEC-003 B — Applied | Complete immutable supported profile manifest; level/points remain derived under that context; no implicit incompatible migration. | FR-AUD-003; TRS §§20.3/15.1; AV-003 |
| AUD-004 / AUD-DEC-004 B — Applied | Controller-owned accepted time/order and unchanged semantic terms; as-of boost preview and ending-wallet minimum. | FR-AUD-004; TRS §§20.4/15.1; AV-004 |
| AUD-005 / AUD-DEC-005 A — Applied | Monotone no-fallback exclusions, no batch re-entry, ≤N+1 passes; Smart runs on final plan; non-maximal subset disclosed. | FR-AUD-005; TRS §§20.5/15.1; AV-005 |
| AUD-006 / AUD-DEC-006 A — Applied | All 11 required ranks have only coin/predecessor guards and future-cycle effects; no extra level/research/skill/contract gates. | FR-AUD-006; TRS §§20.6/15.1; AV-006 |
| AUD-007 / AUD-DEC-007 B — Applied | Single membership, effective-plan diff, explicit delete destination/reference checks and structural atomicity. | FR-AUD-007; TRS §§20.7/15.1; AV-007 |
| AUD-008 / AUD-DEC-008 A — Applied | Obsolete operative status/pin/tail/catalog reservations corrected; historical approvals retained. | Changelog A1; AV-008; corrected operative clauses/evidence |
| DOC-001 / AUD-DEC-009 A — Applied | Dated erratum restores exact original source hashes, release URL, CPU and 2.5D tokens; substantive audit evidence retained. | Changelog A1; AV-009; corrected operative clauses/evidence |

**Current assessment:** Ready with Conditions for M01 as a documentation baseline: the four foundation contracts and remaining M02 rules now have explicit sources/tasks/oracles. A separate implementation instruction is still required. M01 verifies selected artifacts before adoption; M03 actual storage/clock/provider and minimal web evidence, M04–M06 production/hardware, all runtime and human balance/engagement evidence remain unexecuted. The original 3–5-hour plausibility calculations and unvalidated 48-hour goal are unchanged.
