# M02 — Economy, skills, research and automation

> **Audit corrections A1 — 2026-10-28:** Apply the approved contracts in [TRS §§15.1/20](../architecture/IdleFarmer_Technical_v1.5.md), [FRS audit requirements](../requirements/IdleFarmer_Functional_v1.0.md) and the [Audit Decision Register](../decisions/Audit_Decision_Register.md). The task crosswalk below is normative for the listed existing tasks; it does not add gameplay or implement later-stage features. [Correction changelog](../audit/round_01/Audit_Correction_Changelog.md) preserves before/after references. Existing provisional values and Open/Deferred evidence remain unchanged.

Priority P0 · Planning only · Depends on M01 · Next: M03

**Approved foundation update — 2026-10-26:** [Decision Register Group 1](../decisions/Decision_Register.md) / TRS G1 fixes arithmetic, event/command order, interval accounting, bounded replay and numeric-limit recovery. DEC-001's toolchain direction is approved; C1 selects version names; actual artifact/fingerprint verification remains open. Skill, acceleration, budget, optimizer and automation-lifecycle decisions are not approved by Group 1.

**Approved G2 update — 2026-10-27:** Apply [Decision Register Group 2](../decisions/Decision_Register.md) and TRS clarification G2: DEC-003 zero/Empty start, DEC-004 one-point/minimum-rank skill rules, and amended DEC-020 fixed eight-column 8×3 start with strict fourth-row 25→32 unlocking. DEC-002's through-30 table is approved provisional development data; G2 did not select continuation; C1 now approves increasing option B below. G1 contracts remain binding; no game implementation or test execution is claimed.

**Approved G3 update — 2026-10-27:** [Decision Register Group 3](../decisions/Decision_Register.md) / TRS G3 now binds research boost, farm-wide budgets/cap, Smart guarantees/priority, lifecycle/batches and staged advanced work (DEC-007/009/010/011/012/025). Numeric defaults remain provisional for balance; G4 policy is now approved as stated below; actual evidence and named partial subparts remain pending. Earlier notes describing these G3 choices as unresolved are superseded by the synchronized source contracts; no game implementation is claimed.

**Approved G4 update — 2026-10-27:** Project owner: “Group4 approved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G4 binds DEC-015/017/018/021/022 durability/cadences, completed-minute statistics, session/productive utilization, profile-owned settings and end-M03 minimal browser probe. DEC-014 measurement-first policy and DEC-019 authored lifecycle/schema are approved; provider/API evidence remains pending; C2 now approves the exact twelve contract rows/guards/rewards. All earlier pending-G4 statements are updated below; no application tests or implementation are claimed.

**Approved G5 update — 2026-10-27:** Project owner: “group 5 aapproved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G5 approves DEC-023 qualification/sample-review policy (named hardware/art still Open), defers DEC-008 Seed Efficiency/Research Facilities/Growth Booster, and approves DEC-024 costed economy plus normal-speed human evidence with the provisional five-real-minute/diary indicator. Preserve v1 research acceleration; no new balance values, hardware, assets or empirical results are inferred.

**Approved G6 update — 2026-10-27:** [Decision Register](../decisions/Decision_Register.md) / TRS G6 records “Group 6 approved as recommended”: standalone versioned Windows ZIP/executable, required dependencies/licenses/checksums and per-user save preservation. Installer/signing optional by separate selection; Steam/cloud/storefront integration deferred beyond v1. This changes future delivery requirements, not the current milestone's game scope or implementation status.

**Approved closeout C1 — 2026-10-27:** Owner: “DEC-001 - approved, DEC-002 - use option B.” [Decision Register](../decisions/Decision_Register.md) / TRS C1 selects standard Godot 4.7.2/matching templates, GUT v9.7.1, godot-sqlite v4.9 evaluation/reportedSQLite 3.51.0, Compatibility/Windows x86_64. Actual artifacts/hashes/licenses/integration remain unverified. Increasing option B beyond level 30 is approved provisional data: first step57,500; subsequent steps ceil(previous×110/100), one point/level with retained surplus and no arbitrary cap. All existing levels 1–30 values remain unchanged; no code/test result is claimed.

**Approved closeout C2 — synchronized 2026-10-28:** Owner: “Closeout B option A - approved.” [Decision Register](../decisions/Decision_Register.md) / TRS C2 makes FRS §§10.2–10.4's twelve authored offers, exact guards/predicates and frozen provisional rewards binding. Existing optional/manual/three-slot/one-time/offline lifecycle remains intact. This settles DEC-019 content; actual game implementation and balance evidence remain future work.

[Master roadmap / D-xx decisions](00_IdleFarmer_Master_Roadmap.md) · [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md) · [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md)

## Objectives and scope

Complete headless economic decisions and continuous production: all three skill branches, equipment, plot purchases, research/acceleration, fixed fertilizer, Smart Fertilizer, batch actions, automatic harvesting/replanting and deterministic shared-funds allocation. Preserve one simulator and immutable planted-cycle economics. Demonstrate the four-point basic automation path eligible at level 7 and Smart Fertilizer/budget controls at level 9.

Implement basic headless policies now. Define advanced configuration commands and schemas now; final presets/approved rotation and higher-tier content/UX are M05 tasks, as staged by TRS §16. Durable saves/native time are M03; no graphical scenes required. Research acceleration must have a real bounded policy before final release, even if a provisional fixture policy is used during early M02 work.

Primary references: FRS §§3–9,12,16; TRS §§3–6,15–17; T-004–008,023,024. Reuse M01 arithmetic, IDs, commands, state cloning and schedule phases.

## Prerequisites and dependencies

- M01 acceptance passes, including complete provisional XP table and public APIs.
- Apply approved DEC-004 rank costs/prerequisites and amended DEC-020 sequential expansion. Apply approved G3 research/budget/lifecycle/staging choices DEC-007/009/010/011/012/025; only genuinely unspecified content gates and later review choices remain pending. Apply approved DEC-006 phase ordering rather than deciding it again. Other tasks may proceed with isolated fixtures, but gated behavior cannot be marked done while its decision is absent.
- A validated definition exists for every crop, with stable research IDs and level prerequisites. All non-Wheat crops require completed research plus level.
- Persistable state changes must be documented for M03; no service accesses SQL, scene nodes or OS time.

## Required classes and suggested file structure

Reuse `SimulationEngine`, `GameState`, `FarmSystem`, `EconomySystem`, `ProgressionSystem`, `IntegerMath`, commands/results/events and scheduler. New/expanded runtime types are typed `RefCounted`; definition types are `Resource`.

| Suggested path | Required classes / role |
|---|---|
| `core/content/{skill_definition,upgrade_definition,research_definition,fertilizer_definition}.gd` | `SkillDefinition`, `UpgradeDefinition`, `ResearchDefinition`, `FertilizerDefinition` |
| `core/progression/{skill_state,skill_rules,progression_system}.gd` | `SkillState`, `SkillRules`, expanded `ProgressionSystem` |
| `core/economy/{modifier_snapshot,upgrade_system,planting_quote}.gd` | `ModifierSnapshot`, `UpgradeSystem`, `PlantingQuote` using the exact execution calculations |
| `core/research/{research_state,research_system,acceleration_policy}.gd` | `ResearchState`, `ResearchSystem`, explicit bounded `AccelerationPolicy` |
| `core/farming/{automation_configuration,automation_system,settings_resolver}.gd` | `AutomationConfiguration`, `AutomationSystem`, `SettingsResolver` |
| `core/economy/{seed_budget_allocator,fertilizer_optimizer,allocation_proposal}.gd` | `SeedBudgetAllocator`, `FertilizerOptimizer`, immutable feasible `AllocationProposal` |
| `core/simulation/commands/` | Typed purchase, allocate/reset, research, batch action and automation/fertilizer/budget configuration commands |
| `data/{skills,upgrades,research,fertilizers}/` | Versioned provisional values and approved unlock graph |
| `tests/{unit,simulation,balancing}/`, `tests/support/` | Oracle enumerator, budget fixtures, strategy harness and invariant checks |

Keep settings inheritance separate from capability gating: a stored rule may exist while its skill is inactive, but cannot authorize action. Quotes and optimizer proposals are read-only; only engine commit executes spending.

## Detailed implementation tasks

### M02-T01 — Freeze skills and economic policy decisions

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-006 A, AUD-DEC-008 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: M01. Apply approved G2 skill/plot rules and G3 research, budget, mixed-mode priority, authorization and staging policies from FRS §§5,7–9 and TRS §6. Create versioned policy/data records; do not reselect reserve field scope, slot/boost formula, solver fallback or batch/lifecycle behavior. Existing numeric defaults remain provisional for balance and required equipment guards now use AUD-DEC-006 A (coins and sequential ranks only); DEC-008 optional families remain Deferred and excluded. Validate prerequisite/capability guards and current decision status.

**Approved G1 constraints:** Use approved DEC-006 phase order and DEC-016 command identities unchanged. Group 1 did not approve the skill/expansion proposals; Group 2 now approves DEC-004's minimum-rank graph and DEC-020's amended sequential fourth-row expansion. G3 now approves the research boost baseline, farm-wide budget exception and explicit manual replant/enable/respec policies; final numeric balancing and later-group choices remain pending.

**Approved G2 constraints:** Rank/prerequisite and expansion-order decisions are approved under G2, not subjects for silent re-selection. Keep numerical effects/maxima/cap/price balancing provisional; use AUD-DEC-006 A equipment guards and the C1-approved increasing XP option B. Final effects/maxima/cap/prices remain provisional; do not invent extra gates or substitute another continuation.

### M02-T02 — Implement unified modifier snapshots and quotes

**Applied A1 task constraints:** AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01. Combine growth reductions under provisional 60% cap; add coin bonus categories including fertilizer; seed discounts remain inactive unless defined. Provide base/effective durations, seed/fertilizer costs, gross/XP, completed-cycle profit, incremental fertilizer profit/ROI and normalized rates from shared calculation routines. Preserve paid costs and effective reward in cycle snapshot. Test cap waste and no XP bonus from coin-only upgrades. References: FRS §§5.2–5.3,6.2–6.3; TRS §§3.4,4.4; T-004/008.

**Approved G1 constraints:** Quotes and execution use approved DEC-005 floor/ceil/basis-point calculations, including ceil-to-microsecond duration. Guard numeric limits under DEC-026; do not finalize provisional cap/effects through arithmetic approval.

### M02-T03 — Implement plot expansion purchases

Dependencies: T01. Add PurchasePlot with next-ID order, minimum level and per-plot payment as joint preconditions. For unlocked prefix 1..N, accept only N+1 (25→32); row 4 fills left to right in a fixed eight-column 8×4 map, starting with three unlocked rows. Preserve provisional bands 25–26 level 3/250, 27–28 level 5/1,000, 29–30 level 8/4,000, 31–32 level 12/12,000 and total 34,500. Reject skipped, duplicate, already-full, under-level or unaffordable requests with no charge/partial unlock/ID drift. Existing plot/cycle ownership never moves. References: FR-FARM-01/02/06/07/08; FRS §3; TRS §§3.3,4.1,4.3; DEC-020.

**Approved G2 constraints:** Test every 25→32 purchase against current prefix, level and exact coin cost; at high level with ample coins, requesting 27 while only 1–24 are unlocked still fails. Failed 25 purchase cannot make 26 eligible. After all eight, N=32 and further purchases fail without mutation.

### M02-T04 — Implement skill allocation and capability queries

**Applied A1 task constraints:** AUD-DEC-003 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01,T02. Add allocation commands for growth/profit ranks and all eight automation nodes, with point cost, level, prerequisite and maximum-rank checks. Derive effective capabilities from current allocations, rather than persistent booleans that survive a reset. Validate each node/rank boundary and full-automation path; Batch Planting/Harvesting cannot be used early. Deliver skill graph/rank tests. References: FRS §5.2–5.4; TRS §5.

**Approved G2 constraints:** One rank in the preceding growth/profit tier is sufficient once its level gate is met; do not demand full previous-tier ranking. Each rank/node costs one point. Validate the complete automation predecessor chain and four-point basic automation by level 7, plus point conservation after reset.

**Approved G3 constraints:** Capability gates require the purchased node plus source level/prerequisites. Smart level 9 provides reserve/percentage/modes; level 15 adds custom priorities and same-R seed protection Off by default. Fixed recurring fertilizer never requires Smart.

**Approved C1 constraints:** Each post30 option B level grants one point; bank surplus after full skill allocation and preserve level−1 = unspent+allocated invariants. Respec keeps earned level/XP under the same curve; no automatic point spend.

### M02-T05 — Implement paid complete skill reset

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T04. Quote and charge `max(250, 50 × level²)` using checked arithmetic; require confirmation token/version from a later UI command flow, not a second code path. Refund allocated points, preserve XP/level/plots/equipment/completed research, disable refunded automation immediately and preserve existing crop snapshots. Keep stored settings inactive rather than silently re-enabling skills. Validate insufficient funds and duplicate reset. References: FRS §5.5; TRS §§3.4,4.1; T-008; D-25.

**Approved G2 constraints:** Reset preserves the purchased contiguous prefix, fixed coordinates, XP/level and completed research; it cannot relock row-4 plots or create unlock gaps. Existing planted snapshots remain unchanged.

**Approved G3 constraints:** Retain removed configuration inactive; rebuy does not silently restart. Current snapshot/plot prefix preserved. Explicit enable/ApplyAndStart may rearm a valid accepted plan under G3 rules.

### M02-T06 — Implement permanent upgrades

**Applied A1 task constraints:** AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02,T04. Add versioned ranks/costs/effects and PurchaseUpgrade guards. Implement six Irrigation ranks and five Improved Soil ranks from FRS §6.1 using the approved FR-AUD-006 / TRS §20.6 guards: sufficient coins and the immediately preceding family rank only (rank I requires no predecessor), minimum player level 1, and no additional research, skill or contract gate. No equipment-level selection remains pending. Show exact marginal/capped effects in quotes. Effects apply to future plantings only. Seed Efficiency/Research Facilities/Growth Booster are explicitly Deferred under D-08/G5 and absent from saleable content; a post-playtest scoped proposal needs new owner approval before inclusion. Validate rank progression, affordability, max ranks and planted snapshot stability. References: FRS §6.1; TRS §§3,4.4,5,20.6; D-08; AV-006-01–04.

**Approved G5 constraints:** Implement only required Irrigation/Improved Soil families and four defined fertilizer choices in the current v1 catalog. Reject undefined/deferred Seed Efficiency, Research Facilities and Growth Booster IDs without charge; no placeholder/effect/extra slot. Required DEC-007 research boost remains enabled by its normal guards. Reference FRS §6; DEC-008 Deferred.

### M02-T07 — Implement manual research and acceleration

**Applied A1 task constraints:** AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01,T04. Define the 14 source projects with existing provisional costs/durations and level+research gates. Permit one active manually started project and one optional manually confirmed boost: snapshot actual start cost C/original timing, charge ceil(C/2), set remaining_us to ceil(remaining_us/2), mark boost_used. Reject used/completed/no-time-saved/unaffordable requests without charge, reschedule safely and preserve flag/snapshot through save. No auto next project/crop/boost. Deliver exact quote/execution and duplicate/event-boundary tests. References: FRS §8; TRS §§3.5,5,6; DEC-007/G3.

**Approved G1 constraints:** Put ResearchCompleted before the due maturity/automatic-harvest batch at that timestamp per TRS §4.2. No automatic project start/crop assignment follows completion. The one-slot/one-boost ceil(C/2)-cost and ceil(remaining/2)-time policy is now approved under DEC-007/G3.

### M02-T08 — Implement authorized batch manual actions

**Applied A1 task constraints:** AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03–T07. Implement skill-gated BatchPlant/BatchHarvest/ApplyAndStart over canonical selected IDs. Skip ineligible members with per-plot reasons; each accepted planting is all-or-nothing and the accepted subset is one coherent atomic result. All successful selected harvest credits precede its replant spending under G1 order. All-invalid/rejected envelopes change nothing after independently due work; NOT_COMMITTED stays unpublished and UNKNOWN stops for TRS §20.2 reconciliation; failed manual members have no partial charge/state effect. Mere selection is not a first-loop purchase authorization. References: FRS §§5.4,7,9.2; TRS §§4.1–4.3; DEC-025/G3.

**Approved G1 constraints:** Apply approved DEC-025 eligible-subset/replant authorization semantics together with approved batch order. Test a due automatic batch followed by two same-time manual commands in acceptance order; no input-frame-based sharing of future payouts.

### M02-T09 — Implement basic auto-harvest and auto-replant

Dependencies: T04,T07,T08. Add configuration commands and skill checks. Mature crops enter one coherent timestamp batch; auto-harvest and auto-replant are independent. Preserve manual harvest semantics selected in T01. At level 7 both enabled repeatedly execute while affordable; harvested crop selected for next cycle persists. Newly earned levels never auto-spend points/research/select crops. Validate disabling one ability, respec during growth, enabling on a ready crop and explicit planting of an empty configured plot. References: FRS §§5.4,9; TRS §§4.2,5; T-005/008/010; D-25.

**Approved G1 constraints:** Research completion and the whole due farming batch precede accepted manual inputs at the same timestamp. Preserve the separate-command allocation boundary from DEC-006; apply now-approved DEC-025/G3 manual-harvest replant, ready-on-enable and reset/rebuy authorization.

**Approved G3 constraints:** Explicit Auto Harvest enable may collect already-Ready crops; enabled/authorized Auto Replant follows manual and automatic success. A new Empty loop needs Plant/ApplyAndStart; unchanged authorized Stalled loops retry/resume normally offline/reopen, without per-cycle prompts. No automatic rearm after respec.

### M02-T10 — Implement inherited settings and authorization

**Applied A1 task constraints:** AUD-DEC-004 B, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01,T09. Resolve crop/auto/fertilizer/accepted-fallback/eligible-priority fields Plot > Group > Farm with explicit unset semantics. Keep R/percentage/seed-toggle exclusively in FarmBudgetConfiguration; reject per-group/plot override attempts. Gate basic controls/three Smart modes at owned Smart skill level 9; advanced priorities/seed toggle at owned level-15 node. Defaults: R=0, p=25%, seed toggle Off, equal priorities with stable ID ties. Preserve inactive config without silently activating unavailable abilities. Advanced executable features arrive M05. References: FRS §§5.4,7; TRS §6; DEC-010/011/012/G3.

### M02-T11 — Implement seed-first shared-wallet allocator

**Applied A1 task constraints:** AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T09,T10. Gather eligible planting requests after all same-time harvests and XP/accounting. Reserve mandatory seeds using stable effective priority then plot ID, without mutating live funds during planning. Mark unfunded requests empty/stalled retaining selected crop and settings. Prove fertilizer receives only post-seed uncommitted budget. Validate interleaved cheap/expensive seeds, exact wallet exhaustion and requests that fail eligibility. References: FRS §§7.1,9; TRS §§4.2,6; T-005/006.

**Approved G1 constraints:** The relevant seed pool is this approved logical batch, after its own complete harvest/XP/accounting phase. A later manual command cannot retroactively change this allocation. Reserve scope/fallback and optimizer strategy now follow approved DEC-010/009/G3.

**Approved G3 constraints:** All priorities default equal; stable IDs order seed ties without fragmenting a uniform-mode optimizer into singleton groups. Optional seed protection uses max(0,W−R), but free seeds remain eligible below R.

### M02-T12 — Implement fixed recurring fertilizer purchases

**Applied A1 task constraints:** AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02,T10,T11. Calculate Basic/Premium/Advanced from unmodified base coins using source coefficients/floors; exactly one yield fertilizer per cycle. Fixed selection can repeat before Smart Fertilizer unlock; debit at every planting. Respect explicit fallback or reject/stall request according to recorded rule when fertilizer cannot be afforded. Reserve protection applies to optional automated fertilizer, not mandatory seeds by default. Validate no fertilizer for unplanted plots and no unauthorized replacement crop/fertilizer. References: FRS §§5.4,6.2,7; TRS §6; T-004/007.

**Approved G3 constraints:** Honor fixed rules after seed reservations and before Smart funds. No-fertilizer fallback needs accepted permission; otherwise stall uncharged. A direct manual protection override requires clear cost/ending-balance confirmation; automatic replant after manual harvest still obeys automatic budgets.

### M02-T13 — Build exact small-batch fertilizer oracle

Dependencies: T12. Enumerate feasible None/Basic/Premium/Advanced choices for small fixtures, using integer/rational comparisons, checked cross products and deterministic tie rules. Compute incremental net coins/hour using each crop's effective duration. Exclude negative-profit automatic options; apply approved zero/nonpositive-profit handling (None wins). ROI is undefined for None, never divided by zero. Deliver known-answer fixtures and a brute-force oracle bounded to small plot counts; do not enumerate 4^32. References: FRS §7.2; TRS §6; T-023; D-09.

**Approved G1 constraints:** Use safe exact integer/rational comparisons under DEC-005/026, avoiding false overflow of a representable quotient and uncontrolled float authority. The solver strategy/guarantee is approved DEC-009/G3; performance/quality evidence remains future work.

**Approved G3 constraints:** Oracle checks objective per same-priority/same-mode group under remaining funds and global C, not one impossible optimum across conflicting modes. Capital Efficiency's positive marginal ROI preference is not a global-optimum guarantee.

### M02-T14 — Implement production Smart Fertilizer modes

**Applied A1 task constraints:** AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T13. Implement exact Pareto-pruned allocation for Maximum Profit and the same rate objective under remaining shared protection cap for Budget Protection. Capital Efficiency greedily ranks affordable positive marginal net gain/additional fertilizer cost, refreshing upgrades; None has no ROI and wins nonpositive-gain comparisons. Compute one C=floor((max(0,W−S−R)−F)×percent/100) from final feasible seed/fixed plan. Fund fixed rules first, then Smart groups by priority and tied mode order Maximum Profit→Capital Efficiency→Budget Protection, sharing remaining M/C. Use stable lower-spend/ID ties and safe exact comparisons. Compare oracle and benchmark 32 plots; no approximation without a new explicit DEC-009 approval. References: FRS §§7.2–7.3; TRS §6; T-023/024; DEC-009/010/G3.

### M02-T15 — Commit coherent automated batches and safe retries

**Applied A1 task constraints:** AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T11,T12,T14. Finalize feasible seed/fixed requests, releasing failed reservations and replanning deterministically; then validate all accepted cycle costs against shared funds/authorizations. Stage research-first/harvest→credits/accounting→seeds→fixed→Smart→plant outcome with replay metadata and later durable commit. Keep one protection ceiling for this logical batch, not per plot/group/offline interval. Coalesce relevant authorized stalled retries; no-progress attempts cannot loop. Failed cycle requests incur no seed/fertilizer charge or crop substitution. References: FRS §§7,9.2; TRS §§4,6; DEC-009/010/025/G3.

**Approved G1 constraints:** Apply the research-first TRS phase table; stage the whole outcome and attach profile/epoch/counter replay identity. A successful batch's durable replay/state/anchor/accounting commit is M03 work; failed requests never advance gameplay counters or partially charge.

### M02-T16 — Add economic accounting and later-system hooks

**Applied A1 task constraints:** AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T15. Emit immutable transaction categories for seeds, fertilizer, harvest, research/acceleration, upgrade, expansion and reset with cycle cost attribution. Add committed-harvest port for future contracts and current level/accounting observers; no UI-based accounting. Supply typed advanced-settings/contract reserved schema fields and migration notes, without claiming M05 gameplay exists. Validate all categories and no observer writes before batch acceptance. References: FRS §§9–11,13; TRS §§3.5,9–10; M03 prerequisites.

**Approved G1 constraints:** Inventory CommandReplayState and accounted-interval metadata from M01 alongside transaction/cycle cost fields for the M03 serialization handoff. Do not let post-commit presentation observers create a second authoritative economic mutation.

**Approved G3 constraints:** Inventory global budget/authorization/boost-used/snapshot/cursor records for M03, with advanced default/inactive schemas now and full behavior M05. Do not serialize independently overridable wallet fields.

**Approved G4 constraints:** Committed harvest metadata includes simulation timestamp/sequence, cycle/plot/crop identity, quantity, gross/XP and actual manual/automatic origin for approved future-event contract predicates and statistics. No UI event or contract reward is harvest gross; preserve cross-cycle operating versus payment-time cash flow. References: DEC-017/019; FRS §§10–11.

**Approved C2 constraints:** Committed-harvest semantics supply cycle/plot/crop identity, one harvested-cycle quantity, simulation time/deterministic order, actual gross/XP and actual automatic-versus-manual origin. Contract claim credits are a different category, never harvest gross. Same candidate outcome updates all qualifying accepted instances once; full evaluation remains M05.

### M02-T17 — Implement normal-speed progression scenarios

**Applied A1 task constraints:** AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03–T16. Add scripted decision strategies: focused automation, mixed growth/profit, conservative spending and fertilizer use. Decisions explicitly authorize research/skills/crops/purchases and pay real costs; no free fixture unlocks in progression evidence. Track time to level 7 and four automation nodes, idle/stall periods, seed/research/upgrade costs and points. Compare active-only and mixed offline-like advancement. Report whether provisional content reaches 3–5 hours; do not change earnings or conceal misses. References: FRS §§1,12; TRS §14; D-24.

**Approved G2 constraints:** Use approved zero/Empty starting state, provisional through-30 XP table and approved rank/prerequisite rules with actual research/seed/upgrade costs. No starting grants or free unlocks enter pacing evidence. Beyond30 production scenarios now use approved C1 increasing option B, never an invented cap.

**Approved G5 constraints:** Apply approved DEC-024 full-cost focused-automation/mixed growth-profit/coin-XP/low-high-reserve scenarios, active-only and mixed-offline, including no-contract progression. Record explicit purchases/decisions and real/simulated/offline/debug clocks; automated output measures economics, not ~48 human engagement hours. No deferred equipment, free unlocks or hidden tuning.

**Approved C1 constraints:** Full-cost scenarios now use approved increasing option B beyond level 30; remove the missing-tail gate. Preserve source levels 1–30 thresholds and no-grant start; actual pacing/final numerical retuning still needs evidence/recorded review.

### M02-T18 — Close economy gate and persistence handoff

**Applied A1 task constraints:** AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M02-V15 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T16,T17. Run validation; hand off shared farm budget, accepted fallback/loop authorization, inactive rules, cursor and research paid/boost snapshots with G1/G2 invariants. Record solver guarantee and actual benchmark evidence separately from policy approval. Approved G4 cadence/settings/metrics/probe/lifecycle and pending artifact/provider/hardware/art evidence plus approved C1 increasing progression and explicitly Deferred optional families are explicit; do not mark known G3 behavior undefined. References: TRS §§16,18; FRS §15; DEC-012/G3.

**Approved G1 constraints:** Verify approved G1 invariants plus existing acceptance conditions; list remaining non-Group-1 decisions explicitly. G2/G3 now approve the stated skill, budget, optimizer and research policies; fixtures alone cannot approve later amendments or prove implementation success.

**Approved G2 constraints:** Handoff includes next-ID purchase validation, eight-column mapping, approved point/prerequisite graph and source-linked XP table. G3 now approves advanced budget/research/lifecycle policy and staged delivery; C1 now approves increasing option B beyond level 30; only genuine remaining selections/evidence stay pending.

**Approved G4 constraints:** Persistence handoff carries approved G4 commit boundaries, profile-owned settings, authored offer/acceptance/claim eligibility and accounting contracts. C2 now approves exact targets/rewards for M05 implementation; do not reselect approved lifecycle or statistics policy.

**Approved G5 constraints:** Handoff excludes DEC-008 deferred families from definitions/UI/commands. Include costed scenario protocol and separate future normal-speed human evidence under DEC-024. Exact hardware remains Open under approved DEC-023 qualification policy.

**Approved C1 constraints:** Handoff exact option B curve/points and selected toolchain metadata; actual artifact verification remains pending. Continuation is no longer an unapproved choice, and deferred families stay excluded.

**Approved C2 constraints:** C2 definition/acceptance/progress/reward contract is approved, including twelve fixed offer IDs and guards. M03 schemas persist snapshots/order/claim eligibility; M05 implements real content. No contract acceptance arms or spends farm resources.

## Automated tests and validation procedures

Use M01 headless runner, deterministic fixtures and state digests. Unit-test rules independently, then replay mixed 32-plot batches through the actual engine. Exact small-batch optimizer oracle is test-only; production batches use selected algorithm.

| ID | Procedure / expected evidence |
|---|---|
| M02-V01 | Skill graph/ranks/gates: four points yield basic auto-harvest+replant by level 7; fixed repeat fertilizer requires no Smart node; Smart/reserve at 9, enhanced controls at 15, rotation at 20. |
| M02-V02 | T-004: Tomatoes seed 55, Basic fertilizer 41, gross floor(270×1.25)=337, XP 70, completed-cycle profit 337−55−41=241. Cycle snapshot persists after upgrades/reset. |
| M02-V03 | T-005: two or more mature plots credit all rewards before seed reservations; permuting input container order produces same canonical outcome. All 32 plots use one wallet. |
| M02-V04 | T-006/007: required seeds insufficient, optional fertilizer insufficient, reserve equal/above funds and manual fallback forbidden; no negative balance/partial charge/unauthorized crop. Later funds trigger one retry. |
| M02-V05 | T-008: reset mid-growth preserves crop economics and XP/research/equipment/plots, refunds exact points, stops removed automation; reset cost follows quadratic formula. |
| M02-V06 | Research: both level and project gates, one active slot, exact completion, bounded acceleration, duplicate start/completion and rescheduled event invalidation; no auto-next project or crop assignment. |
| M02-V07 | T-023: oracle-known optimal batch, None candidate, negative-profit exclusions, rational ROI and deterministic ties. Each mode gets its own expected allocation. |
| M02-V08 | T-024: 32-plot expensive seed/fertilizer batch with large balances, priorities and inherited fields; measure runtime/frontier size; validate proposal independently for budget/authorization. |
| M02-V09 | All expansion bands and total 34,500; rank/cost upgrade tables, growth cap, whole-coin rounding, pre-checked overflows and failed-command state equality. |
| M02-V10 | Several simulated production hours plus checkpoint-style clone/replay; no unbounded retry queue, no automatic skills/research/purchases outside selected farming rules. |
| M02-V11 | Strategy report records complete costs and milestone times at normalized 1×. A 3–5 hour miss is visible balance evidence, not permission to bypass costs or nerf offline earnings. |
| M02-V12 | G2 gates: at sufficient level/coins, skipped row-4 IDs still fail; sequential 25→32 purchases obey unchanged level/cost bands and total 34,500; any failure preserves prefix/wallet. Growth/profit tier entry succeeds with one preceding rank, no full-tier ranking requirement is imposed, and point/node costs and automation chain match FRS. |
| M02-V13 | G3: one boost/project with ceil(C/2) charge and ceil(remaining/2); no-time-saved/duplicate rejection. W=1,000/S=200/R=100/F=100 gives M=600/C=150 once across all protection groups; equal default priorities, fixed-before-Smart/tied mode order, no unauthorized fallback, free seeds below R, eligible-subset atomic batches and explicit reset/rearm all match the source. |
| M02-V14 | G5 scope/pacing: undefined/deferred Seed Efficiency/Research Facilities/Growth Booster IDs absent/rejected uncharged; required Irrigation/Improved Soil, four fertilizer choices and approved research boost remain covered. Full-cost/no-contract strategy traces contain real decisions/costs and separate economic output from unobserved human engagement. |
| M02-V15 | Audit A1: AV-003 profile-context lookup; AV-004-02–05; AV-005-01–05; AV-006-01–04; AV-007-01/04 contract fixtures. Test exact shared quote/replan/equipment behavior; advanced group command/UI execution remains unavailable until M05. |

## Acceptance criteria and definition of done

- M01 regressions and M02-V01–V15 pass; unresolved balance targets are documented with evidence and owner.
- Skills/equipment/research/expansions/paid reset are command-driven and atomic; all planted economics remain immutable.
- Basic automation repeatedly harvests/replants; seed reservations precede optional spending; fixed fertilizer works without Smart; inheritance and all three Smart modes are demonstrated.
- Solver behavior/guarantees are documented honestly; shared funds never overspent and no unauthorized crop/fertilizer replacement occurs.
- Typed transaction/schema handoff is sufficient for M03 including clock-independent timestamps, consumed cycles, expenses, stats and future claim fields.
- No saves, offline crash safety or final graphical UI is claimed yet. Advanced M05 functions remain explicitly tracked rather than silently omitted.

## Expected deliverables

Future outputs: typed economy/skills/research/automation services and commands; versioned content/skill graph; exact oracle and production optimizer; coherent batch/retry tests; economic transaction schema; progression scenario reports; D-04/06–12/20/25 decisions; M03 persistence handoff and M05 advanced-feature backlog. Current output is this plan only.

## Audit A1 task and validation corrections

These are required constraints on existing tasks, with their original dependency order retained. Source contracts: TRS §§20.1–20.7 (AUD-R-001–007), FRS FR-AUD-001–007; exact test oracles are TRS §15.1 AV-001–009. Historical approval notes describe their original scope; the explicitly applied A1 additions define the current selected clarification. No test is marked passed by this document update.

| Issue / selected decision | Existing task / validation target | Required correction | Exact acceptance extension |
|---|---|---|---|
| AUD-003 / AUD-DEC-003 B | T01/T04/T05; V01/V05/V12 | Skills/quotes/reset use the profile rules, not global latest definitions. | AV-003-02/03; rank/prerequisite/reset fixtures; M02-V15 |
| AUD-004 / AUD-DEC-004 B | T02/T05/T07/T08/T10; V05/V06/V13 | Implement shared quote/semantic validators and accepted-time boost result; bind recurring plans. | AV-004-02–05; M02-V15 |
| AUD-005 / AUD-DEC-005 A | T11/T12/T14/T15; V04/V13 | Implement/exhaustively validate seed/fixed replan, fallback, bounds and coherent final proposal. | AV-005-01–05; existing Smart oracle regressions; M02-V15 |
| AUD-006 / AUD-DEC-006 A | T01/T06/T17; V09/V14 | Use selected 11-row guard manifest and pay all chosen upgrade costs in pacing traces. | AV-006-01–04; actual strategy results later; M02-V15 |
| AUD-007 / AUD-DEC-007 B | T10/T16/T18 | Reserve complete group/authorization command and state contracts with inactive advanced defaults. | AV-007-01/04 contract fixtures; intermediate commands unavailable; M02-V15 |
| AUD-008 / AUD-DEC-008 A | T01 L64 | Distinguish historical pre-C1 tail reservation from present selected option B; equipment guards follow AUD-DEC-006. | AV-008-01; M02-V15 |

**Additional exit condition:** complete the task-level A1 obligations above and M02-V15 at the stage owned by this milestone. Later-runtime cases may be specified with fakes now only where the staging explicitly permits it; they remain required for their real integration milestone. No new mandatory gameplay family, final balance value or earlier native/UI implementation follows from A1.
