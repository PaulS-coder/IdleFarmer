# Idle Farmer — Functional Requirements Specification

> **Audit corrections A1 — 2026-10-28:** Applied approved AUD-DEC-001 B /002 B /003 B /004 B /005 A /006 A /007 B and AUD-DEC-008 A wording corrections. [Audit Decision Register](../decisions/Audit_Decision_Register.md) records approval; [correction changelog](../audit/round_01/Audit_Correction_Changelog.md) records exact scope. Existing numerical data remain provisional; DEC-008 deferred families remain excluded. No game code or runtime test result is produced.

> **Approved closeout C3 — 2026-10-28:** Owner: “DEC-023 - agreed with option A.” **Clean illustrated** is the selected visual direction: crisp silhouettes, restrained outlines, simple smooth shading and natural greens/browns/golden Wheat, guided by column A of the [planning comparison](../decisions/visuals/Art_Direction_Comparison_v1.png). Style selection is settled; M04 specifies and validates the production art bible/sample pipeline, M05 audits catalog consistency and M06 qualifies actual assets/audio/performance. The comparison is not a production sprite set or a change to the approved eight-column farm geometry. No game implementation or empirical pass is implied.

**Document ID:** IF-FRS  
**Version:** 1.0 (consolidated baseline)  
**Status:** Approved direction; provisional balancing values explicitly identified  
**Primary target:** Windows 11  
**Companion document:** `IdleFarmer_Technical_v1.5.md`  
**Scope:** First release; future web port and prestige are outside the initial release

> **Version note:** This file consolidates the functional v1.0 baseline **and all subsequently approved clarifications** through the pre-development v1.5 review. The functional version stays at 1.0 as requested; this is the up-to-date standalone source of truth for gameplay. Numeric tables and implementation suggestions marked *provisional* are not final balancing commitments.

> **Approved clarification — Group 1, 2026-10-26:** The project owner confirmed “Approve Group 1.” This revision incorporates DEC-005, DEC-006, DEC-013, DEC-016 and DEC-026 from the [Decision Register](../decisions/Decision_Register.md); DEC-001's approved toolchain direction is recorded in the technical specification. Exact dependency pins and all other unconfirmed decisions remain open/proposed. Existing provisional gameplay numbers remain provisional; this approval authorizes documentation synchronization, not game implementation. **Historical scope:** reservations in this dated approval describe that revision; current C1–C3/A1 rules and original remaining evidence obligations govern.

> **Approved clarification — Group 2, 2026-10-27:** The project owner approved the rest of Group 2 and amended DEC-020: start with **8 × 3** unlocked plots and unlock **only the fourth row sequentially**, with no gaps in unlocked plot IDs. DEC-003 starting state and DEC-004 point/prerequisite rules are approved; DEC-002's complete through-30 XP table is approved as provisional development data only. At G2 beyond-30 policy remained unresolved; C1 below now approves option B. This clarification supersedes the previous starting geometry/any-eligible purchase proposal; costs, level gates and other balance values are unchanged unless explicitly stated.

> **Approved clarification — Group 3, 2026-10-27:** Project owner: “Approve Group 3.” DEC-007/009/010/011/012/025 are approved: one-project/one-boost research, exact/ROI Smart policies, farm-wide wallet controls and batch cap, level-gated advanced controls, explicit automation lifecycle/batch handling and staged delivery. Default reserve 0, protection 25%, and half-cost/half-remaining research boost are approved initial development values that remain provisional for balance. Other unconfirmed decisions remained unapproved at G3; the subsequent G4 confirmation below resolves its stated scope. This is documentation synchronization, not game implementation or test evidence. **Historical scope:** reservations in this dated approval describe that revision; current C1–C3/A1 rules and original remaining evidence obligations govern.

> **Approved clarification — Group 4, 2026-10-27:** Project owner: “Group4 approved as recommended.” DEC-015/017/018/021/022 are approved: durable economic acknowledgements, initial save/backup cadences, simulation-time completed-minute statistics, productive utilization/session boundaries, profile-owned settings and an end-M03 minimal browser probe. DEC-014's measurement-first selection policy is approved but its exact provider/evidence remains Open. DEC-019's authored one-time lifecycle/schema and provisional level-7/three-slot defaults are approved; at G4 exact content remained Proposed; C2 below now approves the twelve rows and shared rules. No game code or empirical results are produced by this update.

> **Approved clarification — Group 5, 2026-10-27:** Project owner: “group 5 aapproved as recommended.” DEC-024's automated-economy plus normal-speed human-engagement evidence policy is Approved, including the initial provisional five-real-minute recent-meaningful-input indicator supplemented by diaries. DEC-008 is Deferred: Seed Efficiency, Research Facilities and Growth Booster are excluded from v1 unless a later explicitly approved scoped proposal reopens them. DEC-023's representative Windows baseline/vendor coverage and sample-review protocol is Approved; exact hardware, art/assets and final tuning remain Open. No numerical balance table, time goal or empirical result is changed.

> **Approved clarification — Group 6, 2026-10-27:** Project owner: “Group 6 approved as recommended.” DEC-027 selects a versioned standalone Windows ZIP/executable package for v1, containing required data/native libraries/licenses/checksums, with per-user saves outside program files and verified normal-user offline launch/update/save preservation. Installer/signing remains an optional separately selected addition; Steam/cloud/storefront integration is deferred beyond v1. This approval selects delivery policy, not a published build, target architecture or unverified dependency.

> **Approved closeout C1 — 2026-10-27:** Project owner: “DEC-001 - approved, DEC-002 - use option B.” Select standard Godot 4.7.2-stable/matching standard export templates, GUT v9.7.1, godot-sqlite v4.9 evaluation candidate (reported SQLite 3.51.0), Compatibility and initial Windows x86_64. Artifact fingerprints/license inventory and actual integration still need verification. DEC-002's increasing post-30 continuation is approved as provisional development data: first increment 57,500 XP, then ceil(previous increment ×110/100) for each later level; one point per gained level, no discarded XP or gameplay cap. Source levels1–30 and existing content/rank gates remain unchanged; no game implementation/test result is claimed.

> **Approved closeout C2 — 2026-10-28:** Owner: “Closeout B option A - approved.” DEC-019 now includes the twelve exact one-time offers and shared eligibility/progress/frozen-reward rules in §10, as approved provisional development content. The three-slot/manual-claim/abandonment/offline lifecycle remains binding; no new inventory, currency, timer or generation system is added. Final balance and actual implementation evidence remain future work. This clarification is documentation only.

## 1. Product vision and experience

Idle Farmer is a single-player incremental/idle farming game. The player plants crops on separate plots, watches them progress through visually distinctive stages, harvests for coins and experience points (XP), develops skills, researches crops, buys farm improvements, and gradually automates production. In the late game the player manages productivity and investment decisions rather than repeatedly clicking plots.

**Core loop:** Plant → Grow → Harvest → Earn coins and XP → Upgrade → Research → Expand → Automate → Optimize.

**Confirmed principles**

- Farm optimization is the core game; optional agricultural contracts add challenges and bonus rewards.
- Full basic farming automation should be achievable after approximately **3–5 hours of reasonably active normal-speed play** by a player prioritizing that branch.
- After unlocking full automation, target approximately **48 further hours of engaging active play**. This is a playtest/content-design target, **not** 48 hours of required waiting or a cap on offline income.
- Crop growth, running research, and unlocked automatic production can progress while the application is closed, without an arbitrary offline-duration cap.
- Gameplay remains functional with no internet connection.
- Prestige mechanics are **not included in the first release**. They are planned for a subsequent version; the 48-hour target may then change.
- Do not add mandatory contracts, crop spoilage, trading, multiplayer, or real-money purchases to the initial scope.

### 1.1 Resource vocabulary

| Resource | Earned from | Used for |
|---|---|---|
| **Coins** | Crop harvests and claimed contract rewards | Advanced seeds, fertilizers, equipment, research, acceleration, plot expansion, skill resets |
| **XP** | Crop harvests and claimed contract rewards | Accumulates toward player level; **not spent** |
| **Skill points** | One point on each level-up after level 1 | Skill-tree nodes/ranks; refundable by paid reset |

There is **no physical harvested-crop inventory** and no third contract currency in this release. “Yield” means increased **coin reward** on harvest.

## 2. Platform, graphics, controls, and audio

| ID | Requirement |
|---|---|
| FR-PLAT-01 | Launch on supported **Windows 11 x86_64** hardware for the initial release (DEC-001/C1); additional native architectures require separate selection and matched-library qualification. |
| FR-PLAT-02 | Initial target window/content size **1920 × 1080**, primarily windowed. Borderless/fullscreen and scaling are optional refinements. |
| FR-GFX-01 | Render an **isometric 2.5D** graphical farm, not a text-only application. |
| FR-GFX-02 | Use hardware-accelerated graphics; use an NVIDIA GPU where appropriate/available, **without requiring NVIDIA exclusively**. Compatible AMD and Intel GPUs are supported. |
| FR-GFX-03 | Target **60 FPS** on a named representative Windows 11 baseline selected before M04; rendering speed must not affect gameplay timing. Exact configuration remains Open under DEC-023. |
| FR-GFX-04 | Produce artwork automatically **during development**, maintaining the approved **Clean illustrated** visual direction (DEC-023/C3); actual gameplay may use generated sprites, layered artwork, atlases, and compatible animation/shaders. |
| FR-INPUT-01 | Mouse is the primary control mechanism; optional keyboard shortcuts are acceptable. |
| FR-UI-01 | Keep the farm central and visible; use unobtrusive panels/overlays for Store, Skills, Research, Contracts, Statistics, and Settings. |

**Approved qualification policy (DEC-023/G5):** use the Compatibility baseline, 1920×1080 and representative 32-plot 1×/60× scenarios on a named Windows machine, with additional NVIDIA/AMD/Intel compatibility coverage. Record CPU/GPU/RAM/storage, OS build/driver and exact game/content/toolchain versions. Hardware approval never implies universal Windows performance or an approved unseen art style. Select/review the actual baseline before M04 and finalize the coverage matrix before M06; no machine configuration is invented.

**Owner reference-target selection H2 — 2026-10-28 (DEC-023 hardware subpart):** **AMD Ryzen 5 7600X3D**, **at least 16 GB RAM**, **SSD**, and **NVIDIA GeForce RTX 2080 or better, or an AMD graphics card with similar or higher specifications**. This records the owner's clarification of the earlier “2800+” label; it is a reference-target envelope, not a measured machine, automatic launch restriction or published universal minimum-system guarantee. Qualify an actual selected NVIDIA/AMD model against representative scenarios rather than ordering cross-vendor model numbers. Record actual installed RAM/storage, Windows build and driver at qualification. Existing compatible Intel support/coverage remains unchanged; 60 FPS is evaluated on the reference target, not promised for every Intel/other GPU. Concrete art/assets/tuning and actual measurements remain separate.

### 2.1 Crop visuals and animation

Each crop has **five recognizable visual stages**: **Planted → Sprouting → Growing → Ripening → Ready to Harvest**. The fifth begins at 100% maturity. A provisional simple stage mapping places stages 1–4 in successive 25% ranges; precise art thresholds may be tuned. A mature crop is clearly marked and remains ready indefinitely (no spoilage mechanic).

**Approved visual direction (DEC-023/C3): Clean illustrated**, as shown in column A of the planning comparison: crisp silhouettes, restrained outlines, simple smooth shading and a natural green/brown/golden-Wheat palette. Apply this direction consistently to crop/environment artwork; preserve five recognizable stages at actual gameplay size. M04-T02 specifies scale, isometric angle, lighting, precise palette/outline rules, layering and export/import details in a coherent art bible and production sample before bulk generation. Style selection is complete; actual production assets, their readability/provenance and final audio/aggregation tuning still require review/validation. The board's typeface, ready-marker glyph and illustrative patch sizes are not final UI or farm geometry requirements.

Vegetation should subtly sway in simulated wind with non-identical motion between neighboring plants. Planting, harvesting, coin/XP feedback, and subtle environmental motion should make the field feel alive. Ambient wind/visual animation can run at normal visual speed even during debug-time acceleration.

### 2.2 Music and effects

- Include gentle looping **instrumental background music** with an independent **On/Off** switch.
- Play a pleasant **crop-ready** notification once per maturation event (subject to aggregation).
- Play short positive **harvest/coin-ding** effects on successful harvests.
- Optional UI effects cover buttons, purchases, level-ups, and research completion.
- Provide a master volume and separate volume sliders for **Music, Crop Ready, Harvest/Coins, UI Effects**, all **0–100%**. **0% = completely muted** for that class; changes take effect immediately and persist.
- Provisional defaults: Master 80%, Music 25% (enabled), Crop Ready 50%, Harvest 65%, UI 50%.
- Aggregate nearby harvest effects rather than playing dozens simultaneously. Initial tuning targets: **250 ms grouping window**, at most **two harvest sound groups per real-world second**. Apply similar throttling to simultaneous crop-ready events.
- Historical offline events must **not** produce a backlog of sound effects on reopening. A single optional offline-summary sound is permissible.
- Simulation speed must **not** change sound pitch or music playback rate.
- **Approved DEC-021/G4:** sound preferences belong to each save profile and restore before audio starts. Normal/debug profiles remain separate. Immediate cosmetic changes may remain locally audible with a clear unsaved indication if persistence fails; they never imply an economic save succeeded. Debug speed is not persisted and resets to 1× on every launch. Numeric volume/aggregation defaults remain provisional.

## 3. Farm layout and plot operations

| ID | Requirement |
|---|---|
| FR-FARM-01 | Begin with **24 unlocked plots**, logically arranged **8 columns × 3 rows** (IDs 1–24). All start Empty. |
| FR-FARM-02 | Permit purchase of **8 additional plots** in the initially Locked **fourth row** (IDs 25–32), for a maximum of **32**, logically **8 columns × 4 rows**. |
| FR-FARM-03 | Each plot operates independently and may contain a different crop. |
| FR-FARM-04 | Plot states: **Locked**, **Empty**, **Growing**, **Ready for Harvest**. |
| FR-FARM-05 | Clicking an empty plot offers eligible crop planting; clicking a growing plot shows status and remaining time; clicking a ready plot harvests it. |
| FR-FARM-06 | Expansion requires **both minimum player level and coin payment**, not level alone. |
| FR-FARM-07 | Locked plots should be visible as expansion potential without dominating the playing area. |
| FR-FARM-08 | Unlock plots **strictly in ascending ID order 25 → 32**, left to right across row 4. Only the next Locked plot can be purchased; unlocked IDs always form a contiguous prefix without gaps. This is additional to the level and coin requirements. |

**Approved layout/initial-state rules (DEC-003/020):** use the same fixed eight-column row-major map for every farm size. Row 1 is IDs 1–8, row 2 is 9–16, row 3 is 17–24, and row 4 is 25–32. At new game the fourth row is Locked/disabled for farming; it remains visible as expansion potential. Buying a plot changes its unlock state, never its coordinates or another plot's ID. If N plots are unlocked, a purchase can target only ID N+1 and must also satisfy that plot's minimum level and coin cost. A failed or out-of-order purchase charges nothing. “No gaps” applies to unlock status, not planting: already unlocked plots may be Empty, Growing or Ready independently.

Start with **0 coins**, **level 1**, **0 cumulative XP**, **0 unallocated/allocated skill points**, no purchased upgrades, no active contracts and no running/completed post-start research. Wheat is the sole initial crop unlock; no separate Wheat research purchase is required. No crops are preplanted and no paid crop is automatically selected.

**Provisional expansion values (unchanged by the geometry/order approval):**

| Plots | Required level | Cost **per plot** |
|---|---:|---:|
| 25–26 | 3 | 250 |
| 27–28 | 5 | 1,000 |
| 29–30 | 8 | 4,000 |
| 31–32 | 12 | 12,000 |

Total provisional cost for all eight additional plots: **34,500 coins**.

## 4. Crops, growth, planting, and harvest

### 4.1 Crop configuration

Every crop defines a stable ID, display name, basic/advanced class, seed cost, base growth duration, base coin and XP rewards, player-level requirement, research prerequisite, five stage visuals, and animation configuration.

- **Basic seeds are free** each time planted. This initially applies to Wheat and Carrots in the candidate roster.
- **Advanced seeds cost coins on every planting**, including automatic replanting.
- Wheat is the sole initial crop unlock under the approved new-game state in §3; it needs no separate research purchase. Each subsequently introduced variety must satisfy **both** its player-level prerequisite **and** the corresponding completed research project.
- Planting verifies plot availability, crop eligibility, mandatory seed affordability, and permitted optional consumable charges.
- On planting, the game commits seed/consumable spending and records that cycle's modifiers, growth duration, and rewards. Later upgrades or skill resets affect **future** cycles, not already-planted crops.
- Crop timers are independent; mature crops do not expire. Maturity alone awards nothing: reward is credited **on harvest** (manual or unlocked automatic).

### 4.2 Provisional crop catalogue (15 crops)

The first five were defined for early progression; subsequent tiers provide coin-oriented or XP-oriented alternatives. **All numerical entries are provisional.**

| Crop | Required level | Growth | Seed cost | Gross coins/harvest | XP/harvest | Positioning |
|---|---:|---:|---:|---:|---:|---|
| Wheat | 1 | 8 min | 0 | 16 | 6 | Intro/basic |
| Carrots | 2 | 15 min | 0 | 36 | 12 | Basic |
| Corn | 4 | 30 min | 18 | 110 | 32 | Early advanced |
| Tomatoes | 7 | 60 min | 55 | 270 | 70 | Early advanced |
| Pumpkins | 10 | 180 min | 300 | 1,200 | 230 | Long-duration |
| Sunflowers | 12 | 90 min | 230 | 810 | 125 | Coins |
| Strawberries | 12 | 45 min | 185 | 445 | 105 | XP |
| Blueberries | 15 | 120 min | 450 | 1,600 | 180 | Coins |
| Soybeans | 15 | 60 min | 300 | 785 | 185 | XP |
| Grapes | 18 | 240 min | 2,000 | 5,900 | 480 | Coins |
| Coffee | 18 | 180 min | 1,900 | 4,400 | 750 | XP |
| Cotton | 22 | 300 min | 4,500 | 12,500 | 950 | Coins |
| Rice | 22 | 75 min | 1,150 | 2,900 | 370 | XP |
| Vanilla | 26 | 360 min | 7,200 | 24,500 | 1,900 | Coins |
| Saffron | 26 | 120 min | 6,000 | 10,000 | 1,100 | XP |

“Coins” and “XP” positioning refers to **rates and strategic advantages**, not necessarily the largest absolute single-harvest reward. Faster crops reward frequent/automated harvesting; longer crops suit less frequent interaction. Later crops should not make all earlier ones irrelevant for every objective.

## 5. Experience, levels, skills, and respec

### 5.1 Experience

- Start at **Level 1** with zero cumulative XP.
- Harvests and claimed contracts award XP; XP is never spent.
- Each level gained awards **one skill point**; levels earned offline award unallocated points.
- Higher levels permit crop research, equipment, plot purchases, and skill tiers, subject to their additional costs and prerequisites.

**Complete provisional cumulative XP table — approved for development under DEC-002, 2026-10-27:**

All previously supplied anchors are preserved. Missing levels use lower-anchor XP plus the ceiling of the proportional integer difference between the surrounding anchors. Approval adopts this complete table for development; it does not finalize balance values.

| Level | Cumulative XP | Basis |
|---:|---:|---|
| 1 | 0 | Source anchor |
| 2 | 240 | Source anchor |
| 3 | 650 | Source anchor |
| 4 | 1,300 | Source anchor |
| 5 | 2,300 | Source anchor |
| 6 | 3,600 | Source anchor |
| 7 | 5,200 | Source anchor |
| 8 | 7,300 | Source anchor |
| 9 | 10,000 | Source anchor |
| 10 | 13,500 | Source anchor |
| 11 | 18,000 | Source anchor |
| 12 | 24,000 | Source anchor |
| 13 | 29,334 | Interpolated |
| 14 | 34,667 | Interpolated |
| 15 | 40,000 | Source anchor |
| 16 | 50,000 | Interpolated |
| 17 | 60,000 | Interpolated |
| 18 | 70,000 | Source anchor |
| 19 | 88,750 | Interpolated |
| 20 | 107,500 | Interpolated |
| 21 | 126,250 | Interpolated |
| 22 | 145,000 | Source anchor |
| 23 | 181,250 | Interpolated |
| 24 | 217,500 | Interpolated |
| 25 | 253,750 | Interpolated |
| 26 | 290,000 | Source anchor |
| 27 | 347,500 | Interpolated |
| 28 | 405,000 | Interpolated |
| 29 | 462,500 | Interpolated |
| 30 | 520,000 | Source anchor |

### 5.1.1 Approved increasing continuation — DEC-002 option B / C1

The complete levels1–30 table above remains unchanged and provisional for balance. Continue beyond level 30 without an arbitrary gameplay level/XP cap:

- Let T(30)=520,000 cumulative XP.
- The increment from level 30 to31 is I(31)=57,500 XP.
- For L≥32, I(L)=ceil(I(L−1)×110/100), rounded upward **at each step**.
- For L≥31, T(L)=T(L−1)+I(L).
- Each gained level still awards one unallocated skill point; retain surplus points after existing nodes/ranks are full. Do not auto-spend points or add skill/crop tiers, prestige or purchases.
- Preserve all earned XP. A genuine state-result representation failure follows DEC-026's recoverable checkpoint policy; it is not permission to impose a gameplay cap.

| Level | Increment from preceding level | Cumulative XP |
|---:|---:|---:|
| 31 | 57,500 | 577,500 |
| 32 | 63,250 | 640,750 |
| 33 | 69,575 | 710,325 |
| 34 | 76,533 | 786,858 |
| 35 | 84,187 | 871,045 |
| 36 | 92,606 | 963,651 |
| 37 | 101,867 | 1,065,518 |
| 38 | 112,054 | 1,177,572 |
| 39 | 123,260 | 1,300,832 |
| 40 | 135,586 | 1,436,418 |

These are approved **provisional development values**, not final pacing commitments. The constant57,500 continuation (option A) and explicit level 30 cap (option C) were not selected. Later retuning needs a separately recorded balance/content decision with snapshot-safe handling; actual normal/debug/offline and 30-day/year progression still requires implementation validation.

**FR-AUD-003 — Profile-bound progression (AUD-DEC-003 B).** A saved profile uses one complete immutable supported progression/content manifest: XP thresholds, point prices, skill rank maxima, prerequisites and level guards remain internally consistent. Level is the highest reached threshold under that manifest; earned points equal level−1 and are partitioned into unspent plus allocated one-point ranks/nodes. Published definitions are not edited in place. A separately approved newer manifest may serve new profiles; supported existing profiles retain their old manifest unless an explicit compatible migration is approved. Missing/unsupported versions fail recoverably without overwriting the profile. Schema migration preserves this binding and all paid cycle/research/contract snapshots. No awarded-level watermark or new XP/price data is introduced. See TRS §20.3; AV-003-01–05.

### 5.2 Skill branch A — Growth Efficiency (provisional ranks)

| Skill | Minimum level | Max ranks | Effect per rank |
|---|---:|---:|---|
| Faster Germination | 2 | 5 | -4% growth time |
| Improved Cultivation | 10 | 5 | -3% growth time |
| Climate Control | 18 | 3 | -5% growth time |

Growth reductions from skills and equipment combine under a **provisional 60% reduction cap**. Benefits beyond the cap must be shown accurately in UI. **Approved DEC-004 rules:** every rank costs one skill point; Faster Germination has no branch prerequisite, Improved Cultivation requires Faster Germination rank ≥1, and Climate Control requires Improved Cultivation rank ≥1, in addition to each listed level gate. Fully ranking the preceding tier is not required. Existing rank maxima/effects/cap remain provisional balancing values.

### 5.3 Skill branch B — Harvest Profitability (provisional ranks)

| Skill | Minimum level | Max ranks | Effect per rank |
|---|---:|---:|---|
| Efficient Harvest | 2 | 5 | +8% gross coins |
| Soil Productivity | 10 | 5 | +12% gross coins |
| Premium Produce | 18 | 3 | +20% gross coins |

Bonus categories initially **stack additively**; these coins bonuses do not inherently increase XP. **Approved DEC-004 rules:** every rank costs one skill point; Efficient Harvest has no branch prerequisite, Soil Productivity requires Efficient Harvest rank ≥1, and Premium Produce requires Soil Productivity rank ≥1, in addition to each listed level gate. Fully ranking the preceding tier is not required. Existing rank maxima/effects remain provisional balancing values.

### 5.4 Skill branch C — Automation

| Ability | Earliest level | Skill points | Behavior |
|---|---:|---:|---|
| Batch Planting | 3 | 1 | Plant multiple selected plots |
| Batch Harvesting | 4 | 1 | Harvest multiple mature plots |
| Automatic Harvesting | 6 | 1 | Collect crops when mature |
| Automatic Replanting | 7 | 1 | Replant configured crops after harvest |
| Smart Fertilizer | 9 | 1 | Intelligent fertilizer mode selection |
| Farm Presets | 12 | 1 | Save/apply plot-group settings |
| Enhanced Budget Management | 15 | 1 | Custom priorities and advanced reserve controls |
| Crop Rotation | 20 | 1 | Rotate among explicitly approved crops/configurations |

**Approved DEC-004 prerequisite chain:** Batch Planting has no automation predecessor; each subsequent ability requires the immediately preceding listed node: Batch Planting → Batch Harvesting → Automatic Harvesting → Automatic Replanting → Smart Fertilizer → Farm Presets → Enhanced Budget Management → Crop Rotation. Each node costs one skill point and still requires its listed minimum level. **Four skill points** unlock basic continuous harvest + replant, eligible by Level 7. A Level 7 character earns six points by then, allowing a focused automation build. Points are not automatically allocated when a level or prerequisite is reached.

**Approved capability distinction (DEC-011/G3):** fixed fertilizer selection plus recurring auto-purchase is available **without** Smart Fertilizer. Buying Smart Fertilizer at its level-9 gate enables all three intelligent modes, the basic optional-fertilizer reserve and a 0–100% Budget Protection percentage. Buying Enhanced Budget Management at its level-15 gate adds custom priorities and an optional “also protect this reserve from automated seeds” toggle, initially Off, using the same farm reserve amount. Level eligibility alone does not grant the ability. Controls retained after respec are inactive while their capability is absent; they cannot silently enable an invalid Smart plan.

### 5.5 Skill resets

Players can pay coins to reset all allocated skill points, preserving player level/XP, purchased plots/equipment, and completed research. Refunded automation skills cease operating; existing planted crops retain their cycle snapshots. Provisional reset cost: `max(250, 50 × player_level²)` coins. Show cost before confirmation.

**Approved lifecycle (DEC-025/G3):** keep the removed abilities' configuration inactive after reset. Rebuying a skill does not automatically resume spending; explicitly enable/rearm the intended valid purchase plan. A normal reopen resumes already authorized, enabled valid loops without reconfirming each cycle or session. Current planted snapshots and the purchased plot prefix remain unchanged.

## 6. Store, equipment, and consumables

### 6.1 Permanent improvements

Permanent purchases remain in effect indefinitely; some have multiple escalating ranks.

- **Irrigation** reduces crop growth time: proposed ranks I–VI, additional -5% per rank, costs **650 / 2,100 / 12,000 / 60,000 / 300,000 / 1,500,000** coins.
- **Improved Soil** increases coin rewards: proposed rank costs **900 / 3,000 / 20,000 / 110,000 / 650,000**; provisional benefits +10%, +10%, +15%, +15%, +20%.
- **Seed Efficiency** (proposed advanced-seed discount family) is **Deferred beyond the current v1 scope** under DEC-008/G5; no ranks, prices, effects or saleable placeholder are implemented.
- **Research Facilities** (proposed research cost/time family) is **Deferred beyond the current v1 scope** under DEC-008/G5; no ranks, prices, effects or saleable placeholder are implemented.

Upgrades must display cost, precise effect, cap interactions, and unlock requirements.

**FR-AUD-006 — Required equipment guards (AUD-DEC-006 A).** Irrigation I–VI and Improved Soil I–V require sufficient coins and the immediately preceding purchased rank of the same family; rank I requires no previous purchase. Every rank has minimum player level 1 (no additional level restriction), no research/skill/contract guard, and is purchased manually one next rank per command. Reject skipped, duplicate, maximum-rank and unaffordable purchases without partial changes. Use the exact existing costs/effects above; they remain provisional balance data. Purchases affect future plantings only, preserving current cycle snapshots. Optional DEC-008 families remain Deferred. See TRS §20.6; AV-006-01–04.

### 6.2 Fertilizers — confirmed scalable pricing principle

Exactly one coin-yield fertilizer may be applied to a planting cycle. With `B` = unmodified base gross coin reward:

| Fertilizer | Harvest bonus | Purchase cost (whole coins) |
|---|---:|---|
| None | 0% | 0 |
| Basic | +25% | `max(20, ceil(0.15 × B))` |
| Premium | +50% | `max(75, ceil(0.35 × B))` |
| Advanced | +100% | `max(240, ceil(0.78 × B))` |

**Confirmed:** prices scale with crop value. **Provisional:** exact percentage coefficients and price floors. Price is based on base rewards, **not** skill/equipment-adjusted reward. Fertilizer is charged **at planting** and must be purchased again for another cycle. **Growth Booster is Deferred** under DEC-008/G5; no effect, price, additional consumable slot or saleable placeholder is introduced. Retain exactly the four choices None/Basic/Premium/Advanced. Revisit the three deferred additions only after playtests identify a need and the owner approves a complete scoped content/impact proposal. The approved research boost in §8 remains in v1; deferring Research Facilities does not defer acceleration.

### 6.3 Harvest and cost formulas

- `GrossCoins = floor(BaseCoins × (1 + total_coin_bonus))`.
- `NetCompletedCycleProfit = GrossCoins − seed_cost − applied_consumable_cost`.
- `EffectiveGrowthTime = BaseGrowthTime × (1 − capped_growth_reduction)`.
- Growth/reward modifiers are snapshotted at planting; amounts are whole coins/XP with consistent fixed-point rounding.
- **Approved rounding (DEC-005):** coin rewards round down, fertilizer prices round up, and effective growth duration rounds up to a whole microsecond with a positive minimum of 1 μs. The technical specification §4.4 defines the checked integer/basis-point arithmetic. This does not finalize the provisional growth cap or balance coefficients.
- **No negative coin balances**; required costs must be affordable before planting.

The crop-selection UI should show base and effective growth time, seed and fertilizer prices, predicted gross coins, XP, completed-cycle profit, and estimated coins/XP per hour. Show fertilizer's *incremental* profit and ROI so players understand tradeoffs.

## 7. Shared farming budget and Smart Fertilizer

### 7.1 Budget rules — approved field scope and authorization

- All plots share **one coin balance**; there are no per-plot sub-wallets.
- In a logical planting batch, process all its harvest payouts first, then reserve accepted **required seeds before optional fertilizer**. Optional spending never consumes seed commitments.
- Crop selection, auto actions, fertilizer policy/accepted fallback and eligible custom priorities resolve **Individual Plot > Plot Group > Farm Default**. Explicit false/zero overrides are not “unset.”
- **Approved exception (DEC-010/G3):** reserve amount, Budget Protection percentage and the advanced seed-protection toggle are **farm-wide shared-wallet controls**, not plot/group overrides. This narrows the earlier general inheritance wording deliberately; the other inheritable settings retain their hierarchy.
- Initial approved development defaults are **reserve 0 coins**, **protection 25%**, and **seed protection Off**. Percentages are editable 0–100% once the relevant skill is owned; numeric defaults remain provisional for balancing.
- Default plots have **equal priority**. Ascending plot ID orders mandatory seed allocation and equivalent choices; it is not a distinct optimizer-priority group per plot. Custom priority control requires Enhanced Budget Management.
- The basic reserve protects optional **automated fertilizer** spending. When the level-15 seed-protection toggle is On, paid automated seeds use at most max(0, wallet−reserve). Free seeds remain eligible even if the reserve exceeds the wallet.
- Fixed fertilizer rules are respected before Smart choices. Offer “plant the selected crop without fertilizer if seeds are affordable” as an **explicitly accepted** fallback. Without that permission, an unaffordable fixed rule stalls the request with no seed/fertilizer charge; retain its selected crop/settings. No crop or other fertilizer substitution is inferred.
- **FR-AUD-005 (AUD-DEC-005 A):** order candidates by effective priority then ascending plot ID. Reserve seeds, then process fixed fertilizer in that order. At the first unaffordable fixed request without accepted no-fertilizer fallback, exclude that request for this logical batch, discard all tentative seed/fixed reservations and replan the remaining candidates. Never reinsert an excluded request in that batch; seed-unfunded candidates may become eligible after a removal. At most N exclusions and N+1 passes are permitted for N≤32 requests. Compute M and the single shared C only from the final feasible plan, then run unchanged Smart policies. The final subset may be non-maximal; no maximum planted-count guarantee or substitution is inferred. Excluded requests retry only on a genuine relevant funds/configuration change, never merely a blocked-reason update. See TRS §20.5 and AV-005-01–05. Every accepted planting includes authorized costs, cycle creation and snapshots all-or-nothing; failed members are not partly charged.
- Direct manual farming may override protection only after displayed cost/ending-balance confirmation; its normal explicit confirmation can serve as the one-time authorization. No recurring second popup is required. Automatic replant after a manual harvest still obeys automatic budgets. Farming reserve does not block Store/research/expansion/skill-reset purchases.

**Approved simultaneous-batch boundary (DEC-006):** due research completes first, then the whole maturity/automatic-farming batch, before accepted manual commands. Each manual command executes as its own logical batch in accepted order. A Batch Harvest credits all its selected successful harvests before its own replant spending; later input cannot retrospectively join an earlier automatic batch. The now-approved manual-harvest replant/lifecycle policy is §9.2.

### 7.2 Smart Fertilizer modes and guarantees — approved DEC-009/G3

Buying Smart Fertilizer at its level-9 gate enables:

| Mode | Approved decision policy |
|---|---|
| **Maximum Profit** | Exact selection maximizing the sum of expected incremental **net coins/hour** for its relevant same-priority/same-mode group, under remaining authorized funds. |
| **Capital Efficiency** | Deterministic greedy preference for affordable profitable purchases/upgrades with highest **additional net profit / additional fertilizer cost**, refreshing candidates after each choice; no global-optimum claim. |
| **Budget Protection** | The same exact incremental-rate objective as Maximum Profit, limited by both remaining wallet funds and the remaining **single batch-wide protection ceiling**. |

Incremental profit is gross-with-fertilizer minus gross-without-fertilizer minus fertilizer cost; seed cost cancels in this comparison. ROI exists only for positive fertilizer cost. **None** is always a candidate and has no ROI calculation. Smart zero/negative-gain choices lose to None. An explicitly selected manual/fixed fertilizer may still be unprofitable; Smart never silently chooses it.

Use an exact Pareto-pruned batch strategy and a small independent exhaustive test oracle. For equivalent rate outcomes prefer lower spending, then stable plot/fertilizer IDs. Capital Efficiency ratio ties prefer higher additional net rate, then lower spend, then stable IDs. Exact comparisons use the approved integer arithmetic. Benchmark 32-plot runtime/frontier growth before production acceptance. If exact solving proves unsuitable, reopen DEC-009 and explicitly approve a new guarantee/label before adopting a bounded approximation; no automatic or hidden approximation fallback is approved.

### 7.3 Shared spending calculation and mixed-mode order

For automated planting and non-overridden Smart allocation, use the final feasible seed/fixed-fertilizer plan below. A directly confirmed manual override executes only its quoted authorized cycle, without changing stored R or granting an override to later automatic replant/Smart work.

1. Let W be wallet after this batch's harvest credits, S accepted seed costs, R farm reserve, and F explicitly fixed fertilizer costs.
2. Available optional funds before fixed spending are A=max(0,W−S−R). Require F≤A, honoring fixed rules in stable effective-priority/plot-ID order.
3. Remaining Smart funds are M=A−F. Compute **one** protection ceiling C=floor(M×protection_percent/100) for the whole logical batch.
4. Fund Smart groups by custom priority, highest first. At equal priority, order is **Maximum Profit → Capital Efficiency → Budget Protection**. All plots initially share equal priority, so a uniform-mode farm is optimized together.
5. Across all groups, Smart spending cannot exceed M. Across all Budget Protection groups combined, spending cannot exceed C. Each group uses remaining authorized funds and, where relevant, remaining C; never recompute the percentage per plot/group.
6. C is a ceiling, **not reserved money**: earlier groups may leave less, including zero. Higher-priority commitments constrain later optimum claims; there is no claim of one global optimum across conflicting modes/player priorities.
7. Reconcile charges to accepted planted cycles and commit the complete outcome atomically.

Example, not a new price table: W=1,000, S=200, R=100, F=100 gives M=600 and C=150 at 25%. If all Smart requests use Budget Protection, total fertilizer spending is at most 100 fixed +150 Smart and wallet ends at 550. Earlier other-mode spending can reduce actual protection-mode purchases below 150.

This percentage applies per logical simultaneous planting batch, including each eligible offline batch under the same simulator—not once over an entire offline interval. Automation never silently buys unselected crops, unsupported consumables, upgrades, research or skills.

### 7.4 Confirmed input and purchase terms

**FR-AUD-004 — Confirmed farming terms.** The controller stamps current accepted simulation time/order after independently due work; raw UI intents do not supply authoritative past times. Accepted replay commands remain immutable. Confirmations bind the target, crop/fertilizer/fallback, content context, exact costs/modifier results and recurring plan as applicable. For a direct manual reserve override, displayed ending balance is the confirmed minimum: unrelated extra income may leave more, never authorize a lower balance or greater charge. Changed terms refresh and require confirmation; no automatic replacement purchase follows a lost response. Skill-reset quotes bind the level and exact derived reset price. See TRS §§4.1/20.4 and AV-004-01–05.

## 8. Research and crop unlocks

- Every post-start crop requires **both level eligibility and completed research**.
- Research is started manually, has a coin cost and duration, and **continues while the game is closed**.
- **Approved DEC-007/G3:** exactly one research project may be active at a time.
- A project permits at most **one manually purchased boost**, under the approved initial formula below; no automatic/offline boost purchase or instant-completion option is introduced.
- Completed projects remain unlocked and **do not automatically change existing plots**, start another project, or purchase an upgrade.

**Approved initial acceleration policy (DEC-007/G3; coefficients provisional for balance):** let C be the research coin cost actually paid/snapshotted when the project started. One boost costs **ceil(C/2)** coins and changes remaining duration to **ceil(remaining_us/2)**, always positive. Disable/reject it with no charge if rounding saves no time. **Confirmation under FR-AUD-004 (AUD-DEC-004 B):** show the exact fixed boost charge and half-remaining formula; saved time/new completion are exact as of the displayed preview time. At controller acceptance after due work, recompute the exact accepted-time result using ceil(remaining_us/2) and show it in the result. Unrelated changes may leave a quote valid only when its authorized semantic terms remain unchanged; changed target, cost, modifier result, content or recurring plan requires refresh/reconfirmation. Completed, already-used, no-time-saved and unaffordable requests reject uncharged. Persist the original paid/timing snapshot and boost-used flag; save/reopen or a content update never restores the boost or reprices the active project. Completion invalidates its old scheduled event safely.

For Corn research paid at 800 coins, a boost costs 400; it reduces 20 minutes remaining to 10 or 10 to 5 for the same price. Without a boost, research continues normally, including offline. Existing level gates/research prices/durations below are unchanged and remain provisional.

**Provisional research data:**

| Crop unlocked | Required level | Research coins | Duration |
|---|---:|---:|---:|
| Carrots | 2 | 150 | 8 min |
| Corn | 4 | 800 | 20 min |
| Tomatoes | 7 | 2,800 | 45 min |
| Pumpkins | 10 | 9,000 | 120 min |
| Sunflowers | 12 | 10,000 | 60 min |
| Strawberries | 12 | 12,000 | 45 min |
| Blueberries | 15 | 24,000 | 90 min |
| Soybeans | 15 | 26,000 | 60 min |
| Grapes | 18 | 55,000 | 120 min |
| Coffee | 18 | 55,000 | 120 min |
| Cotton | 22 | 120,000 | 180 min |
| Rice | 22 | 110,000 | 150 min |
| Vanilla | 26 | 300,000 | 300 min |
| Saffron | 26 | 250,000 | 240 min |

Wheat starts unlocked.

## 9. Farming automation and offline behavior

- Auto Harvest and Auto Replant are separate unlocks/settings. When both are enabled, plots repeatedly harvest and replant as funds/configuration allow.
- When the application is **closed**, crops and running research continue, and previously unlocked/enabled automation completes multiple cycles as appropriate.
- Offline simulator accounts for seed/fertilizer spending, coin/XP gains, level-ups, accepted-contract progress, research completion, and stalls.
- An automated plot without seed funds becomes **empty and stalled**, preserving the selected crop; it may retry after a money-generating event.
- Newly earned offline skill points are **not auto-spent**; newly unlocked crops are **not auto-researched or auto-assigned**; no unapproved purchases occur.
- Process simultaneous harvests before any replant expenditures at the same time, then deterministic seed and fertilizer allocation.
- Apply the approved due-event and manual-command batch boundaries in §7.1; scene/frame callback order never determines economic spending.
- On return show **elapsed offline time, completed harvests, gross coins, seed/fertilizer expenses, net operating income, XP, levels, research completion, contract objectives, and interrupted plots**.
- No artificial cap on offline time or earned rewards. Long intervals must be handled efficiently, not by replaying every rendered frame.

### 9.1 Offline-first clock policy — confirmed

- No required network or external trusted time service.
- While running, gameplay uses monotonic elapsed time; Windows wall-clock adjustments must not speed up or reverse active gameplay.
- At restart, use persisted credited-through UTC anchor for offline elapsed time.
- If time moved **backward** beyond the saved anchor, do **not** grant negative time or erase earned progress; preserve the anchor and record an inconsistency.
- Positive offline intervals (including unusually long ones) are honored after validation; deliberately advancing a disconnected PC's clock cannot be reliably prevented and is accepted under the offline-first policy.
- Time-zone and daylight-saving changes do not affect UTC-based growth.
- Sleep/hibernate resume must reconcile elapsed time correctly. Debug speed does not multiply time spent sleeping or closed.

**Approved elapsed-time accounting (DEC-013):** track already-accounted active, suspended and closed intervals. Active simulation uses monotonic elapsed time multiplied by the selected debug rate; the credited-through UTC anchor advances only by actual accounted real elapsed time. State, anchor and reconciliation metadata commit together. A sleep-inclusive timing observation must not cause a second sleep correction. Approved DEC-014/G4 selects a measurement-first procedure: use Godot timing plus lifecycle observations only if they prove sufficient active/suspended partitioning; otherwise isolate the required Windows adapter behind TimeProvider. A single elapsed counter or a long frame is not evidence of the suspended portion. Exact provider/API selection and measured suspend evidence remain Open; all suspended time still receives 1×.

A forward wall-clock edit during play does not accelerate active crops, but its positive UTC difference can be honored at the next restart under the existing offline-first policy. After a rollback, the preserved anchor may remain ahead of displayed UTC, giving zero additional offline time until UTC exceeds it. Do not silently rebase the anchor backward, erase progress or introduce an online clock requirement to conceal these accepted consequences.

### 9.2 Approved automation authorization and batch behavior — DEC-025/G3

- Enable/Apply is an explicit authorization of a valid recurring crop/fertilizer purchase plan; opening a menu or selecting an item is not a purchase.
- A new Empty-plot loop requires Plant or Apply-and-start authorization. Already authorized loops stalled for funds retry under unchanged accepted rules when relevant funds/configuration becomes available. Changing a stalled purchase plan or rearming after reset requires explicit authorization.
- Enabling Auto Harvest on an already-Ready crop may harvest immediately after the due-event boundary; show that consequence before enable. When Auto Replant is enabled/authorized, both manual and automatic successful harvests follow the same replant rule and automatic budgets.
- Future settings/presets never replace a growing snapshot. Applying future settings to an occupied plot explicitly authorizes those future recurring choices. Normal reopen/offline progression resumes enabled, authorized valid loops without a new per-cycle/session prompt.
- Presets hold settings, not wallet/XP/research/skills/plot ownership. They cannot buy a Locked plot or bypass the sequential fourth-row rule. Newly purchased plots are not automatically planted by the purchase.
- Rotation uses only the explicitly approved sequence. Advance its cursor only on a **successful planting** of the current entry; failed affordability/eligibility leaves the cursor and selected plan intact and stalls. No unapproved replacement crop is inferred.
- Manual Batch Plant/Batch Harvest/Apply-and-start skips ineligible members with per-plot reasons and commits its authorized eligible subset as **one atomic outcome**. Each accepted planting is all-or-nothing; successful batch harvest credits precede its replant costs. A wholly invalid command changes no gameplay measured after due work. A definitely not-committed candidate is not published; an unknown receipt stops for FR-AUD-002 reconciliation and is never treated as rollback. Failed manual members have no partial charge/gameplay effect.
- On respec, removed capabilities stop immediately and retained configuration becomes inactive. Rebuying them does not silently restart spending. The current cycle, plot prefix and paid upgrades/research remain preserved.

All operations use the same engine, budget, snapshot and durable replay rules. These policies add no new crop system, currency or gameplay purchase family.

**FR-AUD-007 — Group lifecycle (AUD-DEC-007 B).** Each plot belongs to one existing group or none. Create, rename, edit, assign/unassign and delete use stable group identities/revisions and a bounded effective-plan diff. Rename or an overridden field that leaves the effective economic plan unchanged preserves authorization. Effective occupied-plot changes require explicit future-settings Apply and preserve the planted snapshot. New Empty starts, changed Stalled plans and rearming require explicit Plant/Apply-and-start; Ready Auto Harvest enable previews its existing immediate consequence. Deleting a nonempty group requires an explicit existing destination or ungroup-to-farm choice, fresh preview and resolution of all preset references; never silently adopt paid defaults. Structural graph changes are all-or-nothing; explicitly associated farming actions separately retain DEC-025 eligible-subset semantics within the coherent outcome. Locked plots may retain inactive settings but are never unlocked/planted by grouping. No extra group-management level/skill gate is added; named presets and individual fields retain their existing owned capabilities. Contracts/default records are M02, persistence M03, complete advanced behavior/UI M05. See TRS §20.7; AV-007-01–06.

## 10. Optional agricultural contracts — approved DEC-019 / C2

### 10.1 Lifecycle and scope

- Contract Board starts at **Level 7**, with **three accepted/unclaimed slots**, as approved provisional development defaults.
- Contracts remain optional and never gate crops, skills, research or expansion.
- Use versioned authored one-time offers with stable IDs and the twelve approved definitions below. No procedural refresh, cooldown economy, expiry timer or repeatable reward loop is introduced.
- Players manually accept, claim and confirm abandonment. Acceptance creates a unique instance and snapshots the exact objective/reward definition. Completion only makes it claimable; completed-unclaimed still occupies a slot.
- Claim atomically pays its frozen coins/XP once, records claim identity and closes the offer against a second reward. Claim income is separate from crop gross; no contract currency or harvested-crop inventory exists.
- Confirmed abandonment discards progress with no reward/refund. An abandoned unclaimed offer may be reaccepted under a fresh instance at zero progress; a previously claimed one-time offer never pays again within the authoritative retained timeline. Older-backup recovery rolls back the discarded claim credit and flag together under FR-AUD-001; it is not an all-lost-branches permanence guarantee.
- Persist definition/acceptance snapshots, progress, slot/offer/instance state and claimed-offer eligibility with authoritative economic state through save/offline/recovery/content updates.

### 10.2 Approved initial authored catalog

Owner confirmed **“Closeout B option A - approved.”** All twelve rows are approved **provisional development data**, covering quantity, mixed, gross-revenue and automation families at levels 7/18/26. Final tuning requires a separately recorded versioned decision.

| Stable offer ID | Family | Minimum level | Objective after acceptance | Coin reward | XP reward |
|---|---|---:|---|---:|---:|
| CON-Q01 | Quantity | 7 | 96 Wheat harvests | 153 | 57 |
| CON-Q02 | Quantity | 18 | 48 Grapes harvests | 28,320 | 2,304 |
| CON-Q03 | Quantity | 26 | 96 Saffron harvests | 96,000 | 10,560 |
| CON-M01 | Mixed | 7 | 48 Wheat AND 24 Carrots harvests | 163 | 57 |
| CON-M02 | Mixed | 18 | 24 Grapes AND 24 Coffee harvests | 24,720 | 2,952 |
| CON-M03 | Mixed | 26 | 24 Vanilla AND 48 Saffron harvests | 106,800 | 9,840 |
| CON-R01 | Gross revenue | 7 | 8,640 gross crop coins | 864 | 224 |
| CON-R02 | Gross revenue | 18 | 377,600 gross crop coins | 37,760 | 3,072 |
| CON-R03 | Gross revenue | 26 | 1,568,000 gross crop coins | 156,800 | 12,160 |
| CON-A01 | Automation | 7 | 48 automatically harvested Corn cycles | 528 | 153 |
| CON-A02 | Automation | 18 | 48 automatically harvested Coffee cycles | 21,120 | 3,600 |
| CON-A03 | Automation | 26 | 48 automatically harvested Vanilla cycles | 117,600 | 9,120 |

### 10.3 Eligibility and progress predicates

- Require Board access and the row's minimum level. Quantity, mixed and automation offers also require every named target crop unlocked by its normal level+completed-research guards **before acceptance**. Gross-revenue offers count any eligible crop and do not require their design-reference crop researched.
- Automation offers additionally require **ownership of Auto Harvest at acceptance**; Auto Replant is not required. Count only harvests actually initiated by automatic harvesting. Manual harvest on an automation-enabled plot does not count as an automatic harvest.
- Disabling/refunding automation stops future automatic qualifying activity without erasing accepted progress. Existing skill/rearm and stalled-loop rules still apply; accepting a contract never authorizes farming purchases.
- A successfully harvested cycle counts **one**, regardless of coin/yield modifiers. A batch of N distinct qualifying cycles counts N. Mixed goals require **both** named counts, tracked independently; no physical inventory or consumption is introduced.
- Gross-revenue objectives count actual committed crop gross after its snapshotted modifiers, excluding claims and all other credits/debits. Each row's target is fixed authored data, not recalculated per player.
- Count only qualifying harvests **after acceptance in deterministic engine order**, including eligible offline harvests. Timestamp/sequence identifies the boundary: due harvests already processed before acceptance do not count; a later ordered manual harvest at the same simulation timestamp can count. Crops planted before acceptance may count when harvested afterward. Never credit historical pre-acceptance rewards.
- An event may advance every accepted contract it independently satisfies, **once per contract/cycle**. No shared harvested inventory is consumed, and the approved three-slot rule remains unchanged.
- Accepted objective/reward snapshots never reprice after upgrades or data changes. Manual claim/abandon/reaccept and once-only offer eligibility apply identically offline and after recovery.

### 10.4 Design-time reward rationale and balancing boundary

The fixed table was authored as floor(10% of the reference activity's **unmodified base gross**) coins and floor(10% of its base XP). Quantity/mixed/automation rows use the named target harvests; revenue rows use only the reference below to author their reward. References are **not** revenue-objective crop restrictions, a runtime reward formula, or a promise of 10% net profit.

| Offer | Baseline reference activity from FRS §4.2 | Base gross reference | Base XP reference |
|---|---|---:|---:|
| CON-Q01 | 96 × Wheat | 1,536 | 576 |
| CON-Q02 | 48 × Grapes | 283,200 | 23,040 |
| CON-Q03 | 96 × Saffron | 960,000 | 105,600 |
| CON-M01 | 48 × Wheat + 24 × Carrots | 1,632 | 576 |
| CON-M02 | 24 × Grapes + 24 × Coffee | 247,200 | 29,520 |
| CON-M03 | 24 × Vanilla + 48 × Saffron | 1,068,000 | 98,400 |
| CON-R01 | 32 × Tomatoes | 8,640 | 2,240 |
| CON-R02 | 64 × Grapes | 377,600 | 30,720 |
| CON-R03 | 64 × Vanilla | 1,568,000 | 121,600 |
| CON-A01 | 48 × Corn | 5,280 | 1,536 |
| CON-A02 | 48 × Coffee | 211,200 | 36,000 |
| CON-A03 | 48 × Vanilla | 1,176,000 | 91,200 |

The approximate 5–12% activity-equivalent idea remains a balancing rationale; these exact initial rows are approved, not final human-engagement evidence. Retuning requires a recorded content/version decision preserving accepted snapshots and claimed-offer eligibility. Generic M03 protocol fixtures do not substitute for M05's actual authored predicates/rewards/crash tests.

## 11. Live farm statistics and profitability — confirmed

**Available from Level 1** through a dedicated panel/button, not constantly overlaid on farmland.

### 11.1 Time ranges

Last **1 hour**, last **24 hours**, **current session**, and **lifetime**. Include offline farming activity in historical periods at the simulated time when it occurred.

**Approved DEC-017/G4:** production history uses the monotonic simulation timeline. Hour/day historical windows contain the last **60 / 1,440 completed simulated-minute buckets**, ending at the last completed simulated minute; display an “as of” time. They may lag by less than one simulated minute. Show current live totals separately rather than claiming exact arbitrary-second rolling endpoints from coarse buckets. Debug reports explicitly label simulated-hour/day periods and normalize rates by simulated elapsed time; record real/UTC/offline/debug correspondence separately. Wall-clock edits never rewrite historical bucket keys.

**Approved DEC-018/G4:** start current-session counters **after successful startup catch-up commit**, before active simulation. Display startup offline earnings separately; rolling/lifetime history still includes them. An in-process suspension after session start remains part of that process session, labeled suspended rather than active engagement. Guard zero-duration rates.

### 11.2 Indicators

- Growing/ready/empty/stalled plots; number under auto-harvest and auto-replant; productive utilization and separate instantaneous occupancy.
- Harvest count, gross crop coins, seed spending, fertilizer spending, XP earned.
- **Completed-cycle operating profit** (harvest gross income minus that crop cycle's associated seed and fertilizer costs).
- **Cash-flow/net coin-balance change**, including when payments/collections actually happened; show upgrades, research, expansions, skill resets, and claimed contract rewards separately.
- Actual gross coins/hour, operating coins/hour, and XP/hour; crop and individual plot breakdowns, idle time and stall reasons.
- Historical trend charts for income, profit, expenses, XP, and harvest count.

**Approved utilization (DEC-018/G4):** productive utilization = growing plot-time / unlocked plot-time. Instantaneous occupancy = (Growing + Ready plots) / unlocked plots. Track disjoint Growing, Ready-waiting, Empty-not-stalled and Empty-stalled time; the displayed Empty total includes the Stalled subset and must not double-count it. Integrate unlocked capacity over time, so a purchased plot enters the denominator only from purchase onward. Ready waiting is occupied time, not productive growth.

### 11.3 Actual vs projected

- Clearly label **historical actuals**, **next-hour forecast** from the present farm state, and optional **steady-state/hour** rate.
- Forecast must use the **same simulator/economy rules** and a copy of state, including crop progress, approved farm-wide budgets/mode order, active loop authorization, skills, seed costs, fertilizer modes, rotation cursor and stalled plots. It must not change real game state.
- Use clear 1× simulated-time normalization for productivity comparison; debug acceleration must not inflate normalized coins/hour.
- Historical data must be aggregated/retained efficiently; do not accumulate unlimited detailed harvest events.

**Approved initial retention policy (DEC-017/G4; engineering values subject to measured review):** minute aggregates for 48 **simulated hours**, hourly aggregates for 90 **simulated days**, lifetime per-crop/per-plot totals. Preserve current partial-minute/live totals separately, active-cycle cost attribution and bounded replay/claim protection when pruning. Forecast one simulated hour at 1× on the isolated copy; research/contract transitions on that copy never affect live state.

## 12. Developer tools and balancing

- Debug Settings speed slider **1× to 60×**, integer steps, defaults/resets to **1×** each new session, updates immediately.
- Multiplier accelerates simulation-based growth, research and automatic farming; it does **not** accelerate rendering FPS, ambient animation, user input, background music, sound pitch, or sound playback rate.
- Closed/offline periods progress at **normal 1×**.
- Debug speed clearly indicated when >1×, and hidden/omitted from the production game build.
- Separate debug save profiles to avoid modifying normal progress.
- Provide headless scenario testing and economic metrics to validate progression, skill builds, fertilizers, and long offline periods.

### 12.1 Pacing and content validation

- 3–5 active hours to full automation for a suitably focused player (goal; not promised for every strategy).
- About 48 additional **active gameplay hours** of meaningful decisions (research, upgrades, optimization, optional contracts). **Do not conflate** 48 hours of automatic crop production with 48 hours of player engagement.
- Level 30/520,000 XP, 15 crops, costs, XP curve, and upgrade coefficients are **provisional** and must be evaluated with normal-speed active-only and mixed/offline strategies.
- DEC-002/G2 approves the complete through-30 development table; C1 now approves option B's increasing continuation in §5.1.1. Both remain provisional for final balance. Retuning requires a recorded decision; do not substitute a constant tail, cap XP/points or invent progression rewards.
- Strong strategies may progress faster, and large offline earnings must not be arbitrarily reduced just to force the time target.

**Approved evidence policy (DEC-024/G5):** combine complete costed automated economy scenarios with normal-speed human playtests. Compare focused four-node automation, mixed growth/profit, coin/XP and low/high-reserve strategies in active-only and mixed-offline play, including a full no-contract progression scenario. Pay all real seed/fertilizer/research/boost/upgrade/plot/reset costs and record explicit player decisions; no free unlocks or deferred equipment enter progression evidence.

Automated traces establish production, costs and unlock timing, not human engagement. Record local real-open, foreground, simulation, suspended/offline and debug time separately. Initial provisional engagement indicator: foreground with meaningful input/decision within the previous five real minutes, supplemented by human decision diaries. It is a telemetry aid, not a click quota or a definitive judgement of planning/reading. Closed/suspended time and debug multiplication never establish active-play hours. Define a varied human sample before M05 completion, and report its actual size, observed duration and limitations in M06; shorter pilots alone cannot prove the additional ~48-hour goal.

Report target met/missed/insufficient evidence, dominance and content exhaustion honestly. A miss prompts an explicit content/balance/release review; it does not authorize silent price/XP changes, deferred additions, arbitrary offline caps, forced waits, mandatory contracts or reduced earnings. Preserve active-cycle snapshots and version any separately approved tuning.

## 13. Save and reliability — player-facing requirements

- Local, automatic save and resume; saving/reopening preserves coins, XP, skills, plots, crop timers, upgrades, research, automation rules, contracts, statistics and audio preferences.
- Approved G3 persistence also preserves farm reserve/percentage/seed-toggle settings, accepted loop/fallback authorization, inactive configurations, rotation position and research boost-used/paid snapshots. It does not persist a half-applied planting plan or grant a second boost after restart.
- Important economic transactions and offline catch-up must never be partly credited; no repeated harvesting, planting charges, or claimed contract rewards after crashes.
- Maintain recovery/backup support and safe migration of compatible saved games.
- If storage fails, show a clear notice rather than silently claiming the save succeeded.
- Only one process modifies a given save profile at a time.
- First release is fully playable without online authentication or cloud services.

**Approved durability/settings (DEC-015/021/G4):** publish successful economic commands and coherent automatic batches only after their complete durable commit. Use 30 **real-second** time-only checkpoints, independent of debug speed. Maintain two validated rotating backups with an initial **10-real-minute** cadence after successful validated checkpoints, also after validated startup/load, before migration and after successful clean shutdown. Never rotate a corrupt/unvalidated/tentative copy over good recovery generations. Backups can be older than the primary. Shutdown accounts/commits final time; catch-up remains one private calculation and atomic result+anchor checkpoint, without a disk commit for every historical event. A definitely not-committed result retains the prior durable outcome. An unknown commit receipt follows FR-AUD-002 reconciliation and blocks all writes; recovery/retry/exit must never overwrite a possibly committed primary from stale memory. Profile-owned versioned GameSettings is included in the save; restore it before audio. These are initial engineering defaults requiring future qualification, not proof of tested durability.

**Approved retry protection (DEC-016):** economic commands use profile/writer-session/counter identities. Already committed, stale and retired-session commands cannot execute again, including after recovery or response-cache pruning. Returning an old command's full response is optional when it is no longer cached; preventing a second charge/reward is mandatory. A rejected command has no partial gameplay effect. The durable identity/epoch protocol is specified in technical §4.1.

**Approved numeric-limit recovery (DEC-026):** no arbitrary offline-duration or reward cap is introduced. If an actual result cannot be represented safely by the game's checked integer state, retain the complete previous checkpoint and credited-through anchor, publish no partial rewards, and show a recoverable diagnostic for a deliberate recovery/version decision. Never wrap, silently saturate balances or discard eligible time. Ordinary 30-day and one-year scenarios for the released content must still succeed; this error policy is not a performance shortcut.

**FR-AUD-001 — Recovery history (AUD-DEC-001 B).** Restoring an older validated backup restores its complete authoritative timeline: wallet/XP/accounting and offer claim flags roll back together. A discarded-branch claim credit is discarded with its flag; an absent claim may become eligible again within the recovered timeline. Intact-primary one-time claims and stale-command rejection remain mandatory. Newly allocated dynamic identities cannot collide with lost-branch entities; existing entity, plot and authored IDs are retained. Disclose recovered time/revision and possible lost progress. No all-lost-branches claim ledger or anti-rollback guarantee is introduced. See TRS §§3.1/9.3/20.1; AV-001-01–04.

**FR-AUD-002 — Unknown save outcome (AUD-DEC-002 B).** A lost commit response is not proof of rollback. Distinguish committed, definitely not committed and unknown results. During uncertainty retain ownership and block economic input and every save/backup/migration/shutdown write until the settled primary is validated and the complete committed result or unchanged parent is selected. No new purchase replaces the original operation; unreadable/unexpected state stays recoverably stopped. Rebuild state/scheduler/replay/anchor and reconcile pending real intervals once before resuming. Cosmetic drafts may remain visibly unsaved. See TRS §§9.2/20.2; AV-002-01–05.

## 14. Explicit first-release exclusions and future options

**Excluded from initial release:** prestige, multiplayer, player-to-player trading, physical harvested-crop inventory, crop spoilage, real-money purchases, leaderboards, obligatory online services, and mandatory contract completion. **Potential later work:** browser version, Steam integration/cloud saves, prestige/rebalance, further farm systems, and expanded art effects. **Approved deferred additions (DEC-008/G5):** Seed Efficiency, Research Facilities and Growth Booster, with revisit trigger “post-playtest scoped content proposal” and separate explicit approval before inclusion.

**Approved Windows delivery (DEC-027/G6):** ship a versioned standalone ZIP containing the executable and required game data/native dependencies, licenses and checksums. Players extract the package; updating/replacing/removing application files must preserve the farm in its separate per-user application-data location. Validate normal-user launch without editor/network/login, missing native dependencies, read-only/space-containing application paths, update/recovery and save preservation. A conventional installer/signing is optional and needs a concrete separate selection before implementation; it is not a v1 completion prerequisite. Steam APIs/cloud saves/storefront integration are deferred beyond v1 unless separately authorized. Exact supported architecture/native-binary pins and actual packaged test results remain separate records.

The selected tech direction is **standard Godot 4.7.2-stable + typed GDScript**, matching standard 4.7.2 export templates, GUT v9.7.1 and Compatibility; Windows11 x86_64 first. Evaluate isolated godot-sqlite v4.9 with its reported SQLite 3.51.0 before native adoption; exact artifact fingerprints/license inventory and packaged behavior remain future verification, not selected unnamed binaries. The architecture remains Windows first; design should retain a viable later browser port. The separate technical specification details implementation boundaries.

**Approved DEC-022/G4:** audit shared-core/platform boundaries in M01 and run a minimal browser compatibility probe by the end of M03. It tests boot/rendering, shared-core initialization, test snapshot storage/error handling and suspend/resume reconciliation without Windows SQLite. It is an early architecture check, not a full browser game or a promise of browser durability equal to Windows. Browser-specific findings may remain future work; native dependencies leaking into the shared kernel must be fixed. Record actual/partial test evidence honestly.

## 15. Functional acceptance checklist

- [ ] Windows 11 graphical isometric farm at 1920 × 1080 initial target, with GPU acceleration on supported NVIDIA/AMD/Intel hardware, delivered as a versioned standalone ZIP with per-user saves preserved across application replacement/removal.
- [ ] Twenty-four Empty start plots in an 8×3 layout; fourth-row IDs 25–32 unlock sequentially with level+coin gates, without unlock gaps, reaching 8×4.
- [ ] Independent crops, five visible growth stages, subtle swaying and harvest feedback.
- [ ] Basic free seeds, advanced paid seeds, level+research crop gates.
- [ ] Correct harvesting coins, XP, player levels and skill point awards.
- [ ] Three skill branches, prerequisites, skill costs and coin-paid resets.
- [ ] Permanent equipment and single-cycle consumables, including scaled fertilizer pricing.
- [ ] Basic fixed repeat fertilizer purchases without Smart Fertilizer.
- [ ] Level-9 Smart Fertilizer with Maximum Profit, Capital Efficiency and Budget Protection.
- [ ] Shared wallet; seed-first then fixed/Smart allocation; one protection ceiling per batch; farm-wide wallet controls and inherited plot/group/farm crop/action/fertilizer/priority settings; explicit fallback/authorization.
- [ ] Research, acceleration controls and full offline continuation of running projects.
- [ ] Manual/batch/automatic planting and harvesting, with full offline cycles once unlocked.
- [ ] All twelve C2 authored one-time optional contracts, exact level/research/AutoHarvest guards, post-acceptance multi-objective/offline progress, three accepted/unclaimed slots, frozen rewards, explicit abandonment/reacceptance and single-claim outcomes.
- [ ] Level-1 Statistics panel; completed-minute as-of windows, separate live/session/offline totals, growing-time utilization versus occupancy, actual vs forecast and operating vs cash-flow.
- [ ] Background music controls and per-class sound volume including 0% mute; aggregated harvesting effects.
- [ ] Debug 1×–60× simulation speed without changes to visual FPS/audio playback speed.
- [ ] Durable economic acknowledgements, approved time-only/backup cadence, validated recovery, profile-owned settings, offline catch-up and duplicate/time-anomaly protection.
- [ ] M03 minimal browser probe evidence, with full browser release still future scope.
- [ ] Complete costed automated economy traces for the 3–5-hour automation target, plus actual normal-speed human findings for automation pacing and approximately 48 additional engaging active hours; report limits/misses without substituting simulated production duration.
- [ ] Named reference hardware/vendor qualification and separately reviewed coherent asset samples; no undefined deferred equipment/consumables in v1.

- [ ] Audit A1 acceptance: FR-AUD-001–007 / TRS §20 and AV-001–007 preserve identity/recovery, reconcile unknown commits, bind profile rules/confirmed terms, terminate replanning and validate all equipment/group guards. Runtime evidence belongs to the named milestone owners; documentation application alone checks no gameplay box.

## 16. Open balancing and UX decisions (not silently approved)

1. Final progression pacing/balance remains provisional. DEC-002's through-30 table and C1 option B increasing continuation are now defined; continuation/cap is no longer an open design choice. No earned XP or surplus points are discarded.
2. Final numerical crop/seed/equipment/research/plot/fertilizer tuning remains provisional. Seed Efficiency, Research Facilities and Growth Booster are explicitly Deferred under DEC-008; their undefined rules are not v1 implementation blockers.
3. Final skill effect/rank-maximum/cap balancing remains provisional. Required equipment guards are now completely defined by FR-AUD-006; they are no longer an open gate decision. One-point rank costs and branch prerequisite rules are approved under DEC-004; do not replace them with full-tier prerequisites without a new approved change.
4. Final balancing of approved one-project/one-boost half-cost/half-remaining research policy, with Research Facilities explicitly Deferred under DEC-008; the initial formula/limit is no longer undefined.
5. Benchmark/quality evidence for the approved exact/ROI Smart policies, final balancing of approved reserve/protection defaults and UI wording. Approximation requires a new explicit decision; farm-wide field scope/fallback/priority order are no longer undefined.
6. DEC-023/C3 selects Clean illustrated; crop art direction is no longer open. Production art-bible parameters, all 75 crop-stage assets, visual effects, sound assets and final tuning still require their planned specification/review/validation.
7. DEC-024/G5 evidence method and initial five-minute/diary indicator are approved; exact human sample/protocol execution and findings remain future evidence, not proof from planning approval.
8. DEC-019/C2 now defines the exact twelve-offer catalog, availability/progress predicates and frozen provisional rewards. Actual balance/human evidence and any later content changes remain separately reviewable; these initial definitions are no longer missing.
9. Exact release artifact/commit/checksum/license inventory, empirical provider selection, save/backup performance qualification and browser-probe results remain implementation evidence obligations. G4 statistics windows, session/utilization and settings ownership are no longer undefined.

---

**Change control:** Treat this file as the functional source of truth for the first-release scope. Update it when *gameplay behavior* changes. Use `IdleFarmer_Technical_v1.5.md` for *architecture, persistence, reliability, testing, and implementation* requirements. Clearly mark future numerical proposals until playtested and explicitly approved.
