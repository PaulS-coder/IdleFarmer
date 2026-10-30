# Idle Farmer — Pre-Development Readiness

> **Dated audit erratum and application addendum A1 — 2026-10-28:** The original audit below (findings, severities, scenarios, calculations and pre-correction assessment) is preserved as historical evidence. Its source line citations identify the frozen pre-A1 baseline, not shifted current lines. Approved corrections are tracked in the appended A1 addendum and [Audit_Correction_Changelog.md](Audit_Correction_Changelog.md), with current before/after references. DOC-001 repairs only exact technical strings; it does not rewrite substantive findings. Decisions are Applied to documentation, not runtime-verified. Original DEC-001/014/023 evidence remains Open and DEC-008 remains Deferred.

Audit date: **2026-10-28 (America/New_York)**. Current saved baseline: `C:/_/IdleFarmer/docs`; FRS v1.0, TRS v1.5/C3, Decision Register revision 14. No game code or source-document changes were made.

## Overall assessment: Not Ready

The package is close to a usable implementation baseline, but four foundation contracts should be clarified before M01 gameplay code starts. These are targeted corrections, not a recommendation to replace the architecture or introduce mechanics. After the conditions below are met, M01 can proceed independently; the remaining empirical work belongs to later milestones.

| Readiness measure | Result |
|---|---|
| Critical issues | **0** |
| High issues | **3** — AUD-001/002/003 |
| Medium issues | **4** — AUD-004/005/006/007 |
| Low issues | **1** — AUD-008 |
| Formally unresolved decision count | **3 Open parents**: DEC-001, DEC-014, DEC-023, each with approved subparts |
| Other decision status | **23 Approved; 1 Deferred** (DEC-008); zero Proposed parents |
| Additional unclosed policy/data details | Recovery-branch guarantees (AUD-001), changed-curve earned levels/points (AUD-003), and equipment unlock gates (AUD-006) need explicit disposition within existing decision scope; do not add them to the 3-parent count as if they were new independent DEC topics |
| Planned coverage | All 27 decisions, 16 named FR IDs, 7 ARCH IDs, 30 source tests, 101 tasks and 92 validation IDs traced |
| Missing requirement coverage | No wholly orphan requirement family or unrelated task found; **7 behavioral areas lack a complete executable contract/oracle**, listed below |
| Static integrity | No broken relative project link, undefined fully qualified task/validation ID, or declared local dependency cycle found; FRS/TRS/image hashes match recorded fingerprints |
| Balance evidence | Two idealized costed schedules support 3–5-hour plausibility; human pacing and 48 additional engaging active hours remain unvalidated |
| Revision comparison limit | Older incomplete drafts available and read; no prior full approved revisions or Git commits available for an authoritative before/after regression diff |

The register itself states the 23/3/1 status at [DR decision index, L54](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:54) and names remaining obligations at [DR remaining facts/evidence, L1234](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:1234). Reviewing 27 topics does not mean 27 fully Approved decisions or 27 empirical passes.

## M01-specific blockers

| Issue | Required correction before dependent M01 code | Exact affected sources |
|---|---|---|
| **AUD-001 — High** | Define identity allocation across older-backup restoration and the scope of one-time claim permanence. A fresh command epoch alone cannot restore lost entity/claim history. Choose the namespace/no-reuse and rollback guarantees before state/command IDs are frozen. | [DR DEC-016, L233](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:233); [TRS §3.1, L119](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:119); [TRS §3.5, L179](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:179); [M01 M01-T05/T06, L80](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:80) |
| **AUD-002 — High** | Reserve an outcome-unknown commit/reconciliation contract; prevent a running controller from writing an old checkpoint after a successful commit whose receipt was lost. Define safe receipt verification and state reload under ownership. | [TRS §5 repository, L272](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:272); [M03 M03-T02, L75](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:75); [M03 M03-T05, L105](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:105); [M01 M01-T06/T13, L94](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:94) |
| **AUD-003 — High** | Specify how a profile keeps earned level/points if an approved later balance update changes its XP curve. Either retain old versioned rules until explicit migration, or define a concrete mapping/invariant. Do not invent XP or revoke abilities silently. | [TRS §3.2, L132](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:132); [TRS §5, L278](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:278); [M03 M03-T10, L147](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:147); [M01 M01-T12, L132](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:132) |
| **AUD-004 — Medium** | Define controller timestamp/sequence acceptance and confirmation binding to a quote/plan. Ordinary queued clicks must have a valid route, and stale quotes cannot become replacement purchases without consent. | [TRS §4.1, L193](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:193); [M01 M01-T06, L96](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:96); [M04 M04-T08/T09, L104](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:104) |

These are **documentation/interface gates**, not a demand to implement M03 persistence before M01. Documentation can be corrected without running the game. Toolchain inventory and read-only preparation can continue, but no implementation is authorized by this audit request. Actual named artifact verification remains M01-T01 setup work and must pass before those artifacts are adopted; it is not replaced by reapproving names.

## Missing executable coverage and safe deferrals

| Item | Latest safe resolution point | Why it can wait beyond corrected M01 |
|---|---|---|
| AUD-005 fixed-fertilizer reservation release/replanning | Before M02-T11/T12/T15 acceptance | No fertilizer allocator is required in M01; keep existing seed-first/fixed-first choices and add a terminating subset oracle. |
| AUD-006 required-equipment per-rank unlock manifest | Before M02-T01/T06 completion and any upgrade-using pacing claim | M01 can validate crop/manual/XP foundations without assuming equipment availability. Prices/effects stay provisional; explicit gates still required. |
| AUD-007 group lifecycle/membership/authorization | Define contracts in M02-T10/T16 before M03 schema; executable management in M05-T11 | M01 group fields can remain inert. Future group changes must apply existing DEC-025 consent rather than silently change stalled purchases. |
| AUD-008 obsolete task/status reservations | During source synchronization before their tasks execute | Controlling FRS/C1/C2 decisions are clear; this Low issue must not reopen settled approvals. |
| DEC-001 native SQLite adoption | M03-T01/T02; engine/templates/GUT artifact verification earlier at M01-T01 | Candidate is approved for evaluation, not presumed qualified. No SQLite import is needed in core M01. |
| DEC-014 provider measurement | M03-T07/T09 | M01 reserves injectable active/suspended observations; Windows sleep/hibernate adequacy must be measured later. |
| DEC-023 actual baseline/art bible/assets | Actual baseline before M04-T01; proof set/art bible before bulk generation; final matrix M06 | H2 target and C3 Clean illustrated selection are already settled. Production parameters and measurements require actual production work. |
| Exact optimizer/frontier and 30-day/year qualification | Early current-content benchmark M02-T13/T14; reference/aggregation M03-T13; final hardware M06-T06 | Benchmark gates already exist. Preserve exact guarantees and durable commits; approximation/weaker sync needs a new explicit decision. |
| Human 3–5 h/48 h evidence | Protocol/sample before M05 closure; actual evidence/disposition M06-T09/T10/T15 | Headless schedules do not prove engagement. Do not require nonexistent-game human playtests before foundational development. |
| Production browser port, optional installer/signing, Steam/cloud, prestige, three DEC-008 families | Outside current v1 unless separately approved | Minimal browser probe is **not** deferred: M03-T18 before T17 remains required. Deferrals do not authorize placeholder mechanics. |

There are no unexplained orphan tasks in the reverse matrix. Gaps concern precision and acceptance of specified behavior, especially groups, rather than an absent whole gameplay subsystem.

## Recommended correction order

1. Resolve **AUD-001** recovery scope and entity identity namespace; document the distinction between intact-primary crash recovery and rollback to an older generation.
2. Define **AUD-002** commit outcome/reconciliation and stale-checkpoint protection. Integrate the same contract with the M01 in-memory sink and later repository/controller.
3. Resolve **AUD-003** progression/content compatibility invariant. Preserve current option B and all approved initial values; the needed work is migration policy.
4. Clarify **AUD-004** accepted-time stamping and quote/plan authorization. Add the exact queued-input/rejection baseline scenarios to M01/M02/M04 plans.
5. Before M02 behavior acceptance, settle **AUD-005/006/007**: deterministic replanning, equipment gates and group ownership/consent. Update affected source requirements/tasks/oracles together.
6. Remove **AUD-008** obsolete operative reservations; preserve historical approval tables. Refresh source fingerprints and traceability after legitimate source edits.
7. Execute later empirical gates in their current milestone order; report actual results, failures and limits. Do not silently change approved scope, balance or guarantees to produce a pass.

## Explicit conditions required before starting M01

- [ ] The four M01 blocker contracts above have concrete written outcomes in FRS/TRS/register where applicable and synchronized M01/M03/M04 task interfaces. A general approval without a specified rule is insufficient.
- [ ] DVS-017/018/019/020 (uncertain receipt, older backup, changed XP curve, queued quote) have one agreed expected outcome or an explicitly bounded compatibility policy. The ordinary current curve, budget and lifecycle decisions stay intact.
- [ ] The new M01 state/command/clock/sink inventory identifies all persisted identities, awarded-point/version invariants and controller-owned input metadata, without platform/native imports.
- [ ] Later M02/M03/M04 gaps have named task owners/deadlines and remain visible; no unimplemented advanced command is marked working and no future test is marked passed.
- [ ] Source files are reconciled, fingerprints updated and this audit's issue/traceability status reviewed against that exact saved baseline.
- [ ] A **separate implementation instruction** is given after this planning audit. Then M01-T01 verifies selected artifacts before adoption; no need to reselect Godot 4.7.2/GUT 9.7.1/Compatibility/x86_64 or demand future SQLite/art/human tests first.

When these conditions are met, the assessment can become **Ready with Conditions for M01**, with the remaining conditions attached to their owning milestones. This audit does not certify release readiness or approve any source correction automatically.

## Delivered audit package

- [PreDevelopment_Audit_Report.md](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Audit_Report.md) — all 8 classified findings, evidence, feasibility and source fingerprints.
- [Requirements_Traceability_Matrix.md](C:/_/IdleFarmer/docs/audit/round_01/Requirements_Traceability_Matrix.md) — all 27 decision chains, non-decision coverage, 30 source tests and 101-task reverse map.
- [Design_Validation_Scenarios.md](C:/_/IdleFarmer/docs/audit/round_01/Design_Validation_Scenarios.md) —34 scenarios and independent economic/progression calculations, with future tests clearly distinguished.
- [PreDevelopment_Readiness.md](C:/_/IdleFarmer/docs/audit/round_01/PreDevelopment_Readiness.md) — this standalone decision summary and M01 entry conditions.

## A1 current readiness reassessment — 2026-10-28

**Overall assessment: Ready with Conditions for M01 (documentation baseline only).** The original Not Ready assessment above is retained as dated audit evidence. All nine approved resolutions are Applied across source contracts, roadmap, six plans and acceptance references; no decision is marked Verified and no game/runtime/human test has been run.

| Measure | Current result |
|---|---|
| Historical findings | 0 Critical /3 High /4 Medium /1 Low; DOC-001 is a separate Low evidence correction |
| Remaining unaddressed Critical/High documentation findings | 0; their selected corrections are Applied, with runtime verification still required |
| Remaining audit decision selections | 0; all nine selected; application does not validate implementation |
| Original unresolved parent count | 3 Open: DEC-001 actual artifact/adoption, DEC-014 measured provider/API, DEC-023 actual production qualification; 23 Approved and DEC-008 Deferred retained |
| Requirement coverage | All seven missing behavior contracts now have FR-AUD/AUD-R rules, owning tasks and 39 AV oracles; 101 tasks/98 milestone validations/T-001–030 retained or extended |
| M01-specific design blockers | No remaining contract-selection blocker among AUD-001–004. Toolchain artifact verification remains M01-T01 before adoption. |
| Later obligations safely staged | Actual SQLite/clock/recovery/browser probe M03; production art/basic UI M04; real contracts/advanced groups/forecast M05; integrated performance/human pacing M06 |
| Balance/engagement evidence | Unchanged: 3–5-hour plausibility is not a measured validation; ~48 additional engaging active hours remain unvalidated |

### Explicit conditions before starting M01

- [x] Concrete selected identity/recovery, commit outcome, manifest and accepted-input rules written in FRS/TRS and original register.
- [x] M01–M06 task interfaces and exact AV-001–007 oracles synchronized; later-stage obligations have owners.
- [x] Current FRS/TRS source fingerprints refreshed, audit history/erratum preserved and correction mapping recorded in the changelog.
- [ ] Separate game implementation instruction. This document-update request does not start coding.
- [ ] At M01-T01, verify selected actual artifacts/checksums/licenses/runner behavior before adopting them; later SQLite/native adoption remains M03.

**Correction order completed in documentation:** 001/002 identity and outcome boundaries →003 profile context →004 accepted terms →005/006/007 allocator/content/group detail →008 operative wording →009 exact audit evidence → traceability/fingerprints/Applied status. Current runtime acceptance remains the existing milestone sequence. The original findings, source baseline fingerprints and unsatisfied human/performance evidence are preserved; no blanket release-readiness claim is made.

## R2-C1 navigation amendment — 2026-10-29

The four Delivered audit package links above now target their existing round_01 locations. The original assessment and dated A1 reassessment remain historical evidence; their counts and technical claims were not rewritten. Current post-correction readiness, M01-T01's Not Yet Verified gate and later unvalidated obligations are in the [Round 2 readiness addendum](../round_02/R2_Development_Readiness.md#post-correction-readiness-addendum--r2-c1-2026-10-29) and [R2 correction changelog](../round_02/R2_Correction_Changelog.md).
