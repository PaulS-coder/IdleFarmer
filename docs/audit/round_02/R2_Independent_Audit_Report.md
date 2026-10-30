# Idle Farmer — Round 2 Independent Pre-Development Audit

Audit completed: **2026-10-29, America/New_York**. Baseline: the saved A1 documentation in **C:/_/IdleFarmer**, not the earlier drafts in the chat's starting directory. This review changes only the four Round 2 reports. No game code, source requirements, plans, decisions or Round 1 records were changed. No executable game tests, export, native integration, benchmark or human playtest was run.

## Verdict and counts

**Overall: READY WITH CONDITIONS. M01 design baseline: READY. Complete M01–M06 program: READY WITH CONDITIONS.** No unresolved foundational design blocker was established. M01 can begin under its existing artifact-verification and foundation-test gates without an identified need for substantial architectural rework. Later empirical gates remain mandatory; this is not release certification.

| Classification | Critical | High | Medium | Low |
|---|---:|---:|---:|---:|
| All findings registered in Round 2 | 0 | 0 | 0 | 3 |
| Newly identified issue outside existing Round 1 correction scope | 0 | 0 | 0 | 1 |
| Continuing incomplete Round 1 documentation corrections | 0 | 0 | 0 | 2 |

R2-001 continues DOC-001's link-verification obligation; R2-002 continues AUD-008's stale-operative-wording obligation. R2-003 is a new audit-fixture defect. They are not three new game-design defects.

Of the original eight findings, **7 are Verified Resolved and 1 is Partially Resolved**. Including the supplemental DOC-001 correction, the nine-item verification set is **7 Verified Resolved, 2 Partially Resolved, 0 Unresolved, 0 Regression Introduced, 0 Deferred by Approval, 0 Unable to Verify**. These outcomes concern the documentation/design only. The separate [correction verification](R2_Round1_Correction_Verification.md) gives the evidence and remaining work.

## Sources, authority and method

The following current files form the baseline. References to sections and task IDs throughout this report use these files; line numbers are one-based lines of the saved A1 files, not the older lines quoted in Round 1.

| Alias | Source |
|---|---|
| FRS | [Functional specification](../../requirements/IdleFarmer_Functional_v1.0.md), v1.0/A1 |
| TRS | [Technical specification](../../architecture/IdleFarmer_Technical_v1.5.md), v1.5/A1 |
| DR | [Original Decision Register](../../decisions/Decision_Register.md), revision 15 |
| ADR | [Audit Decision Register](../../decisions/Audit_Decision_Register.md), revision 6 |
| RM | [Master roadmap](../../implementation/00_IdleFarmer_Master_Roadmap.md) |
| M01 | [Headless foundation](../../implementation/01_M01_Headless_Simulation_Foundation.md) |
| M02 | [Economy, skills, research and automation](../../implementation/02_M02_Economy_Skills_Research_Automation.md) |
| M03 | [Saves, time and offline farming](../../implementation/03_M03_Saves_Time_Offline_Farming.md) |
| M04 | [Visual farm, art, UI and audio](../../implementation/04_M04_Visual_Farm_Art_UI_Audio.md) |
| M05 | [Contracts, statistics and progression](../../implementation/05_M05_Contracts_Statistics_Complete_Progression.md) |
| M06 | [Validation and Windows release](../../implementation/06_M06_Validation_Performance_Windows_Release.md) |
| R1-AR | [Round 1 audit](../round_01/PreDevelopment_Audit_Report.md) |
| R1-TM | [Round 1 traceability](../round_01/Requirements_Traceability_Matrix.md) |
| R1-VS | [Round 1 scenarios](../round_01/Design_Validation_Scenarios.md) |
| R1-RD | [Round 1 readiness](../round_01/PreDevelopment_Readiness.md) |
| A1-CL | [Correction changelog](../round_01/Audit_Correction_Changelog.md) |
| Art reference | [Approved comparison board](../../decisions/visuals/Art_Direction_Comparison_v1.png), column A |

The team read the current specifications, all six plans, roadmap and original decision history before using the Round 1 findings as a checklist. Separate coherence, feasibility and adversarial reviews supplied evidence; the lead also assessed scope, interaction states and quantitative examples. No earlier conversation was used to fill a requirement gap. Round 1 materials, approval options, correction excerpts and staged tests were examined afterward. Findings were retained only after checking controlling source text and a concrete consequence. Recorded owner quotations establish documentary approval scope; this audit does not authenticate the originating conversations.

Three review workers supplied substantial findings and coverage before their turns ended with workspace-credit errors. The lead retained their delivered evidence, independently checked retained findings and completed synthesis. There is no completed separate-provider cross-model review or independent-model certification. This limitation does not turn unfinished executable qualification into a pass.

The package has **101 unique implementation tasks, 98 unique milestone validation rows, 30 TRS test IDs and 39 A1 AV criteria**. No undefined explicit fully qualified task/validation reference was found in the current planning package. Declared local task dependencies were inspected; the intentional M03-T18-before-T17 handoff is valid, not a cycle. Source authority remains FRS for gameplay and TRS for architecture, with approved amendments in DR/ADR.

The original register has **23 Approved parents, 3 Open parents with approved subparts (DEC-001/014/023), and 1 Deferred parent (DEC-008)**. Reviewing 27 decisions does not mean every empirical subpart is resolved. All nine audit choices are approved. Their recorded Applied status was not accepted as proof of closure.

## Fresh full-system conclusions

| Area | Independent design assessment | Remaining implementation evidence |
|---|---|---|
| Requirements and starting state | Zero coins/XP, 24 Empty plots, Wheat-only unlock, fixed eight-column IDs and sequential fourth-row purchases agree. Empty occupancy gaps do not violate unlocked-prefix rules. | M01 initial fixtures; M02 all eight purchase gates; M04 click/view mapping. |
| State ownership and interfaces | TRS §§2–5 define one authoritative state and engine, typed logical contracts and a controller-owned commit boundary. Runtime RefCounted/data services and presentation-only Nodes are a feasible split. Logical APIs explicitly allow concrete typed signatures to be refined. | Parse/headless/clone/import-boundary checks in M01; later fields must enter the same validation/codec inventory. |
| Deterministic ordering | Research precedes the complete automatic maturity/harvest/credit/XP/accounting/plant batch. Accepted manual commands are serialized afterward. Numeric entity order is retained separately from UUID identity. | Tie, replay, stale-event and partition tests at M01/M02; restoration and aggregation parity at M03/M05. |
| Shared economy | Mandatory seeds precede fixed fertilizer and Smart groups. Final feasible plans alone define M and C. Farm-wide controls cannot become group wallets. Monotone fixed-request exclusions terminate within N+1 passes; non-maximal planted subsets are explicitly allowed. | Independent oracle, permutation/cascade cases, exact rate comparisons and 32-plot frontier measurements in M02. |
| Gameplay and progression | Free Wheat prevents a mandatory paid-seed deadlock. Rank/prerequisite graph is acyclic; four nodes buy basic automation by level 7. No automatic skill spending, research purchase or contract claiming is inferred. | Full-cost strategies, actual action latency and normal-speed observations; no blanket claim of balanced content. |
| Crop modifiers and research | Planted economics/maturity remain immutable after reset or purchase; future cycles use current supported rules. One active research project and one paid half-remaining boost are defined, including stale-event invalidation and no-time-saved rejection. | M02 snapshot and quote tests; M03 boost/recovery fixtures; M04 as-of previews. |
| Timekeeping | Monotonic active, 1× suspended/offline and debug-scaled simulation clocks are separated. Real elapsed alone advances the anchor. Forward-clock abuse and a future anchor after rollback are accepted offline-first consequences, not new defects. | DEC-014 provider measurements and interval reconciliation in M03; fake traces alone cannot prove Windows sleep semantics. |
| Persistence and recovery | Complete candidate checkpoints, separate durable revisions, expected parents, UNKNOWN reconciliation and blocked writes address stale-memory overwrite. Older backup recovery rolls back the entire timeline; fresh namespaces prevent new identity collisions. | Actual SQLite adapter WAL/FULL, receipt loss, process lock, codec, backup and migration faults in M03 and M06. |
| Contract lifecycle | Twelve authored optional offers, frozen rewards, post-acceptance order, actual automatic origin, mixed AND goals, three unclaimed slots and manual claims are sufficiently defined. Same-batch accounting/progress avoids a second-save listener gap. | M05 true catalog/claim/crash evidence; generic M03 claim fixtures are explicitly insufficient. |
| Statistics and forecasts | Completed-minute half-open windows, separate live totals, completed-cycle costs versus payment-time cash flow, Growing-only utilization, expansion-time capacity and deep-copy forecasts agree. | Independent accounting/state-time ledgers, pruning, exact boundary and copy-reference checks in M03/M05. |
| Windows and future web | Native storage/time isolation, Compatibility, GDScript and single-thread-friendly core preserve a plausible web path. The required M03 minimal probe is distinguished from a full future port. | Pinned binary/export qualification, actual probe and vendor/performance evidence. |
| Scope and complexity | Repository/time seams have current fake/native/probe consumers. Bounded replay, identities, manifests and targeted group diffs serve actual durability/authorization requirements. No generalized journal, overlapping groups, extra currency or deferred equipment is required. | Split large tasks according to measured implementation effort; indicative estimates are not commitments. |
| Milestone plan | Foundation → economy → durable time/offline → graphical shell → full reporting/contracts/advanced rules → qualification is coherent. Repeated tests at later integration points are intentional. | T06 save-cadence skeleton in M03 must receive final clock/accounting integration through T16; M05 forecast must be rerun after advanced rules integrate at T15. |

No proven gameplay/economy exploit outside the explicitly accepted offline clock/backup policy was established. No wholly orphan required gameplay family or unrelated implementation task was identified. These conclusions do not establish runtime correctness, exact-solver performance or economic pacing.

## Retained Round 2 findings

### R2-001 — Audit navigation still points outside round_01

| Field | Assessment |
|---|---|
| Severity / category / class | **Low** / cross-document traceability / proven broken references |
| Relationship | Continuing incomplete DOC-001 / AUD-DEC-009 A, especially AV-009-02; no separate claim that its original hash/token repairs failed. |
| Exact evidence | FRS/TRS/RM/M01–M06 and DR header line 3 link to ../audit/Audit_Correction_Changelog.md; DR line 1378 repeats it. ADR §1 lines 32–35 and §4/§6 use C:/_/IdleFarmer/docs/audit/PreDevelopment_Audit_Report.md and the analogous matrix/scenario/readiness paths. A1-CL §2 lines 91–94 also uses these nonexistent locations. R1-RD delivered-package links at lines 79–82 have the same problem. |
| Scope | A file-existence scan, stripping optional :line suffixes, found **91 broken link occurrences in 13 Markdown files**, resolving to five missing target forms: the changelog outside round_01 and the four old audit-file paths. There are 11 broken changelog links in the ten main planning files alone. |
| Counterexample | Following the current FRS correction-history link cannot open a file at docs/audit/Audit_Correction_Changelog.md. The existing file is docs/audit/round_01/Audit_Correction_Changelog.md. The same approved closure criterion explicitly requires all local links to resolve. |
| Root cause | References were not reconciled with the current directory layout. Available evidence does not establish when the move or stale-link creation occurred. |
| Consequence | A developer cannot follow the approval-to-change evidence from current source headers; the recorded link-check success is not reproducible against this baseline. The actual source rules remain readable and correct. |
| Recommended resolution | Retarget relative changelog links through round_01 and current absolute links to the four existing round_01 files. Preserve historical line/baseline semantics; do not silently reinterpret old line numbers as current source lines. |
| Required document changes | The ten main planning files, ADR, A1-CL and R1-RD at the locations listed above; use a dated navigation erratum for preserved audit history. Refresh current-source hashes if source bytes are subsequently edited. No gameplay/decision change. |
| Required checks | Rerun AV-009-02 over relative and absolute local links with line suffix handling; confirm target existence and valid line bounds. Retain separate old/current fingerprints. No new game test. |
| Earliest milestone / M01 blocker / deferral | M01 documentation handoff; **does not block M01**. Safe to repair during baseline housekeeping before downstream reviewers rely on linked closure evidence. Owner: documentation maintainer. |

### R2-002 — Operative wording still reopens settled equipment guards and application status

| Field | Assessment |
|---|---|
| Severity / category / class | **Low** / decision synchronization / proven obsolete current-action text |
| Relationship | Residual AUD-008 / AUD-DEC-008 A. AUD-006's substantive equipment design is resolved. |
| Exact evidence | M02-T06 line 110 says to “read unresolved level requirements from decision content.” FRS FR-AUD-006, line 291, and TRS §20.6, lines 949–953, explicitly define every required rank as level 1 with no extra level/research/skill/contract gate. M02-T06 line 108 binds the A1 correction, so the authority is clear but the task body remains stale. ADR §2 also says source-document application/game/runtime verification “None has started for these resolutions,” while revision 6 and §10 record application complete; that sentence lacks a historical qualifier. |
| Counterexample | An implementer following the task's direct instruction reports missing equipment levels or seeks new approval, although the approved manifest already supplies the answer. A reader can also mistake “not started” for the current source-application status. |
| Root cause | Appended corrective crosswalks did not remove all obsolete active prose. |
| Consequence | Avoidable approval requests and incorrect tracking of unfinished work. This is not a remaining ambiguity about actual equipment eligibility: the normative FRS/TRS and A1 crosswalk override the old phrase. |
| Recommended resolution | Replace the T06 phrase with a direct reference to FR-AUD-006/TRS §20.6. Mark ADR's old lifecycle statements historical or distinguish Applied documentation from unstarted game implementation and runtime verification. Preserve actual dated approval history. |
| Required document changes | M02-T06; ADR §2 and any equivalent current-action reservations found by a scoped search. No reapproval or new equipment gates. Update changed-byte fingerprints as appropriate. |
| Required checks | AV-008-01/02 plus a search for operative unresolved-equipment/application-not-started claims; retain AV-006 guard tests unchanged. No new gameplay test is needed. |
| Earliest milestone / M01 blocker / deferral | Before M02-T06 execution; **does not block M01**. Safe to defer to the documentation handoff before M02. Owner: documentation maintainer. |

### R2-003 — A nominally valid rotation fixture contains a level-ineligible crop

| Field | Assessment |
|---|---|
| Severity / category / class | **Low** / test-design validity / proven audit-fixture contradiction |
| Relationship | Newly identified; not a repeat of AUD-007's resolved group contract. |
| Exact evidence | R1-VS DVS-013, line 226: “A valid level-20 rotation has sequence Coffee/Rice.” FRS §4.2, line 155, and §8 research table, line 395, both require level **22** for Rice. Rotation ownership at level 20 does not bypass crop eligibility. |
| Counterexample | A level-20 profile with the proposed sequence cannot satisfy the nominal valid-plan premise under normal Rice unlock guards. A later failure at the Rice entry would confound the successful-cursor/recovery case with the separate invalid-eligibility case. |
| Root cause | Scenario preconditions were not checked against the crop/research gates. |
| Consequence | Copying the audit scenario as a positive executable fixture can produce an irrelevant failure or encourage a gate-bypassing fixture that does not test the claimed nominal case. No production plan instructs such a bypass. |
| Recommended resolution | Add a dated erratum specifying level 22 or above with Coffee and Rice researched, all rotation prerequisites owned, and explicit sequence authorization. Keep level-20/Rice as a separately labeled negative eligibility test if useful. The Round 2 validation report supplies that corrected positive scenario without editing Round 1. |
| Required document changes | Future authorized erratum for R1-VS DVS-013; no FRS/TRS/decision change. Preserve the original record. |
| Required checks | M05-T12, M05-V08/V11/V12 and M06-V13 fixtures must validate all crop guards before calling a plan valid; failed planting preserves cursor. This is a scenario correction, not a claim an executable test failed. |
| Earliest milestone / M01 blocker / deferral | M03 if used as an advanced persistence fixture, otherwise before M05-T12 validation; **does not block M01**. Owner: scenario/test maintainer. |

## Independent calculations and unvalidated numerical assumptions

These are document calculations, not executions of the game simulator.

| Check | Result and boundary |
|---|---|
| Expansion | 2×250 + 2×1,000 + 2×4,000 + 2×12,000 = **34,500** coins. |
| Tomatoes + Basic | Fertilizer ceil(270×0.15)=**41**; gross floor(270×1.25)=**337**; profit 337−55−41=**241**. |
| Shared cap | W=1,000, S=200, R=100, F=100 → A=700, M=600, C=150 at 25%. Fixed+BP spend is at most 250 when all Smart groups use BP. Wallet is **at least** 550; an upper spending bound does not force every coin to be spent. |
| XP continuation | Independent integer recurrence matches levels 31–40: 577,500; 640,750; 710,325; 786,858; 871,045; 963,651; 1,065,518; 1,177,572; 1,300,832; 1,436,418. |
| Representation | T(349)=**9,203,731,170,706,289,434**; T(350)=**10,124,104,287,776,924,021**, above signed-int64 maximum 9,223,372,036,854,775,807. Valid current XP lookup need not represent the next threshold. |
| Contracts | The twelve fixed rows match their stated floor-10% authoring references. Total one-time rewards: **590,828 coins / 54,099 XP**. This is finite bonus content, not an engagement-duration proof. |
| Simple automation plausibility | With 24 synchronized Wheat plots, no purchased upgrades, no contracts and no growth skills, each idealized batch earns 144 XP. 36 batches give 5,184 XP; 37 give **5,328 XP at 296 simulated minutes (4 h 56 min)**. At level 7 there are six earned points, enough for the four-node basic automation chain. All seeds are free. This deliberately omits human action latency and assumes immediate replant/harvest and deliberate allocation; it supports plausibility only. |
| Long offline workload | At the provisional 60% growth reduction, Wheat lasts 192 seconds. A synthetic stable 32-plot farm has **432,000 harvests in 30 days** and **5,256,000 in 365 days**, plus up to 525,600 minute boundaries/year if processed individually. Event-driven design alone does not prove the five-second target. |

All base crop net profits are positive without optional fertilizer; paid seed shortages can stall advanced production but do not remove free Wheat. Smart's incremental comparison correctly cancels seed costs and rejects nonpositive fertilizer gains. Expensive explicit fixed choices are permitted and are not an optimizer defect. Later coin/XP crops must still be tested with full modifiers: their table labels are strategic intentions, not proven global niches.

The **3–5-hour automation target is plausible, unvalidated**. The **approximately 48 additional engaging active hours target is unvalidated**. No executed full-cost late-game simulator or normal-speed participant record was supplied. Neither target is proven met or proven impossible. Final balance, exact optimizer frontier, 60 FPS, <3 ms simulation and <5 s stable 30-day catch-up remain appropriately staged evidence obligations, not pre-M01 defects.

## Technology verification and limits

Official sources consulted during this review identify the selected [Godot 4.7.2 release](https://godotengine.org/download/archive/4.7.2-stable/), [GUT v9.7.1 compatibility with Godot 4.7.x](https://raw.githubusercontent.com/bitwes/Gut/v9.7.1/README.md), and [godot-sqlite v4.9 candidate](https://github.com/2shady4u/godot-sqlite/releases/tag/v4.9). These establish published metadata, not binary fingerprints, license completeness or actual combined compatibility. M01-T01 and M03-T01 still own adoption evidence.

[SQLite transaction semantics](https://www.sqlite.org/lang_transaction.html), [synchronization settings](https://www.sqlite.org/pragma.html#pragma_synchronous) and [consistent backup guidance](https://www.sqlite.org/backup.html) support the need for settled transactions, explicit outcome identity and consistent WAL-aware backup. The conclusion that the proposed coordinator is suitable is architectural reasoning; the selected wrapper must prove it can implement the protocol. [Godot's web guidance](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) supports a GDScript/Compatibility browser path, with browser-specific limitations and separate storage qualification.

No previous full pre-A1 source snapshot or commit diff was available in this checkout to authenticate every historical byte-level change. A1-CL contains before/after excerpts and hashes; current bytes and current rules can be checked, while complete historical preservation cannot be independently reconstructed from hashes alone. This is a provenance limitation, not evidence of a semantic regression. The broken paths cannot be dated reliably, so no finding is labeled Regression Introduced merely because it appears after a correction cycle.

## Baseline identity and preservation

Current FRS SHA-256: **5F7AB5BFD12E831F341D9E816B6C27E786ECEB51FEF356B110B53A84A091819A**. Current TRS SHA-256: **C0D11CD9A3A4AF4E056E33D71D4359F79DD32AFBCCEA9F5CDD4FA7AC2A62286E**. Both match RM §1 and A1-CL §4. The comparison image remains **92F04DC1374A5C7EEAF01CE84785D09E36F1FC0935C99030688974499FC7C16F**. Historical pre-A1 hashes in Round 1 intentionally differ.

The companion [traceability and validation report](R2_Traceability_And_Validation.md) covers all decisions, requirement families, tasks and at least the fourteen requested adversarial categories. The [readiness report](R2_Development_Readiness.md) defines precise later gates and the absence of any remaining M01 design blocker. Correct the three Low documentation issues before their evidence or tasks are relied upon; no new gameplay feature or architectural replacement is recommended.

## Appendix — exact current source manifest

These hashes identify the 16 reviewed Markdown documents and reference image at audit completion. They are current saved bytes, distinct from the historical pre-A1 manifests. All 17 files were hash-compared again after writing Round 2 and remained unchanged.

| File below docs/ | SHA-256 |
|---|---|
| [architecture/IdleFarmer_Technical_v1.5.md](../../architecture/IdleFarmer_Technical_v1.5.md) | C0D11CD9A3A4AF4E056E33D71D4359F79DD32AFBCCEA9F5CDD4FA7AC2A62286E |
| [audit/round_01/Audit_Correction_Changelog.md](../../audit/round_01/Audit_Correction_Changelog.md) | CAFA82B80E60DCCECC3343BB72B6C8DF3A8FADA809E5E824B463ED23F1270996 |
| [audit/round_01/Design_Validation_Scenarios.md](../../audit/round_01/Design_Validation_Scenarios.md) | 2F2C20E500456E55107506FEF6DDD3AB21B5C5A3C7A83BF4F27E043C6B9138E8 |
| [audit/round_01/PreDevelopment_Audit_Report.md](../../audit/round_01/PreDevelopment_Audit_Report.md) | A09E499300119BF2466234BC4A7E3AFEC03290D191E59D1E35BF4DE854010A10 |
| [audit/round_01/PreDevelopment_Readiness.md](../../audit/round_01/PreDevelopment_Readiness.md) | FA2C8ABB8E283B21031BDC77BF1DCD915E9D1A900A5E2C192C87805CEE55B959 |
| [audit/round_01/Requirements_Traceability_Matrix.md](../../audit/round_01/Requirements_Traceability_Matrix.md) | 3CAB8BF66C320A525B6E4B73C5770439939E4FACBFAFA3E620DEC0EFFB3F7985 |
| [decisions/Audit_Decision_Register.md](../../decisions/Audit_Decision_Register.md) | B566464EB5927AF9441CCD92C3725820B6A9B00F80C181E804BDC4659799AB9F |
| [decisions/Decision_Register.md](../../decisions/Decision_Register.md) | 3ABF7647C7B0D2B4A127A3EDBCCADCAFEAAD7CB47CA518439A8270D0A6B74662 |
| [decisions/visuals/Art_Direction_Comparison_v1.png](../../decisions/visuals/Art_Direction_Comparison_v1.png) | 92F04DC1374A5C7EEAF01CE84785D09E36F1FC0935C99030688974499FC7C16F |
| [implementation/00_IdleFarmer_Master_Roadmap.md](../../implementation/00_IdleFarmer_Master_Roadmap.md) | 938C7A1F4AEA8C3EF75FDEDB2E373891D55E19DE488324A6BEA732EAF98F6351 |
| [implementation/01_M01_Headless_Simulation_Foundation.md](../../implementation/01_M01_Headless_Simulation_Foundation.md) | 6F7AA838134E5655057ABADD8FA046491991F51398F67841291F1F822B48A6E0 |
| [implementation/02_M02_Economy_Skills_Research_Automation.md](../../implementation/02_M02_Economy_Skills_Research_Automation.md) | 355A3EFFBA3925333C72422064EB5C2C58CA185A22A6073581F374CCCF465D53 |
| [implementation/03_M03_Saves_Time_Offline_Farming.md](../../implementation/03_M03_Saves_Time_Offline_Farming.md) | B29B4809B515292BCE69AD32E2CA11C0BB0E3AFFF5505DB3892FC2118B9267D5 |
| [implementation/04_M04_Visual_Farm_Art_UI_Audio.md](../../implementation/04_M04_Visual_Farm_Art_UI_Audio.md) | C16216278291BC7A031E364E120E919E76EB3A230BD9474B92DBB38DDC620149 |
| [implementation/05_M05_Contracts_Statistics_Complete_Progression.md](../../implementation/05_M05_Contracts_Statistics_Complete_Progression.md) | FB811B20D3CC0A27B5A260394171F1232262FFDE5FED34556F73039B1BC3ACAE |
| [implementation/06_M06_Validation_Performance_Windows_Release.md](../../implementation/06_M06_Validation_Performance_Windows_Release.md) | C41418F94BC54C5E7174DCCCE04729791E528A62C23D596B20804C2091909BC0 |
| [requirements/IdleFarmer_Functional_v1.0.md](../../requirements/IdleFarmer_Functional_v1.0.md) | 5F7AB5BFD12E831F341D9E816B6C27E786ECEB51FEF356B110B53A84A091819A |
