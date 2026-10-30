# S3 — Clock, planting, maturity, harvest and XP levels (M01-T08 to T12)

Recorded: 2026-10-30 UTC, branch `m01-implementation`. Run: `tools/run_tests.ps1`, exit 0, **160 tests, 3,486 assertions, 0 failures** (`run_s3_pass/`).

## Delivered

| Area | Files |
|---|---|
| Clock foundation (T08) | `core/time/time_provider.gd` (abstract), `simulation_clock.gd`; `TimeAnchor.credit()` / `observe_utc()`; `tests/support/fake_time_provider.gd` |
| Base planting calculations (T09) | `core/economy/economy_system.gd`, `planting_quote.gd` |
| Manual planting, maturity and harvest (T10/T11) | `core/farming/farm_system.gd` |
| Cumulative XP and levels (T12) | `core/progression/progression_system.gd`, `xp_grant.gd` |
| Tests | `tests/unit/test_simulation_clock.gd`, `test_planting_quotes.gd`, `test_plant_command.gd`, `test_maturity_harvest.gd`, `test_progression.gd`; planting/harvest helpers in `tests/support/fixtures.gd` |

## Validation coverage (S3 portions; engine-level runs are S4)

- **V02 / T-001 / T-003:**
  - Wheat planted at t=0 is still Growing at 479,999,999 μs and Ready at 480,000,000 μs; harvest pays 16 coins and 6 XP once.
  - Corn debits 18, matures at 1,800,000,000 μs and pays 110 coins and 32 XP.
  - No reward at planting or maturity.
  - A Ready crop does not spoil and pays the same after 30 days.
  - Stages are derived exactly at 0/25/50/75/100%.
- **V03 / T-020 (transition part):**
  - repeating a harvest gives `NO_CYCLE`;
  - an old cycle ID cannot harvest a replacement cycle (`CYCLE_MISMATCH`);
  - stale or early maturity events are ignored;
  - every rejection leaves the full state digest unchanged, including ID and sequence counters, and schedules nothing.
- **T10 rejections:** `UNKNOWN_PLOT`, `UNKNOWN_CROP`, `PLOT_LOCKED`, `PLOT_OCCUPIED`, `LEVEL_REQUIRED` (even with research done), `RESEARCH_REQUIRED`, `INSUFFICIENT_COINS` and `NUMERIC_LIMIT` (entity ID, insertion sequence, maturity time). The precedence order is confirmed.
- **AV-004-02 (planting part):** a changed manifest, seed cost, growth, gross or XP gives `STALE_TERMS` with no charge, and that check runs before affordability.
- **V05 / V13 (grant part):**
  - below/at each threshold for levels 2–30;
  - a multi-level award (0 → 5,200 XP gives level 7 and 6 points);
  - option B crossings from 30 to 35;
  - surplus points persist after all 34 ranks are full (level 45, 10 unspent);
  - the maximum representable XP gives level 349 and 348 points;
  - an XP overflow fails with nothing applied;
  - `LevelGained` is emitted on a harvest that crosses a level.
- **V06:**
  - 480 s at 1× equals 8 s at 60× (both reach 480,000,000 μs);
  - split and combined intervals give the same result;
  - a UTC rollback or forward jump does not change active simulation time, the anchor tracks real elapsed time only, and backward UTC is logged as an anomaly.
- **V10 (time and numeric parts):**
  - suspended and offline time run at 1× even at 60×;
  - TRS trace: 10 s at 60× plus 1 h suspended gives 4,200 s simulated, the anchor advances 3,610 s, and nothing is credited twice;
  - a wallet overflow on harvest is atomic and the cycle is not consumed;
  - clock overflow or invalid input leaves the clock unchanged, all-or-nothing.
- **V12 (provider part):** the fake provider reports an active/suspended split and models a monotonic clock that excludes sleep.

## Mutation checks

| Injected defect | Caught by |
|---|---|
| Harvest does not terminate the cycle (double payment) | 3 tests (run in isolation) |
| Maturity requires time > maturity (off-by-one) | 7 maturity/harvest tests |
| `STALE_TERMS` check bypassed | 2 tests |
| Suspended time multiplied by debug speed | 2 clock tests |
| Multi-level award grants at most 1 point | 5 progression tests |

All mutations were reverted, and the clean suite passes.

## Decisions taken in this slice (recorded in the build plan change log)

- **Manual planting does not change `selected_crop_id`.** Selection is configuration, not a purchase (DVS-012). Auto-replant configuration is set by M02 commands.
- **`FarmSystem.harvest_ready_cycle` is the single harvest transition**, ready for M02 automatic harvest (TRS §4.2: "Manual harvesting uses the same harvest transition").
- **The economy uses identity modifiers in M01.** `EconomySystem.current_modifiers()` is the hook for M02 skills, equipment and fertilizer. The provisional growth cap is 60%.
