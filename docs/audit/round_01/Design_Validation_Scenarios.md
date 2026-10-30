# Idle Farmer — Design Validation Scenarios

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

## Evidence rules

**Calculated** means independent exact-integer/rational arithmetic was performed for this audit. It does not mean Godot, SQLite, a browser or a human playtest passed. **Specified / future test** means the sources provide the intended behavior and implementation must demonstrate it. **Unresolved oracle** means an audit finding prevents selecting one expected result honestly. The calculations are finite audit schedules/ledgers, not an implementation of the game or a reusable game simulator. No provisional value was retuned.

Scenarios use source content as of this audit. Explicitly constructed later-game states are valid feature fixtures, not free unlocks in a progression proof. Source T-xxx and milestone Vxx references remain future tests. Scope/reference aliases above make this file standalone.

## Independently calculated economic oracles

Sources: [FRS §4.2 crop table, L139](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:139), [FRS §6.2 fertilizer, L291](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:291), [FRS §6.3 formulas, L300](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:300); exact rounding [TRS §4.4, L245](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:245). At base modifiers, incremental fertilizer gain is floor(B×bonus)−fertilizer cost; seed cost cancels. Net/hour below excludes research/equipment and uses continuous zero-idle production. Rational entries are exact, decimals elsewhere are labeled rounded.

| Crop | Basic cost / incremental net | Premium cost / incremental net | Advanced cost / incremental net | No-fertilizer net coins/hour | Base XP/hour |
|---|---:|---:|---:|---:|---:|
| Wheat | 20 / -16 | 75 / -67 | 240 / -224 | 120 | 45 |
| Carrots | 20 / -11 | 75 / -57 | 240 / -204 | 144 | 48 |
| Corn | 20 / +7 | 75 / -20 | 240 / -130 | 184 | 64 |
| Tomatoes | 41 / +26 | 95 / +40 | 240 / +30 | 215 | 70 |
| Pumpkins | 180 / +120 | 420 / +180 | 936 / +264 | 300 | 230/3 |
| Sunflowers | 122 / +80 | 284 / +121 | 632 / +178 | 1160/3 | 250/3 |
| Strawberries | 67 / +44 | 156 / +66 | 348 / +97 | 1040/3 | 140 |
| Blueberries | 240 / +160 | 560 / +240 | 1248 / +352 | 575 | 90 |
| Soybeans | 118 / +78 | 275 / +117 | 613 / +172 | 485 | 185 |
| Grapes | 885 / +590 | 2065 / +885 | 4602 / +1298 | 975 | 120 |
| Coffee | 660 / +440 | 1540 / +660 | 3432 / +968 | 2500/3 | 250 |
| Cotton | 1875 / +1250 | 4375 / +1875 | 9750 / +2750 | 1600 | 190 |
| Rice | 435 / +290 | 1015 / +435 | 2262 / +638 | 1400 | 296 |
| Vanilla | 3675 / +2450 | 8575 / +3675 | 19110 / +5390 | 8650/3 | 950/3 |
| Saffron | 1500 / +1000 | 3500 / +1500 | 7800 / +2200 | 2000 | 550 |

All 15 crop rows were recalculated. Negative gains for Wheat/Carrots and Corn Premium/Advanced are expected from price floors; they are not arithmetic defects. Smart must choose None there; a knowingly authorized fixed/manual unprofitable choice remains allowed. Coin skills/equipment stack additively and do not multiply fertilizer's nominal bonus; rounding can change a marginal gain by a coin when comparing two floored rewards, so the runtime oracle must use floor(with)−floor(without)−cost at its actual modifiers.

## Concrete adversarial scenarios

### DVS-001 — New game, prefix ownership and expansion rejection

**Evidence:** Calculated totals; future state/command test. **Finding link:** None established.

**Source:** [FRS FR-FARM-01–08, L98](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:98); [FRS §3 initial state, L109](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:109).

**Given:** A new game has level 1, zero XP/coins/points, plots 1–24 Empty, plots 25–32 Locked, and only Wheat unlocked.

**Action / adversarial sequence:** Check all coordinates. In a separate valid high-level, funded fixture, request plot 27 before 25; then buy 25 through 32. Retry 25 and fail a purchase of 26. Leave scattered unlocked plots Empty.

**Expected / required disposition:** Only N+1 can unlock with both level and coins. Failed purchases preserve wallet, IDs and prefix. All eight cost 34,500. Crop occupancy may have gaps; unlocked ownership may not.

**Implementation validation owner:** M01-V01/V11; M02-V12; M03-V01/V09; M04-V01/V12; M06-V10.

### DVS-002 — Maturity, harvest snapshot and competing old cycle IDs

**Evidence:** Specified / future test. **Finding link:** AUD-004 for rejection-baseline detail.

**Source:** [FRS §4.1 snapshots, L132](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:132); [TRS §4.3 state machine, L229](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:229).

**Given:** Wheat planted at t=0 has maturity 480,000,000 μs and reward 16 coins/6 XP. Another plot grows a different crop.

**Action / adversarial sequence:** Advance just below and exactly to maturity. Purchase upgrades or reset after planting. Wait days while Ready. Submit duplicate harvests, old cycle IDs and stale maturity events.

**Expected / required disposition:** Maturity marks Ready without reward. Harvest pays the immutable snapshot once. Ready never spoils; plots remain independent. Rejecting an input cannot undo legitimate due work processed before that input.

**Implementation validation owner:** T-001/003/008/020; M01-V02/V03/V08; M02-V05; M06-V01.

### DVS-003 — Tomato rounding, None and growth-cap boundaries

**Evidence:** Calculated; future integer execution test. **Finding link:** None established.

**Source:** [FRS §6.2 prices, L291](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:291); [FRS §6.3 formulas, L300](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:300); [TRS §4.4 arithmetic, L247](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:247).

**Given:** Tomatoes have base reward 270, seed cost 55, growth 60 minutes and XP 70. Basic adds 25%.

**Action / adversarial sequence:** Compare quote and execution. Exercise growth reduction below/at/above 60%, fractional microsecond durations, and large products whose final quotient fits int64.

**Expected / required disposition:** Basic costs 41, gross is 337, completed-cycle profit is 241 and XP is 70. Growth at the cap is 24 minutes. Apply reward floor and cost/duration ceiling, with minimum 1 μs. None has no ROI division. Safe representable quotients succeed without floats.

**Implementation validation owner:** T-004; M01-V05/V10; M02-V02/V09; M04-V04; M06-V12.

### DVS-004 — Increasing XP, all points and finite lookup boundary

**Evidence:** Calculated; future progression/persistence test. **Finding link:** AUD-003 only for subsequent changed-curve migration.

**Source:** [FRS §5.1 table, L168](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:168); [FRS §5.1.1 recurrence, L205](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:205); [TRS §5 safe progression, L278](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:278).

**Given:** Use all 30 current thresholds and the approved increasing recurrence, with earned-point conservation.

**Action / adversarial sequence:** Check immediately below/at/above every threshold, multi-level rewards, retries, surplus points after all 34 ranks/nodes, and max int64 XP.

**Expected / required disposition:** Thresholds 31–35 are 577,500; 640,750; 710,325; 786,858; 871,045. Threshold 40 is 1,436,418. Level 349 fits; its next mathematical threshold does not. Valid max XP still maps to level 349 and 348 earned points. Codec and lookup must not discard XP.

**Implementation validation owner:** T-010/021/029; M01-V13; M03-V18; M06-V16.

### DVS-005 — Skill graph, exact four-point automation and respec rearm

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §5.2 prerequisites, L239](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:239); [FRS §5.3 prerequisites, L249](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:249); [FRS §5.4 chain, L264](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:264); [FRS §5.5 reset, L270](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:270).

**Given:** At level 7 the player has earned six points. Four purchase the complete basic automation predecessor chain. Existing crops, upgrades and a purchased plot prefix are present.

**Action / adversarial sequence:** Try skipped predecessors, level-only access and one-rank versus fully ranked prerequisites. Reset at level 7, rebuy, reopen and explicitly rearm.

**Expected / required disposition:** One preceding growth/profit rank is sufficient; all listed level gates still apply. Reset costs 2,450, refunds allocated points exactly, and preserves XP/level, equipment, research, plots and current cycles. Rebuy does not silently resume spending. Ordinary valid authorized loops otherwise resume without repeated prompts.

**Implementation validation owner:** T-008; M02-V01/V05/V12/V13; M04-V13; M05-V12.

### DVS-006 — One research boost, microscopic remaining time and stale completion

**Evidence:** Calculated formulas; future command/crash test. **Finding link:** None established.

**Source:** [FRS §8 research, L360](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:360); [FRS §8 boost, L366](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:366); [TRS §5 research contract, L284](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:284).

**Given:** Corn research actually paid 800, has 20 minutes remaining and has not been boosted. Separate fixtures have 1 or 2 μs remaining.

**Action / adversarial sequence:** Boost at 20 and 10 minutes remaining; retry, restart, change current research prices, deliver the stale completion event, and attempt concurrent projects.

**Expected / required disposition:** Cost is 400 in both normal cases; remaining time becomes 10 or 5 minutes. At 1 μs no time is saved, so reject without charge or consuming the boost. At 2 μs the result is 1 μs. Persist the paid snapshot and used flag; only the valid completion unlocks the crop. No automatic next project or boost.

**Implementation validation owner:** T-009; M02-V06/V13; M03-V14; M04-V05; M06-V13.

### DVS-007 — Research, level-up, auto batch and two manual commands tied

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [DR DEC-006 phases, L181](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:181); [TRS §4.2 phases, L215](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:215); [FRS §7.1 batch boundary, L326](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:326).

**Given:** Research and two automated maturities share a timestamp. Harvest XP crosses a level. Two manual commands are accepted at that same time.

**Action / adversarial sequence:** Permute containers and callbacks, restore the pending queue, and compare the recorded manual order. Include a BatchHarvest over several Ready plots.

**Expected / required disposition:** Research precedes the full due harvest/credit/XP/contract/accounting phase, then seed/fixed/Smart allocation and cycle creation. Manual commands follow serially. No offline skill purchase or retrospective pooling with later input. BatchHarvest pools only its own successful harvest credits before its replant spending.

**Implementation validation owner:** T-005/020/021; M01-V04/V08; M02-V03/V13; M03-V07; M06-V12.

### DVS-008 — One protection ceiling, mixed modes and reserve extremes

**Evidence:** Calculated; future allocator execution test. **Finding link:** None established.

**Source:** [FRS §7.1, L313](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:313); [FRS §7.3, L342](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:342); [TRS §6.2, L311](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:311).

**Given:** W=1,000, final S=200, R=100, F=100 and protection=25%.

**Action / adversarial sequence:** Split protection requests across groups and priorities; place MP/CE before BP. Test percentages 0/100, R above W, advanced seed protection, free seeds, and a confirmed manual override followed by auto replant.

**Expected / required disposition:** A=700, M=600 and C=150 once for the batch. Total BP spend ≤150 and total Smart spend ≤600. Earlier groups can leave BP less or nothing. All-BP fertilizer totals at most 250, ending wallet at least 550. Free seeds remain eligible below reserve; manual override never extends to later automatic work.

**Implementation validation owner:** T-005–007/023/024; M02-V04/V13; M05-V12; M06-V13.

### DVS-009 — Fixed request reservation release oscillation

**Evidence:** Unresolved oracle. **Finding link:** AUD-005.

**Source:** [DR DEC-010 steps, L443](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:443); [TRS §6.2, L316](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:316); [M02 M02-T15, L154](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:154).

**Given:** W=100, R=0, equal priority. Plot 1 requests Corn seed 18 plus Premium 75, without fallback; plot 2 requests Corn seed 18 plus None.

**Action / adversarial sequence:** Reserve both seeds: 36 leaves 64, so plot 1 fixed fertilizer fails. Release its seed reservation and replan. Repeat after input permutation and with a 32-plot cascade.

**Expected / required disposition:** First specify a unique subset and termination measure. A monotone exclusion rule consistent with seed-first would plant plot 2 alone, spend 18 and end at 82. Repeatedly reinserting plot 1 recreates the infeasible set. Do not silently change priority or fallback permission. The audit does not approve a new allocation policy.

**Implementation validation owner:** M02-T11/T12/T15; sharpen M02-V04/V13; M03-V14 differential aggregation.

### DVS-010 — Exact solver versus individually tempting fertilizer

**Evidence:** Calculated small-batch optimum; future solver test. **Finding link:** None established.

**Source:** [FRS §7.2 mode objectives, L334](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:334); [TRS §6.3 solver, L328](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:328).

**Given:** Two 60-minute Tomato plots each need seed 55. W=205 and R=0 leave 95 for fertilizer. Per plot, Basic costs 41/gains 26; Premium costs 95/gains 40; Advanced costs 240/gains 30.

**Action / adversarial sequence:** Enumerate all 16 assignments independently. Compare MP, BP at 25%, CE with all 95, and an exact tie case with fertilizer budget 41. Then vary effective durations.

**Expected / required disposition:** MP selects Basic twice: spend 82, incremental rate 52/hour, beating one Premium at 40/hour. BP ceiling is 23 and selects None. CE also starts with Basic here, without acquiring a global-optimum guarantee. At budget 41 the lower plot ID wins the equivalent allocation. Use rate, not profit per cycle, when durations differ.

**Implementation validation owner:** T-023/024; M02-V07/V08/V13; M06-V01/V06.

### DVS-011 — Inherited zero/false, group reassignment and deleted group

**Evidence:** Unresolved group-command oracle; existing consent outcomes specified. **Finding link:** AUD-007.

**Source:** [FRS §7.1 inheritance, L317](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:317); [FRS §9.2 changed stalled plan, L420](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:420); [TRS §3.3 group_id, L141](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:141); [M05 M05-T11, L151](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:151).

**Given:** Farm default is fixed Advanced; group G is None. Plot 1 inherits G and is an armed stalled loop. Other plots have explicit false or zero overrides.

**Action / adversarial sequence:** Move plot 1 to a paid group, delete G, apply a preset referencing a deleted group, attempt multiple memberships, and attempt a group-level reserve override.

**Expected / required disposition:** Define valid group lifecycle and membership outcomes first. Changes to a stalled effective purchase plan require existing explicit authorization; current cycles remain immutable. Reject dangling references and farm-budget override attempts. Explicit false/zero stays set. Round-trip and forecast the membership boundary.

**Implementation validation owner:** M02-T10/T16 contracts; M03-T03 codec; M05-T11/V08/V12 behavior.

### DVS-012 — Selection is not a purchase; ready-on-enable and manual harvest replant

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §9.2, L417](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:417); [TRS §4.3 lifecycle, L241](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:241).

**Given:** There are a never-started Empty plot, a Ready plot, a Growing plot and an authorized funds-stalled plot; relevant skills may be owned or refunded.

**Action / adversarial sequence:** Select a paid crop without applying it; enable Auto Harvest on Ready; manually harvest with replant enabled; apply future settings to Growing; reset/rebuy and reopen.

**Expected / required disposition:** Selection alone cannot start a paid loop. Disclosed enable can collect Ready. Authorized Auto Replant follows manual and automatic harvests under automatic budgets. Future settings preserve the current snapshot. Reset config remains inactive until rearmed; valid unchanged loops resume without per-cycle/session consent.

**Implementation validation owner:** M02-V05/V13; M04-V13; M05-V08/V12; M06-V13.

### DVS-013 — Rotation cursor at failed seed, missing unlock and crashed commit

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §9.2 rotation, L424](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:424); [TRS §4.3 cursor, L243](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:243); [M05 M05-T12, L157](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:157).

**Given:** A valid level-20 rotation has sequence Coffee/Rice and cursor Coffee. Separate fixtures lack seed funds or crop eligibility.

**Action / adversarial sequence:** Attempt planting, add funds, retry, crash before/after commit, apply a future preset, reset/rebuy, and run offline/forecast.

**Expected / required disposition:** Failure preserves cursor and selected crop with no charge or substitution. Successful planting advances once with the cycle/spend commit. Restore the same cursor and authorization. Rotation cannot buy Locked plots. Existing crop snapshots stay fixed; forecasts affect only copies.

**Implementation validation owner:** M03-V14; M05-V08/V11/V12; M06-V13.

### DVS-014 — Sleep at 60× with inclusive and exclusive ticks

**Evidence:** Calculated trace; actual Windows provider still Open. **Finding link:** None established.

**Source:** [FRS §9.1 ledger, L413](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:413); [TRS §7.1 provider, L354](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:354); [TRS §7.2 oracle, L373](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:373).

**Given:** Ten active real seconds at 60× are followed by 3,600 suspended seconds. Fakes expose both inclusive and exclusive tick models.

**Action / adversarial sequence:** Resume without focus, checkpoint, crash/reopen and test missing lifecycle notifications. Later measure actual sleep, hibernate and reboot on the pinned Windows/engine combination.

**Expected / required disposition:** Simulation advances 600+3,600=4,200 seconds; real anchor advances 3,610. Sleep is never multiplied by 60 or counted twice. A slow frame or focus loss cannot identify suspension. Missing partition evidence must be resolved under DEC-014 rather than guessed.

**Implementation validation owner:** T-017; M01-V10/V12; M03-V05; M06-V03/V14.

### DVS-015 — UTC forward/backward, restoration and startup cutover

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §9.1, L403](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:403); [TRS §7.2, L358](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:358); [M03 M03-T08, L133](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:133).

**Given:** A known saved anchor and monotonic baseline are available. Include active wall jumps, rollback, restart before the anchor, restoration, DST and a very long positive interval.

**Action / adversarial sequence:** Use fake clocks for all edits. Separately spend five real seconds calculating/committing catch-up and delay UI startup; then play, shut down and reopen.

**Expected / required disposition:** Active wall edits never affect elapsed simulation. Positive restart deltas are honored; negative deltas give zero additional offline time and preserve progress/anchor. Past buckets never rekey. The cutover trace must account for computation/lifecycle gaps exactly once. This is a future trace requirement, not an asserted current cutover bug.

**Implementation validation owner:** T-013–016/019; M03-V04/V12/V13; M06-V03/V12.

### DVS-016 — Atomic live economic batch and intact-primary crash recovery

**Evidence:** Specified / future actual SQLite test. **Finding link:** None established.

**Source:** [FRS §13 atomicity, L552](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:552); [TRS §9.2, L419](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:419); [M03 M03-T05, L105](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:105).

**Given:** A coherent batch harvests, updates XP/contracts/accounting, funds seeds/fertilizer and creates cycles. SQLite uses verified WAL/FULL under exclusive profile ownership.

**Action / adversarial sequence:** Fault every write boundary, kill before/after commit, reload the intact primary, and retry current/retired/cached/pruned command identities.

**Expected / required disposition:** Recover the whole old or new revision with matching state, anchor, replay and statistics. No charged unplanted cycle or duplicate reward. Rejected gameplay remains unchanged; pruned response data never restores eligibility. Notify only after durability. Private offline history commits once.

**Implementation validation owner:** T-018–020; M03-V02/V03/V13/V14; M05-V03; M06-V04.

### DVS-017 — Receipt loss without killing the running controller

**Evidence:** Unresolved reconciliation protocol. **Finding link:** AUD-002.

**Source:** [M03 M03-T02, L75](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:75); [M03 M03-T05, L105](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:105); [M03 M03-T15, L209](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:209).

**Given:** Memory has revision 40; the DB commits 41 but the receipt is lost. Keep the controller alive.

**Action / adversarial sequence:** Attempt original retry, a new command, settings save, time checkpoint, backup and shutdown. Repeat with a definitely rolled-back transaction.

**Expected / required disposition:** Specify outcome-unknown reconciliation under exclusive ownership before further writes. Read the committed identity/revision and restore state/scheduler/anchor/high-water coherently. Never overwrite 41 with 40 or issue a replacement purchase. A definite rollback may retry; uncertainty must not be treated as rollback.

**Implementation validation owner:** Extend M03-T02/T05/T06/T15 and V02/V13; M04-V05; M06-V04.

### DVS-018 — Older backup predating allocations and claimed offer

**Evidence:** Unresolved rollback-scope and allocation-namespace oracle. **Finding link:** AUD-001.

**Source:** [DR DEC-016 identities, L233](C:/_/IdleFarmer/docs/decisions/Decision_Register.md:233); [TRS §3.5 claimed eligibility, L179](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:179); [TRS §9.3 backups, L434](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:434).

**Given:** Backup B has entity counter 100 and Q01 unclaimed. The primary later allocates entity 100 and claims Q01, then becomes unrecoverable.

**Action / adversarial sequence:** Restore B, establish a fresh command epoch, allocate an entity, inspect offer eligibility and retry an old command payload.

**Expected / required disposition:** Choose the identity namespace and recovered-history scope explicitly. The new command epoch rejects old payloads but cannot reconstruct lost primary claims or allocations. State whether one-time protection applies within the recovered timeline or across lost branches. The old claim credit also rolls back, so this is not proof of net extra coins in the recovered balance.

**Implementation validation owner:** M01-T05/T06 identity contract; M03-T10/V13; M05-T06/V13; M06-T04.

### DVS-019 — Changed XP curve and rank maxima on existing allocated profile

**Evidence:** Unresolved migration oracle. **Finding link:** AUD-003.

**Source:** [TRS §3.2 points/level, L132](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:132); [M03 M03-T10, L147](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:147); [M05 M05-T13, L163](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:163).

**Given:** A profile has XP 5,200, level 7, six earned points and allocated Auto Replant. A counterfactual later approved curve moves level 7 to 6,000; another changes a rank maximum.

**Action / adversarial sequence:** Migrate, restart and retry migration; also test lowered thresholds. Preserve active paid cycles and accepted contract/research snapshots.

**Expected / required disposition:** Before coding, choose retention of the old versioned curve or an explicit approved mapping. Do not invent XP, revoke abilities silently or violate point conservation. Unsupported migrations preserve old saves/backups. Newly crossed levels award points at most once under the chosen policy.

**Implementation validation owner:** M01-T03/T05/T12 policy; M03-T03/T10/V09; M05-T13; M06-V04.

### DVS-020 — Queued click/confirmation crossing time and state changes

**Evidence:** Unresolved input/quote boundary. **Finding link:** AUD-004.

**Source:** [TRS §4.1, L193](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:193); [M02 M02-T05, L90](C:/_/IdleFarmer/docs/implementation/02_M02_Economy_Skills_Research_Automation.md:90); [M04 M04-T08, L104](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:104); [M04 M04-T09, L112](C:/_/IdleFarmer/docs/implementation/04_M04_Visual_Farm_Art_UI_Audio.md:112).

**Given:** A UI quote uses visible time 100.000. Before acceptance the controller reaches 100.016 and commits an unrelated automated batch.

**Action / adversarial sequence:** Queue planting, a reset quote across a level-up, and a boost quote while remaining time changes. Lose a response and replay the accepted command log.

**Expected / required disposition:** Define controller-owned accepted time/order and bind confirmed plan/quote identity. Execute unchanged authorized terms or refresh/reconfirm. Never backdate or silently issue a replacement purchase. Specify whether unrelated state revisions invalidate an otherwise unchanged quote, and how ordinary queued clicks avoid stale-time failure.

**Implementation validation owner:** M01-T06/T13/T14; M02-T02/T05; M04-V04/V05; M06-V12.

### DVS-021 — Profile lock, backup rotation and migration failure

**Evidence:** Specified / future adapter/process test. **Finding link:** None established.

**Source:** [TRS §9.2 one writer, L423](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:423); [TRS §9.3 generations, L434](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:434); [M03 M03-T04, L97](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:97).

**Given:** Two processes target one profile. Two known-good backup generations exist; committed primary data remains in the WAL.

**Action / adversarial sequence:** Attempt concurrent startup/catch-up/writes; kill the owner and reacquire. Exercise 30/600 real seconds at 1× and 60×. Interrupt backups/migrations and inject corruption, disk-full, permission and unknown-schema errors.

**Expected / required disposition:** One writer owns the entire lifecycle. Time checkpoints use 30 real seconds; two backup generations rotate every 600 real seconds after valid checkpoints and at validated lifecycle points. Use consistent backup APIs. Failed or tentative copies preserve good generations. Unknown saves are not overwritten or silently reset; disclose older recovery age.

**Implementation validation owner:** T-026–028; M03-V09/V10/V15; M06-V04/V10.

### DVS-022 — All 12 authored contract definitions and reward arithmetic

**Evidence:** Calculated catalog; future guard/predicate implementation. **Finding link:** None established.

**Source:** [FRS §10.2 catalog, L442](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:442); [FRS §10.3, L461](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:461); [FRS §10.4 rationale, L472](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:472).

**Given:** Load all Q/M/R/A01–03 definitions, Board level 7, row levels 7/18/26 and three occupied accepted-unclaimed slots.

**Action / adversarial sequence:** Check every target/reward/reference. Test missing named research, missing Auto Harvest, Auto Harvest without Auto Replant, gross targets without reference-crop research, duplicate active acceptance and a fourth slot.

**Expected / required disposition:** All 12 fixed rewards match their floor-10% design references: total 590,828 coins/54,099 XP. Named crops are required for named-target offers. A offers require owned Auto Harvest, not Auto Replant. Gross targets accept any crop without reference-crop research. Completed-unclaimed occupies a slot; accepted rewards never reprice.

**Implementation validation owner:** T-011; M05-V01/V13/V16; M06-V01/V04.

### DVS-023 — Ordered contract progress, automatic origin and mixed AND

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §10.3 auto source, L464](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:464); [FRS §10.3 predicates, L466](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:466); [FRS §10.3 ordered boundary, L468](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:468); [TRS §5.1, L295](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:295).

**Given:** Three accepted objectives independently match some harvests. Crops may predate acceptance; acceptance and due harvests can share a timestamp.

**Action / adversarial sequence:** Run due auto harvest, accept, then a later manual harvest at the same time. Batch N distinct cycles, manually harvest an auto-enabled plot, satisfy one mixed counter only, and replay an event.

**Expected / required disposition:** Exclude pre-acceptance events; later ordered harvests may count. One quantity per cycle, N for N cycles, AND for mixed targets. Each matching instance may progress once per cycle. Actual automatic origin is required for A offers. Modified crop gross counts; claim income does not. No auto-claim or inventory consumption.

**Implementation validation owner:** M02-T16 metadata; M05-V01/V02/V13/V16; M06-V01/V02.

### DVS-024 — Frozen claim, abandonment, cache eviction and offer closure

**Evidence:** Specified within intact history; older rollback requires DVS-018. **Finding link:** AUD-001 only for older backup branch.

**Source:** [FRS §10.1 lifecycle, L437](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:437); [FRS §10.3 snapshot, L470](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:470); [TRS §5.1 claims, L299](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:299).

**Given:** A completed instance has a frozen C2 reward. Current crop data/upgrades change later.

**Action / adversarial sequence:** Claim twice, crash around commit, prune response cache, retire the epoch, abandon another instance and reaccept, then attempt a claimed offer. Cross several option-B levels with claim XP.

**Expected / required disposition:** Within the intact history, pay the frozen reward once with closure, XP/points, accounting, replay and anchor. Claim income cannot advance gross objectives. Abandon has no reward/refund; reaccept gets a fresh instance and zero progress. Cached-result pruning cannot reopen eligibility. Older backup semantics require DVS-018.

**Implementation validation owner:** T-011/018–020; M05-V02/V03/V13/V16; M06-V04.

### DVS-025 — Minute-aligned windows and cost attribution across periods

**Evidence:** Calculated ledger; future query test. **Finding link:** None established.

**Source:** [TRS §10 accounting, L484](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:484); [TRS §10.1 half-open windows, L492](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:492); [FRS §11.1, L501](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:501).

**Given:** Plant Tomato+Basic at 59:59, paying 96. Harvest at 119:59 for gross 337/XP 70. Query at 120:05.

**Action / adversarial sequence:** Query the last 60 completed minutes [60:00,120:00), the earlier payment period, and the current partial minute. Add events just below and exactly at 120:00.

**Expected / required disposition:** The historical hour includes gross 337, attributed cycle cost 96, operating profit 241 and XP 70. Its cycle cash flow is +337 because the debit occurred earlier; the payment period has −96. Events at 120:00 belong to the new partial bucket. Label as-of 120:00 and separate live totals.

**Implementation validation owner:** T-025; M03-V08/V16; M05-V04/V05/V14; M06-V05.

### DVS-026 — Utilization versus occupancy with mid-period expansion

**Evidence:** Calculated state-time ledger; future test. **Finding link:** None established.

**Source:** [FRS §11.2 utilization, L514](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:514); [TRS §10.2, L500](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:500).

**Given:** For the first 30 minutes, 24 plots contain 12 Growing and 12 Ready. At minute 30 buy/plant plot 25; the next 30 minutes have 13 Growing and 12 Ready. Use long-duration fixtures.

**Action / adversarial sequence:** Integrate capacity/state time; query occupancy and utilization. Separately exercise Empty-stalled, Empty-not-stalled and zero-duration sessions.

**Expected / required disposition:** Growing time is 750 plot-minutes; capacity is 1,470. Productive utilization is 750/1470=51.0204% rounded. Instant occupancy is 25/25=100%. Ready waiting contributes 720, and the disjoint sum is 1,470. New capacity starts at purchase; Stalled is counted once within Empty.

**Implementation validation owner:** M03-V16; M05-V05/V14; M06-V05.

### DVS-027 — Retention, ready-for-months cycle and session boundaries

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §11.1 session, L503](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:503); [FRS §11.3 retention, L523](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:523); [TRS §10.1, L494](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:494).

**Given:** A paid crop matures and waits Ready beyond 90 simulated days. Old minute/hour detail is pruned but the cycle snapshot remains. Startup catch-up also earns income.

**Action / adversarial sequence:** Harvest after retention expiry, query lifetime/rolling/session measures, suspend after session start, and reopen.

**Expected / required disposition:** Retain the unharvested cycle cost for eventual operating profit. Rollups conserve totals and do not reopen replay/claim eligibility. Startup earnings belong to history and a separate report, not the fresh process session. In-process suspension belongs to that session but never active engagement; guard zero denominators.

**Implementation validation owner:** T-025/029; M03-V16; M05-V05/V14; M06-V05.

### DVS-028 — One-hour forecast, long crop and isolation/cancellation

**Evidence:** Specified / future test. **Finding link:** None established.

**Source:** [FRS §11.3 forecast, L518](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:518); [TRS §10.3, L504](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:504); [M05 M05-T09, L133](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:133); [M05 M05-T10, L145](C:/_/IdleFarmer/docs/implementation/05_M05_Contracts_Statistics_Complete_Progression.md:145).

**Given:** A newly planted Vanilla has six hours to maturity. Other fixtures include automation, stalls, rotation, boosted research and accepted contracts. Live debug speed is 60×.

**Action / adversarial sequence:** Clone and advance one simulated hour at 1×. Repeatedly open/cancel forecasts while live play advances. Inspect nested references, repositories, IDs, sessions, settings and callbacks; invalidate stale caches.

**Expected / required disposition:** New Vanilla earns no harvest in the next hour; steady-state is a different display. Copy-only research/contract transitions are allowed, but no invented manual claim/start/rearm or live epoch change. Results match the isolated reference; live state and storage remain untouched. Yield/cancel work to keep input responsive and report forecast age.

**Implementation validation owner:** T-022; M05-V06/V12/V14; M06-V05/V07.

### DVS-029 — Analytic long-offline Wheat and boundary-rich differential path

**Evidence:** Calculated harvest/XP totals; future engine/aggregation test. **Finding link:** None established.

**Source:** [FRS §9 uncapped, L401](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:401); [TRS §8 aggregation, L401](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:401); [TRS §14 long targets, L614](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:614); [M03 M03-T13, L183](C:/_/IdleFarmer/docs/implementation/03_M03_Saves_Time_Offline_Farming.md:183).

**Given:** Use an already-funded valid level-12 profile: XP 24,000, legally purchased 32 plots, four basic automation nodes, seven unspent points, no growth/equipment, all Wheat planted at t=0 and authorized.

**Action / adversarial sequence:** Advance exactly 30 days and one 365-day year, including events at the target endpoint. Compare event reference and aggregation, then add shortages, caps, rotations, contracts and minute edges.

**Expected / required disposition:** 30 days: 172,800 harvests, gross 2,764,800, XP gain 1,036,800; final XP 1,060,800, level 36, 31 unspent plus four allocated. Year: 2,102,400 harvests, gross 33,638,400, XP gain 12,614,400; final XP 12,638,400, level 62, 57 unspent plus four allocated. Seeds/fertilizer cost zero. Endpoint replants and final scheduler/IDs must also match; no pooled whole-absence budget.

**Implementation validation owner:** T-012/021/029; M03-V11/V14/V18; M05-V11; M06-V06/V16.

### DVS-030 — 32-plot solver/commit stress and boundedness

**Evidence:** Calculated workload bounds; future hardware benchmark. **Finding link:** None established.

**Source:** [TRS §6.3 complexity, L333](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:333); [TRS §14 targets, L610](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:610); [M06 M06-T06, L125](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:125); [M06 M06-T07, L139](C:/_/IdleFarmer/docs/implementation/06_M06_Validation_Performance_Windows_Release.md:139).

**Given:** Name actual reference hardware, build and content. Use 32 automated plots at 1×/60× with mixed policies, expensive options, charts/forecast and backup work. Capped Wheat lasts 3.2 real seconds at 60×.

**Action / adversarial sequence:** Measure aligned and staggered maturities, exact optimizer frontier/work, memory, commit latency and p95/p99 frame stalls across repeated warm and cold/import-separated runs.

**Expected / required disposition:** Aligned plots produce one batch per 3.2 seconds; staggering can reach 10 distinct batches/second. Never merge logical timestamps to weaken durability. Current useful fertilizer capacity is at most 611,520; this is not a performance proof. A capped-Wheat year has 5,256,000 harvests and 525,600 minute boundaries. Bound memory by retained state. Report all target misses; reopen decisions before approximation or weaker sync.

**Implementation validation owner:** T-024/029; M02-V08; M03-V11; M06-V06/V07/V13/V15.

### DVS-031 — Genuine numeric failure versus representable long progress

**Evidence:** Specified / future fault test. **Finding link:** None established.

**Source:** [FRS §13 numeric limits, L562](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:562); [TRS §4.4 safe arithmetic, L253](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:253); [TRS §4.4 recovery, L255](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:255).

**Given:** One input has an overflowing naive product but a representable quotient; another has a truly unrepresentable final wallet/counter/timestamp. A prior valid checkpoint exists.

**Action / adversarial sequence:** Exercise planting, harvest and aggregation boundaries, injecting numeric failure after earlier members have been staged. Run normal released-content 30-day/year cases too.

**Expected / required disposition:** Safe quotients succeed; genuine final overflow preserves the entire checkpoint/anchor/statistics with no partial reward. No wrap, saturation or hidden offline cap. An unrepresentable next mathematical XP threshold is not an invalid current lookup. Ordinary long cases must succeed rather than take this error shortcut.

**Implementation validation owner:** M01-V10/V13; M03-V13/V18; M06-V12/V16.

### DVS-032 — Audio/settings/debug separation, browser probe and standalone safety

**Evidence:** Specified / future integration/platform test. **Finding link:** None established.

**Source:** [FRS §2.2, L81](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:81); [FRS §12, L527](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:527); [FRS §14 delivery, L568](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:568); [TRS §9.5 browser, L480](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:480).

**Given:** Normal/debug profiles have separate preferences; production uses qualified Windows x86_64 SQLite. The minimal browser composition excludes native Windows imports.

**Action / adversarial sequence:** Test load delays, volumes 0/1/default/100, music switch, 249/250 ms and second edges, offline sound suppression, 60× and failed settings writes. Test a clean offline ZIP install/update/removal and the browser boot/render/storage/error/resume probe.

**Expected / required disposition:** Restore preferences before playback; zero truly mutes, at most two harvest groups play per real second, with natural pitch/wind. Speed resets to 1× and is absent from production. Cosmetic failure never acknowledges saved economy. ZIP preserves per-user saves and fails clearly on missing libraries. Browser results are actual/partial/fail; no full-web durability or unrun pass is inferred.

**Implementation validation owner:** T-002/030; M03-V17; M04-V06–V10/V14; M06-V09/V10/V16.

## DVS-033 — Costed normal-speed automation schedules

**Evidence: independent finite schedule calculations, not game or human tests.** Sources: [FRS §4.2, L139](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:139), [FRS §5.1, L168](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:168), [FRS §5.2, L235](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:235), [FRS §5.4, L253](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:253), [FRS §8, L374](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:374), [FRS §12.1, L542](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:542). Owners: M02-T17/V11/V14, M05-T14/V10, M06-T09/V08.

Both schedules use the actual zero/Empty 24-plot start. Harvesting, planting, decisions and individual clicks before batch skills take zero time; all plots are synchronized. These idealizations isolate numerical possibility from human reaction and UI time. No equipment, expansion, fertilizer, contracts, boost or reset is used. All used costs are paid.

Allocate Faster Germination rank 1 at level 2, Batch Plant at 3, Batch Harvest at 4, Faster Germination rank 2 at 5, Auto Harvest at 6, and Auto Replant at 7. This uses all six earned points. Allocate after harvest and snapshot the new growth reduction only on the next planting. Enable owned actions explicitly; start the first full loop with Plant/ApplyAndStart.

### Schedule A — Wheat only

Each batch earns 384 coins/144 XP. The first two cycles last 8 minutes; cycles then last 7.68 minutes until level 5 and 7.36 minutes afterward. No cash is spent.

| Wheat batch | Simulated minutes | XP | Coins | Level/action |
|---|---:|---:|---:|---|
| 2 | 16.00 | 288 | 768 | 2; growth rank 1 |
| 5 | 39.04 | 720 | 1,920 | 3; Batch Plant |
| 10 | 77.44 | 1,440 | 3,840 | 4; Batch Harvest |
| 16 | 123.52 | 2,304 | 6,144 | 5; growth rank 2 |
| 25 | 189.76 | 3,600 | 9,600 | 6; Auto Harvest |
| 37 | 278.08 | 5,328 | 14,208 | 7; Auto Replant and explicit free loop start |

Time is **4.6347 simulated hours**, rounded. A Wheat route with no growth ranks reaches level 7 at 37×8=296 minutes, or 4.9333 hours. These calculations show starter cash or research is not necessary for a focused path, but small manual delays can matter near five hours.

### Schedule B — Wheat to Corn

Follow A through level 4 at minute 77.44. Pay 800 for Corn research, leaving 3,040 coins. Continue Wheat for three batches while the 20-minute research runs. Research finishes at 97.44; the next Wheat harvest at 100.48 leaves XP 1,872 and wallet 4,192. Corn requires its own completed research and level 4; the current sources impose no prior Carrot research dependency.

Plant 24 Corn for 432 coins. First growth is 28.8 minutes with the 4% reduction. Its harvest reaches level 5; buy the second growth rank and use 27.6-minute future cycles.

| Corn batch | Simulated minutes | XP | Wallet after harvest, before next seed | Action |
|---|---:|---:|---:|---|
| 1 | 129.28 | 2,640 | 6,400 | Level 5; growth rank 2 |
| 2 | 156.88 | 3,408 | 8,608 | Pay next seed 432 |
| 3 | 184.48 | 4,176 | 10,816 | Level 6; enable Auto Harvest |
| 4 | 212.08 | 4,944 | 13,024 | Continue; no Auto Replant yet |
| 5 | 239.68 | 5,712 | 15,232 | Level 7; buy Auto Replant, explicitly start next loop |

At the first full loop start, pay another 432, leaving **14,800 coins**. Before that planting: gross=13×384+5×2,640=18,192; research=800; five Corn seed batches=2,160; wallet=15,232. The next seed cost is fully included in the 14,800 ending wallet. Time is **3.9947 simulated hours**, rounded. No research boost, contract reward or free unlock was assumed.

**Assessment:** both schedules make the 3–5-hour target numerically plausible. They do not validate human timing, other crop/build/boost strategies, equipment gates or mixed offline behavior. Future shared-engine full-cost traces and normal-speed observations remain required. Strong strategies may be faster under the approved goal; three hours is not a universal minimum.

## DVS-034 — Finite late-game content and 48-hour engagement

**Evidence: conditional calculations; engagement unvalidated.** Sources: [FRS §1, L39](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:39), [FRS §4.2, L154](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:154), [FRS §5, L231](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:231), [FRS §6.1, L276](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:276), [FRS §10, L430](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:430), [FRS §12.1, L534](C:/_/IdleFarmer/docs/requirements/IdleFarmer_Functional_v1.0.md:534), [TRS §14.2, L630](C:/_/IdleFarmer/docs/architecture/IdleFarmer_Technical_v1.5.md:630). Owners: M05-T13/T14/T16, M06-T09/T10/V08/V15.

Existing skill ranks/nodes total 13 growth + 13 profit + 8 automation = **34 points**, all fillable at level 35/871,045 XP. Later points are banked; no extra mechanic follows.

All research costs **974,750 coins**; Irrigation costs **1,874,750**; Improved Soil costs **783,900**; expansion costs **34,500**. Combined cost is **3,667,900**, excluding recurring seeds/fertilizer, boosts and resets. A sum does not account for research slot/duration constraints or prove a full new-game route.

Consider a conditional already-funded level-26/290,000-XP fixture with 32 Saffron plots, all equipment, 13 profit ranks, eight growth ranks (Faster 5, Cultivation 1, Climate 2), and four basic automation nodes. This uses 25 points. Equipment reduces growth 30% and those skills 33%, capped at 60%. Fixed Advanced fertilizer does not require Smart. Each synchronized 0.8-hour batch awards 35,200 XP; 17 batches award 598,400 XP and reach level 35 after **13.6 simulated hours**. This excludes the time and expense to fund/unlock that state and measures no human engagement.

At full profit skills (160%), Soil (70%) and Advanced (100%), gross multiplier is 4.3:

| Crop | Net per cycle | Capped cycle duration | Net coins/plot/hour | XP/plot/hour |
|---|---:|---:|---:|---:|
| Saffron | 43,000−6,000−7,800=29,200 | 0.8 h | 36,500 | 1,375 |
| Vanilla | 105,350−7,200−19,110=79,040 | 2.4 h | 32,933⅓ | 791⅔ |

Saffron wins both continuous rates in this state; Vanilla retains its longer unattended interval. This calls for a strategy-diversity investigation, not a claim that Vanilla has no use for any play style. The 12 one-time contract rewards total **590,828 coins/54,099 XP**. Their objectives may progress concurrently, so adding nominal objective durations exaggerates content duration. Neither finite rewards nor 34 skill purchases establishes 48 meaningful active hours.

**Required experiment:** before M05 closes, define a varied human sample and diary protocol. Record real-open, foreground, simulated, suspended/offline and debug intervals separately. Report actual participant count, normal-speed duration, post-automation useful decisions, repetition and exhaustion, including contract-avoiding play. Exercise the provisional recent-input indicator at 299.999/300/300.001 real seconds, focus loss and 1×/60×; supplement reading/planning with diaries. That indicator alone cannot prove engagement. Full-cost active-only and mixed-offline traces must pay all chosen seeds, fertilizer, research, equipment, plots, boosts and resets.

**Required disposition:** report met/missed/insufficient evidence separately for automation pacing and further engagement. Today the 48-hour target is **insufficient evidence**: neither validated nor proven impossible. A future miss requires an explicit product/balance decision. Do not turn accelerated production into human hours, cap offline income, force contracts or add mechanics to make the target appear met.

## Scenario execution ledger

| Evidence class | Completed in this audit | Still required |
|---|---|---|
| Arithmetic | All 15 crop/fertilizer rows, expansion, 12 contract reward references, XP vectors/int64 boundary, two automation schedules, long Wheat totals, utilization/accounting examples and conditional terminal rates | Godot parity, complete overflow paths, shared-engine costed strategy scenarios |
| Static package | Ten current documents and ten older drafts read; image inspected; ZIP identity, source hashes, local links, 101 task IDs, 92 validations and declared dependency graph checked | Corrected contracts, updated source hashes and actual implementation coverage |
| Recovery | Concrete counterexamples and acceptance boundaries authored | SQLite crashes, in-process receipt loss, backup rollback, migrations, ownership and provider measurements |
| Performance | Workload bounds and fixtures calculated | Named-hardware solver, active frames, commits, forecast latency, 30-day/year and browser/vendor evidence |
| Human experience | Limits and required protocol identified | Actual normal-speed automation and post-automation observations/diaries; no human hours claimed today |

Future runs must record fixture/content/schema/build versions, accepted commands/order, expected result, actual result and evidence path. Close each unresolved oracle before accepting its dependent behavior. A scenario with an expected result is not automatically a passing game test.

## A1 selected scenario oracles — 2026-10-28

The original DVS-001–034 scenarios and calculations remain unchanged above (apart from any separately recorded exact-token erratum). Their old unresolved wording describes the pre-correction audit. These current selected outcomes replace the need to choose an oracle; they do not report test execution. Other original scenarios remain binding under the updated source contracts.

| Historical scenario | Current selected oracle / required test extension |
|---|---|
| DVS-017 | AUD-DEC-002 B: TRS §20.2; AV-002-01, AV-002-02, AV-002-03, AV-002-04, AV-002-05 |
| DVS-018 | AUD-DEC-001 B: TRS §20.1; AV-001-01, AV-001-02, AV-001-03, AV-001-04 |
| DVS-019 | AUD-DEC-003 B: TRS §20.3; AV-003-01, AV-003-02, AV-003-03, AV-003-04, AV-003-05 |
| DVS-020 | AUD-DEC-004 B: TRS §20.4; AV-004-01, AV-004-02, AV-004-03, AV-004-04, AV-004-05 |
| DVS-009 | AUD-DEC-005 A: TRS §20.5; AV-005-01, AV-005-02, AV-005-03, AV-005-04, AV-005-05 |
| DVS-011 | AUD-DEC-007 B: TRS §20.7; AV-007-01, AV-007-02, AV-007-03, AV-007-04, AV-007-05, AV-007-06 |
| DVS-033 | AUD-DEC-006 A: TRS §20.6; AV-006-01, AV-006-02, AV-006-03, AV-006-04 |

### Exact selected AV oracles

| Criterion | Required result (future execution unless expressly a document check) |
|---|---|
| AV-001-01 | Restore a checkpoint before an allocation: the new full dynamic identity differs while the restored old entities retain their IDs; retired command payloads are stale. |
| AV-001-02 | Restore before Q01’s claim: old reward and closure both roll back; eligibility follows the recovered timeline, with no separate additive payout. |
| AV-001-03 | Fixed injected namespace and identical accepted inputs produce identical IDs, scheduler order and aggregation/reference state across active/debug/offline/forecast. |
| AV-001-04 | Round-trip composite references and counters at valid integer bounds; reject collisions/malformed references before mutation; preserve namespace during receipt reconciliation. |
| AV-002-01 | DB commits revision 41 but receipt is lost while memory is 40: all write routes remain blocked until read-back selects 41; no second debit or stale overwrite. |
| AV-002-02 | A definitely rolled-back operation verifies the unchanged parent and can report not committed; an unsettled/failed read cannot be treated as rollback. |
| AV-002-03 | Exercise auto, catch-up, time-only, settings, migration and startup receipts, not only manually identified economic commands. |
| AV-002-04 | Try retry, new purchase, settings save, backup and shutdown during UNKNOWN; preserve good backups and fail closed without an old snapshot save. |
| AV-002-05 | After reconciliation/crash, compare full state, replay marks, accepted IDs and state+anchor/real-interval accounting against uninterrupted execution; inject equivalent asynchronous outcomes through portable fakes. |
| AV-003-01 | A level-7/5,200-XP profile with Auto Replant remains valid on its original immutable manifest when a different manifest raises level 7 to 6,000. |
| AV-003-02 | Lowered thresholds and changed rank maxima/prerequisites in a new manifest never apply implicitly to an old profile; unsupported/missing definitions preserve its save. |
| AV-003-03 | Validate level−1=unspent+allocated and one-point awards/surplus for current and supported legacy contexts across active/offline/forecast/restart. |
| AV-003-04 | Supported schema migration preserves manifest reference, XP, allocation, cycle/research/contract snapshots and IDs; fail/interrupt/retry with a valid backup and no duplicate award. |
| AV-003-05 | A separately approved content migration, if later supplied, must have a version-specific exact mapping and idempotent commit tests before it is enabled; no such mapping is approved here. |
| AV-004-01 | A click crosses a due harvest: that batch commits first, the controller stamps current time, and unchanged authorized terms may execute without backdating. |
| AV-004-02 | Change target cycle/project, exact cost, modifier result, content context or recurring plan: reject/refresh with no charge or automatic replacement purchase. |
| AV-004-03 | Boost preview ages naturally: fixed charge/formula stay authorized; accepted-time result uses ceil(remaining/2), and completed/1-μs/no-time-saved cases reject uncharged. |
| AV-004-04 | Unrelated extra income can increase ending wallet but never lower the confirmed minimum or increase cost; reset level/price change requires refresh. |
| AV-004-05 | Duplicate pending intent and lost acknowledgement cannot become a fresh purchase; accepted logs replay exact ordering, while rejected gameplay equality excludes independently committed due work. |
| AV-005-01 | W=100/R=0: Corn (18)+Premium (75) without fallback on plot 1, Corn (18)+None on plot 2. Plant plot 2 only, spend 18, end at 82; plot 1 stalls uncharged. |
| AV-005-02 | Cascading exclusions and newly affordable seed candidates terminate with≤N exclusions/≤N+1 passes; input permutation leaves the same canonical plan. |
| AV-005-03 | Under the approved current Corn prices, W=100 with plot 1 Corn (18)+Basic (20), plot 2 Corn (18)+Premium (75), plot 3 Corn (18)+None starts with S=54/A=46: Basic fits but Premium fails; exclusion/replan yields a defined stable subset. Add a labeled synthetic package fixture to demonstrate allowed non-maximality without calling it production balance. |
| AV-005-04 | Fallback accepted/declined, R>W, advanced seed protection, zero-cost seeds, priorities and fixed-before-Smart all preserve no negative balance and one final shared C. |
| AV-005-05 | A planning/stall-reason event cannot self-trigger unbounded zero-time retries. Offline aggregation and forecast match the event reference at each actual logical batch, including full failed-commit rollback. |
| AV-006-01 | For each of 11 required ranks assert predecessor, exact cost, insufficient funds, duplicate/skipped/max-rank rejection and no partial state/ID drift. |
| AV-006-02 | Under A, an explicitly funded valid level-1 fixture may buy rankI and later ranks sequentially without invented research/skill/contract gates. This is an isolated guard fixture, not a new-game cash grant. |
| AV-006-03 | Existing crop duration/reward snapshots remain unchanged; next planting uses additive equipment effects and the growth cap, with exact quote/execution parity. |
| AV-006-04 | Run actual full-cost upgrade-using strategies and the existing no-equipment/no-contract path. Report pacing outcomes without changing prices or gates silently; deferred families remain absent. |
| AV-007-01 | Create/rename/assign/unassign/delete with unique group IDs, zero/one membership and valid destinations; malformed/missing references reject unchanged. |
| AV-007-02 | Moving a stalled None plan to paid Advanced, or deleting its group to a paid farm default, cannot spend or silently arm without the existing explicit changed-plan start authorization. |
| AV-007-03 | Occupied cycles remain immutable; explicit future Apply and Ready-on-enable effects are previewed; new Empty/Locked plots never auto-start/unlock from membership. |
| AV-007-04 | A rename or overridden field leaving the effective purchase plan unchanged preserves existing valid loop authorization; explicit false/zero remains an override. |
| AV-007-05 | A failed structural mutation rolls back all graph changes; separately requested eligible action subsets still follow DEC-025 and commit coherently, with no charged failed member. |
| AV-007-06 | Unresolved preset references block deletion; save/reopen/backup/forecast preserve graph, versions and plan authorization. No live forecast writes or hidden group budget overrides. |
| AV-008-01 | Every operative Open/Proposed/missing approval claim about C1/C2/C3/DEC-027 is either genuinely pending or explicitly labeled historical; no settled choice is reopened. |
| AV-008-02 | After authorized edits, cross-check original decision status, source sections, task/test IDs, links, current hashes and preserved dated approval evidence. Runtime test status remains pending. |
| AV-009-01 | Every displayed SHA-256 has exactly 64 hexadecimal characters and equals the hash of the specifically named baseline bytes; preserve original and amended manifests separately. |
| AV-009-02 | All local links resolve and line numbers exist; all HTTP(S) targets contain no whitespace; compare the corrected release URL and CPU/2.5D tokens byte-for-byte with authoritative sources. |
| AV-009-03 | Review the erratum/diff: only intended technical-token/format repairs and explicit status notes change; original findings and approval evidence are not silently rewritten. |

DVS-017 selects settled-primary read-back; DVS-018 selects namespaced new entities and coherent rollback of lost credit/flag; DVS-019 keeps the old supported immutable rules; DVS-020 validates accepted-time semantic terms. AV-005 adds the precise W=100 allocation and bounded cascading/non-maximal subset cases. Equipment/group criteria close their missing oracles without inventing new gates or overlapping groups. Mode comparisons use identical injected namespace/accepted inputs and retain economic identities. All original numerical examples remain provisional/example calculations, not newly finalized balance or measured implementation evidence.

## R2-C1 DVS-013 fixture erratum — 2026-10-29

This current, authorized documentation erratum supersedes the nominal positive precondition of DVS-013 only. Its original level-20 Coffee/Rice sentence above is preserved as historical audit evidence and must not be copied as a valid positive fixture. No historical conclusion, approved crop gate, research rule, automation capability or fallback policy is changed.

**Corrected positive preconditions:** Player level **22 or above**; Coffee and Rice both unlocked through their existing level and completed-research guards; Crop Rotation and its full prerequisite chain owned; an existing unlocked plot; explicitly authorized Coffee/Rice sequence with cursor Coffee and the intended fertilizer/fallback terms. Normal seed funds are required for each accepted planting. This is an isolated eligible fixture, not a cost-free progression claim. Coffee requires level 18 and Rice level 22; owning the level-20 rotation node never grants a crop unlock.

**Action and expected result:** Exercise initial insufficient funds, subsequent funds-triggered retry of the unchanged authorized plan, definite commit failure, UNKNOWN receipt reconciliation, restart/offline/forecast, future settings and reset/rebuy. Failed affordability or crop eligibility leaves wallet, current entry, cursor and planted snapshot unchanged, with no charge or inferred replacement crop. A successful planting advances exactly once together with the seed/fertilizer charge, new cycle and coherent durable outcome. UNKNOWN blocks writes and preserves pending identities until reconciliation. Refund/rebuy does not rearm spending. Forecasts mutate only their copies; grouping/rotation cannot unlock a Locked plot.

**Separate negative fixture:** A level-20 profile with the automation prerequisite chain may own Crop Rotation, but Rice remains ineligible under its normal level/research guards. Test the planting guard separately: a direct manual Rice request rejects without charge (an ineligible batch member is skipped), while an automated current-entry planting attempt stalls uncharged without cursor advance or substitution. Do not pre-unlock Rice to call this the nominal positive case. The negative fixture tests planting failure and cursor preservation; it does not assert a new rule for accepting or storing an ineligible sequence or discarding a whole rotation.

**Sources and existing checks:** FRS §§4.2/5.4/8/9.2; TRS §§4.3/6.4/20.7; M03-V14; M05-T12/M05-V08/V11/V12/V17; M06-V13. R2-S15 in [Round 2 validation](../round_02/R2_Traceability_And_Validation.md#r2-s15--corrected-positive-rotation-fixture-and-negative-gate-case) supplies the corrected companion scenario. R2-003 status and verification evidence are in [R2 correction changelog](../round_02/R2_Correction_Changelog.md). These are document checks; no game test was run.
