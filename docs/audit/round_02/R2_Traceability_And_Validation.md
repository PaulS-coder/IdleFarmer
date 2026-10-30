# Idle Farmer — Round 2 Traceability and Design Validation

Assessment date: **2026-10-29, America/New_York**. Baseline: saved A1 documents in C:/_/IdleFarmer. This is a decision → requirement → design → task → **planned** test assessment, plus adversarial reasoning. No executable game test or full game simulation was run. Numeric examples below are independent calculations. Isolated fixture states do not claim a costed natural progression path unless explicitly stated.

## Source key and scope

| Key | Current source |
|---|---|
| FRS | [Functional specification v1.0/A1](../../requirements/IdleFarmer_Functional_v1.0.md) |
| TRS | [Technical specification v1.5/A1](../../architecture/IdleFarmer_Technical_v1.5.md) |
| DR / ADR | [Original Decision Register revision 15](../../decisions/Decision_Register.md) / [Audit Decision Register revision 6](../../decisions/Audit_Decision_Register.md) |
| RM | [Master roadmap](../../implementation/00_IdleFarmer_Master_Roadmap.md) |
| M01 | [Headless foundation plan](../../implementation/01_M01_Headless_Simulation_Foundation.md) |
| M02 | [Economy/skills/research/automation plan](../../implementation/02_M02_Economy_Skills_Research_Automation.md) |
| M03 | [Saves/time/offline plan](../../implementation/03_M03_Saves_Time_Offline_Farming.md) |
| M04 | [Visual farm/art/UI/audio plan](../../implementation/04_M04_Visual_Farm_Art_UI_Audio.md) |
| M05 | [Contracts/statistics/progression plan](../../implementation/05_M05_Contracts_Statistics_Complete_Progression.md) |
| M06 | [Validation/Windows release plan](../../implementation/06_M06_Validation_Performance_Windows_Release.md) |
| R1 | [Audit](../round_01/PreDevelopment_Audit_Report.md), [traceability](../round_01/Requirements_Traceability_Matrix.md), [scenarios](../round_01/Design_Validation_Scenarios.md), [readiness](../round_01/PreDevelopment_Readiness.md) |
| A1-CL | [Correction changelog](../round_01/Audit_Correction_Changelog.md) |

All section references use these current files, except explicitly historical R1 citations. T-nnn denotes the TRS §15 matrix; AV-nnn-nn denotes its §15.1 extensions; Mnn-Vnn denotes the owning milestone's validation table. A task/validation range is inclusive. Most FRS clauses have section references rather than unique FR IDs; the coverage ledger intentionally includes those unnumbered requirements.

The independent review preceded R1 checklist use. The current inventory is **27 original decision topics, 9 audit decisions, 16 original named FR IDs plus 7 FR-AUD IDs, 7 ARCH IDs, 101 implementation tasks, 98 milestone validation rows, 30 source test IDs and 39 AV criteria**. All explicit fully qualified current task/validation references resolve to definitions. No wholly orphan required feature or unrelated task was established. Coverage means a written owner/oracle exists, not that its implementation passed.

## 1. All 27 original decisions

DR statuses are 23 Approved, 3 Open with approved subparts, 1 Deferred. The table traces the selected operative policy, including later approved audit amendments. Unselected historical alternatives are not requirements.

| Decision / present status | Approved requirement and design | Main implementation tasks | Planned acceptance/tests and disposition |
|---|---|---|---|
| DEC-001 — Open, selected names/policy approved | FRS §14; TRS §1.1, ARCH-002/004/006/007; Godot 4.7.2/templates/GUT 9.7.1/Compatibility/x86_64, SQLite v4.9 evaluation. | M01-T01/T15; M03-T01/T02; M06-T01/T11/T12 | M01-V09/V13; M03-V17; M06-V09/V10/V16. Actual artifact/native/adoption checks open; no M01 design gap. |
| DEC-002 — Approved provisional data | FRS §§5.1/5.1.1/FR-AUD-003; TRS §§3.2,5,20.3; exact through-30 table and increasing post-30 recurrence. | M01-T03/T04/T12/T14; M03-T03/T12/T13; M05-T13/T15 | M01-V05/V11/V13/V14; M03-V18/V19; M06-V16; T-010/021/029; AV-003. Balance remains provisional. |
| DEC-003 — Approved | FRS §3; TRS §§3.1–3.3; zero coins/XP/points, Wheat-only, 24 Empty/8 Locked. | M01-T03/T05; M02-T17; M04-T01/T03 | M01-V01/V11; M02-V11; M04-V01; T-001. |
| DEC-004 — Approved | FRS §§5.2–5.5; TRS §§3.2/3.5/5; one-point ranks/nodes and minimum-rank/linear prerequisites. | M02-T01/T04/T05; M04-T11 | M02-V01/V05/V12/V15; T-008/010; AV-003/006. Equipment guards now explicit; stale task wording R2-002. |
| DEC-005 — Approved | FRS §6.3; TRS §4.4; basis points, checked int64, floor rewards/ceil costs/duration/minimum 1 μs. | M01-T04/T09; M02-T02/T13; M03-T13 | M01-V05/V10/V13; M02-V02/V09; M06-V12; T-001–004/021. |
| DEC-006 — Approved | FRS §§7.1/7.4/9.2; TRS §§4.1–4.3/20.4; due research/farm batch before serial accepted input. | M01-T06/T07/T13/T14; M02-T08/T09/T15 | M01-V04/V14; M02-V03/V13/V15; T-005/021; AV-004. |
| DEC-007 — Approved provisional coefficients | FRS §8; TRS §§3.5/5/20.4; one project/one boost, ceil(paid C/2), ceil(remaining/2). | M02-T07; M03-T03/T12; M04-T11 | M02-V06/V13/V15; M03-V06/V14; T-009; AV-004-03. |
| DEC-008 — Deferred | FRS §§6.1/6.2/14/16; TRS §§3.5/16/17; exclude Seed Efficiency/Research Facilities/Growth Booster. | M02-T06; M04-T10; M05-T02/T13/T14/T16 | M02-V14; M05-V09/V15; M06-V15. Owner-approved post-playtest scoped-proposal trigger; no executable placeholder. |
| DEC-009 — Approved, benchmark unproven | FRS §§7.2/7.3; TRS §§6.2/6.3; exact MP/BP rate objective and ROI-greedy CE, stable ties. | M02-T13/T14/T15; M05-T09/T14; M06-T06 | M02-V07/V08/V13/V15; T-023/024; AV-005. Runtime/frontier qualification required, no hidden approximation. |
| DEC-010 — Approved provisional defaults | FRS §§7.1–7.4/FR-AUD-005; TRS §§6.1–6.4/20.5; farm R/p/toggle, one C, explicit fallback. | M02-T10–T15; M03-T03/T13; M04-T12; M05-T11 | M02-V04/V13/V15; M03-V14; M05-V12/V17; T-005–007/023/024; AV-005. |
| DEC-011 — Approved | FRS §§5.4/7.1; TRS §6.1; owned Smart at 9, enhanced priorities/seed reserve at 15; fixed fertilizer ungated by Smart. | M02-T04/T10/T14; M04-T12; M05-T11/T12 | M02-V01/V13; M05-V08/V12; M06-V13. |
| DEC-012 — Approved | FRS §§5.4/9.2; TRS §§6.4/16; M02 advanced contracts → M03 records → M05 execution/UI. | M02-T10/T16/T18; M03-T03/T17; M04-T12/T18; M05-T11/T12/T16 | M02-V15; M03-V14/V19; M05-V08/V12/V17. Intermediate unavailable commands cannot be claimed complete. |
| DEC-013 — Approved | FRS §9.1; TRS §§7/8; real interval ledger/anchor versus debug simulation. | M01-T08; M03-T07–T09/T12/T14/T16 | M01-V10/V12; M03-V04/V05/V12/V13; T-013–017/019/021. |
| DEC-014 — Open, selection method approved | FRS §9.1; TRS §§7.1/7.2; measured Godot-first/native-if-needed duration and active/suspended partition. | M01-T08; M03-T07/T09/T16; M06-T05 | M01-V12; M03-V05; M06-V03/V14; T-017. Actual API/measurement remains M03 gate. |
| DEC-015 — Approved, qualification pending | FRS §13/FR-AUD-002; TRS §§9.2–9.4/12/20.2; durable economics, WAL/FULL, real cadences/validated backups. | M03-T01/T05/T06/T10/T14/T15; M06-T04/T07 | M03-V02/V03/V09/V12/V15/V19; T-018–020/026–028; AV-002. |
| DEC-016 — Approved | FRS §13/FR-AUD-001; TRS §§3.1/4.1/20.1/20.2; fresh writer epoch, success high-water, bounded cache, full entity namespace. | M01-T05/T06/T11; M03-T03–T05/T10; M05-T04/T06/T07 | M01-V03/V10/V14; M03-V13/V19; M05-V13/V17; T-018–020/028; AV-001/002. |
| DEC-017 — Approved provisional retention | FRS §11.1–11.3; TRS §§10.1/10.3; completed simulation-minute windows, bounded rollups/live totals. | M03-T03/T11/T13; M05-T07–T10/T15 | M03-V08/V16; M05-V04–V07/V14; T-022/025/029. |
| DEC-018 — Approved | FRS §§11.1/11.2; TRS §10.2; post-catch-up session, Growing utilization, distinct occupancy/capacity. | M03-T11; M05-T07/T08/T10 | M03-V16; M05-V05/V14; M06-V05/V14; T-025. |
| DEC-019 — Approved provisional catalog | FRS §§10.1–10.4; TRS §§3.5/5.1/8–10; twelve authored optional one-time contracts and exact predicates/rewards. | M02-T16; M03-T03/T05/T12/T13; M05-T01/T03–T06/T14/T15 | M05-V01–V03/V13/V16/V17; M06-T03/T04; T-011/018–020. Generic schema fixtures do not replace catalog evidence. |
| DEC-020 — Approved amendment | FR-FARM-01/02/06/08, FRS §3; TRS §§3.3/4.3; 8×3 start, fixed eight-column map, 25→32 prefix purchase. | M01-T03/T05; M02-T03/T05; M03-T03/T04/T10; M04-T03/T08/T10 | M01-V01/V11; M02-V09/V12; M04-V01/V12; T-001/026. |
| DEC-021 — Approved | FRS §§2.2/13; TRS §§3.1/3.5/9.4/11.2; profile-owned versioned settings, restore before audio, debug reset. | M01-T05; M03-T03/T06; M04-T14/T15/T17 | M01-V12; M03-V15; M04-V07/V10/V14; M06-V10/V14. |
| DEC-022 — Approved | FRS §14; TRS §§1.1/9.5/15 T-030; required minimal end-M03 browser probe. | M01-T15; M03-T18 before T17; M06-T11 | M01-V09/V12; M03-V17; M06-V09; T-030. Full web release remains future. |
| DEC-023 — Open, protocol/target/style approved | FRS §§2/2.1; TRS §§11/14.1; Windows/vendor evidence, H2 envelope, Clean illustrated art pipeline. | M01-T01; M04-T01/T02/T05/T06/T18; M05-T02; M06-T01/T06–T08 | M04-V02/V11/V15; M06-V06/V07/V15. Actual hardware/assets/tuning evidence pending. |
| DEC-024 — Approved evidence method | FRS §§1/12.1; TRS §14.2; full-cost traces versus normal-speed human observations/diaries. | M02-T17; M03-T11; M05-T13/T14/T16; M06-T09/T10 | M02-V11/V14; M05-V10/V15; M06-V08/V15. Neither engagement target is proven. |
| DEC-025 — Approved | FRS §§5.5/9.2/FR-AUD-007; TRS §§4.3/6.4/20.7; explicit start/rearm, eligible manual subsets, future-only presets and success-only rotation. | M02-T05/T08–T10/T15; M04-T12; M05-T11/T12/T15 | M02-V05/V13/V15; M04-V13/V16; M05-V08/V12/V17; T-006–008; AV-004/007. |
| DEC-026 — Approved | FRS §13; TRS §§3.2/4.4/7.2/8; safe quotients and genuine-overflow whole-checkpoint preservation without offline caps. | M01-T04; M03-T08/T13–T15; M06-T05/T06 | M01-V05/V10/V13; M03-V11/V13/V18; T-015/019/029. |
| DEC-027 — Approved | FR-PLAT-01, FRS §14; TRS §§9.2/16/17; standalone Windows ZIP, offline normal-user operation, per-user save preservation. | M03-T01; M06-T12–T15 | M06-V10/V11/V16; T-026–028 in packaged scenarios. Installer/signing optional, Steam/cloud future. |

## 2. All approved audit decisions

The seven functional corrections add explicit source requirements, rather than replacing the original decision table. M01-V14, M02-V15, M03-V19, M04-V16, M05-V17 and M06-V17 carry staged A1 coverage in each plan.

| Audit choice | Requirement → technical design | Task ownership → exact planned criteria | Round 2 verification |
|---|---|---|---|
| AUD-DEC-001 B | FR-AUD-001 → TRS §§3.1/4.2/9.3/20.1 | M01-T05/T06/T07/T14; M03-T03/T04/T10/T14/T16; M04-T13; M05-T04/T06/T07/T15; M06-T04/T14 → AV-001-01–04, T-011/020/021 | Verified Resolved: namespaced new allocations, retained numeric ordering, coherent lost-branch credit/claim rollback. |
| AUD-DEC-002 B | FR-AUD-002 → TRS §§5/9.2/12/20.2 | M01-T06/T13/T14; M03-T02/T03/T05/T06/T10/T14/T15/T16; M04-T08/T13/T15; M05-T06/T15; M06-T04 → AV-002-01–05 | Verified Resolved: all write routes block UNKNOWN, settled-primary identity selects whole outcome. |
| AUD-DEC-003 B | FR-AUD-003 → TRS §§3.2/9.4/20.3 | M01-T02/T03/T05/T12/T14; M02-T01/T04/T05; M03-T03/T10/T12/T13/T16; M04-T11; M05-T13/T15; M06-T03/T04/T09 → AV-003-01–05 | Verified Resolved: immutable supported complete profile rules, no implicit changed-curve migration. |
| AUD-DEC-004 B | FR-AUD-004 → TRS §§4.1/5/20.4 | M01-T06/T13/T14; M02-T02/T05/T07/T08/T10; M03-T05; M04-T08/T09/T11/T12; M05-T11; M06-T03/T08 → AV-004-01–05 | Verified Resolved: raw/accepted distinction, semantic quotes/as-of preview/ending-wallet minimum. |
| AUD-DEC-005 A | FR-AUD-005 → TRS §§6.2/20.5 | M02-T11/T12/T14/T15; M03-T13; M04-T12; M05-T09/T11/T15; M06-T03/T06 → AV-005-01–05 | Verified Resolved: canonical exclusions, ≤N+1 passes, final single cap and no self-trigger retries. |
| AUD-DEC-006 A | FR-AUD-006 → TRS §§3.5/20.6 | M02-T01/T06/T17; M03-T03/T10; M04-T10; M05-T02/T13/T14; M06-T03/T09 → AV-006-01–04 | Verified Resolved: eleven complete coin/predecessor guard rows; stale prose separately tracked. |
| AUD-DEC-007 B | FR-AUD-007 → TRS §§3.3/4.1/6.4/9.4/20.7 | M02-T10/T16/T18; M03-T03/T05/T10/T17; M04-T12/T18; M05-T11/T12/T15; M06-T03/T04/T08 → AV-007-01–06 | Verified Resolved: group graph, effective consent, explicit deletion/reference handling and coherent structure/action atomicity. |
| AUD-DEC-008 A | Operative approval accuracy → A1 source/task wording | Corrected DR §3/TRS §13/M01-T05/M02-T01/M06-T02 → AV-008-01/02, final M06-V17 | Partially Resolved: R2-002 in M02-T06/ADR §2. |
| AUD-DEC-009 A | Byte-exact audit evidence and links → dated erratum/manifests | R1 audit files/A1-CL/ADR → AV-009-01–03, final M06-V17 | Partially Resolved: R2-001, 91 stale local-link occurrences; exact token repairs exist. |

## 3. Functional requirement coverage, including unnumbered clauses

Each row covers all subclauses named in its scope. It is an audit grouping, not a new gameplay requirement or substitute ID. Cross-reference the decision and audit tables for exact policy variants.

| FRS source and confirmed scope | Technical design | Implementing tasks | Planned tests/acceptance |
|---|---|---|---|
| §1 core loop, coins/XP/points, no inventory/currency, optional contracts | TRS §§1/3–5/16 | M01-T03/T09–T12; M02-T17; M05-T03/T04/T14 | T-001/003/010/011; M02-V11/V14; M05-V10/V16 |
| §1/§12.1 approximate automation/engagement targets and evidence limits | TRS §14.2 | M02-T17; M05-T13/T14/T16; M06-T09/T10/T15 | M02-V11; M05-V10/V15; M06-V08/V15 |
| FR-PLAT-01 Windows11 x86_64 | TRS §§1.1/9.2/16 | M01-T01; M03-T01; M06-T12/T13 | M06-V10/V16 |
| FR-PLAT-02 1920×1080 window, optional scaling/fullscreen refinements | TRS §§11.1/14.1 | M04-T01/T18; M06-T08 | M04-V11; M06-V07 |
| FR-GFX-01 isometric 2.5D | TRS §11.1 | M04-T03/T04/T07 | M04-V01/V02/V11 |
| FR-GFX-02 hardware acceleration and NVIDIA/AMD/Intel compatibility | TRS §§1.1/11.1/14.1 | M04-T01; M06-T01/T08 | M04-V15; M06-V07/V15 |
| FR-GFX-03 60 FPS on actual reference, timing independent of rendering | TRS §§1/14/14.1 | M01-T14/T15; M04-T01/T17; M06-T07/T08 | T-002/021; M06-V07 |
| FR-GFX-04/§2.1 generated Clean illustrated art, five stages, thresholds, Ready indefinite, varying sway | TRS §§3.4/4.3/11.1 | M01-T11; M04-T02/T04–T07; M05-T02 | M04-V02/V11/V15; all 75 stages; T-001 |
| FR-INPUT-01 mouse primary, optional shortcuts | TRS §§4.1/11.1 | M04-T08/T09 | M04-V03/V05 |
| FR-UI-01 central visible farm and Store/Skills/Research/Contracts/Statistics/Settings panels | TRS §11.1 | M04-T01/T09–T15; M05-T05/T10/T11/T12 | M04-V03/V11; M05-V07/V08 |
| §2.2 instrumental looping music/on-off, class/master sliders, true 0 mute, defaults, persistence | TRS §§3.5/11.2 | M03-T03/T06; M04-T14/T15 | M03-V15; M04-V07/V14 |
| §2.2 maturity/harvest notifications, 250ms/two-groups throttling, no offline backlog, natural debug pitch | TRS §§4.2/11.2 | M04-T07/T13/T14/T16/T17 | T-002; M04-V06–V09 |
| FR-FARM-01/02/07 24 Empty/8 Locked start, visible expansion, max32 | TRS §§3.1/3.3/11.1 | M01-T03/T05; M04-T03/T04 | M01-V01/V11; M04-V01/V12 |
| FR-FARM-03/04 independent plots and Locked/Empty/Growing/Ready states | TRS §§3.3/3.4/4.3 | M01-T05/T10/T11/T14; M04-T04 | T-001/003/021; M01-V08 |
| FR-FARM-05 Empty/Growing/Ready click actions | TRS §§4.3/11.1 | M01-T10/T11; M04-T08/T09 | M04-V03/V04 |
| FR-FARM-06/08 level+payment, sequential IDs25–32, stable coordinates, no unlock holes | TRS §§3.3/4.3 | M02-T03; M03-T03/T10; M04-T03/T10 | M02-V09/V12; M04-V12; T-026 |
| §3 zero new-game coins/XP/points/upgrades/contracts/research, Wheat sole start, no preplant/paid auto-selection | TRS §§3.1/3.2 | M01-T03/T05; M02-T17 | T-001; M01-V01/V11 |
| §4 all 15 crop definitions, basic free/advanced paid seeds, level+research guards | TRS §§3.4/5 | M01-T02/T09/T10; M02-T07; M05-T02 | T-001/003/004; M02-V06; M05-V09 |
| §4 planting-time charge/snapshot, no maturity payout, manual/auto reward once, no spoilage | TRS §§3.4/4.3/9.2 | M01-T09–T11; M02-T09/T15; M03-T05 | T-001/003/008/018/020 |
| §5.1 XP never spent, exact table/continuation, all level points, surplus | TRS §§3.2/5/20.3 | M01-T03/T04/T12; M03-T12/T13; M05-T13 | T-010/029; M01-V11/V13; AV-003 |
| §§5.2/5.3 growth/profit ranks, costs/edges/levels, additive effects and growth cap | TRS §§3.5/4.4/5 | M02-T01/T02/T04; M04-T11 | M02-V01/V09/V12; T-008 |
| §5.4 eight automation nodes, four-point basic chain, fixed fertilizer/Smart/enhanced distinctions | TRS §§3.5/6.1/6.4 | M02-T04/T08–T10/T14; M05-T11/T12 | M02-V01/V13; M05-V08/V12 |
| §5.5 paid full reset, preserved XP/assets/snapshots, stopped capabilities/inactive rules, explicit rearm | TRS §§4.3/5/6.4 | M02-T05/T10; M04-T11/T12; M05-T11 | T-008; M02-V05/V13; AV-004/007 |
| §6.1/FR-AUD-006 eleven rank prices/effects/guards, future cycles, show caps, deferred exclusions | TRS §§3.5/20.6 | M02-T06; M04-T10; M05-T02/T13 | AV-006; M02-V09/V14/V15 |
| §6.2 exactly one None/Basic/Premium/Advanced yield fertilizer, scaled base-value prices, every planting charge | TRS §§3.4/4.4/6 | M02-T02/T12/T14/T15 | T-004/023/024; M02-V02/V07/V08 |
| §6.3 gross/net/growth rounding, affordability, preview rates/incremental profit/ROI | TRS §§4.4/5/6.3/20.4 | M01-T04/T09; M02-T02; M04-T09 | T-003/004; M04-V04; AV-004 |
| §7.1 shared wallet, seed-first, Plot>Group>Farm with explicit false/zero, farm-only budget controls | TRS §§6.1/6.2/20.7 | M02-T10/T11; M03-T03; M04-T12; M05-T11 | T-005–007; M02-V04/V13; AV-005/007 |
| §7.1 reserve, advanced seed-toggle, free seed edge, explicit fallback/manual override and no other purchase restriction | TRS §§6.1/6.2/20.4/20.5 | M02-T08/T10–T12/T15; M05-T11 | M02-V13/V15; AV-004-04/005-04 |
| §7.1/FR-AUD-005 terminating fixed exclusions, canonical subset and genuine-event retry | TRS §20.5 | M02-T11/T12/T15; M03-T13; M05-T09 | AV-005-01–05; T-006/007/024 |
| §§7.2/7.3 exact MP/BP, ROI CE, None, safe ties, priority/mode grouping, single final C and atomic charges | TRS §§6.2/6.3 | M02-T13–T15; M03-T13; M05-T09/T11 | T-023/024; M02-V07/V08/V13; AV-005 |
| §7.4/FR-AUD-004 accepted input/terms, confirmed ending-balance minimum, changed quote refresh | TRS §§4.1/20.4 | M01-T06/T13/T14; M02-T02/T08; M04-T08/T09 | AV-004-01–05; T-020/021 |
| §8 one running project/one manual boost, original paid cost, timing ceil, completion and no auto-next | TRS §§3.5/4.2/5 | M02-T07; M03-T03/T12; M04-T11 | T-009; M02-V06/V13; AV-004-03 |
| §9 closed cycles include costs/XP/contracts/stalls; no skill/research/new-crop auto purchases; complete offline report | TRS §§8/9/12 | M03-T12–T14; M04-T13; M05-T06 | T-009–012/019/029; M03-V06/V11; M04-V06 |
| §9.1 monotonic active/UTC anchor, rollback/forward/DST, accepted no trusted time, sleep1×/debug separation | TRS §7 | M01-T08; M03-T07–T09/T16; M06-T05 | T-013–017; M03-V04/V05/V12/V13 |
| §9.2 explicit starts/Ready enable/manual harvest replant/future presets/reset/rearm, subset atomicity and rotation cursor | TRS §§4.3/6.4/20.7 | M02-T08–T10/T15; M04-T12; M05-T11/T12/T15 | M02-V13; M05-V08/V12/V17; AV-004/007 |
| §9.2/FR-AUD-007 single group lifecycle/consent/reference graph/staging | TRS §20.7 | M02-T10/T16; M03-T03/T10; M05-T11/T12 | AV-007-01–06; M05-V17 |
| §10.1 optional Board/three slots/one-time accept/claim/abandon/reaccept, coherent recovery | TRS §§3.5/5/20.1/20.2 | M05-T03–T06; M03 generic records | T-011/018–020; M05-V01–V03/V13/V17 |
| §§10.2–10.4 all 12 exact rows, level/research/AutoHarvest guards, mixed AND, actual origin/gross, post-acceptance order, concurrent progress/frozen rewards | TRS §5.1/§8 | M05-T01/T03/T04/T06/T14/T15 | M05-V16/V17; T-011; actual row-by-row predicates required |
| §11.1 Level1 statistics, 60/1440 completed minutes/as-of/live/session/lifetime and offline historic attribution | TRS §§10.1/10.2 | M03-T11; M05-T07/T08/T10 | M03-V16; M05-V05/V07/V14 |
| §11.2 plot/state/count/expense/XP/trends, completed-cycle profit versus cash flow/category details | TRS §10 | M03-T11; M05-T07/T08/T10 | T-025; M05-V04/V05/V14 |
| §11.2 productive Growing time versus occupancy, Ready/stalled/Empty disjoint accounting and capacity integration | TRS §10.2 | M03-T11; M05-T07/T08 | M03-V16; M05-V05/V14 |
| §11.3 actual/forecast/optional steady state, same simulator deep copy, normalization, retention and paid-cycle preservation | TRS §§8/10.1/10.3 | M05-T07/T09/T10/T15 | T-022/025/029; M05-V05/V06/V11/V14 |
| §12 debug integer1–60, reset1×, debug profile separation, production omission, natural presentation and headless metrics | TRS §§7.4/11/14 | M01-T08/T14; M04-T17; M06-T08/T12 | T-002/017/021; M04-V09/V10; M06-V10 |
| §13 full local persistence, no half economics, backups/migrations/storage failure/one process/offline operation | TRS §§9/12 | M03-T01–T06/T10/T14–T16; M06-T04/T13 | T-018–020/026–028; M03-V01–V03/V09/V10/V15 |
| §13/FR-AUD-001–003 coherent recovery/UNKNOWN/manifest/retired IDs/overflow no caps | TRS §§20.1–20.3/4.4 | M01 foundation contracts; M03 coordinator/codec/recovery; M05 claims | AV-001–003; T-019/020/026/029 |
| §§14/16 exclusions, future web/ZIP, change control and provisional values | TRS §§1.1/9.5/16–18 | M01-T15; M03-T18; M05-T02/T13/T16; M06-T11–T15 | T-030; M02-V14; M05-V15; M06-V09–V11/V15/V16 |
| §15 complete acceptance checklist | TRS §18 | M06-T02/T15 | M06-V11/V17; actual evidence or explicit approved exception, no planning-pass substitution |

## 4. Architecture and source-test coverage

| Architecture rule | Task ownership | Planned evidence |
|---|---|---|
| ARCH-001 scene-independent core | M01-T05/T13/T15; all later gameplay services | M01-V09; T-021/022/030 |
| ARCH-002 typed RefCounted/runtime, Resource/content, Node/presentation | M01-T01/T02/T05/T06; M04 shell | Parse/headless/clone validation; M01-V07/V09 |
| ARCH-003 explicit commands/results, no hidden UI mutation | M01-T06/T13; M02-T15; M04-T08 | M01-V03/V04/V14; M04-V05/V16 |
| ARCH-004 platform adapters | M01-T08/T15; M03-T01/T02/T07/T18 | M01-V09/V12; M03-V05/V17; T-030 |
| ARCH-005 versioned content | M01-T02/T03/T05; M03-T03/T10; M05-T13 | AV-003; T-026; M03-V18/V19 |
| ARCH-006 headless simulation/forecast | M01-T01/T13–T15; M05-T09 | M01-V09; T-021/022/029 |
| ARCH-007 single authoritative context initially | M01-T13; M03-T04/T12–T14 | Clone/ownership/unknown tests; T-019/021/028 |

| Source tests, all IDs covered | First substantive owner and meaning | Later evidence |
|---|---|---|
| T-001/003 | M01-V01/V02, new game/base Wheat/Corn formula fixtures | M06-V01 |
| T-002 | M01-V06 core clock, M04-V09 full natural presentation | M06-V07 |
| T-004 | M02-V02 exact Tomato/Basic costs/reward/profit | M06-V01 |
| T-005/006/007 | M02-V03/V04/V13/V15, simultaneous credits, shortage, authorized fallback | M03-V14; M06-V01/V13/V17 |
| T-008 | M02-V05 snapshot/reset | M06-V01; AV-003/006 |
| T-009/010/012 | M03-V06 offline research/points/8h/7d, with M01 XP precursor | M05 true-content integration; M06-V02 |
| T-011 | M05-V02/V13/V16/V17 true contracts/manual claim | M06-V02/V04 |
| T-013/014/015/016 | M03-V04 rollback/future anchor/forward restart/DST | M06-V03 |
| T-017 | M03-V05 measured/provider and fake suspend cases | M06-V03/V14 |
| T-018/019/020 | M01 in-memory identity; M03-V02/V03/V13/V19 actual atomicity, catch-up and replay | M05 true claims; M06-V04/V12/V17 |
| T-021 | M01-V06/V08/V14 then M03-V07/V18 reference/offline modes | M05-V11; M06-V02/V16 |
| T-022 | M05-V06 cloned next-hour forecast | M06-V05 |
| T-023/024 | M02-V07/V08 exact/ROI oracle and32-plot measurements | M06-V01/V13 |
| T-025 | M03-V08 accounting fixture; M05-V04 complete queries | M06-V05 |
| T-026/027/028 | M03-V09/V10/V19 migration/corruption/space/one writer | M06-V04/V10 packaged cases |
| T-029 | M03-V11/V18 actual production long offline/reference aggregation | M05-V11; M06-V06/V16 |
| T-030 | M01-T15 recipe; M03-T18/M03-V17 required minimal probe | M06-T11/M06-V09; partial/unrun is not pass |

## 5. Traceability gaps, rejected gap claims and dependency assessment

| Item | Exact affected file/section | Assessment and action |
|---|---|---|
| R2-001 | Current source headers; ADR §§1/4/6/10; A1-CL §§2/3; R1 readiness package links | 91 broken local references in 13 files prevent complete AV-009-02 closure. Correct destinations through round_01; no missing source content. |
| R2-002 | M02-T06 line110; ADR §2 | Obsolete unresolved-level/application prose survives. Authoritative guards and Applied status exist; remove stale operative instruction without reopening approvals. |
| R2-003 | R1 scenarios DVS-013 line226 | Nominal level 20/Coffee-Rice fixture violates Rice level 22 gate. Correct positive fixture in dated erratum; use R2-S15 below. |
| Uncovered whole functional family | FRS §§1–16 and task reverse map | None established. All original named FR and unnumbered families have source design, owner and planned test/acceptance. This does not certify every implementation edge. |
| Wholly orphan task | All101 task definitions | None established. Setup/qualification/handoff tasks trace architectural/release duties rather than a direct gameplay FR. |
| M03-T18 numbering | M03-T18 dependencies T03/T06/T09/T12/T16 and M01-T15; M03-T17 depends T16/T18 | Valid intentional order. “Before T17 handoff” is explanatory prose, not a dependency of T18 on T17. A naive parser of the entire paragraph would invent a cycle. |
| Early M03 save skeleton | M03-T06, final integration M03-T16 | Skeleton can precede measured clock; final cadence/time reconciliation needs T08/T09/T11 integration and must pass T16. No separate circular dependency established. |
| Forecast before advanced rules | M05-T09 versus T11/T12/T15 | T09 supplies isolated engine-based forecast; T15 reruns advanced rule/reference parity. Reuse the same simulator, do not freeze a simpler forecast implementation. |
| Claimed tests lack executables | All plans/AV/T matrices | Expected in pre-development documents. This is future evidence, not a missing implementation owner or a passed test. |
| Precise script signatures/provider algorithm | TRS §5, M01/M03 tasks | Logical interfaces and invariants are sufficiently defined; concrete typed signatures and empirical provider selection are explicitly scheduled. Do not demand complete implementation code before M01. |
| Final numerical balance/hardware/art | FRS §§12/16, TRS §14, DEC-001/014/023/024 | Explicit staged obligations. No unsupported claim that they are resolved; do not invent requirements or mark them as M01 defects. |

The exact optimizer and long-offline targets remain technical feasibility risks requiring measurements; active/offline equivalence remains a required proof by implementation tests. No new missing foundational design was established. Approval status and current source hashes match the operative authority; historical hashes intentionally differ.

## 6. Adversarial design-validation scenarios

All scenarios below are **design analysis / future executable tests**. “Adequate” means the documents determine the expected behavior. It never means a runtime test passed. Each scenario includes preconditions, sequence, expected outcome, references, failure modes and a gap disposition. Paid/unlocked synthetic fixtures explicitly satisfy eligibility; they do not skip costs in pacing evidence.

### R2-S01 — Thirty-two simultaneous harvests with insufficient replant funds

**Preconditions:** Valid isolated level-12-or-higher profile; all 32 plots purchased in a contiguous prefix; Auto Harvest and Auto Replant owned/enabled/authorized. All32 base Wheat cycles mature together; no coin modifiers, wallet 0, farm R = 0, equal priorities. Future accepted crop is researched Corn/None, seed18. This is not a natural new-game progression claim.

**Sequence:** Drain the due timestamp, harvest all 32, then form the one replant batch. At the next Corn maturity include the four authorized stalled plots as coalesced retries.

**Expected:** First batch credits 32×16=512 before spending. IDs1–28 plant Corn at 504 total; IDs29–32 remain configured/stalled uncharged; wallet 8. After28 Corn harvests, wallet 8+3,080=3,088;32 Corn seeds cost 576, leaving2,512. No first-harvest callback consumes money before the other31 credits.

**Requirements/tests:** FRS §§7.1/9.2; TRS §§4.2/6.2/20.5; T-005/006/024; M02-V03/V04/V13/V15; AV-005.

**Failure modes:** Per-plot callback allocation; seed double-debit; unfunded cycle creation; nondeterministic container traversal; missing retry or zero-time retry spin. **Adequacy:** Defined. Test input permutations, manual input at same timestamp and complete commit failure/UNKNOWN. No additional rule required.

### R2-S02 — Smart Fertilizer, competing groups, reserves and overrides

**Preconditions:** Smart/enhanced nodes and prerequisites owned in a valid high-level fixture. W = 1,000 after credits, accepted seed total200, farm R = 100, fixed total100, p = 25%. Eligible priority/mode groups exist. Try a plot-level R override and an explicit false/zero inheritable setting.

**Sequence:** Resolve Plot>Group>Farm settings, reject forbidden wallet override, finalize seed/fixed plan, compute M/C once, process priorities and tied MP→CE→BP order. Repeat with seed-protection On, R>W, p0/p100 and explicit fallback accepted/refused.

**Expected:** A700, M600, C150. C is a ceiling, not reserved cash; earlier MP can consume all 600 and leave BP0. All BP groups combined spend≤150 and all Smart groups≤600. Free seeds remain possible below R; a paid seed can use basic reserve only when advanced seed protection is Off. Explicit false/zero is not unset. Manual override grants only its confirmed cycle, not future automatic exemption.

**Requirements/tests:** FRS §§5.4/7.1–7.4; TRS §6/20.4/20.5; T-023/024; M02-V07/V08/V13/V15; AV-005-04.

**Failure modes:** Percentage recomputed per group, hidden separate budgets, mode order reversed, fixed spending after Smart, lower-priority global-optimum claim or unaccepted substitution. **Adequacy:** Defined. Exact mode oracle/frontier performance is future evidence; no new design gap established.

### R2-S03 — Growth/coin modifiers change during an existing crop

**Preconditions:** Eligible funded high-level fixture, Tomatoes researched, Faster Germination5 ranks (20%), no other growth effect. A Tomato cycle has snapshotted48-minute growth. Preserve a pending manual quote and a valid existing auto policy on other plots.

**Sequence:** Buy IrrigationI (+5% reduction) for650; quote/plant a future Tomato; then confirm a paid reset and later rebuy abilities. Attempt old pending quote and let the original crop mature.

**Expected:** Original remains48 minutes with original reward/cost snapshot. After IrrigationI, future Tomato is45 minutes. After reset, a newly planted Tomato with only IrrigationI is57 minutes. Removed automation becomes inactive; rebuy alone does not rearm. The stale pending manual modifier quote refreshes; unchanged authorized policy does not reinterpret an already planted cycle. Equipment remains owned and reset preserves level/XP/research.

**Requirements/tests:** FRS §§4.1/5.5/6.3/FR-AUD-006; TRS §§3.4/20.4/20.6; T-008; M02-V05; AV-004-02/006-03.

**Failure modes:** Recomputing current maturity/reward from global skills; refunding paid cycle costs; restarting spending after rebuy; executing a changed manual quote. **Adequacy:** Defined. No new consent mechanism or retroactive bonus is needed.

### R2-S04 — Several level increases during offline production

**Preconditions:** Level7/5,200 XP;24unlocked plots; four basic automation nodes allocated, two points unspent. Base Wheat/None already planted at t0 and valid continuous automation armed. No modifiers or paid seeds. Catch-up target is exactly 8 hours later.

**Sequence:** Process60eight-minute harvest/replant batches through the inclusive target, awarding all XP/points and never allocating new skills. Commit once with the anchor.

**Expected:** 24×60=1,440 harvests,8,640 XP gained,13,840 totalXP → level 10 (13,500 threshold); exactly three new points, so five unspent plus four allocated equals9=level−1. Gross23,040 coins. No automatic Smart purchase at 9, new research or crop assignment. Intermediate level 8/9 boundaries remain consistent in event/aggregate paths.

**Requirements/tests:** FRS §§5.1/5.4/9; TRS §§3.2/5/8/20.3; T-010/012/021; M03-V06/V18/V19; AV-003.

**Failure modes:** Award one point per payout instead of gained level, skip crossed levels, double points after restart, read latest rather than bound manifest or auto-spend. **Adequacy:** Defined; exact numbers give a future reference oracle. No runtime pass claimed.

### R2-S05 — Research completion coincides with automatic production

**Preconditions:** Eligible profile with running Corn research whose completion matches Wheat maturity; existing Wheat loops valid; no accepted command before that due boundary. Separate boost-used/unboosted and stale-completion fixtures.

**Sequence:** Advance to the tied timestamp, then accept a manual crop/research action. Replay an old completion event after a previously purchased boost changed completion time.

**Expected:** Research completes first, then the entire due farming batch, then accepted manual actions. The unlock does not assign Corn, start new research or buy a boost. Current planted snapshots remain unchanged. Old rescheduled completion is stale; one-project/one-boost flags survive reload. A naturally aged boost uses accepted remaining time, not obsolete preview timing.

**Requirements/tests:** FRS §§7.1/8/9; TRS §§4.2/5/8/20.4; T-009; M02-V06/V13; M03-V06/V14; AV-004-03.

**Failure modes:** UI/callback order wins, duplicate completion, automatic purchase/assignment or second boost after restart. **Adequacy:** Defined. Need actual tied-event and fault tests, not a new requirement.

### R2-S06 — Contract completion and claiming across save/restart

**Preconditions:** Valid eligible level 7+ profile; CON-Q01 unclaimed/available, free slot. A due Wheat harvest precedes the acceptance command at the same simulation time. Track another accepted matching offer where applicable.

**Sequence:** Accept after due work, complete96later Wheat harvests (including planted-before-acceptance crops harvested afterward), save/restart, then claim. Lose the commit response and try duplicate pending delivery, new claim, settings save and shutdown. Separately restore a validated backup preceding the claim.

**Expected:** Pre-acceptance due crop gives no progress. Each later qualifying cycle counts once per independently matching accepted contract. Completion itself pays0 and retains the slot. Manual claim pays frozen153 coins/57 XP and closes Q01 atomically. UNKNOWN blocks all writes until primary read-back; no replacement claim. Old-backup restoration rolls back both lost claim reward and flag with fresh new-allocation namespace; retained-primary replay cannot pay twice.

**Requirements/tests:** FRS §10/FR-AUD-001/002; TRS §§5.1/20.1/20.2; T-011/018–020; M05-V01–V03/V13/V16/V17; AV-001-02/002.

**Failure modes:** Counting timestamp without order, auto-claim, double-count per cycle, treating manual harvest on auto-enabled plot as automatic, claim credited outside transaction or mixing recovered flag with lost-branch wallet. **Adequacy:** Defined; actual catalog faults remain M05/M06, not covered by generic M03 fixtures.

### R2-S07 — Application crashes during offline catch-up

**Preconditions:** Valid old checkpoint/anchor and owned profile; pending startup namespace; enabled farming/research/accepted contracts. Include deterministic event and aggregate reference paths.

**Sequence:** Terminate during private calculation, before COMMIT, after COMMIT, and after the database commits but before the receipt is delivered. Try reopening or retrying while an operation remains unsettled.

**Expected:** Before definite commit, retain old complete checkpoint and credited-through anchor, no published payout. After complete commit, recover new state+anchor+stats+replay/identity together. Uncertain live receipt first settles/reads primary and preserves pending identity, blocking backups/shutdown writes. Rerun only from selected coherent state; no additive offline reward outside it.

**Requirements/tests:** FRS §13/FR-AUD-001/002; TRS §§8/9/12/20.1/20.2; T-019; M03-V03/V13/V19; AV-002-03/05.

**Failure modes:** New anchor with old economy, new economy with old anchor, stale overwrite, early namespace rotation, historical event array memory growth. **Adequacy:** Defined. Adapter/fault qualification is required before M03 completion.

### R2-S08 — Crash during planting, harvest or equipment purchase

**Preconditions:** Valid funded Corn18/None request, a distinct mature base Corn110 coins/32 XP cycle, and an eligible Improved SoilI900coin quote. Use separate parent checkpoints, stable command identities and a whole-lifecycle profile lock.

**Sequence:** For each operation inject pre-transaction, mid-write, pre-COMMIT, post-COMMIT/pre-receipt and post-receipt termination/failure. Retry same pending delivery, then a new command against the selected state. Also attempt a second process.

**Expected:** Plant debit and new cycle/maturity/accounting/replay/anchor are all old or all new. Harvest removes the consumed cycle and credits 110/32/progress/accounting together. Soil purchase900debit and rank/effect are atomic, future-only. Same/stale/retired commands cannot repeat effects; UNKNOWN is not rollback. A second writer cannot mutate.

**Requirements/tests:** FRS §13/FR-AUD-006; TRS §§4.1/9.2/20.2/20.6; T-018/020/028; M03-V02/V10/V19; AV-002/006.

**Failure modes:** Durable UI success before commit; partial seed charge; duplicate rewards; rank without debit; response-cache eviction permitting replay; transaction lock mistaken for profile ownership. **Adequacy:** Defined. Native adapter/package evidence is future work.

### R2-S09 — Windows clock moves backward or forward

**Preconditions:** Saved coherent anchor, fake UTC and monotonic sources; separate running/restart traces and a normal1× profile. Do not alter the host clock during automated tests.

**Sequence:** During play move UTC±onehour while monotonic time advances10 seconds; checkpoint/exit/reopen; later restore wall time. Also change time zone/DST and test huge representable forward intervals.

**Expected:** Active simulation advances10 seconds, not±onehour. Real-accounted elapsed advances the anchor, never debug-scaled time or a raw wall-time jump. Reopen below anchor gives0additional offline time, preserves earned state and logs diagnostic. Positive restart difference is honored under accepted offline-first policy; time zone/DST affects display only. True representation failure preserves old complete checkpoint/anchor.

**Requirements/tests:** FRS §9.1/§13; TRS §§7/4.4; T-013–016; M03-V04/V13; M06-V03; DEC-013/026.

**Failure modes:** Rebase backward, negative XP/growth, live UTC delta used as active time, second payout of the same interval. **Adequacy:** Defined. Deliberate forward-clock exploitation and delayed offline credit while wall time is behind a future anchor are accepted limits, not new bugs to “fix.”

### R2-S10 — Sleep/hibernate while debug speed is60×

**Preconditions:** Debug profile at 60×, adequate clock observations or fakes partitioning active/suspended intervals; both inclusive/exclusive tick fixtures. Speed resets to1× after a new launch.

**Sequence:**10active real seconds,3,600 seconds OS suspension, resume without requiring focus; interrupt/save/restart at reconciliation boundaries. Include a long awake frame to ensure it is not automatically classified as sleep.

**Expected:**600+3,600=**4,200 simulated seconds**; anchor advances3,610real seconds. The sleep hour is counted once at 1×. Inclusive ticks do not receive a second sleep correction; exclusive ticks do not lose suspended elapsed. Foreground inactivity/slow frame alone does not prove suspension. Audio/render timing remains natural.

**Requirements/tests:** FRS §§9.1/12; TRS §§7.1/7.2/7.4; T-017; M03-T07/T09/T16; M03-V05/V13; M06-V03/V14.

**Failure modes:**60× sleep payout, lost hour, double wake credit, focus-dependent repair or accidental normal-profile modification. **Adequacy:** Algorithmic boundary is defined; **actual provider adequacy remains unverified and is an M03 condition**, not a completed pass or M01 blocker.

### R2-S11 — Very long offline sessions and millions of cycles

**Preconditions:** Isolated eligible level 26+ profile,32 purchased plots, fully authorized base Wheat/None loops; enough growth skills plus Irrigation to reach60%cap, no coin bonus; planted at t0. All paid ownership is fixture history, not granted by the tested offline path.

**Sequence:** Advance30 days and365 days at 1× using reference and optimized paths; repeat boundary-rich alternatives with staggered cycles, shortages, Smart groups, research, contracts and changed retention windows. Record time/memory separately from correctness.

**Expected stable oracle:**192 seconds/cycle;30 days gives13,500 cycles/plot=432,000 harvests.365 days gives164,250 cycles/plot=5,256,000 harvests,**84,096,000gross coins /31,536,000 XP**, with zero new seed/fertilizer expense. Level increases grant the exact difference under the manifest. Queue/history remain bounded; retain only approved buckets/lifetime/replay facts, not millions of UI events. Aggregate jumps preserve all outcome-changing boundaries and logical batch identities/caps.

**Requirements/tests:** FRS §§9/11.3/13; TRS §§8/10/14; T-029; M03-T12/T13/T14; M03-V11/V18/V19; M05-V11; M06-V06/V16.

**Failure modes:** Cap/discard time, minute-boundary CPU cost hidden, unbounded event lists, algebraic grouping changes funds/IDs/contracts or false int64 overflow from intermediates. **Adequacy:** Defined correctness/resource requirements. The five-second 30-day target is provisional and unproven; year correctness does not imply a five-second promise.

### R2-S12 — Completed-cycle profit differs from actual cash flow

**Preconditions:** Tomato/Basic cycle paid55seed+41fertilizer before a historical window, with gross 337 snapshotted. Harvest lies inside the window; no automatic replant in the simple case. Add distinct equipment/research/reset/expansion/contract categories in variants.

**Sequence:** Complete harvest, close minute buckets, query window/live/lifetime/session views, prune older detail and rerun after restart. Then test a replant or claim at the window boundary.

**Expected:** Completed-cycle operating profit is337−55−41=**241**. Harvest-window cash flow is**+337**; earlier payment window contains−96. With automatic next planting, that new cycle's96cash outflow belongs to the new payment timestamp, not the completed old cycle's profit. Contract rewards remain separate from crop gross. Half-open bucket endpoints, as-of time and partial live totals prevent double counting. Utilization counts Growing time; Ready waiting is occupancy only; capacity grows from purchase time.

**Requirements/tests:** FRS §§11.1–11.3; TRS §10; T-025; M03-V08/V16; M05-V04/V05/V14; M06-V05.

**Failure modes:** Net wallet labeled cycle profit, current prices replacing paid snapshots, expense double counting on rollup, claim advancing crop-revenue goals, or Stalled counted in addition to Empty. **Adequacy:** Defined. Independent accounting/state-time fixtures are required, no new economic feature.

### R2-S13 — Older schema or recovery backup restoration

**Preconditions:** Supported old-schema snapshot with complete immutable manifest and paid crop/research/contract data; validated older backup; separate missing/unsupported manifest and corrupt-primary variants.

**Sequence:** Backup before migration, fail/interrupt/retry migration; restore older validated generation; submit retired commands; allocate new cycles/contracts/groups. Attempt missing-definition load without a valid mapping.

**Expected:** Schema-only migration preserves manifest, XP/point invariants, full IDs and all paid snapshots. No implicit latest-curve/rank reinterpretation. Unsupported versions stop recoverably without overwrite. Old backup selects whole authoritative timeline and discloses lost revision/time/progress; new allocations use fresh namespace, existing references unchanged; lost claim credit and closure roll back together. Corrupt/unvalidated copies never replace good recovery generations.

**Requirements/tests:** FRS §13/FR-AUD-001/003; TRS §§9.3/9.4/20.1/20.3; T-026/027; M03-V09/V13/V19; AV-001/003.

**Failure modes:** Latest definitions silently invalidate skills, free XP/plot grants to “repair” corruption, ID collisions, global claim permanence promised without surviving history, lost good backups or stale migration overwrite after UNKNOWN. **Adequacy:** Defined for supported mappings; no universal migration engine is required or approved.

### R2-S14 — Active, accelerated and offline deterministic equivalence

**Preconditions:** Same valid cloned state, immutable manifest, fixed injected allocation/writer tokens, identical accepted command schedule where replayed, same target simulation time. For natural closed-time comparison, use already authorized loops without inventing new offline player commands. Include different advance partitions and checkpoint cadences.

**Sequence:** Run reference advancement as one step and deterministic partitions at 1× and60× clocks, then offline 1×. Include tied research/maturity/commands, shortages/fixed exclusions, contracts and rotation. Restore scheduler midway and rerun forecast on an isolated copy.

**Expected:** Wallet, XP, points, skills, cycles/economic IDs and order, research, contracts, authorization/cursor and historical economic totals/buckets agree at the same simulation target. Real/UTC/debug/session correspondence and per-run durable checkpoint metadata are validated separately because real schedules differ. Commit attempts do not consume gameplay counters. No normalization removes an economic mismatch. Forecast leaves every live mutable reference and repository unchanged.

**Requirements/tests:** TRS §§1/4/8/10.3/20.1/20.2; T-021/022; M01-V06/V08/V14; M03-V07/V18; M05-V06/V11/V17; AV-001-03/002-05/003/004-05/005-05.

**Failure modes:** Float/time rounding drift, UUID lexical sorting, commit cadence shifting cycle IDs, order-free checksum comparison, pooled offline caps, live clone alias or resetting active authorization on reopening. **Adequacy:** Defined. Actual equality proof remains implementation work; different real intervals are not expected to yield equal debug simulation durations.

### R2-S15 — Corrected positive rotation fixture and negative gate case

**Preconditions:** Positive case: **level ≥22**, all automation predecessors including Crop Rotation owned, Coffee and Rice researched, valid explicit Coffee/Rice sequence and cursor Coffee. Separate negative case: level 20 with Rice still ineligible. This explicitly corrects the nominal premise in R1 DVS-013 without editing its historical text.

**Sequence:** Try Coffee planting without funds, add funds and explicitly retry under unchanged authorization, lose receipt before/after commit, then proceed to Rice; reset/rebuy and forecast variants.

**Expected:** Affordability failure leaves cursor/selection and wallet unchanged. Successful planting advances exactly once with the cycle/spend commit. UNKNOWN preserves pending result; reset/rebuy does not rearm. Positive Rice succeeds only when its normal guards and funds hold; negative level 20/Rice cannot bypass research/level requirements. No skipped “replacement” crop is inferred.

**Requirements/tests:** FRS §§4.2/5.4/8/9.2; TRS §§4.3/6.4/20.7; M03-V14; M05-T12/M05-V08/V11/V12/V17; M06-V13.

**Failure modes:** Invalid positive fixture, cursor moves on failure, duplicate advance after receipt loss or rotation unlock bypass. **Adequacy:** Production rule defined; **R2-003 requires an audit-scenario erratum/precondition check** before the old fixture is reused.

### R2-S16 — Time spent calculating/committing startup catch-up

**Preconditions:** Valid cutoff/anchor, then five real seconds spent in catch-up commit/backup/UI setup before normal timing. No wall-clock edit; launch speed1×. Include UNKNOWN settlement taking further elapsed time.

**Sequence:** Sample offline target, perform delayed startup, begin active progression, immediately save/restart, then repeat an interrupted startup. Keep observations across the handoff.

**Expected:** The five-second interval cannot disappear or be credited again on immediate restart. State/anchor/interval observations bridge the calculation-to-active cutoff exactly once. UNKNOWN settlement uses the selected coherent state and pending real observations. Session starts after committed startup catch-up; startup/offline reporting remains distinct from active engagement.

**Requirements/tests:** FRS §9.1; TRS §§7.2/8/12.1/20.2; M03-T08/T12/T14/T16, M03-V12/V13/V19; historical R1 DVS-015 explicitly includes this delay trace.

**Failure modes:** Starting fresh monotonic baseline after setup loses elapsed time; moving anchor to observed UTC silently discards it; both handoff and next restart recredit it. **Adequacy:** Required by the interval invariant and existing explicit scenario. This is a test emphasis, not a newly missing contract or a new finding.

### R2-S17 — Checkpoint cadence, settings writes and gameplay identity order

**Preconditions:** Same injected simulation identity context, identical commands/target time, but one run adds time-only/settings checkpoints and another does not. Independently owned debug/normal profiles; bounded command response cache.

**Sequence:** Plant/harvest between extra saves, evict cached responses, lose a settings/time-only receipt, try another purchase/shutdown/backup, then reconcile and continue.

**Expected:** Cycle/event/transaction allocation order is identical across the two gameplay runs. Commit IDs/durable revisions can differ but never consume next_entity_id. UNKNOWN from any save route blocks every write; cosmetic draft may remain explicitly unsaved without economic success. Cached-response pruning never makes a committed or retired command executable again.

**Requirements/tests:** TRS §§4.1/9.2/20.2 checkpoint-identity ownership; AV-001-03/002-03/002-04; M01-V14; M03-V13/V15/V19; M04-V14/V16; M06-V17.

**Failure modes:** Checkpoint-induced ID drift, settings overwriting uncertain economy, stale-command gap reuse or a false “saved” indicator. **Adequacy:** Explicitly defined; M01 fake-sink checks precede real M03 adapter tests.

## 7. Scenario conclusions

The fourteen requested categories are covered by R2-S01–S14; R2-S15–S17 sharpen rotation, startup cutover and checkpoint-cadence cases. None is reported as an executed pass. The current architecture supplies adequate expected behavior for the substantive cases. Real timing sources, adapter fault behavior, exact solver performance, aggregate/reference equality, frame pacing and human engagement require the named future evidence.

The nominal rotation fixture correction is Low and does not alter production gates. The two remaining Round 1 documentation obligations concern accurate operative wording and reachable evidence. No new gameplay feature, cap, journal or architectural replacement follows from this assessment.

## 8. Complete implementation-task reverse map

The task-level ledger below covers all 101 tasks, including setup, handoff and qualification. Its source clauses and validation IDs are planned coverage. A1 source rules/crosswalks remain normative for the affected tasks, and final M06 evidence must repeat the integrated assertions. No row represents a task completed by this audit.

| Task / source location | Purpose | Requirement/design chain | Planned validation |
|---|---|---|---|
| [M01-T01](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:52) | Freeze reproducible project/toolchain contract | TRS §1.1; ARCH-002/006 | M01-V09, M01-V13 |
| [M01-T02](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:62) | Define content IDs and validation rules | FRS §4; TRS §§3.4/20.3 | M01-V01, M01-V05, M01-V14 |
| [M01-T03](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:68) | Supply full initial-state and XP fixtures | FRS §§3/5.1; DEC-003/020 | M01-V01, M01-V11, M01-V13 |
| [M01-T04](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:78) | Implement checked integer arithmetic primitives | TRS §4.4; DEC-005/026 | M01-V05, M01-V10, M01-V13 |
| [M01-T05](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:86) | Implement authoritative records and deep cloning | TRS §§3/9.4/20.1/20.3 | M01-V07, M01-V11, M01-V12, M01-V14 |
| [M01-T06](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:102) | Define typed commands, events and mutation batches | TRS §§4.1/20.2/20.4 | M01-V03, M01-V04, M01-V14 |
| [M01-T07](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:112) | Implement deterministic scheduler | TRS §4.2; DEC-006 | M01-V04, M01-V08, M01-V14 |
| [M01-T08](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:120) | Implement injectable clock foundation | FRS §§9.1/12; TRS §7 | M01-V06, M01-V10, M01-V12 |
| [M01-T09](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:128) | Implement base planting calculations | FRS §§4/6.3; TRS §4.4 | M01-V02, M01-V05 |
| [M01-T10](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:134) | Implement manual planting transition | FR-FARM-03–05; FRS §4.1 | M01-V02, M01-V03 |
| [M01-T11](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:138) | Implement maturity and manual harvest transition | FRS §§2.1/4.1; TRS §4.3 | M01-V02, M01-V03, M01-V04 |
| [M01-T12](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:144) | Implement cumulative XP and level awards | FRS §5.1; TRS §§3.2/20.3 | M01-V05, M01-V11, M01-V13, M01-V14 |
| [M01-T13](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:154) | Assemble SimulationEngine command/advance API | TRS §§2/5/8; ARCH-001/003/006 | M01-V08, M01-V09, M01-V14 |
| [M01-T14](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:162) | Add replay and mode-equivalence scenarios | TRS §§1/4/20.1/20.2; T-021 | M01-V04, M01-V06, M01-V08, M01-V10, M01-V13, M01-V14 |
| [M01-T15](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:174) | Validate architecture and portability boundaries | ARCH-001–007; TRS §§1.1/9.5 | M01-V09, M01-V12 |
| [M01-T16](C:/_/IdleFarmer/docs/implementation/01_M01_Headless_Simulation_Foundation.md:184) | Close foundation gate and handoff | TRS §§16/18; M01 completion | M01-V01–14 |
| [M02-T01](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:60) | Freeze skills and economic policy decisions | FRS §§5–8; TRS §§5/6/20.3/20.6 | M02-V01, M02-V12, M02-V14, M02-V15 |
| [M02-T02](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:70) | Implement unified modifier snapshots and quotes | FRS §6.3; TRS §§4.4/20.4 | M02-V02, M02-V09, M02-V15 |
| [M02-T03](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:78) | Implement plot expansion purchases | FR-FARM-06/08; TRS §§3.3/4.3 | M02-V09, M02-V12 |
| [M02-T04](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:84) | Implement skill allocation and capability queries | FRS §§5.2–5.4; TRS §5 | M02-V01, M02-V12, M02-V15 |
| [M02-T05](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:96) | Implement paid complete skill reset | FRS §5.5; TRS §§4.3/20.4 | M02-V05, M02-V13, M02-V15 |
| [M02-T06](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:106) | Implement permanent upgrades | FRS §6.1/FR-AUD-006; TRS §20.6 | M02-V09, M02-V14, M02-V15 |
| [M02-T07](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:114) | Implement manual research and acceleration | FRS §8; TRS §§5/20.4 | M02-V06, M02-V13, M02-V15 |
| [M02-T08](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:122) | Implement authorized batch manual actions | FRS §§7.1/7.4/9.2; TRS §4.1 | M02-V03, M02-V04, M02-V13, M02-V15 |
| [M02-T09](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:130) | Implement basic auto-harvest and auto-replant | FRS §9; TRS §§4.2/4.3/6 | M02-V03, M02-V04, M02-V10, M02-V13 |
| [M02-T10](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:138) | Implement inherited settings and authorization | FRS §§7.1/9.2; TRS §§6.1/20.7 | M02-V04, M02-V13, M02-V15 |
| [M02-T11](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:144) | Implement seed-first shared-wallet allocator | FRS §7.1/FR-AUD-005; TRS §§6.2/20.5 | M02-V03, M02-V04, M02-V13, M02-V15 |
| [M02-T12](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:154) | Implement fixed recurring fertilizer purchases | FRS §§6.2/7.1; TRS §§6.4/20.5 | M02-V04, M02-V13, M02-V15 |
| [M02-T13](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:162) | Build exact small-batch fertilizer oracle | FRS §7.2; TRS §6.3 | M02-V07, M02-V08, M02-V15 |
| [M02-T14](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:170) | Implement production Smart Fertilizer modes | FRS §§7.2/7.3; TRS §6.3 | M02-V07, M02-V08, M02-V13, M02-V15 |
| [M02-T15](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:176) | Commit coherent automated batches and safe retries | FRS §§7/9.2/13; TRS §§4.2/6/20.5 | M02-V03, M02-V04, M02-V10, M02-V13, M02-V15 |
| [M02-T16](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:184) | Add economic accounting and later-system hooks | FRS §§10/11; TRS §§3.5/5/10/20.7 | M02-V10, M02-V13, M02-V15 |
| [M02-T17](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:198) | Implement normal-speed progression scenarios | FRS §12.1; TRS §14.2; DEC-024 | M02-V11, M02-V14, M02-V15 |
| [M02-T18](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:210) | Close economy gate and persistence handoff | TRS §§16/18; M02 completion | M02-V01–15 |
| [M03-T01](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:61) | Verify SQLite adapter and packaging spike | FRS §§13/14; TRS §§1.1/9.2 | M03-V09, M03-V10, M03-V15 |
| [M03-T02](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:75) | Define repository contract and fault seams | FRS §13/FR-AUD-002; TRS §§5/20.2 | M03-V02, M03-V03, M03-V13, M03-V19 |
| [M03-T03](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:83) | Define lossless snapshot/schema codec | TRS §§3/9.4/20.1/20.3/20.7 | M03-V01, M03-V13, M03-V14, M03-V18, M03-V19 |
| [M03-T04](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:101) | Implement Windows schema and exclusive ownership | FRS §13; TRS §§4.1/9.2 | M03-V01, M03-V10, M03-V13, M03-V19 |
| [M03-T05](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:111) | Implement atomic economic commits and durable idempotency | FRS §13/FR-AUD-002; TRS §9.2 | M03-V02, M03-V03, M03-V13, M03-V14, M03-V19 |
| [M03-T06](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:125) | Implement save cadence and safe lifecycle orchestration | FRS §13; TRS §§9.2/9.3/12/20.2 | M03-V12, M03-V15, M03-V19 |
| [M03-T07](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:135) | Measure and wrap Windows clock sources | FRS §9.1; TRS §§7.1/7.2 | M03-V04, M03-V05, M03-V13 |
| [M03-T08](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:143) | Implement credited-through interval reconciliation | FRS §9.1; TRS §§7.2/8/20.2 | M03-V04, M03-V05, M03-V12, M03-V13, M03-V19 |
| [M03-T09](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:149) | Implement suspend/resume separation | FRS §§9.1/12; TRS §7 | M03-V05, M03-V12, M03-V13 |
| [M03-T10](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:157) | Implement recovery generations and migrations | FRS §13; TRS §§9.3/9.4/20.1/20.3 | M03-V09, M03-V13, M03-V15, M03-V19 |
| [M03-T11](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:169) | Implement durable base accounting and time mapping | FRS §11; TRS §10 | M03-V08, M03-V12, M03-V16 |
| [M03-T12](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:179) | Implement isolated reference catch-up | FRS §§8–10/13; TRS §8 | M03-V03, M03-V06, M03-V07, M03-V11, M03-V18, M03-V19 |
| [M03-T13](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:197) | Add proven stable-cycle aggregation | FRS §§7/9/11; TRS §§8/10/20.5 | M03-V07, M03-V11, M03-V14, M03-V16, M03-V18, M03-V19 |
| [M03-T14](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:217) | Commit catch-up and anchor atomically | FRS §13/FR-AUD-002; TRS §§8/9/20.2 | M03-V03, M03-V12, M03-V13, M03-V19 |
| [M03-T15](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:227) | Implement recoverable storage/time error routes | FRS §§9.1/13; TRS §§9/12/20.2 | M03-V04, M03-V09, M03-V13, M03-V19 |
| [M03-T16](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:237) | Exercise recovery, time and equivalence matrix | TRS §§7–10/15; complete M03 faults | M03-V01–16, M03-V18, M03-V19 |
| [M03-T18](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:249) | Run the minimal browser compatibility probe | FRS §14; TRS §§9.5/15 T-030 | M03-V17 |
| [M03-T17](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:253) | Close durable simulation gate | TRS §§16/18; M03 completion | M03-V01–19 |
| [M04-T01](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:62) | Establish Windows scene shell and rendering baseline | FR-PLAT-01/02; FR-GFX-01–03; TRS §11.1 | M04-V01, M04-V11, M04-V15 |
| [M04-T02](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:74) | Specify the approved art direction's production bible and pipeline | FR-GFX-04; FRS §2.1; TRS §11.1 | M04-V02, M04-V11, M04-V15 |
| [M04-T03](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:80) | Implement stable isometric farm layout | FR-FARM-01/02/07/08; TRS §3.3 | M04-V01, M04-V12 |
| [M04-T04](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:86) | Implement snapshot-driven PlotView | FRS §§2.1/3/4; TRS §§3.3/11.1 | M04-V01, M04-V02, M04-V03 |
| [M04-T05](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:90) | Generate/integrate early crop-stage artwork | FR-GFX-04; FRS §2.1; TRS §11.1 | M04-V02, M04-V11, M04-V15 |
| [M04-T06](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:94) | Generate/integrate remaining crop-stage artwork | FR-GFX-04; FRS §4.2; TRS §11.1 | M04-V02, M04-V11, M04-V15 |
| [M04-T07](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:98) | Add wind and farming feedback | FRS §§2.1/2.2; TRS §11 | M04-V02, M04-V08, M04-V09 |
| [M04-T08](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:102) | Connect mouse commands and selection | FR-INPUT-01; FR-FARM-05; TRS §§4.1/20.4 | M04-V03, M04-V05, M04-V16 |
| [M04-T09](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:114) | Implement crop selection and planting preview | FRS §§4.1/6.3/7.4; TRS §20.4 | M04-V04, M04-V05, M04-V16 |
| [M04-T10](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:124) | Implement Store and expansion panel | FRS §§3/6.1; TRS §§3.3/20.6 | M04-V05, M04-V12, M04-V16 |
| [M04-T11](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:134) | Implement Skills and research panels | FRS §§5/8; TRS §§5/20.3/20.4 | M04-V05, M04-V13, M04-V16 |
| [M04-T12](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:146) | Implement basic automation/budget settings UI | FRS §§7/9.2; TRS §§6/20.4/20.7 | M04-V13, M04-V16 |
| [M04-T13](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:152) | Implement offline summary and reliability messages | FRS §§9/13; TRS §§8/12/20.1/20.2 | M04-V06, M04-V14, M04-V16 |
| [M04-T14](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:164) | Integrate music and separate audio buses | FRS §2.2; TRS §11.2 | M04-V07, M04-V09 |
| [M04-T15](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:170) | Implement persistent settings panel | FRS §§2.2/13; TRS §§3.5/11.2/20.2 | M04-V07, M04-V14, M04-V16 |
| [M04-T16](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:178) | Implement real-time effect aggregation | FRS §2.2; TRS §11.2 | M04-V06, M04-V08, M04-V09 |
| [M04-T17](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:182) | Integrate dev-only speed controls and diagnostics | FRS §12; TRS §7.4 | M04-V09, M04-V10 |
| [M04-T18](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:190) | Close visual integration gate | FRS §15; TRS §§16/18; M04 completion | M04-V01–16 |
| [M05-T01](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:61) | Validate approved authored contract definitions | FRS §§10.2–10.4; TRS §5.1 | M05-V01, M05-V09, M05-V16 |
| [M05-T02](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:69) | Audit complete crop/research/equipment catalog | FRS §§4.2/6/8; TRS §§3.4/20.6 | M05-V09, M05-V15, M05-V17 |
| [M05-T03](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:79) | Implement contract acceptance and progress | FRS §§10.1/10.3; TRS §5.1 | M05-V01, M05-V02, M05-V13, M05-V16, M05-V17 |
| [M05-T04](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:89) | Implement manual claim and abandonment | FRS §10.1; TRS §§5.1/20.1/20.2 | M05-V02, M05-V03, M05-V13, M05-V16, M05-V17 |
| [M05-T05](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:101) | Add Contract Board and offline report integration | FR-UI-01; FRS §§9/10; TRS §11.1 | M05-V01, M05-V02, M05-V13, M05-V16 |
| [M05-T06](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:109) | Extend save/catch-up/recovery for real contracts | FRS §§10/13; TRS §§8/9/20.1/20.2 | M05-V02, M05-V03, M05-V11, M05-V13, M05-V16, M05-V17 |
| [M05-T07](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:123) | Complete statistics query and retention semantics | FRS §11.1/11.3; TRS §10.1 | M05-V04, M05-V05, M05-V11, M05-V14 |
| [M05-T08](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:135) | Implement full actual reports and trends | FRS §11.2; TRS §10.2 | M05-V04, M05-V05, M05-V07, M05-V14 |
| [M05-T09](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:141) | Implement copy-isolated next-hour forecast | FRS §11.3; TRS §§10.3/20.5 | M05-V06, M05-V11, M05-V12, M05-V14, M05-V17 |
| [M05-T10](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:155) | Implement Level-1 Statistics & Profitability panel | FR-UI-01; FRS §11; TRS §10 | M05-V04, M05-V05, M05-V06, M05-V07, M05-V14 |
| [M05-T11](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:161) | Implement presets and advanced budget management | FRS §§5.4/7/9.2/FR-AUD-007; TRS §20.7 | M05-V08, M05-V12, M05-V17 |
| [M05-T12](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:169) | Implement approved crop rotation and advanced UX | FRS §§4.2/5.4/9.2; TRS §§4.3/6.4/20.7 | M05-V08, M05-V11, M05-V12, M05-V17 |
| [M05-T13](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:177) | Validate approved progression and final balance | FRS §§5/12.1; TRS §§14.2/20.3/20.6 | M05-V09, M05-V10, M05-V15, M05-V17 |
| [M05-T14](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:193) | Run full economic strategy and content validation | FRS §§1/12.1; TRS §14.2 | M05-V10, M05-V11, M05-V15, M05-V17 |
| [M05-T15](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:209) | Verify integrated reports and advanced persistence | FRS §§9–13; TRS §§8–10/20 | M05-V03, M05-V06, M05-V11, M05-V12, M05-V13, M05-V14, M05-V17 |
| [M05-T16](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:227) | Close feature-complete gate | FRS §15; TRS §§16/18; M05 completion | M05-V01–17 |
| [M06-T01](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:61) | Freeze qualification matrix and release inputs | FRS §§2/14/15; TRS §§1.1/14.1/18 | M06-V07, M06-V10, M06-V15, M06-V16 |
| [M06-T02](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:71) | Assemble source acceptance evidence map | FRS §15; TRS §§15/18; all decisions | M06-V11, M06-V16, M06-V17 |
| [M06-T03](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:91) | Run complete deterministic economic regression | FRS §§3–10; TRS §§4–6/20 | M06-V01, M06-V02, M06-V12, M06-V13, M06-V16, M06-V17 |
| [M06-T04](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:105) | Qualify real save durability and recovery | FRS §13; TRS §§9/12/20.1–20.3 | M06-V04, M06-V12, M06-V14, M06-V16, M06-V17 |
| [M06-T05](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:121) | Qualify clocks and extreme elapsed intervals | FRS §9.1/13; TRS §§7/8/4.4 | M06-V03, M06-V06, M06-V12, M06-V14, M06-V16 |
| [M06-T06](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:131) | Benchmark offline simulation and optimizer | FRS §§7/9; TRS §§6.3/8/14 | M06-V01, M06-V06, M06-V12, M06-V13, M06-V17 |
| [M06-T07](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:147) | Profile active frame/simulation/storage cost | FR-GFX-03; TRS §§9.2/14.1 | M06-V07, M06-V14, M06-V15 |
| [M06-T08](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:155) | Qualify GPU, visual, input and audio behavior | FRS §2; TRS §11/20.4/20.7 | M06-V07, M06-V13, M06-V15, M06-V17 |
| [M06-T09](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:169) | Validate economy and 3–5-hour automation goal | FRS §12.1; TRS §14.2 | M06-V08, M06-V15, M06-V16, M06-V17 |
| [M06-T10](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:185) | Evaluate additional 48 active hours of engagement | FRS §1/12.1; TRS §14.2 | M06-V08, M06-V15 |
| [M06-T11](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:191) | Audit web portability and M03 T-030 evidence | FRS §14; TRS §9.5/15 T-030 | M06-V09, M06-V14 |
| [M06-T12](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:201) | Build reproducible Windows distribution | FRS §14/DEC-027; TRS §9.2 | M06-V10, M06-V16 |
| [M06-T13](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:211) | Test clean install, upgrade and offline operation | FRS §§13/14; TRS §§9/12/16 | M06-V04, M06-V10, M06-V16 |
| [M06-T14](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:219) | Complete release documentation and recovery UX review | FRS §§13/14; TRS §§9.3/12/18 | M06-V10, M06-V11, M06-V17 |
| [M06-T15](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:235) | Run final release gate and handoff | FRS §15; TRS §18; final release gate | M06-V01–17 |
