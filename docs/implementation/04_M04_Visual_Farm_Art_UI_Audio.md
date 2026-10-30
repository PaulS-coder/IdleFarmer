# M04 — Visual farming game, art, UI and audio

> **Audit corrections A1 — 2026-10-28:** Apply the approved contracts in [TRS §§15.1/20](../architecture/IdleFarmer_Technical_v1.5.md), [FRS audit requirements](../requirements/IdleFarmer_Functional_v1.0.md) and the [Audit Decision Register](../decisions/Audit_Decision_Register.md). The task crosswalk below is normative for the listed existing tasks; it does not add gameplay or implement later-stage features. [Correction changelog](../audit/round_01/Audit_Correction_Changelog.md) preserves before/after references. Existing provisional values and Open/Deferred evidence remain unchanged.

**Approved closeout C3 — 2026-10-28:** Owner: “DEC-023 - agreed with option A.” **Clean illustrated** is the selected visual direction: crisp silhouettes, restrained outlines, simple smooth shading and natural greens/browns/golden Wheat, guided by column A of the [planning comparison](../decisions/visuals/Art_Direction_Comparison_v1.png). Style selection is settled; M04 specifies and validates the production art bible/sample pipeline, M05 audits catalog consistency and M06 qualifies actual assets/audio/performance. The comparison is not a production sprite set or a change to the approved eight-column farm geometry. No game implementation or empirical pass is implied.

Priority P1 · Planning only · Depends on stable M01–M03 contracts · Next: M05

**Approved foundation update — 2026-10-26:** [Decision Register Group 1](../decisions/Decision_Register.md) / TRS G1 governs commands, arithmetic, time/replay accounting and numeric-limit errors. Compatibility and GUT/standard Godot direction are approved under DEC-001; C1 selects version names; actual artifact verification remains open. This historical G1 update did not approve art/audio or later policies; G3 now approves budgets/lifecycle as noted below. Art/audio final tuning and G4 stated policy is subsequently approved below; actual evidence remains pending.

**Approved G2 update — 2026-10-27:** Apply [Decision Register Group 2](../decisions/Decision_Register.md) and TRS clarification G2: zero/Empty start, one-point/minimum-rank skill prerequisites, fixed eight-column 8×3 starting layout and next-ID-only fourth-row 25→32 unlocking. The through-30 XP table is approved provisional development data; C1 now defines beyond level 30; genuinely unconfirmed policies/evidence remain pending. G1 safety contracts remain binding; no game implementation is claimed.

**Approved G3 update — 2026-10-27:** Apply [Decision Register Group 3](../decisions/Decision_Register.md) / TRS G3 for shared budgets/cap, research boost, optimizer/priority, lifecycle/batches and staged advanced features (DEC-007/009/010/011/012/025). Numeric defaults remain provisional for balance; G4 policy is subsequently approved below; partial selections/evidence remain pending. Earlier pending-G3 notes are superseded by these synchronized source contracts; no implementation/evidence is claimed.

**Approved G4 update — 2026-10-27:** Project owner: “Group4 approved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G4 binds DEC-015/017/018/021/022 durability/cadences, completed-minute statistics, session/productive utilization, profile-owned settings and end-M03 minimal browser probe. DEC-014 measurement-first policy and DEC-019 authored lifecycle/schema are approved; provider/API evidence remains pending; C2 now approves the exact twelve contract rows/guards/rewards. All earlier pending-G4 statements are updated below; no application tests or implementation are claimed.

**Approved G5 update — 2026-10-27:** Project owner: “group 5 aapproved as recommended.” [Decision Register](../decisions/Decision_Register.md) / TRS G5 approves DEC-023 qualification/sample-review policy (named hardware/art still Open), defers DEC-008 Seed Efficiency/Research Facilities/Growth Booster, and approves DEC-024 costed economy plus normal-speed human evidence with the provisional five-real-minute/diary indicator. Preserve v1 research acceleration; no new balance values, hardware, assets or empirical results are inferred.

**Approved G6 update — 2026-10-27:** [Decision Register](../decisions/Decision_Register.md) / TRS G6 records “Group 6 approved as recommended”: standalone versioned Windows ZIP/executable, required dependencies/licenses/checksums and per-user save preservation. Installer/signing optional by separate selection; Steam/cloud/storefront integration deferred beyond v1. This changes future delivery requirements, not the current milestone's game scope or implementation status.

**Approved closeout C1 — 2026-10-27:** Owner: “DEC-001 - approved, DEC-002 - use option B.” [Decision Register](../decisions/Decision_Register.md) / TRS C1 selects standard Godot 4.7.2/matching templates, GUT v9.7.1, godot-sqlite v4.9 evaluation/reportedSQLite 3.51.0, Compatibility/Windows x86_64. Actual artifacts/hashes/licenses/integration remain unverified. Increasing option B beyond level 30 is approved provisional data: first step57,500; subsequent steps ceil(previous×110/100), one point/level with retained surplus and no arbitrary cap. All existing levels 1–30 values remain unchanged; no code/test result is claimed.

**Approved closeout C2 — synchronized 2026-10-28:** Owner: “Closeout B option A - approved.” [Decision Register](../decisions/Decision_Register.md) / TRS C2 makes FRS §§10.2–10.4's twelve authored offers, exact guards/predicates and frozen provisional rewards binding. Existing optional/manual/three-slot/one-time/offline lifecycle remains intact. This settles DEC-019 content; actual game implementation and balance evidence remain future work.

[Master roadmap / D-xx decisions](00_IdleFarmer_Master_Roadmap.md) · [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md) · [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md)

## Objectives and scope

Turn the durable headless systems into a Windows farming game: 1920×1080 initial window, GPU-accelerated isometric farm, mouse controls, state-driven crop stages, subtle varied wind, integrated farming/economy panels, offline summary and real-time audio. Generate artwork during development under one consistent art direction; game runtime uses packaged assets without an online generation dependency.

Build the central farm, crop selection, Store, Skills, Research, Settings and navigation shell now. Contracts and full Statistics/Profitability workflows arrive in M05; leave clear routes for their panels. Statistics must be accessible from level 1 by first-release integration, never an unlock reward. Presentation must not own or mutate farming state, rewards, clocks or persistence.

Primary references: FRS §2/2.1/2.2, §§3–9,12–13; FR-PLAT-01/02, FR-GFX-01–04, FR-INPUT-01, FR-UI-01, FR-FARM-01–07; TRS §§1,11–14,16 M04; T-002 presentation portion.

## Prerequisites and dependencies

- M03 startup/recovery/commit lifecycle, read-only state snapshots, offline report, typed errors and live/historical presentation event markers stable.
- M02 provides planting/upgrade/reset/research quotes using actual economic rules. UI must reuse these, not reimplement formulas.
- Select/review the actual named representative hardware before M04-T01 under DEC-023/G5. Review actual coherent art samples/workflow/provenance in M04-T02 before bulk generation; final vendor/hardware/driver and audio-tuning qualification belongs to M06.
- Use the approved DEC-001 Compatibility renderer baseline and perform pinned-version/GPU smoke checks. All assets/shaders must have a compatibility-safe path; no NVIDIA-exclusive dependency.
- Frozen content IDs allow generation of all 15×5 crop stages now; M05 validates full catalog gameplay, not a late art restart.

## Required classes and suggested file structure

Presentation/lifecycle classes extend `Node`, `Node2D` or appropriate `Control`. Read models/formatters extend typed `RefCounted`. Any runtime setting changes pass through controller/settings service; core gameplay remains free of presentation imports.

| Suggested path | Classes / scenes and role |
|---|---|
| `scenes/main.tscn`, `scenes/farm/farm.tscn`, `presentation/farm_presenter.gd` | `FarmPresenter`, composition and snapshot binding |
| `scenes/plots/plot_view.tscn`, `presentation/{plot_view,plot_layout,crop_stage_resolver}.gd` | `PlotView`, pure `PlotLayout` and `CropStageResolver`; stable ID mapping |
| `presentation/{ui_command_router,panel_router,quote_presenter}.gd` | `UICommandRouter`, `PanelRouter`, `QuotePresenter` |
| `scenes/ui/{crop_selection,store,skills,research,settings,offline_summary,error_dialog}.tscn` | Corresponding panel controllers; submit typed commands, show structured results |
| `presentation/{audio_manager,audio_event_aggregator,settings_presenter}.gd` | `AudioManager`, real-time `AudioEventAggregator`, persistent setting controls |
| `assets/{crops,environment,interface,audio}/`, `assets/manifest/` | 75 crop-stage assets, environment/UI, music/effects, source/license/direction manifest |
| `presentation/shaders/`, `debug/{speed_controls,diagnostics}/` | Compatibility wind shader/fallback, debug-only controls |
| `tests/{integration,unit}/`, `tests/fixtures/presentation/` | UI binding, plot mapping, stage/volume/aggregation tests and repeatable visual scenarios |

Use one view per logical plot at this scale. Visual nodes may be destroyed/rebuilt without touching crop cycles. View interpolation reads progress; only core maturity events make a crop ready.

## Detailed implementation tasks

### M04-T01 — Establish Windows scene shell and rendering baseline

Dependencies: M03. Create main composition scene, initial 1920×1080 window, Compatibility renderer and sensible stretch/scaling baseline. Initialize controller/load/recovery before farm/audio; display loading/recoverable status without tentative balances. Validate launch on available Windows GPU and headless core remains unaffected. Deliver shell, renderer record and startup screenshots; full vendor matrix is M06. References: FR-PLAT-01/02, FR-GFX-02/03; TRS §§11.1,12.

**Approved G1 constraints:** Use approved Compatibility/standard Godot direction with explicitly reviewed exact engine/export pins; renderer approval is not GPU/performance proof. Initialize scenes/audio only after durable startup/catch-up and the current writer epoch are ready.

**Approved G2 constraints:** Fresh committed state displays 0 coins/XP, level 1, 24 Empty unlocked plots and a disabled-for-farming fourth row. Disabled means existing Locked plot state, not a new gameplay state.

**Approved G5 constraints:** Select/review actual representative Windows baseline before this milestone, naming CPU/GPU/RAM/storage/OS/driver. Use Compatibility/1080p/32-plot 1× and60× scenarios; preliminary timings are not final vendor coverage or a universal 60 FPS claim.

**Approved C1 constraints:** Use approved standard Godot 4.7.2/Compatibility/Windows x86_64 and matching standard templates; qualify on actual named hardware separately. Test HUD/quotes around post30 option B thresholds without scene-owned progression.

### M04-T02 — Specify the approved art direction's production bible and pipeline

Dependencies: T01. Use approved Clean illustrated direction (DEC-023/C3; FRS §2.1/TRS §11.1) and column A as the style reference. Document isometric angle, tile footprint, crop palette/material style, lighting direction, restrained outlines, simple shading, five-stage readability, naming and transparent export/atlas rules. Select development-time generation workflow and retain prompts/reference/version/license/provenance per batch. Produce a small Wheat/environment/Carrot proof set and verify consistent direction/scale before bulk work. No runtime image-generation call or new gameplay asset theme. Deliver art bible and approved sample sheet. References: FR-GFX-01/04; FRS §2.1; TRS §11.1; D-23 and art decision in FRS §16.

**Approved G5/C3 constraints:** Clean illustrated direction is explicitly selected; do not reopen that choice. Apply G5's sample/art-bible/readability/provenance review to the actual production proof set before bulk generation. Record concrete scale/palette/lighting/layer/transparency/import/atlas/wind parameters and review findings; the planning comparison is not a runtime atlas or final UI design. Keep final audio/aggregation tuning evidence separate.

### M04-T03 — Implement stable isometric farm layout

Dependencies: T01,T02. Use a fixed eight-column row-major map: IDs 1–8, 9–16 and 17–24 are the three initially unlocked/Empty rows (8×3); IDs 25–32 form the initially Locked fourth row. Purchases extend its unlocked prefix left to right, only N+1 next, reaching 8×4 with no skipped unlocks. Implement hit-testing/depth sorting and frame all 32 cells without changing coordinates/IDs after purchase. Keep Locked row subdued and visible. Validate ID→row/column→click mapping. References: FR-FARM-01/02/07/08; FR-GFX-01; TRS §§3.3,11.1; approved DEC-020.

**Approved G2 constraints:** Only unlock status changes as N grows; columns never expand and crops/statistics retain plot IDs. Gaps in crop occupancy are allowed; gaps in unlocked status are not.

### M04-T04 — Implement snapshot-driven PlotView

Dependencies: T03. Bind locked/empty/growing/ready display, selected crop, stall reason, automation indicators and growth/remaining time from committed snapshots. Derive five stages using M01 thresholds; mature marker persists indefinitely. Use monotonic/simulation values supplied by controller for progress rendering, never a second maturity clock. Rebuild all views and confirm state digest unchanged. Deliver stage-boundary and stale-view/rebind tests. References: FRS §§2.1,3–4; TRS §§3.3,11.1.

### M04-T05 — Generate/integrate early crop-stage artwork

Dependencies: T02,T04. Produce Wheat, Carrots, Corn, Tomatoes and Pumpkins, each with five recognizable stages and consistent anchors. Validate alpha edges, isometric footprint, neighboring overlap/depth and ready silhouette. Import textures/atlases with documented scaling/filtering appropriate to the approved Clean illustrated direction and T02 art bible. Deliver 25 stage entries and in-engine inspection sheet; no placeholder remains for these crops at exit. References: FRS §§2.1,4.2; FR-GFX-04.

### M04-T06 — Generate/integrate remaining crop-stage artwork

Dependencies: T05. Produce remaining ten crops in two reviewable five-crop batches under the same Clean illustrated art bible, each with five stages; split into T06a/T06b if needed. Validate all 75 stage references resolve and alternate coin/XP crops remain visually distinct. Record asset sizes, attribution and source versions. Deliver full crop atlas/assets and in-engine catalog scene used only for QA. References: FRS §§2.1,4.2; TRS §11.1.

### M04-T07 — Add wind and farming feedback

Dependencies: T04–T06. Add subtle per-plant phase/amplitude variation, compatible shader or layered animation fallback, planting/harvest feedback and coin/XP visual intents after successful committed results. Drive ambient motion by presentation real time, separate from debug simulation. Throttle transient visuals for large automatic batches and eliminate historical catch-up effects. Validate 1×/60× equal ambient motion and no mutation on animation completion. References: FRS §§2.1,12; TRS §§11.1,12.2.

### M04-T08 — Connect mouse commands and selection

**Applied A1 task constraints:** AUD-DEC-002 B, AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T04,T07. Empty plot opens crop selection; growing plot opens status/remaining time; ready click submits HarvestCrop; locked plot previews level+coin expansion requirements. Multi-selection/batch buttons respect skill capability. Attach unique command IDs, disable duplicate submission while pending, refresh on structured errors and never pre-credit display. Deliver click-through integration tests with injected repository latency/failure. References: FR-INPUT-01; FR-FARM-05/06; FRS §5.4; TRS §4.1.

**Approved G1 constraints:** Route commands through the controller's profile/writer-epoch/counter generator and current accepted simulation time; due scheduled work finishes before input. Handle duplicate/stale/invalid-time results without repeating rewards or silently issuing a replacement purchase after lost acknowledgement.

**Approved G2 constraints:** Only next Locked ID N+1 may submit an eligible expansion purchase. Later Locked cells show why prior plots are required along with their existing level/cost gates. Revalidate at commit and handle skipped/stale/double purchase without charge or auto-substituting another plot.

**Approved G3 constraints:** Batch controls report skipped ineligible plots rather than silently aborting a valid subset or charging failed members. A complete command/commit failure shows no success feedback; the accepted subset appears only after its atomic commit.

### M04-T09 — Implement crop selection and planting preview

**Applied A1 task constraints:** AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T08. Show level/research eligibility, base/effective growth, seed/fertilizer charges, predicted gross/XP/net profit, normalized coin/XP rate and fertilizer incremental profit/ROI using M02 quotes. For None show ROI as not applicable. Include explicit crop/fertilizer/fallback authorization and recurring setting indication; selection alone does not spend. Revalidate stale quote against current revision on submit. Deliver quote parity tests and denial/error UX. References: FRS §§4.1,6.3,7; TRS §§5–6.

**Approved G1 constraints:** Show approved floor/ceil economy and ceil-microsecond duration from the shared quote service. Revalidate against committed revision; do not reproduce integer economics in presentation floats. Apply now-approved G3 reserve/fallback policy; G4 metric/settings ownership choices are approved below.

**Approved G3 constraints:** Preview exact recurring purchase plan and accepted fallback. Empty-loop start/changed stalled plan needs Plant/ApplyAndStart; a normal direct manual reserve override uses displayed cost/ending-balance confirmation, not repeated per-cycle popups. Valid running loops resume without reopening a consent prompt.

### M04-T10 — Implement Store and expansion panel

**Applied A1 task constraints:** AUD-DEC-006 A. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T09. Display current/next upgrade ranks, exact costs/effects, growth cap waste and unmet gates, plus individual plot purchases. Submit existing commands; saleable catalog excludes all three explicitly Deferred DEC-008 families. Reflect atomic purchase failures and duplicate guard without changing wallet locally. Validate all Irrigation/Improved Soil ranks and final 32-plot layout. References: FRS §§3,6.1; TRS §§4.1,11.1; D-08.

**Approved G2 constraints:** Preview current next row-4 plot, required level, exact existing cost and order gate. Each success reveals the following ID; do not offer any-eligible or multi-plot purchase behavior that bypasses the sequence.

**Approved G5 constraints:** The three DEC-008 optional families are Deferred and excluded, not locked future purchases or saleable placeholders. Display only defined v1 equipment/fertilizers; keep the approved research acceleration in Research.

### M04-T11 — Implement Skills and research panels

**Applied A1 task constraints:** AUD-DEC-003 B, AUD-DEC-004 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T09. Render approved skill/rank/prerequisite/cost states and paid reset preview. Research shows one active project, completion progress and one available boost with ceil(original actual paid C/2) charge and ceil(remaining/2) result. Preview exact saved time/ending balance; disable used/completed/no-time-saved boosts and never reset the flag on reopen. Route only typed commands with post-commit updates. References: FRS §§5,8; TRS §§5–6,11.1; DEC-007/025/G3.

**Approved G1 constraints:** At equal timestamps, completed research and due harvest batches precede allocation/reset/research input commands under TRS §4.2. UI reflects committed ordering rather than using frame callbacks to change rewards.

**Approved G2 constraints:** Render the approved one-point rank costs and rank≥1 previous-tier edges, plus immediate-predecessor automation chain. Do not label full previous-tier ranking as required. Effects/maxima/cap and boost coefficients remain provisional for balancing; the one-project/one-boost research policy is now approved under G3.

**Approved C1 constraints:** Display approved option B next-level thresholds and banked points accurately across30/31/32/35, preserving1point/level and existing maximum node ranks. Research boost/gates unchanged; no fabricated post30 reward content.

### M04-T12 — Implement basic automation/budget settings UI

**Applied A1 task constraints:** AUD-DEC-004 B, AUD-DEC-005 A, AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T09,T11. Expose separate auto actions, fixed repeat fertilizer before Smart, three Smart modes/reserve/percentage at owned level-9 node. R/p/seed-toggle are farm-wide controls, not per-plot overrides; show inherited crop/auto/fertilizer/fallback/eligible-priority fields separately. Explain fixed-before-Smart, tied mode order and one protection ceiling that guarantees no funding. Accept fallback/start/rearm explicitly; disclose immediate Ready harvest on enable and valid eligible-subset outcomes. Preserve inactive respec config. Advanced priority/seed toggle/preset/rotation executable UI completes M05. References: FRS §§5.4,7,9.2; TRS §6; DEC-009/010/011/012/025/G3.

### M04-T13 — Implement offline summary and reliability messages

**Applied A1 task constraints:** AUD-DEC-001 B, AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T08,T11,T12. Display committed elapsed time, harvests, gross, seed/fertilizer expenses, net operating income, XP/levels, research, contract-progress slot and interrupted plots with reasons. Label gross versus net; do not offer a second payout/claim button for already-committed offline farming. Add clear save/recovery/ownership/time-diagnostic messages and safe retry/recovery/exit actions supplied by M03. Deliver normal/zero-time/rollback/failure fixtures. References: FRS §§9,13; TRS §§8,9.3,12.

**Approved G1 constraints:** Add recovery presentation for DEC-026 true numeric-limit failure: retain old checkpoint/anchor, show no partial payout and require deliberate recovery/version handling. Explain DEC-013 future-anchor zero-extra-offline behavior and accepted forward-on-restart consequence clearly; do not claim trusted-time security.

**Approved G3 constraints:** Use durable boost-used/remaining state and loop authorization in offline summaries; never offer an additive payout or automatic research boost/rearm. G4 now defines completed-minute statistics and profile-owned GameSettings.

**Approved G4 constraints:** Offline summary presents startup earnings separately from session, shows honest save/backup recovery state, and never grants a second payout. G4 hour/day labels use as-of simulated minute; settings ownership is profile-specific.

### M04-T14 — Integrate music and separate audio buses

Dependencies: T01,T07. Add instrumental loop and pleasant ready/harvest/UI sounds with asset provenance. Create Master/Music/Crop Ready/Harvest-Coins/UI buses; music has independent On/Off. Implement 0–100% mapping with explicit mute at zero, not a merely quiet finite dB value. Audio starts only after persisted preferences load; simulation speed cannot affect pitch/playback. Deliver bus routing and mute tests. References: FRS §2.2; TRS §11.2.

**Approved G4 constraints:** Restore validated profile-owned GameSettings before playback, with independent normal/debug preferences. Test zero mute and startup ordering under injected load/recovery delays.

### M04-T15 — Implement persistent settings panel

**Applied A1 task constraints:** AUD-DEC-002 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T14. Bind master/category sliders and music switch to validated GameSettings persistence, immediately updating playback and saving preferences. Use provisional defaults Master 80/Music 25 enabled/Ready 50/Harvest 65/UI 50 on genuinely new profiles. Restore before music starts; volumes survive restart independent of debug multiplier. Include display settings only within agreed scope. Deliver mute/toggle/reopen integration tests including save failure feedback. References: FRS §§2.2,13; TRS §§3.5,11.2; D-21.

**Approved G4 constraints:** Cosmetic slider changes affect playback immediately; commit the profile settings and show unsaved status on failure without advancing economic state. Use defaults only for genuinely new profiles/validated missing fields; debug speed is excluded and resets to 1×.

### M04-T16 — Implement real-time effect aggregation

Dependencies: T14,T15. Coalesce harvest/ready intents using real monotonic presentation time: provisional 250 ms window, max two harvest groups per real-world second; apply analogous ready throttle. Suppress historical/offline sound events entirely, optionally one summary sound if selected. Use cycle/event IDs to avoid repeat ready notification from view refresh; reset queues across recovery/load. Deliver fake real-time aggregator tests and listening checks at 32 plots/60×. References: FRS §2.2; TRS §11.2; T-002 presentation portion.

### M04-T17 — Integrate dev-only speed controls and diagnostics

Dependencies: T12,T16. Add integer 1×–60× slider to debug settings, immediate SimulationClock update, visible >1× label and reset to 1× each launch. Use separate debug profile; production export contains no speed UI or accessible debug commands. Show optional queue/simulation/frame timing diagnostics without affecting gameplay. Verify no global time_scale modification and natural wind/music/input. Deliver debug/release export distinction tests. References: FRS §12; TRS §7.4; T-002.

**Approved G1 constraints:** Debug multiplies active simulation only; natural UI/audio/wind timing and 1× suspended/closed accounting remain M03's authority. Different normal/debug writer/profile state cannot be mixed by presentation.

**Approved G4 constraints:** Debug profile settings are separate, but no profile persists speed; session reset never reuses offline startup earnings or labels suspended time as engagement.

### M04-T18 — Close visual integration gate

**Applied A1 task constraints:** AUD-DEC-007 B. Follow the exact per-issue task/test crosswalk in this plan’s “Audit A1 task and validation corrections” section and TRS §§15.1/20. M04-V16 extends this task’s acceptance evidence; no runtime pass is implied.

Dependencies: T10–T13,T15–T17. Add unobtrusive panel navigation with central farm visible, including M05 Statistics/Contracts routes. Run seeded 24/32-plot UI scenarios, screenshot/video capture, readable 1080p mouse flows, window scaling and preliminary frame measurements. Compare headless and UI-driven command logs for identical outcomes. Deliver art/audio manifest, known issues and M05 UI integration handoff. References: FR-UI-01; FRS §15; TRS §§11,14,16 M04.

**Approved G1 constraints:** Validate stale/duplicate-command UI feedback, post-commit-only reward effects, numeric-limit recovery notice and clock-anomaly summaries. G3/G4 stated lifecycle/settings/accounting policy and C3 Clean illustrated direction are approved; actual production assets, final tuning and evidence remain pending.

**Approved G2 constraints:** Capture fresh 8×3 and each fourth-row prefix through 8×4; verify no visual reflow/ID ownership shift. Preserve legitimate scattered planting and fail skipped unlock attempts regardless of high player level or abundant coins.

**Approved G3 constraints:** Qualify G3 farm-wide field scope, cap/priority label, one-boost preview/used state, explicit ready/start/rearm and subset failure feedback. Interface must explain material spending consequences, not optimizer implementation jargon.

**Approved G4 constraints:** Verify settings-before-audio/unsaved UI and startup-report/session separation; keep C2 catalog/C3 style approvals explicit and require actual production-asset, hardware and empirical acceptance evidence.

**Approved G5 constraints:** Handoff names actual baseline and sample approval evidence, five-stage coverage/provenance and remaining final tuning/vendor measurements. Do not manufacture approvals or results if hardware/assets are still unspecified.

**Approved C1 constraints:** C1 baseline/continuation approval is settled; report actual artifact/hardware/UI evidence separately. No false level 30 cap or constant57,500 tail in presentation.

**Approved C2 constraints:** Keep the Contracts route and data handoff consistent with approved C2; full Board/predicate/claim workflows still belong to M05. No unapproved offers, dynamic refresh/reward formula or automatic purchases are inferred.

## Automated tests and validation procedures

Unit-test pure layout/stage/formatting/aggregation components. Integration-test command routing through fake/durable controller adapters; real UI tests must confirm commit failure cannot display successful economic feedback. Keep manual visual/listening checks reproducible rather than claiming they are proven by unit tests.

| ID | Procedure / expected outcome |
|---|---|
| M04-V01 | Map/click all 32 IDs using fixed eight-column coordinates; start 8×3/24 Empty unlocked plots with row 4 Locked, then sequential 25→32 unlocks to 8×4. Existing planted-cycle ownership/depth never shifts; central farm remains visible and Locked suffix subdued. |
| M04-V02 | Capture all 15 crops at 0/25/50/75/100% and boundaries just below; five readable Clean illustrated stages at actual gameplay scale, Ready at 100%, no missing texture/import error or spoilage. |
| M04-V03 | Empty/growing/ready/locked click flows, batch gates and affordability failures; canonical authoritative state unaffected by view destruction/rebuild. |
| M04-V04 | Preview equals committed seed/fertilizer/gross/net/XP/duration; stale quote rejected or refreshed; negative-profit manual choice explicit and never silently selected by Smart. |
| M04-V05 | Store/skills/reset/research/acceleration/automation UI routes only typed commands; inject disk-full before commit and verify no success sound/reward/false saved notice. |
| M04-V06 | Reopen displays committed offline summary once, with all required categories; no duplicate payout action or backlog of ready/harvest effects. |
| M04-V07 | All audio categories at 0, 1, defaults and 100%; zero genuinely silent, music switch independent, persistence restored before playback. Compare 1×/60× pitch and loop duration. |
| M04-V08 | Aggregator fake timestamps at 249/250 ms and second-window edges; <=2 harvest groups per real second under continuous events, similar ready limiting and no duplicate maturation sound after rebind. |
| M04-V09 | T-002 complete: Wheat matures in ~8 real seconds at 60× with same reward; wind/music remain natural, input responsive, frame pacing independent. |
| M04-V10 | Production export excludes speed controls/debug command access and normal profile untouched; debug relaunch resets 1×. |
| M04-V11 | Human screenshot/listening checklist at 1080p and supported scaling; art consistent, panel text/costs readable, central farm remains visible. Preliminary GPU/FPS observations named by hardware, no universal performance claim. |
| M04-V12 | G2 unlock UX: row 4 starts Locked; only 25, then 26 … 32 becomes the next purchase target. Later cells cannot bypass order even when level/coins suffice. Failed/canceled/duplicate purchase leaves visible prefix/wallet unchanged; Empty planting gaps among unlocked cells remain usable. |
| M04-V13 | G3 UI: farm R/p cannot appear as plot/group overrides; cap≠reserved funding; fixed/Smart order and paid manual override clear. Ready-on-enable, inactive reset/rearm, one boost and accepted/refused fallback show exact consequences; subset success waits for durable commit and skipped members are uncharged. |
| M04-V14 | G4 settings/UX: normal/debug profile preferences restore before audio; immediate slider failure shows unsaved status without economic success. Startup offline report and current session stay separate; as-of labels do not promise second-aligned historical windows. |
| M04-V15 | G5 qualification: actual reference configuration named before M04, C3 style approval and actual production sample/art-bible review recorded before bulk assets, five-stage readability/provenance checked; vendor/final-tuning evidence honest. No unseen sample, generic hardware placeholder or omitted Deferred family is treated as approved/implemented v1 content. |
| M04-V16 | Audit A1: AV-001 recovery disclosure; AV-002-04 stopped/unsaved status; AV-003 manifest-specific display; AV-004-01–05 quote/preview/accepted results; AV-005 fixed-stall messaging; AV-006 Store guards; AV-007-02/03 basic configuration consent. Full advanced group management remains M05. |

## Acceptance criteria and definition of done

- M04-V01–V16 pass with automated outputs plus visual/audio evidence; existing headless/recovery suites still pass.
- Actual Windows graphical farm operates all M01–M03 workflows through commands; no reward/timer/accounting owned by scenes.
- All 75 crop stages resolve, wind varies subtly, ready state is unmistakable, and generated art follows the approved Clean illustrated bible, is consistent/licensed and packaged for offline runtime.
- Audio volume/mute/music/aggregation persist and stay at natural speed. Offline effects are suppressed. Production debug control exclusion demonstrated.
- Required basic panels and offline/recovery flows work; M05 contracts/statistics/advanced automation work is accurately identified as pending.
- 60 FPS is measured provisionally here and formally qualified on reference hardware in M06.

## Expected deliverables

Future outputs: Windows farm/main scenes, typed presenters and panels, generated stage/environment/UI assets and manifest, audio assets/buses/settings, effect aggregator, debug-only speed controls, screenshots/listening notes, UI parity/recovery tests and M05 routes/hand-off. Current output is this plan only.

## Audit A1 task and validation corrections

These are required constraints on existing tasks, with their original dependency order retained. Source contracts: TRS §§20.1–20.7 (AUD-R-001–007), FRS FR-AUD-001–007; exact test oracles are TRS §15.1 AV-001–009. Historical approval notes describe their original scope; the explicitly applied A1 additions define the current selected clarification. No test is marked passed by this document update.

| Issue / selected decision | Existing task / validation target | Required correction | Exact acceptance extension |
|---|---|---|---|
| AUD-001 / AUD-DEC-001 B | T13; V06 | Show recovered revision/time/possible lost progress without claiming recovered lost-branch facts. | AV-001-02; recovery message fixture; M04-V16 |
| AUD-002 / AUD-DEC-002 B | T08/T13/T15; V05/V14 | Show unresolved/reconciling state; prevent duplicate replacement purchases and old shutdown/settings writes. | AV-002-04; latency/settings/recovery UI fixtures; M04-V16 |
| AUD-003 / AUD-DEC-003 B | T11; V05 | Display correct profile thresholds/allocations; do not present a legacy rule as a new undefined curve. | AV-003-03; quote/display parity; M04-V16 |
| AUD-004 / AUD-DEC-004 B | T08/T09/T11/T12; V04/V05/V13 | Show precise as-of/accepted results and changed-term refresh; preserve pending intent identity. | AV-004-01–05; user-facing confirmation checks; M04-V16 |
| AUD-005 / AUD-DEC-005 A | T12; V13 | Explain fixed-policy stalls without promising maximum planted count or authorized substitutions. | AV-005-01/03 user message fixtures; M04-V16 |
| AUD-006 / AUD-DEC-006 A | T10; V05 | Store shows only real rank/cost/cap guards, no invented level/research lock. | AV-006-01–03; preview/execution parity; M04-V16 |
| AUD-007 / AUD-DEC-007 B | T12/T18 handoff | Basic group settings route follows agreed capability/consent semantics; advanced management remains M05. | AV-007-02/03; correct UI staging; M04-V16 |

**Additional exit condition:** complete the task-level A1 obligations above and M04-V16 at the stage owned by this milestone. Later-runtime cases may be specified with fakes now only where the staging explicitly permits it; they remain required for their real integration milestone. No new mandatory gameplay family, final balance value or earlier native/UI implementation follows from A1.
