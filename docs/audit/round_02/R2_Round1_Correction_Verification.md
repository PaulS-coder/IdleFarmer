# Idle Farmer — Round 1 Correction Verification, Round 2

Verified: **2026-10-29, America/New_York**, against the saved A1 package in C:/_/IdleFarmer. This is independent **documentation and design verification**, not a report of executable game tests. No source file, decision status or historical audit record was edited.

## Sources and interpretation

Canonical sources: [FRS v1.0/A1](../../requirements/IdleFarmer_Functional_v1.0.md), [TRS v1.5/A1](../../architecture/IdleFarmer_Technical_v1.5.md), [original Decision Register revision 15](../../decisions/Decision_Register.md), [Audit Decision Register revision 6](../../decisions/Audit_Decision_Register.md), [master roadmap](../../implementation/00_IdleFarmer_Master_Roadmap.md), and the six plans: [M01](../../implementation/01_M01_Headless_Simulation_Foundation.md), [M02](../../implementation/02_M02_Economy_Skills_Research_Automation.md), [M03](../../implementation/03_M03_Saves_Time_Offline_Farming.md), [M04](../../implementation/04_M04_Visual_Farm_Art_UI_Audio.md), [M05](../../implementation/05_M05_Contracts_Statistics_Complete_Progression.md), [M06](../../implementation/06_M06_Validation_Performance_Windows_Release.md).

Original issues and evidence: [Round 1 audit report](../round_01/PreDevelopment_Audit_Report.md), [traceability matrix](../round_01/Requirements_Traceability_Matrix.md), [design scenarios](../round_01/Design_Validation_Scenarios.md), [readiness assessment](../round_01/PreDevelopment_Readiness.md) and [A1 correction changelog](../round_01/Audit_Correction_Changelog.md). The [Round 2 independent report](R2_Independent_Audit_Report.md) defines R2-001–003; the [validation report](R2_Traceability_And_Validation.md) supplies new scenario reasoning.

The fresh review of the current baseline preceded the Round 1 checklist. Each resolution below was checked against actual normative source rules and owning task/validation rows, rather than accepted from the register's Applied labels. Old audit line citations identify its pre-A1 baseline. Current source sections and stable task IDs are the reliable crosswalk; changed line positions alone are not a defect.

“Verified Resolved” means the original missing/contradictory **design contract** is now correctly defined and propagated sufficiently to implement and test. It does not mean that the unwritten game has passed AV/T/V checks. Runtime work remains in its approved milestone. It is therefore neither an unresolved design finding nor a “Deferred by Approval” design finding merely because its future executable test has not run.

## Complete outcome matrix

| Original ID and severity | Original issue | Approved decision | Current implementation of the correction | Independent outcome | Remaining issue / regression check |
|---|---|---|---|---|---|
| AUD-001 — High | Counter-only dynamic IDs and unbounded claim permanence were incompatible with older-backup rollback. | AUD-DEC-001 **B** | FR-AUD-001; TRS §§3.1,4.2,9.3,20.1; namespaced full IDs plus recovered authoritative timeline. | **Verified Resolved** | No new semantic defect established. Intact-primary once-only claims remain distinct from old-generation rollback. |
| AUD-002 — High | A committed result with lost receipt could leave old memory able to overwrite the database. | AUD-DEC-002 **B** | FR-AUD-002; TRS §§3.1,5,9.2,12,20.2; three outcomes, expected parent/durable revision and stopped read-back. | **Verified Resolved** | Commit IDs are also explicitly outside gameplay allocation, preventing checkpoint cadence from changing cycle identities. |
| AUD-003 — High | Retuning XP/skills could invalidate earned level/points and allocations without a compatibility invariant. | AUD-DEC-003 **B** | FR-AUD-003; TRS §§3.2,9.4,20.3; complete immutable supported profile manifest and no implicit incompatible migration. | **Verified Resolved** | Current option B and one-point rules unchanged; arbitrary legacy support is not promised. |
| AUD-004 — Medium | Raw UI time/quotes could become stale or authorize replacement terms across due events. | AUD-DEC-004 **B** | FR-AUD-004; TRS §§4.1,5,20.4; accepted-time stamping, semantic terms, as-of boost preview, ending-wallet minimum. | **Verified Resolved** | No backdating, blanket stale-click rejection or replacement purchase is required. Rejection baseline excludes independently due work. |
| AUD-005 — Medium | Fixed-fertilizer reservation release had no terminating deterministic selection/re-entry rule. | AUD-DEC-005 **A** | FR-AUD-005; TRS §§6.2,20.5; permanent per-batch exclusions, fresh reservation passes, final M/C. | **Verified Resolved** | Conditional Smart optimum retained; non-maximal planted subset explicitly permitted, not a regression against a maximal-count promise. |
| AUD-006 — Medium | Required equipment rank unlock guards were absent. | AUD-DEC-006 **A** | FR-AUD-006; TRS §20.6; all six/five ranks require coins and previous family rank only, minimum level 1. | **Verified Resolved** | Prices/effects unchanged and future-cycle snapshots preserved. A stale task phrase remains under AUD-008, not an undefined guard. |
| AUD-007 — Medium | Group CRUD/membership/deletion could bypass inherited-plan consent or leave invalid references. | AUD-DEC-007 **B** | FR-AUD-007; TRS §§3.3,4.1,6.4,9.4,20.7; single membership, effective-plan diffs, reference-safe atomic structure. | **Verified Resolved** | Administrative operations have no invented unlock; named presets/fields keep existing capability gates and staged delivery. |
| AUD-008 — Low | Active prose reopened settled choices despite authoritative approval elsewhere. | AUD-DEC-008 **A** | The originally cited pin, tail, catalog and DEC-008/027 clauses were corrected; A1 status/history is distinguished in most source text. | **Partially Resolved** | M02-T06 line 110 still calls equipment levels unresolved. ADR §2 retains unqualified not-started application prose. **R2-002**. |
| DOC-001 — Low, supplemental finding | Audit prose cleanup corrupted literal hashes, URL and technical tokens. | AUD-DEC-009 **A** | Dated errata preserve separate old/current manifests; literal release URL, 64-hex hashes and CPU/2.5D tokens repaired. | **Partially Resolved** | AV-009-02 requires all local links to resolve. 91 occurrences still use missing old audit/changelog locations. **R2-001**. |

| Verification population | Verified Resolved | Partially Resolved | Unresolved | Regression Introduced | Deferred by Approval | Unable to Verify |
|---|---:|---:|---:|---:|---:|---:|
| Original eight AUD findings | 7 | 1 | 0 | 0 | 0 | 0 |
| Supplemental DOC-001 | 0 | 1 | 0 | 0 | 0 | 0 |
| All nine approved correction decisions | **7** | **2** | **0** | **0** | **0** | **0** |

R2-003 is a newly found invalid nominal rotation fixture, not a regression attributed to one of these corrections. No available complete pre-A1 snapshot establishes that the corrections introduced it or the stale paths. No original High remains open at the design level.

## Finding-by-finding technical verification

### AUD-001 / AUD-DEC-001 B — Recovery history and identity

**Expected changes:** FRS §§10/13; TRS root/cycle/contract/identity/scheduler/recovery/schema contracts; DR DEC-015/016/019; M01 identity/clone/replay foundation, M03 startup/recovery/codec, M04 disclosure, M05 true claims, M06 fault qualification.

**Actual evidence:** FRS §10.1 expressly pairs lost claim credit and lost claim closure; FR-AUD-001 identifies the recovered authoritative timeline. TRS §3.1 defines dynamic IDs as save ID + injected allocation namespace + checked counter. Fixed plot/authored IDs remain unchanged. TRS §4.2 retains numeric ordering rather than sorting UUID strings. §§8/20.1 inject a fresh owned namespace before catch-up allocation and persist it before accepting commands. UNKNOWN retains the pending namespace until reconciliation; it does not rotate prematurely.

**Counterexample replay:** Restore a backup with next counter 100 and Q01 unclaimed after the lost branch allocated 100 and claimed Q01. The new allocation has a different full namespace, while old restored entities retain theirs. The recovered balance and claim flag both precede the lost claim; Q01 can be earned/claimed in the recovered timeline without adding an external old-branch payout. A retired old command cannot recreate a missing instance. The impossible all-lost-branches guarantee has been explicitly replaced under the approved choice, rather than implemented with an unapproved second ledger.

**Propagation/tests:** M01-T05/T06/T07/T14 and M01-V14; M03-T03/T04/T10/T14/T16 and M03-V19; M04-T13/M04-V16; M05-T04/T06/T07/T15 and M05-V13/V17; M06-T04/T14 and M06-V17. TRS T-011/T-020/T-021 and AV-001-01–04 test old allocation/claim restore, fixed injected IDs, numeric ordering, codec bounds and receipt context. Original unconditional recovery wording is narrowed in operative contracts and DR; frozen audit quotations are preserved as history.

**Conclusion:** Verified Resolved. Actual recovery/UUID/codec behavior still requires implementation tests. No regression identified.

### AUD-002 / AUD-DEC-002 B — Unknown commit outcomes

**Expected changes:** Controller/kernel candidate-result interface, repository contract, all checkpoint routes, lifecycle/settings/backups, durable replay and clock reconstruction. M01 must reserve the interface; M03 implements actual storage.

**Actual evidence:** FR-AUD-002 and TRS §20.2 distinguish COMMITTED, NOT_COMMITTED and UNKNOWN. TRS §5 defines commit ID and expected parent durable revision plus settled read-back. UNKNOWN blocks economic input and economic/automatic/catch-up/startup/time-only/settings/migration/shutdown writes and backup rotation while retaining ownership. Open operations settle before a validated read. The matching new identity selects the complete result; the unchanged parent can establish definite failure; an unexpected/unreadable state remains stopped. §§3.1/20.2 separate durable revision from unsaved simulation revision, and commit IDs from gameplay entity allocation.

**Counterexample replay:** A planting at revision 40 commits 41 but loses its receipt. Memory cannot save 40 during retry, settings or shutdown. Validated read-back of 41 rehydrates wallet, cycle, replay, scheduler and anchor; no fresh purchase is issued. A verified unchanged 40 is the separate not-committed path. Unsettled reads do not prove rollback. Pending real intervals are reconciled once after selecting the state.

**Propagation/tests:** M01-T06/T13/T14, M01-V14; M03-T02/T03/T05/T06/T10/T14/T15/T16, M03-V02/V03/V13/V15/V19; M04-T08/T13/T15, M04-V16; M05-T06/T15, M05-V17; M06-T04/M06-V17. T-018–020/T-027 and AV-002-01–05 cover live-process receipt loss and every write route, not only crash-and-reload. Task phrases about failed-commit rollback are explicitly qualified as definite NOT_COMMITTED by TRS §15.1 and plan A1 crosswalks.

**Conclusion:** Verified Resolved. The actual adapter may still fail qualification; design verification is not evidence that its API exposes every necessary observation.

### AUD-003 / AUD-DEC-003 B — Profile-bound progression

**Expected changes:** Root content binding, full skill/curve interpretation, load validation order, migrations, quotes/UI/offline/forecast contexts and future balance policy. Do not silently add an awarded-level watermark or change the selected XP curve.

**Actual evidence:** FR-AUD-003 and TRS §20.3 bind a supported profile to one complete immutable manifest, including thresholds, point prices, rank maxima, prerequisites and level gates. Level remains highest reached threshold; level−1 equals unspent plus allocated one-point ranks/nodes. Definitions are not edited in place. Load resolves the manifest before invariant validation or catch-up. Unsupported definitions fail recoverably without overwrite; schema-only migration preserves binding and paid snapshots. A later incompatible migration requires its own approved mapping, with no invented XP grant or skill revocation.

**Counterexample replay:** An original level-7/5,200-XP profile with Auto Replant remains interpreted by its original level-7 threshold even when a different manifest raises that threshold to 6,000. Lower thresholds or different maxima in the newer manifest do not implicitly reaward points or invalidate old allocations. The current increasing post-30 recurrence remains unchanged.

**Propagation/tests:** M01-T02/T03/T05/T12/T14/M01-V14; M02-T01/T04/T05/M02-V15; M03-T03/T10/T12/T13/T16/M03-V18/V19; M04-T11/M04-V16; M05-T13/T15/M05-V17; M06-T03/T04/T09/M06-V17. AV-003-01–05 covers raised/lowered thresholds, maxima/edges, point conservation, schema binding, interruption and unsupported mappings; T-010/T-021/T-022/T-026/T-029 preserve cross-mode/context behavior.

**Conclusion:** Verified Resolved. Complete historical byte preservation is not independently provable from a hash-only older baseline, but the current selected compatibility contract is directly present and correct.

### AUD-004 / AUD-DEC-004 B — Accepted input and confirmations

**Expected changes:** Separate raw intent from accepted immutable envelope; central stamping after independently due work; semantic quote scope; defined naturally aging research preview; explicit manual ending-balance bound; no replacement operation on lost receipt.

**Actual evidence:** FRS §7.4/§8 and TRS §§4.1/5/20.4 supply each rule. The legacy requested-time field, if retained, contains accepted controller time. Recorded accepted envelopes are never restamped for replay. Crop/fertilizer/fallback/content/cost/modifier/recurring terms are protected where applicable; changed terms require refresh/reconfirmation. Extra unrelated income may increase the confirmed ending wallet but cannot authorize a lower ending balance or higher charge. Reset quotes bind level and price. Research quotes bind target, actual paid C, fixed charge, unused boost and half-remaining rule; saved time is as-of preview and recomputed at acceptance. Completed/no-time-saved cases reject without charge.

**Counterexample replay:** A click displayed at t=100 crosses an automatic harvest before dequeue. Due work commits first and the raw intent is stamped at current time. Unchanged semantic terms can proceed; changed cycle/price/modifier terms cannot become a replacement purchase. Rejecting the command does not undo the independent harvest. A boost preview can age normally without asserting its preview completion time is immutable.

**Propagation/tests:** M01-T06/T13/T14/M01-V14; M02-T02/T05/T07/T08/T10/M02-V15; M03-T05/M03-V19; M04-T08/T09/T11/T12/M04-V16; M05-T11/M05-V17; M06-T03/T08/M06-V17. AV-004-01–05 and T-020/T-021 define queue crossings, changed terms, aged boosts, reset/ending-wallet cases, pending identity and replay baseline.

**Conclusion:** Verified Resolved. No requirement for a costly general dependency graph or per-cycle popup was introduced.

### AUD-005 / AUD-DEC-005 A — Terminating fixed-plan allocation

**Expected changes:** Canonical candidate order, failed fixed-request exclusion/re-entry rule, seed release, final M/C, fallback, retry trigger, explicit known-answer and 32-plot bounds.

**Actual evidence:** FRS §7.1 FR-AUD-005 and TRS §§6.2/20.5 exclude the first unaffordable no-fallback fixed request for that batch, discard tentative reservations and replan the remaining universe. Excluded requests cannot re-enter; initially unfunded seeds may be reconsidered after removal. At most N exclusions/N+1 passes apply. Final feasible seed/fixed spending alone determines M and C. Only a genuine relevant funds/configuration event retries stalls; changed blocked-reason bookkeeping is not such an event. Non-maximality is stated explicitly.

**Independent known answer:** W=100, Corn seed 18 each, plot 1 Premium 75 without fallback, plot 2 None. Initial seeds 36 leave 64; Premium fails. Exclude plot 1, replan plot 2: charge 18, ending wallet **82**. For the three-plot AV-005-03 fixture (Basic/Premium/None), initial S=54/A=46; exclude Premium, replan Basic+None with S=36/F=20 and wallet **44**. Removed Premium never displaces an accepted seed by re-entry. A decreasing remaining-candidate set proves termination.

**Propagation/tests:** M02-T11/T12/T14/T15, M02-V04/V13/V15; M03-T13/M03-V14/V19; M04-T12/M04-V16; M05-T09/T11/T15/M05-V17; M06-T03/T06/M06-V17. AV-005-01–05 adds exact subsets, cascades/input permutation, fallback/reserve/zero-seed edges, no self-trigger and reference/forecast parity. Smart exact/ROI policies remain unchanged after fixed-plan feasibility.

**Conclusion:** Verified Resolved. ≤33 seed/fixed passes is not a runtime bound for the separate exact Smart solver; that qualification remains open appropriately.

### AUD-006 / AUD-DEC-006 A — Required equipment guards

**Expected changes:** All eleven guard rows, no invented level/research/skill/contract gate, exact cost/effects and previous-rank checks, snapshots and costed strategies.

**Actual evidence:** FRS FR-AUD-006 and TRS §20.6 explicitly enumerate the six Irrigation prices and five Soil prices/effects. Rank I requires no predecessor; later ranks require n−1. Minimum player level 1 means no extra level restriction. Every rank is a manual next-rank purchase with affordability; skipped/duplicate/max/insufficient requests reject atomically. Current crops retain their snapshots. FRS §16 and DR DEC-004 now close the unspecified-guard topic; deferred equipment families remain excluded.

**Propagation/tests:** M02-T01/T06/T17, M02-V09/V14/V15; M03-T03/T10/M03-V19; M04-T10/M04-V16; M05-T02/T13/T14/M05-V17; M06-T03/T09/M06-V17. AV-006-01–04 requires each rank's cost/predecessor/invalid cases, funded level-1 isolated fixture, future-only effects/cap and full-cost strategies. No startup cash grant or final balance approval is implied.

**Conclusion:** Verified Resolved for behavior. M02-T06's leftover “unresolved” phrase is a distinct synchronization residue assigned to AUD-008/R2-002, not grounds to pretend the actual guard rule is absent.

### AUD-007 / AUD-DEC-007 B — Group lifecycle and consent

**Expected changes:** Stable IDs/revisions, zero/one membership, CRUD/assign/unassign/delete command contracts, destination/preset references, effective-plan changes and structural atomicity distinct from eligible farming subsets.

**Actual evidence:** FRS FR-AUD-007 and TRS §20.7 define all these rules. Rename or overridden edits with no effective economic change retain authorization. Occupied settings changes require explicit future Apply while preserving the current cycle. New Empty starts, changed Stalled plans and rearm require Plant/Apply-and-start. Deleting nonempty groups needs an explicit valid destination or ungroup-to-farm choice with fresh diff and resolved preset references. Invalid structure rolls back all structure; separately associated authorized farming actions retain DEC-025 subset semantics within one coherent commit. Locked settings remain inactive; grouping cannot purchase/unlock plots. Administrative group operations acquire no new skill gate; named presets and fields retain existing gates.

**Counterexample replay:** Moving an authorized stalled None plan into a paid Advanced group, or deleting its group to a paid farm default, cannot silently spend. The effective plan changes and requires explicit action. Rename-only edits preserve authorization. Dangling preset references prevent deletion. Forecast clones preserve the graph without touching live plan identities.

**Propagation/tests:** M02-T10/T16/T18/M02-V15 defines interfaces/default records; M03-T03/T05/T10/T17/M03-V19 persists them; M04-T12/T18/M04-V16 supplies basic routing; M05-T11/T12/T15/M05-V17 implements full behavior/UI; M06-T03/T04/T08/M06-V17 qualifies. AV-007-01–06 covers lifecycle/reference validity, indirect paid changes, snapshots/Ready enable, unchanged overrides, atomicity/subsets and recovery/copy isolation.

**Conclusion:** Verified Resolved. This does not pull advanced M05 behavior into M01/M02 or add overlapping/nested group mechanics.

### AUD-008 / AUD-DEC-008 A — Operative approval wording

**Corrected evidence:** DR §3 now distinguishes DEC-008 Deferred from DEC-027 Approved. TRS §13 distinguishes selected names from artifact qualification. M01-T05 recognizes approved C2 content. M02-T01 uses selected equipment guards and option B. M06-T02 maps option B tests rather than requiring reselection. Historical G1–G6/C1–C3 records retain dated scope and supersession notes.

**Incomplete evidence:** M02-T06 line 110 still directs the reader to unresolved equipment level requirements. ADR §2's unqualified “None has started” for application contradicts the current Applied state. The A1 normative text prevents a gameplay ambiguity, but the original Low issue was precisely stale active instructions despite correct controlling authority; a new overriding note alone is not complete removal.

**Required completion:** R2-002's small operative wording correction and AV-008-01/02 scoped search. Do not reopen approvals, erase dated history or change equipment costs/gates. The existing 23 Approved /3 Open /1 Deferred inventory remains accurate.

**Conclusion:** Partially Resolved; no M01 blocker and no new architectural regression established.

### DOC-001 / AUD-DEC-009 A — Literal evidence and references

**Corrected evidence:** R1-AR's SQLite URL is now the literal 2shady4u release path; displayed source hashes are 64 hexadecimal characters; R1-TM preserves Ryzen 5 7600X3D and 2.5D. Dated errata distinguish original findings and pre-A1 fingerprints from the current amended manifest. Current FRS/TRS bytes match RM and A1-CL After hashes. Original substantive conclusions remain distinguishable from the A1 addenda.

**Incomplete evidence:** Actual local references still omit round_01. The full package scan found **91 missing-target occurrences in 13 files**. The four Round 1 files and changelog do exist at the paths linked in this report. AV-009-02 explicitly requires all local targets and lines to exist; the current application-complete/link-check statements cannot establish this criterion. A1-CL itself contains 28 stale absolute audit links; ADR contains 48 stale relative/absolute references.

**Required completion:** R2-001 retargeting and repeat document checks, preserving historical source-line meaning and separate manifests. Complete old-source byte equality cannot be reconstructed without the old bytes; hashes and excerpts provide a recorded comparison, not a full independently replayable diff. This provenance limit should remain disclosed.

**Conclusion:** Partially Resolved. Do not label the correction wholly failed: the exact-token repairs are real. Do not label link failures a proven correction-induced regression without revision evidence.

## Cross-correction checks

| Interaction | Verified coherent selected behavior |
|---|---|
| Identity + UNKNOWN | Pending namespace/commit identity survives uncertainty; no rotation or stale write before resolution. |
| Identity + deterministic modes | Numeric ordering survives namespaced IDs; commit cadence does not consume gameplay counters. Fixed injected identities permit meaningful equality checks. |
| Manifest + migration + UNKNOWN | Supported binding/state/replay/anchor commit together; uncertain migration is reconciled instead of replayed against a guessed parent. |
| Quote + group/default inheritance | Indirect effective plan changes receive the same consent validation as direct configuration. |
| Seed/fixed planner + advanced groups | One batch snapshot of priorities/authorizations/content; final M/C is computed once, not per group or whole offline duration. |
| Equipment + manifest + quotes | All contexts read the profile's guard/effect data; purchased upgrades affect future plantings and stale manual previews refresh. |
| Recovery + statistics/claims | Credits, flags, progress, cash flow and time anchor select one whole timeline; no second “offline payout” outside the checkpoint. |

None of the seven substantive corrections requires changing the six-milestone sequence, adopting unapproved journals, inventing content, weakening durability or capping offline income. M01 may proceed with its four foundation contracts now specified. The remaining Low corrections and later empirical gates are detailed in [development readiness](R2_Development_Readiness.md).
