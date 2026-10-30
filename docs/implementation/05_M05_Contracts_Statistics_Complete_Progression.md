# M05 — Contracts, statistics and complete progression

> **Audit corrections A1 — 2026-10-28:** Apply the approved contracts in [TRS §§15.1/20](../architecture/IdleFarmer_Technical_v1.5.md), [FRS audit requirements](../requirements/IdleFarmer_Functional_v1.0.md) and the [Audit Decision Register](../decisions/Audit_Decision_Register.md). The task crosswalk below is normative for the listed existing tasks; it does not add gameplay or implement later-stage features. [Correction changelog](../audit/round_01/Audit_Correction_Changelog.md) preserves before/after references. Existing provisional values and Open/Deferred evidence remain unchanged.

**Approved closeout C3 — 2026-10-28:** Owner: “DEC-023 - agreed with option A.” **Clean illustrated** is the selected visual direction: crisp silhouettes, restrained outlines, simple smooth shading and natural greens/browns/golden Wheat, guided by column A of the [planning comparison](../decisions/visuals/Art_Direction_Comparison_v1.png). Style selection is settled; M04 specifies and validates the production art bible/sample pipeline, M05 audits catalog consistency and M06 qualifies actual assets/audio/performance. The comparison is not a production sprite set or a change to the approved eight-column farm geometry. No game implementation or empirical pass is implied.

Priority P1 · Planning only · Depends on M01–M04 · Next: M06

**Approved foundation update — 2026-10-26:** Apply [Decision Register Group 1](../decisions/Decision_Register.md) / TRS G1 to all contracts, reports and forecasts. Replay identities/epochs, bounded cache semantics, phase order, interval ledger and finite-limit recovery are approved; no contract offer/reward, statistics-window, utilization, progression-tail or advanced-automation proposal is approved by Group 1.

**Approved G2 update — 2026-10-27:** Apply [Decision Register Group 2](../decisions/Decision_Register.md) and TRS clarification G2: zero/Empty start, one-point/minimum-rank skill prerequisites, fixed eight-column 8×3 starting layout and next-ID-only fourth-row 25→32 unlocking. The through-30 XP table is approved provisional development data; C1 now defines beyond level 30; genuinely unconfirmed policies/evidence remain pending. G1 safety contracts remain binding; no game implementation is claimed.

**Approved G3 update — 2026-10-27:** Apply [Decision Register Group 3](../decisions/Decision_Register.md) / TRS G3 for shared budgets/cap, research boost, optimizer/priority, lifecycle/batches and staged advanced features (DEC-007/009/010/011/012/025). Numeric defaults remain provisional for balance; G4 policy is subsequently approved below; partial selections/evidence remain pending. Earlier pending-G3 notes are superseded by these synchronized source contracts; no implementation/evidence is claimed.

**Approved G4 update — 2026-10-27:** Project owner: “Group4 approved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G4 binds DEC-015/017/018/021/022 durability/cadences, completed-minute statistics, session/productive utilization, profile-owned settings and end-M03 minimal browser probe. DEC-014 measurement-first policy and DEC-019 authored lifecycle/schema are approved; provider/API evidence remains pending; C2 now approves the exact twelve contract rows/guards/rewards. All earlier pending-G4 statements are updated below; no application tests or implementation are claimed.

**Approved G5 update — 2026-10-27:** Project owner: “group 5 aapproved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G5 approves DEC-023 qualification/sample-review policy (named hardware/art still Open), defers DEC-008 Seed Efficiency/Research Facilities/Growth Booster, and approves DEC-024 costed economy plus normal-speed human evidence with the provisional five-real-minute/diary indicator. Preserve v1 research acceleration; no new balance values, hardware, assets or empirical results are inferred.

**Approved G6 update — 2026-10-27:** [Decision Register](../decisions/Decision_Register.md) / TRS G6 records “Group 6 approved as recommended”: standalone versioned Windows ZIP/executable, required dependencies/licenses/checksums and per-user save preservation. Installer/signing optional by separate selection; Steam/cloud/storefront integration deferred beyond v1. This changes future delivery requirements, not the current milestone's game scope or implementation status.

**Approved closeout C1 — 2026-10-27:** Owner: “DEC-001 - approved, DEC-002 - use option B.” [Decision Register](../decisions/Decision_Register.md) / TRS C1 selects standard Godot 4.7.2/matching templates, GUT v9.7.1, godot-sqlite v4.9 evaluation/reportedSQLite 3.51.0, Compatibility/Windows x86_64. Actual artifacts/hashes/licenses/integration remain unverified. Increasing option B beyond level 30 is approved provisional data: first step57,500; subsequent steps ceil(previous×110/100), one point/level with retained surplus and no arbitrary cap. All existing levels 1–30 values remain unchanged; no code/test result is claimed.

**Approved closeout C2 — synchronized 2026-10-28:** Owner: “Closeout B option A - approved.” [Decision Register](../decisions/Decision_Register.md) / TRS C2 makes FRS §§10.2–10.4's twelve authored offers, exact guards/predicates and frozen provisional rewards binding. Existing optional/manual/three-slot/one-time/offline lifecycle remains intact. This settles DEC-019 content; actual game implementation and balance evidence remain future work.

[Master roadmap / D-xx decisions](00_IdleFarmer_Master_Roadmap.md) · [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md) · [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md)

## Objectives and scope

Integrate the remaining first-release systems: optional Contract Board/manual claims, full Level-1 Statistics & Profitability panel, copy-isolated next-hour forecasts, higher-tier content, farm presets, enhanced budget management and explicitly approved crop rotation. Reconcile full economy/progression with active-only and mixed/offline strategies.

Preserve M03 historical accounting and migrations rather than replacing or discarding earlier saves. Contracts never gate crops/research/skills/expansion and never auto-claim. Forecasts use the same engine in an isolated clone, not a separate rate calculator. Do not invent new crop systems, mandatory tasks or contract currencies to extend engagement.

Primary references: FRS §§4–12,15–16; TRS §§3–6,8–11,14–18; T-011,022,025 and contract-complete T-018–020/029.

## Prerequisites and dependencies

- M04 playable shell and M03 durable accounting/schema/catch-up validated. Existing debug/normal profile separation and post-commit event routing remain intact.
- M02 skill/config schemas define unlocks: presets 12, enhanced budgets 15, rotation 20, with required predecessor nodes.
- M05-T01 validates approved C2 exact definitions within the settled lifecycle; M05-T02 audits the explicit DEC-008 deferral and required catalog; T13 validates approved C1 option B progression and final balance before claiming feature completion.
- D-17/18 time ranges/normalization, D-19 contract design and D-25 future-cycle application semantics recorded as decisions. Numeric content remains provisional until tested/approved.

## Required classes and suggested file structure

Runtime/forecast/query records are typed `RefCounted`; definitions extend `Resource`; UI controllers extend `Control`/`Node`.

| Suggested path | Classes / role |
|---|---|
| `core/contracts/{contract_definition,contract_state,contract_system,objective_evaluator}.gd` | `ContractDefinition`, `ContractState`, `ContractSystem`, `ObjectiveEvaluator` |
| `core/simulation/commands/` | Typed accept/claim/abandon, preset CRUD/apply, group/priority/budget and rotation commands |
| `core/statistics/{statistics_system,statistics_query,statistics_report,forecast_service,forecast_report,retention_policy}.gd` | Complete `StatisticsSystem`, `StatisticsQuery`, `StatisticsReport`, `ForecastService`, `ForecastReport`, `RetentionPolicy` |
| `core/farming/{farm_preset,preset_system,rotation_policy,advanced_budget_policy}.gd` | `FarmPreset`, `PresetSystem`, `RotationPolicy`, `AdvancedBudgetPolicy` |
| `scenes/ui/{contracts,statistics,presets,advanced_automation}.tscn`, `presentation/` | `ContractBoardPanel`, `StatisticsPanel`, `PresetsPanel`, `AdvancedAutomationPanel`, chart views |
| `data/{contracts,crops,research,skills,upgrades,levels}/` | Full reviewed content, predicates, rewards and complete curve |
| `persistence/migrations/`, `tests/fixtures/saves/` | Migration from M03/M04 plus active-contract/advanced-rule fixtures |
| `tests/{unit,simulation,recovery,balancing,integration}/` | Contract replay, forecast isolation, rollup/reference queries, progression strategy scenarios |

No forecast instance receives live repository/audio/UI callbacks. UI reports must indicate actual/forecast/steady-state explicitly and separate operating profit from wallet cash flow.

## Detailed implementation tasks

### M05-T01 — Validate approved authored contract definitions

Dependencies: M01–M04. Import exactly the twelve approved C2 rows and FRS §10.3 predicates as versioned typed ContractDefinition content. Preserve fixed targets/minimum levels/coin-XP rewards and named-crop/AutoHarvest eligibility; design-reference rows are rationale only, never runtime repricing. Validate all four families and stable IDs against independent fixtures; accepted snapshots and one-time lifecycle are unchanged. Deliver canonical data/version manifest and predicate fixtures; do not ask to reapprove the selected catalog. References: FRS §§10.1–10.4; TRS §§3.5,5.1,8–10; DEC-019/C2.

**Approved G4 constraints:** Implement approved authored one-time lifecycle, provisional level 7/three accepted-unclaimed slots and future committed harvest semantics; C2 now supplies approved quantities/challenges/rewards; validate them without random generation/expiry/repeat rewards. DEC-019 is Approved for initial provisional data; retuning still needs recorded review.

**Approved C2 constraints:** Load exactly FRS §10.2 CON-Q01–Q03/M01–M03/R01–R03/A01–A03 with canonical targets/minimum levels/frozen coins/XP. Typed definitions encode named-crop unlock/AutoHarvest ownership and predicate family. Validate unique IDs/content versions and targets/rewards against independent fixtures; all twelve are approved provisional data, not another pending selection.

### M05-T02 — Audit complete crop/research/equipment catalog

**Applied A1 task constraints:** AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T01. Verify all 15 source crops, 14 research projects, stage assets and skill/upgrades gate references. Audit stage artwork against the approved Clean illustrated direction and M04's production art bible; report inconsistent batches without reopening the selected style. Apply settled DEC-008/G5: Seed Efficiency, Research Facilities and Growth Booster are Deferred/excluded from v1 and cannot appear as saleable placeholders. A later inclusion needs a new post-playtest scoped proposal, approved complete definitions and impact/migration/test review. Validate irrigation/soil totals, source prices and no earlier crop irrelevant for every goal; changes stay versioned proposals until approved. Deliver catalog coverage and balance decision record. References: FRS §§4,6,8,16; D-08.

**Approved G2 constraints:** Catalog audits include FR-FARM-08 sequential unlock eligibility and DEC-004's approved one-point/edge graph; they do not redesign layout/order or rank costs as open balance assumptions.

**Approved G5 constraints:** DEC-008 disposition is settled: Seed Efficiency/Research Facilities/Growth Booster are Deferred with trigger post-playtest scoped content proposal and new explicit approval. Audit their absence and required Irrigation/Improved Soil/fertilizer/research-boost coverage; no new inclusion decision or invented table blocks M05.

### M05-T03 — Implement contract acceptance and progress

Dependencies: T01,T02. Add manual AcceptContract guarded by level/slot/offer state. Consume committed harvest semantics inside the same authoritative working batch as harvest, not via a UI listener or second non-atomic save. Update quantities/mixed/revenue/challenge progress exactly once per cycle/event. Completion sets claimable only; no wallet/XP reward yet. Deliver predicate tests for eligible/ineligible crop, manual/auto harvest and acceptance timestamps. References: FRS §10; TRS §§4.2,5,9.2.

**Approved G1 constraints:** Update accepted-contract progress within the approved harvest→XP/contracts/accounting phase, before seed spending and the single durable outcome. G4 lifecycle is approved; C2 now defines exact authored predicates/targets/rewards as approved provisional data.

**Approved G4 constraints:** Accept snapshots definition/reward and a fresh instance only for eligible unclaimed offer; only later committed harvest events count, including offline. Use named crops/gross crop income/actual auto-harvest metadata; completion remains claimable without auto-reward and still occupies a slot.

**Approved C2 constraints:** Accept only at Board/row level with slot/unclaimed-offer and all named crop unlock guards; A offers require owned AutoHarvest, not AutoReplant. Revenue rows do not require reference-crop research. Evaluate after acceptance in total engine order; same-timestamp later manual harvest can count, preceding due harvest cannot. One per distinct cycle, mixed AND, actual modified gross excluding claims, actual auto-origin; one event can advance every independently qualifying accepted instance once.

### M05-T04 — Implement manual claim and abandonment

**Applied A1 task constraints:** AUD-DEC-001 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T03. Claim only completed accepted contracts; atomically set claimed identity and credit coin/XP through existing progression/accounting path. Record contract rewards separately from crop income; gained XP can award unspent points. Implement approved confirmed abandonment with discarded progress/no refund/reward and fresh-instance zero-progress reacceptance of unclaimed offers. Reject duplicate/stale claim/accept/abandon commands with no side effects. Deliver exact wallet/XP/claim-state tests. References: FRS §§5.1,10–11,13; TRS §§4.1,9.2; T-011/020.

**Approved G1 constraints:** DEC-016 requires a currently accepted completed unclaimed contract instance; unknown/closed IDs or retired-epoch commands cannot reconstruct an offer or pay again. Preserve approved command high-water even if its full response is evicted; DEC-019/G4 now approves the explicit abandonment/reacceptance/one-time eligibility contract.

**Approved G4 constraints:** Confirm abandon, discard progress without reward/refund, permit unclaimed abandoned offer reacceptance with new instance/zero progress. Persist claimed-offer eligibility so a claimed one-time offer never pays twice within the retained timeline, including cache/history pruning and intact-primary recovery. Older-backup recovery restores the paired old wallet/claim state; a lost-branch reward is rolled back with its claim flag (AUD-DEC-001 B).

**Approved C2 constraints:** Manual claim pays exactly the accepted frozen C2 coins/XP once through C1 progression and records offer closure atomically; no reprice from current upgrades/reference formula. Abandon/reaccept follows existing zero-progress/new-instance policy; claim credits never advance revenue objectives.

### M05-T05 — Add Contract Board and offline report integration

Dependencies: T04. Build optional Board with available/active/completed/claimed states, clear objective/reward previews and explicit accept/claim controls. Show closed-time objective progress in offline report without auto-claiming. Basic farming/research/skills/plot purchases remain accessible with zero contracts accepted. Deliver mouse workflow and no-contract full-progression scenario. References: FRS §§2,9–10; TRS §11.1.

**Approved G4 constraints:** Show completed-unclaimed slots explicitly and offer manual claim/confirmed abandonment with consequences. Exact approved authored objectives/rewards are prerequisites; farming remains fully usable without contracts.

**Approved C2 constraints:** Board displays all approved authored definitions, minimum-level/target-unlock/AutoHarvest prerequisites, goals and frozen rewards clearly. Accepted/completed-unclaimed occupy the existing three slots; no claim/refresh/currency/inventory/timer or farming authorization is invented.

### M05-T06 — Extend save/catch-up/recovery for real contracts

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T04,T05. Migrate prior saves and include full offers/progress/claim IDs/objective snapshots in deep copies, validation and checkpoints. Make aggregation break or accurately account at contract threshold/predicate transitions. Inject crash around combined harvest-progress and claim-reward commits, including committed response lost and restart retry. Deliver actual T-011 and contract-specific T-018–020 evidence; generic M03 identity tests alone are insufficient. References: FRS §§9–10,13; TRS §§8–9; T-011/018–020/026.

**Approved G1 constraints:** Extend real contract crash tests to pruned cached responses, retired writer epochs, crash before first epoch success and backup-restored new epochs. Preserve profile/replay/anchor/interval metadata with the combined progress/reward/accounting commit.

**Approved G3 constraints:** Contract storage tests preserve G3 budget/auth/cursor/boost records in the same full checkpoint; no contract claim triggers unapproved rearm/new research/boost purchases. DEC-019/G4 lifecycle is approved; C2 now supplies approved exact objectives/challenges/rewards; final retuning needs separate review.

**Approved G4 constraints:** Crash/recovery covers acceptance snapshot, completed-unclaimed slot, abandon/reaccept fresh instance, one-time claimed offer and post-acceptance harvest sequence; keep all eligibility with economic/accounting state. Generic storage tests alone do not satisfy T-011.

**Approved C2 constraints:** Real crash/replay/backup corpus covers all four C2 families, acceptance boundary including same-time order, mixed/concurrent progress and frozen rewards across definition changes. Preserve claimed-offer protection and C1 XP/points; generic M03 protocol tests alone do not satisfy T-011.

### M05-T07 — Complete statistics query and retention semantics

**Applied A1 task constraints:** AUD-DEC-001 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02,T06. Implement approved D-17/18 last 60/1440 completed simulated-minute windows/as-of labels, separate live partial totals and post-catch-up session/lifetime mapping. Use initial retention of minute aggregates for 48 simulated hours, hourly for 90 simulated days and lifetime crop/plot totals. Do not substitute arbitrary-second windows or an alternative retention policy without an amended decision. Roll up/prune transaction detail safely, retaining cycle-attributed costs for unharvested crops and dedupe guarantees. Deliver migration/backfill and query oracle tests. References: FRS §11.1–11.3; TRS §10; T-025; D-16/17/18.

**Approved G1 constraints:** Pruning statistical detail or old closed contract records must never reopen command or claim eligibility. Retain the approved replay high-water/current-epoch protocol and needed unharvested cycle attribution. Apply approved DEC-017/018 windows, initial retention and utilization; later numeric tuning needs recorded review.

**Approved G3 constraints:** Retain G3 accepted authorization/current-plan/cursor and active paid-cycle attribution while pruning history. This does not finalize now-approved DEC-017/018 window/session/utilization definitions under G4.

**Approved G4 constraints:** Use exactly last 60/1440 completed simulated-minute buckets with as-of label and separate partial/live totals. Initial retention 48 simulated hours/90 simulated days, wall edits never rekey history; rolling/session/retention boundaries and active-cycle attribution use independent oracle tests.

### M05-T08 — Implement full actual reports and trends

Dependencies: T07. Query active/empty/stalled/auto counts, utilization, harvests/gross/seed/fertilizer/XP, completed-cycle profit, categorized cash flow, idle/stall reasons and per-crop/plot rates. Use elapsed simulated 1× time for production normalization and label real/session/debug segments separately; guard zero-duration denominators. Add bounded trend series for income/profit/expenses/XP/counts; contract rewards/research/equipment/reset/expansion remain separate. Deliver numeric fixtures reconciled to balance changes and lifetime totals. References: FRS §11; TRS §10; T-025.

**Approved G4 constraints:** Growing-time utilization differs from instantaneous Growing+Ready occupancy. Integrate purchased capacity; Empty total includes Stalled subset once; session starts after committed startup catch-up and uses simulated production denominators with zero guards.

### M05-T09 — Implement copy-isolated next-hour forecast

**Applied A1 task constraints:** AUD-DEC-005 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T06–T08. Clone all mutable state, scheduler, content view and relevant policies; advance same engine one simulated hour at 1× using isolated accounting and sink repository, never live writes/notifications. Include growth progress, funds, fertilizer modes, stalls, research completion and accepted-contract progress; no manual reward claims/new decisions invented. Return crop-income/expenses/net/XP/stalls with explicit assumptions. If caching, key on authoritative revision/config/content and invalidate after changes. Deliver source digest/reference identity tests plus reference advance equivalence. References: FRS §11.3; TRS §10; T-022.

**Approved G1 constraints:** Use the engine directly on a deep clone with isolated repository/time/ID inputs. Forecast/reference startup must not allocate or persist a fresh live writer epoch, mutate live replay counters/cache/interval ledger, emit UI/audio, or write live statistics. Arithmetic/phase order match approved TRS §§4.1–4.4.

**Approved G3 constraints:** Forecast uses cloned shared R/p/toggle, one-C-per-logical-batch mode order, valid armed loops, successful-plant cursor and boost-used schedule. It never starts/rearms a loop or buys a research boost on its own and never mutates live records.

**Approved G4 constraints:** Advance only the isolated copy one simulated hour at 1×, permitting copy-only research/contract transitions but no live settings/session/repository/ID/accounting mutation. Preserve approved bucket labels and current plan/authorization.

**Approved C2 constraints:** Forecast progresses only cloned accepted C2 snapshots, with actual qualifying origin, mixed/gross/boundary rules; no live eligibility/progress/session mutation, invented acceptance or automatic claim. C1 XP may change only on the clone's legitimately modeled rewards; no manual claim is fabricated.

### M05-T10 — Implement Level-1 Statistics & Profitability panel

Dependencies: T08,T09. Replace M04 route with dedicated panel reachable from level 1, unobtrusive to farm. Provide range selector, crop/plot breakdowns and trend charts. Label Historical actuals, Next-hour forecast and optional Steady-state/hour distinctly; never present theoretical steady-state as actual. Explain completed-cycle versus cash-flow differences in concise UI help. Display forecast age/state revision and computation status without freezing main input. Deliver golden-number UI tests for normal, offline and debug profiles. References: FR-UI-01; FRS §11; TRS §11.1.

**Approved G4 constraints:** Hour/day controls show completed-minute as-of time, separate current live totals and simulated-period labels in debug. Explain productive utilization versus occupied plots, separate offline startup report/current session and crop income/claim rewards.

### M05-T11 — Implement presets and advanced budget management

**Applied A1 task constraints:** AUD-DEC-004 B, AUD-DEC-005 A, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T06,T10. Implement approved level-12 preset CRUD/apply and level-15 custom priorities/same-R automated-seed toggle under capability checks. Farm R/p/toggle remain shared controls; plot-group presets cannot smuggle a global budget override or copy wallet/XP/research/unlocks. Preview future settings and explicit ApplyAndStart purchases; preserve current snapshots/plot prefix. Default seed toggle Off; free seeds remain eligible below R. Test inherited false/zero, inactive respec/rebuy, no unauthorized rearm and insufficient funds. References: FRS §§5.4,7,9.2; TRS §§3.5,6,16; approved DEC-010/011/012/025.

**Approved G2 constraints:** Presets/groups/advanced budgets under approved G3 staging/lifecycle must preserve permanent purchased prefix and fixed plot IDs. Applying settings cannot unlock skipped plots or add a crop to the Locked suffix.

### M05-T12 — Implement approved crop rotation and advanced UX

**Applied A1 task constraints:** AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T11. Implement level-20 explicitly approved crop/configuration sequences and persistent cursor/plan IDs. Advance only after successful planting; affordability/eligibility failure retains cursor/current authorized entry and stalls, never silently skips/replaces. Apply future-only presets/rotation, explicit start/rearm and existing-loop reopen semantics. Validate per-cycle seed/fallback budgets and mixed-mode priority against locked-slot/skill gates; preserve ID prefix/snapshots through save and aggregate breaks. References: FRS §§5.4,7,9.2; TRS §§6,8; approved DEC-025/G3.

**R2-C1 fixture correction:** Existing M05-V08/V11/V12 and M06-V13 must use level ≥22, completed Coffee and Rice research, all owned Crop Rotation prerequisites and an explicitly authorized Coffee/Rice sequence for the positive nominal case. The level-20 rotation-node gate does not bypass Rice's level-22 crop/research guards. In the separate level-20/Rice negative planting case, a direct manual request rejects the ineligible planting (a batch skips that member), while an automated current-entry attempt stalls uncharged; the cursor/current entry remain unchanged and no crop substitution is inferred. Insufficient funds likewise never advances the cursor. Follow the [dated DVS-013 erratum](../audit/round_01/Design_Validation_Scenarios.md#r2-c1-dvs-013-fixture-erratum--2026-10-29), which supersedes only the old fixture premise and adds no gameplay rule. No executable result is claimed.

**Approved G2 constraints:** Approved rotations reference stable existing unlocked plot IDs; arbitrary planted/Empty patterns remain valid. Rotation cannot acquire a later row-4 plot to work around an order/eligibility stall.

### M05-T13 — Validate approved progression and final balance

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T02,T12. Validate source levels 1–30 plus approved C1 increasing option B and one-point/retained-surplus policy. Check all released crop/research/equipment gates and full no-softlock progression. Final numerical retuning requires an explicit recorded balance/content revision preserving snapshots and earned XP; do not reselect the already approved continuation or infer a cap/linear fallback. Deliver complete manifest and production-boundary fixtures. References: FRS §§5.1,5.1.1,12,16; TRS §§3.2,5,14,17; DEC-002/C1.

**Approved G1 constraints:** DEC-026 recovery is not permission to clamp ordinary XP or silently treat level 30 as a cap. C1 resolves DEC-002 continuation; future balance changes remain pending; the through-30 development table and DEC-004 rank/prerequisite policy are approved under G2, while numerical effect/cap balancing remains provisional.

**Approved G2 constraints:** The through-30 curve is approved for development but remains numerically provisional; C1 now approves option B beyond level 30 for full production scenarios. Preserve earned XP and source level gates; do not misuse DEC-026 representation errors as a continuation policy.

**Approved G3 constraints:** G3 boost/budget/optimizer/lifecycle choices are fixed initial policies; only proposed numeric retuning and genuinely unconfirmed decisions require further approval. Exact solver performance still needs evidence; no silent approximation or beyond-30 XP cap.

**Approved G5 constraints:** Any final numeric retuning still needs its recorded review, but DEC-008 scope deferral and DEC-024 evidence method are settled. Target misses cannot silently add optional families, change earned XP or alter existing planted snapshots.

**Approved C1 constraints:** Implement/validate settled option B progression from FRS §5.1.1; final balance changes require a new recorded decision, not another continuation choice. No new crop/skill tier, prestige reward or implicit XP cap; preserve surplus points and snapshots.

### M05-T14 — Run full economic strategy and content validation

**Applied A1 task constraints:** AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T05,T06,T10–T13. Run focused automation, coin/XP builds, low-reserve/high-reserve, short/long crop, active-only and mixed/offline strategies with all real research/seed/fertilizer/upgrade costs. Include no-contract strategy and late-game choices; report crop dominance, fertilizer incremental gains/ROI, time to automation and sequence of useful decisions after it. Headless simulations measure production/economics, not 48 hours of human engagement. Deliver local reports and proposed balance changes, never hidden offline cap or mandatory chores. References: FRS §§1,6–7,12; TRS §14; D-24.

**Approved G2 constraints:** Use zero/Empty initial state, full 30-row development curve, rank≥1 branch prerequisites and sequential expansion with unchanged prices in all real-cost scenarios. Report any pacing miss honestly rather than adding starting money or changing the approved rules silently.

**Approved G3 constraints:** Strategies explicitly authorize boosts/start/rearm and pay real C-based prices. Compare rate/ROI/protection modes under correct fixed/priority order; do not pool all offline income into one fertilizer budget or claim greedy Capital Efficiency is globally optimal.

**Approved G5 constraints:** Use approved complete-cost automated strategy suite and independent no-contract path. Identify economics/dominance/content gaps and propose any versioned retuning for approval; human diaries/normal-speed evidence, not headless production, establish active engagement.

**Approved C1 constraints:** Pacing strategies use selected increasing tail and actual rewards/costs; no automatic conversion to linear/capped progression to meet human engagement targets. Report deficits for explicit retuning review.

**Approved C2 constraints:** Run all twelve frozen C2 definitions in costed progression plus an independent full no-contract strategy. Report bonus/pacing/engagement findings honestly; any reward/availability retuning needs a new versioned owner decision preserving accepted snapshots.

### M05-T15 — Verify integrated reports and advanced persistence

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B, AUD-DEC-003 B, AUD-DEC-005 A, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M05-V17 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T14. Exercise save/reopen/clone/forecast with contracts, presets, custom priorities, reserve controls, rotation and full content. Compare 8-hour/7-day/30-day aggregate accounting to reference path, including contract completion and rotation breaks. Ensure forecast cannot mutate live repository, IDs, stats or dedupe state. Deliver integrated regression evidence and M06 save corpus. References: TRS §§8–10,15; T-011/012/021/022/025/026/029.

**Approved G1 constraints:** Audit replay/interval metadata in save/clone/forecast checks alongside economy. Use fixed fixture writer tokens for comparable scenarios and separately test production epoch retirement; safe representable arithmetic must succeed, true limit errors preserve the prior full checkpoint.

**Approved G2 constraints:** Save/forecast/reset fixtures retain eight-column coordinates, 1..N unlock prefix and correct points/XP. Forecast never invents future expansion purchases; use C1 increasing option B whenever a scenario crosses30.

**Approved G3 constraints:** Use complete G3 round-trip/clone/recovery fixtures: farm-only budgets, accepted fallback/armed versus inactive loops, rotation cursor and one-boost flag. All legitimate running loops resume without a fresh per-session prompt.

**Approved G4 constraints:** Integrated fixtures retain settings/profile ownership, acceptance/claim eligibility, bucket/live totals/state-time across save/forecast/recovery; no reacceptance can bypass a claimed offer or retroactively count pre-acceptance harvests.

**Approved C1 constraints:** Save/clone/forecast fixtures cross31/32/35 under the same exact recurrence; original/live XP, points and stored events remain untouched by isolated forecasts. Preserve all G1–G6 invariants.

**Approved C2 constraints:** Round-trip/clone/recover every C2 definition/acceptance/progress/frozen-reward/one-time state. Replayed harvest/claim cannot advance/pay twice; closed-time aggregation matches independent per-event evaluation for all families and concurrent instances.

### M05-T16 — Close feature-complete gate

Dependencies: T15. Review every FRS §15 item against real implementation, mark M06-only evidence separately and close mandatory gameplay decisions. Produce content/version manifest, migration notes, contract/statistics screenshots, API changes and known issues. DEC-008 optional families are explicitly Deferred; required research acceleration/Smart modes/crop roster cannot be quietly removed. Deliver M06 acceptance inventory and human playtest protocol. References: FRS §§14–16; TRS §§16 M05,18.

**Approved G1 constraints:** Carry forward approved G1 source contracts and identify only genuinely pending choices. Report no tests or game features as completed on the basis of documentation approval.

**Approved G2 constraints:** Handoff records G2 approvals as completed documentation decisions; only final balance, actual artifact verification and genuinely pending provider/hardware/art verification remains open; C2 authored content is approved. No implementation or playtest evidence follows from approval itself.

**Approved G4 constraints:** G4 lifecycle/statistics/settings/probe policy is settled. C2 supplies exact authored contract content; require actual implementation evidence; provider/API evidence, actual artifact verification, hardware/art and actual artifact/provider verification remain named gates; C1 pins/continuation are settled.

**Approved G5 constraints:** Before handoff define varied normal-speed human sample/play-style/diary protocol for M06, actual participant/evidence reporting and provisional five-real-minute meaningful-input indicator plus planning/reading notes. Report shortages honestly; protocol approval is not a claim that ~48 hours were observed. Deferred content is not a missing mandatory v1 feature.

**Approved C1 constraints:** DEC-002 continuation is resolved; only final balance/empirical qualification and genuine artifact/provider/hardware/art verification remains pending; C2 authored content is approved. Do not treat selected names as verified binaries.

**Approved C2 constraints:** Exact C2 content approval is complete; verify actual definition/predicate/UI/claim/crash evidence and final balance, rather than asking to approve the same table again. Artifact/provider/hardware/art facts remain separately pending.

## Automated tests and validation procedures

Use exact ledgers and reference event simulation as independent oracles. All fixtures include source content versions and real costs. Simulations that bypass early unlocks are explicitly isolated formula tests, never progression evidence.

| ID | Procedure / expected outcome |
|---|---|
| M05-V01 | Approved provisional level-7 Board/three accepted-unclaimed slots, completed-unclaimed included; accept only valid offer, each crop/mixed/revenue/challenge predicate exact; no progress from pre-acceptance harvests or visual effects. |
| M05-V02 | T-011: accepted contract progresses through closed-time harvests; reopen completed but unclaimed; manual claim pays once; second claim/restart retry pays zero. No expiry. |
| M05-V03 | Crash before/after combined harvest+contract progress and claim commits; old or new full state only, coin/XP/stat categories consistent. M03/M04 save migration preserves farm. |
| M05-V04 | T-025 at reporting boundary: seed/fertilizer paid outside interval, harvest inside; operating profit includes cycle costs, cash flow reflects actual payment timestamp. Include upgrades/research/reset/expansion/contract claims as separate categories. |
| M05-V05 | Query minute/hour boundaries, 48-hour/90-day retention transitions, zero-length session, expansion changing unlocked plot-time denominator and offline buckets. No double counting at rollup. |
| M05-V06 | T-022: hash and deep mutable-reference audit before/after forecast; live wallet/XP/plots/research/contracts/stats/IDs/dedupe/repository untouched. Forecast equals isolated one-hour reference advance. |
| M05-V07 | Statistics available at level 1; actual/forecast labels, 1× normalized rates under debug, crop/plot/stall breakdowns and trends match fixtures. |
| M05-V08 | Presets/priority/reserve/rotation gates at 12/15/20, explicit authorization and future-cycle-only changes. Empty/false/zero inheritance correct; no unapproved crop/fertilizer after failed rotation planting. |
| M05-V09 | All 15 crops/14 projects/75 art stages and required skill/equipment content valid; beyond-30 policy explicit and overflow-safe; no new physical inventory or currency. |
| M05-V10 | Full no-contract progression remains possible. Strategy suite records all costs and 3–5 hour target evidence; additional 48-hour target explicitly awaits human active-engagement validation in M06. |
| M05-V11 | 8-hour/7-day/30-day fixtures with accepted contracts and rotation match reference totals; optimized aggregation stops at all new policy/predicate boundaries; memory/history bounded. |
| M05-V12 | G3 advanced integration: same shared C across priority groups, farm-only wallet fields, free seeds under advanced reserve, future-only presets, no unlock bypass, successful-plant-only cursor and explicit post-respec rearm. Forecast/offline/save preserve authorized state and boost-used flag without live writes or automatic purchases. |
| M05-V13 | G4 contract lifecycle: three accepted/unclaimed slots including completed; only post-acceptance actual harvests advance snapshots, claims excluded from gross-crop targets. Confirmed abandon discards/no refund; reaccept new instance starts zero; claimed offers never pay again after intact-primary crash/pruning/recovery; an older backup coherently rolls back lost credit/claim flags and new full dynamic IDs use a fresh namespace. C2 authored content is now approved; actual predicate/reward evidence remains required. |
| M05-V14 | G4 reports: completed-minute/as-of versus live totals, debug simulated-hour normalization, productive Growing-only utilization versus instantaneous occupancy, disjoint idle/stalled time and purchase-time capacity. Fresh session excludes startup catch-up; copy-only forecasts leave settings/session/claims unchanged. |
| M05-V15 | G5 content/evidence handoff: three optional families remain Deferred; full-cost strategies exclude them and preserve no-contract progression. Varied normal-speed sample/play-style/diary protocol exists before M05 closure, with actual future sample reporting and clear automated-economy versus human-engagement acceptance. |
| M05-V16 | C2 catalog: all twelve exact IDs/levels/targets/frozen coin-XP rewards; named-crop research and AutoHarvest-only acceptance; one-cycle and mixed AND, same-time ordered post-acceptance, actual auto/manual origin, actual gross excluding claims and one event across all independently matching instances. Claims pay exact snapshots through C1 points once across save/content-change/crash/replay; full no-contract progression remains valid. |
| M05-V17 | Audit A1: AV-001/002 real authored contract claims/recovery; AV-003 supported manifest/forecast contexts; AV-004 indirect authorization; AV-005 planner/forecast parity; AV-006 complete required ranks/full-cost evidence; AV-007-01–06 real group/preset/rotation lifecycle. No-contract progression remains mandatory. |

## Acceptance criteria and definition of done

- All M05 validations and affected earlier suites pass; all first-release gameplay is integrated and required open content decisions resolved.
- Optional contracts pay manually once, persist correctly and never gate core progress. Offline objective progress is durable.
- Statistics are accessible from level 1, include historical offline activity, distinguish actual/forecast and operating/cash-flow measures, and use bounded retention.
- Forecasts use the shared simulator, exact current policies and a fully isolated copy; no live side effects or invented purchases.
- Full roster/research/progression and advanced automation are usable with explicit player authorization and migrations.
- Balance reports are honest about provisional numbers and human-engagement limits; M06 receives reproducible scenarios/save corpus rather than unsupported pacing claims.

## Expected deliverables

Future outputs: contract definitions/services/Board/claim recovery, full statistics queries/charts/retention, isolated forecast service, presets/advanced budget/approved rotation with UI, complete versioned catalog/curve, save migrations, economic scenario evidence and M06 acceptance/playtest package. Current output is this plan only.

## Audit A1 task and validation corrections

These are required constraints on existing tasks, with their original dependency order retained. Source contracts: TRS §§20.1–20.7 (AUD-R-001–007), FRS FR-AUD-001–007; exact test oracles are TRS §15.1 AV-001–009. Historical approval notes describe their original scope; the explicitly applied A1 additions define the current selected clarification. No test is marked passed by this document update.

| Issue / selected decision | Existing task / validation target | Required correction | Exact acceptance extension |
|---|---|---|---|
| AUD-001 / AUD-DEC-001 B | T04/T06/T07/T15; V03/V13/V16 | Use restored eligibility with paired wallet rollback and intact-history once-only guards; pruning preserves retained facts. | AV-001-02/04; real authored claim corpus; M05-V17 |
| AUD-002 / AUD-DEC-002 B | T06/T15; V03/V13/V16 | Repeat unknown-result tests for real contract progress/claims and full configuration. | AV-002; T-011/018–020; M05-V17 |
| AUD-003 / AUD-DEC-003 B | T13/T15; V09/V11 | Keep old-profile support and approved tuning separate; full forecast/offline/save parity per context. | AV-003-03–05; T-021/022/026; M05-V17 |
| AUD-004 / AUD-DEC-004 B | T11; V08/V12 | Group/preset changes use the same quote/authorization path. | AV-004-02/05 + AV-007; M05-V17 |
| AUD-005 / AUD-DEC-005 A | T09/T11/T15; V06/V11/V12 | Forecast and advanced priority rules use the same planner. | AV-005-02/04/05; copy/reference parity; M05-V17 |
| AUD-006 / AUD-DEC-006 A | T02/T13/T14; V09/V10 | Audit all ranks, excluded optional families and full-cost balance consequences. | AV-006-04; no-contract/no-equipment comparisons; M05-V17 |
| AUD-007 / AUD-DEC-007 B | T11/T12/T15; V08/V12 | Implement complete single-membership CRUD, destination/deletion preview, reference guards and action-subset distinction. | AV-007-01–06 with real group/preset/rotation states; M05-V17 |

**Additional exit condition:** complete the task-level A1 obligations above and M05-V17 at the stage owned by this milestone. Later-runtime cases may be specified with fakes now only where the staging explicitly permits it; they remain required for their real integration milestone. No new mandatory gameplay family, final balance value or earlier native/UI implementation follows from A1.
