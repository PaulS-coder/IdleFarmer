# M02 — Readiness findings and proposed decisions

Date: 2026-10-30 · Status: **working note, non-authoritative** · Scope:

**Owner approval, 2026-10-30: "Accept all".**

- Q1–Q3 are answered as recommended in §3.
- E1–E18 (§6) are approved as working implementation decisions for M02 and recorded in [M02_Build_Plan.md](M02_Build_Plan.md).
- The documentation corrections C1–C3 (§4) remain proposals; they need a separate, specific approval before any existing document is edited.

- Is M02 ([02_M02_Economy_Skills_Research_Automation.md](02_M02_Economy_Skills_Research_Automation.md)) fully specified at the product level, or does it need a brainstorm?
- Is the M02 plan sufficient to code from, given the M01 code as actually built?

This note changes no existing document.

**Sources reviewed:**

- the M02 plan;
- FRS §§3, 5.2–5.5, 6–9 and FR-AUD-004–007;
- TRS §§3.3–3.5, 4, 5, 6, 15/15.1 (T-004–008, T-023/024, AV-004–007) and 20.4–20.7;
- Decision Register DEC-004/007–012/020/024/025, and Audit Decision Register AUD-DEC-004–007;
- DVS-003/005/006/008–013/033;
- the merged M01 code, its handoff and its build plan.

## 1. Verdict

| Question | Answer |
|---|---|
| Is another brainstorm needed? | **No.** All M02 product rules and numeric tables are specified and approved (G2/G3/G5, C1, AUD-DEC-004–007). Two small player-facing questions (Q1, Q2) can be answered in one line each, without a session. |
| Is the M02 plan sufficient to code from? | **No.** Like M01, it is a policy/acceptance document. M01 also diverged from its suggested structure, several M01 internals must change (batch pipeline, command plumbing, typed settings), and about 18 engineering choices are open. **Create `M02_Build_Plan.md`** in the M01 format once Q1–Q3 and the proposed decisions are approved. |
| Biggest risk | Maximum Profit and Budget Protection require an exact optimum over a sum of rates with different denominators. This needs arbitrary-precision rational arithmetic in GDScript plus a Pareto frontier that is fast enough for 32 plots × every offline batch. **A spike should be the first M02 work.** If exactness proves infeasible, DEC-009 must be reopened (an owner decision) rather than quietly approximated. |

## 2. Data completeness (all present; all provisional for balance)

| Data | Source | Status |
|---|---|---|
| Irrigation I–VI | FRS §6.1 | Costs 650 / 2,100 / 12,000 / 60,000 / 300,000 / 1,500,000; −5% growth per rank. Complete. |
| Improved Soil I–V | FRS §6.1 | Costs 900 / 3,000 / 20,000 / 110,000 / 650,000; effects +10 / +10 / +15 / +15 / +20%. Complete. |
| Equipment guards | FR-AUD-006 | Coins plus the previous rank only; level 1. Complete. |
| Fertilizer | FRS §6.2 | None 0 / 0. Basic +25%, price max(20, ⌈0.15B⌉). Premium +50%, max(75, ⌈0.35B⌉). Advanced +100%, max(240, ⌈0.78B⌉). B is the unmodified base reward. Complete. |
| Skill effects | FRS §5.2–5.4 | Growth −4%×5, −3%×5, −5%×3. Coins +8%×5, +12%×5, +20%×3. Automation chain gated at levels 3/4/6/7/9/12/15/20. Complete. |
| Growth cap / bonus stacking | FRS §5.2, TRS §4.4 | Additive; 60% cap on growth reduction; coin bonuses do not affect XP. Complete. |
| Reset cost | FRS §5.5 | max(250, 50·L²). Complete. |
| Plot expansion | FRS §3 | Plots 25–26: level 3, 250 each. 27–28: level 5, 1,000. 29–30: level 8, 4,000. 31–32: level 12, 12,000. Total 34,500. Complete. |
| Research and boost | FRS §8 | 14 rows already in `content_m01_v1`. Boost: ⌈C/2⌉ coins and ⌈remaining/2⌉ time, once per project. Complete. |
| Budget maths | FRS §7.3, TRS §6.2 | A = max(0, W−S−R), M = A−F, C = ⌊M·p/100⌋ once per batch. Defaults R=0, p=25, seed protection Off. Complete. |
| Smart modes and tie-breaks | FRS §7.2, TRS §6.3 | Defined, with oracle scenarios DVS-008/010 and AV-005-01/03. Complete. |

## 3. Product questions for the owner (short answers suffice)

| # | Question | Why it is open | Recommendation |
|---|---|---|---|
| **Q1** | When a player manually plants a plot that has Auto Replant enabled, does that **arm the recurring loop**, and with what? | FRS §9.2 says a new Empty-plot loop needs "Plant or Apply-and-start authorization", but it does not say which plan a plain Plant authorizes when the planted crop or fertilizer differs from the plot's configured plan. M01 decided that manual planting does not change the selected crop. | Plant arms the loop **only when** the planted crop and fertilizer match the plot's effective configured plan, and the quote shows the recurring plan. Otherwise it is a one-off planting and the loop stays unarmed until an explicit Apply-and-start. *Alternative:* Plant overwrites the plot's own setting with what was planted. |
| **Q2** | Capital Efficiency ranks fertilizer purchases by "additional net profit / additional cost". Is that profit **per cycle** (classic ROI) or **per hour**? | FRS §7.2 and TRS §6.3 don't say. The UI elsewhere shows per-cycle ROI (FRS §6.3), and Capital Efficiency's tie-break uses "higher additional net rate", which implies the primary ratio is not the rate. | **Per cycle** (classic ROI), with ties broken by higher per-hour rate, then lower spend, then stable IDs. |
| **Q3** | Confirm the **staging of seed protection and custom priorities**. | The M02 tasks (T10/T11, V13, AV-005-04) test them, but DEC-012 and TRS §6.4/§16 say M05 completes them. | M02 implements and tests their **allocator logic and level-15 gates with fixtures**; their configuration commands return `FEATURE_UNAVAILABLE` until M05. |

## 4. Documentation inconsistencies (proposed corrections; not applied)

**Applied 2026-10-30:** C1–C3 were applied as dated notes in the M02 plan with owner approval; see [M02_Proposed_Doc_Changes.md](../../artifacts/M02/M02_Proposed_Doc_Changes.md). C4 needed no change.

| # | Issue | Proposed fix |
|---|---|---|
| C1 | Staging conflict over seed protection and custom priorities. | Record the Q3 ruling in the M02 plan. |
| C2 | M02-T07 says research has "level+research gates", but research projects have no research prerequisites (DVS-033). | Change the wording to "level gate". |
| C3 | Stale lines in the M02 plan: L7 says skill/budget/optimizer decisions are "not approved", and L261 lists "D-04/06–12/20/25 decisions" as future outputs. Both are superseded by G2/G3. | Add a dated note marking them historical. |
| C4 | TRS §4.3 has an "Empty → Stalled" transition while FR-FARM-04 lists four plot states. | No fix needed. Implement Stalled as Empty plus a stall reason and authorization, not a fifth state. |

## 5. M01 carry-over findings (fix early in M02)

These are honest gaps in the merged M01 code. None affects M01's tested behaviour, but M02 would expose each one.

1. **Engine-level committed-harvest/accounting hooks were not implemented.** M01-T13 and build plan §3.6 asked for no-op hooks. The controller's post-commit `add_commit_listener` covers *publication* but not a typed committed-harvest port. Implement it as part of M02-T16.
2. **`StateChangeBatch.append` drops `failure_code`,** and `GameController._advance` commits regardless. This is latent because M01's advance cannot fail, but M02 batches can hit a numeric limit. Fix: an advance that fails at a timestamp stops there and commits nothing (DEC-026).
3. **The controller commits the due work when a command is rejected.** That is correct only while every command validates before it mutates. M02 batch commands must follow plan-then-apply.
4. **`EconomicTransaction` requires a `cycle_id`.** Research, upgrade, expansion and reset transactions need it nullable, plus an origin (manual or automatic).
5. **Response-cache entries store full result primitives inside `GameState`.** With 32-plot batch results, 256 entries will bloat state and digests. Store compact entries instead.

## 6. Proposed engineering decisions for the M02 build plan (need approval)

| # | Topic | Proposed decision |
|---|---|---|
| E1 | Manifest | New `content_m02_v1`: a superset of v1 with the M01 rows unchanged, plus skill effects, upgrades, fertilizers, expansion bands, reset formula and growth cap (moved out of code). It stays a draft until M02-T18, then is frozen. `content_m01_v1` stays in the tests for the AV-003 regressions. |
| E2 | Schema | Keep `schema_version` 1 until M03 freezes the durable layout; log every field change. |
| E3 | Rate arithmetic | A big-integer rational type in `core/math` for exact rate comparisons, prototyped and benchmarked first (S0). |
| E4 | Batch architecture | A pure `BatchPlanner` produces an immutable proposal and a `BatchApplier` applies it atomically. Due batches and all farming commands share this path. The engine processes phases 1–2 events, then runs phases 3–8 once per timestamp. |
| E5 | Numeric failure in advance | Stop at that timestamp, commit nothing, and report recoverably (DEC-026). |
| E6 | Retry trigger | A stalled loop retries on a wallet credit in a later batch, or on a configuration/authorization command. Retries are never scheduled events. |
| E7 | Research events | Each research run gets an `EntityId`. A boost cancels the completion event and reinserts it with a new sequence. The rebuild includes the active research. |
| E8 | Replant after manual harvest | Runs inside the same command batch: credits first, then replant spending (DEC-025). |
| E9 | Failure codes | Add `PLOT_UNLOCK_ORDER_REQUIRED`, `SKILL_*`, `UPGRADE_*`, `RESEARCH_ACTIVE`/`RESEARCH_DONE`, `BOOST_USED`, `NO_TIME_SAVED`, `NOTHING_TO_RESET`, `FEATURE_UNAVAILABLE`. Target and gate checks come before `STALE_TERMS`, and coins after it. |
| E10 | Settings | Typed tri-state fields (`unset` / value) for Plot > Group > Farm. Budget fields are farm-only. `PlotState` keeps only runtime fields. |
| E11 | Authorization | A typed record holding plan revision, plan digest and an armed flag. Reset disarms it; rebuying a skill never rearms it. |
| E12 | Capabilities | Always derived from skill ranks, never stored. |
| E13 | Transactions | Separate seed and fertilizer transactions; nullable `cycle_id`; origin field. |
| E14 | Smart groups in M02 | Partitioned by mode only. All priorities are equal until M05 (Q3). |
| E15 | Oracle | An independent Python vector generator, plus a GDScript brute force for 8 plots or fewer. |
| E16 | Purchase intents | Quotes bind the "next" identity (next rank, plot N+1, research run, reset level), so a re-delivered intent fails `STALE_TERMS` rather than buying twice. |
| E17 | Command plumbing | Command classes move into `core/simulation/commands/`, with one factory for decode/intent → command. Per-member outcomes go in `CommandResult`. |
| E18 | Research and skill state | Keep `PlayerState.skill_ranks`. Promote `ExtensionState.Research` to `core/research/research_state.gd` with the same primitive keys. |

## 7. Proposed build-plan slices

| Slice | M02 tasks | Content | Relative size |
|---|---|---|---|
| S0 | (prep) | Rational-arithmetic and Pareto-frontier spike with a 32-plot benchmark; command plumbing refactor; fixes for the carry-over findings (§5); manifest skeleton | 1 |
| S1 | T01, T02 | Content definitions and validation, `content_m02_v1`, modifier snapshot, fertilizer pricing, quotes and terms | 1.5 |
| S2 | T03–T06 | Plot purchase, skill allocation, reset and upgrades, with quotes (AV-004-04, AV-006) | 1.5 |
| S3 | T07 | Research start/boost/completion and its phase-1 event (AV-004-03, DVS-006) | 1 |
| S4 | T08–T12, part of T15 | Typed settings and authorization, engine batch pipeline, batch commands, auto-harvest/replant, seed allocator, fixed fertilizer and the replan rule (AV-005) | 3 |
| S5 | T13, T14, rest of T15 | Exhaustive oracle, production Smart modes, 32-plot benchmark | 3 |
| S6 | T16 | Accounting categories, committed-harvest port, reserved advanced schemas (AV-007-01/04) | 1 |
| S7 | T17, T18 | Full-cost strategy harness, pacing report against the 3–5 h target, M03 handoff | 1.5 |

**Recommended next step:**

1. Answer Q1–Q3.
2. Approve E1–E18, or amend them.
3. I then write `M02_Build_Plan.md` (file layout, contracts, failure order, V01–V15 test map with exact values) and start with the S0 spike.

S0's result decides whether DEC-009's exact-solver guarantee holds as approved.
