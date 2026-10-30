# M02 S2 — Plot, skill, reset and equipment purchases (M02-T03 to T06)

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import: exit 0, **281 tests, 10,349 assertions, 0 failures** (`run_s2_suite/`).

## Delivered

| Area | Files |
|---|---|
| Commands | `core/simulation/commands/terms_command.gd` (typed flat terms, strict decode, immutable); `purchase_plot_command.gd`, `allocate_skill_command.gd`, `reset_skills_command.gd`, `purchase_upgrade_command.gd`; `CommandFactory` registration |
| Skills | `core/progression/skill_system.gd` (allocation and reset with quotes); `core/progression/capabilities.gd` (derived, never stored) |
| Purchases | `core/economy/purchase_system.gd` (plot N+1 and equipment next rank, with quotes) |
| Wiring | Engine dispatch; controller quote APIs (`quote_plot_purchase`, `quote_upgrade`, `quote_skill`, `quote_reset`, `capabilities`, fertilizer-aware `quote_plant`); full failure-code set and order (build plan §3.3); new transaction types and categories (`plot_purchase`/expansion, `upgrade_purchase`/equipment, `skill_reset`/reset); new event types |
| Validation | `GameState.validate` rejects equipment families or ranks that the bound manifest does not define (AV-003) |
| Tests | `tests/simulation/test_purchases.gd`, `tests/unit/test_skill_rules.gd`, `tests/unit/test_reset.gd`; fixture helpers `Fixtures.command`, `Fixtures.engine_for` |

## Validation coverage

- **V09 / V12, plots:**
  - sequential purchases 25→32 at 250 / 250 / 1,000 / 1,000 / 4,000 / 4,000 / 12,000 / 12,000, total 34,500;
  - nothing is planted automatically;
  - with all 32 unlocked, a further purchase gives `PLOTS_FULL`;
  - a request for plot 27 with plots 1–24 unlocked fails even at level 30 with 1,000,000 coins;
  - a failed purchase of 25 does not make 26 eligible;
  - level and coins are joint preconditions;
  - an old intent cannot buy plot 26;
  - a v1 profile gets `FEATURE_UNAVAILABLE`.
- **AV-006-01/02, equipment:**
  - all 11 ranks bought sequentially from level 1 at their exact costs;
  - for every rank, a skipped rank (`UPGRADE_PREDECESSOR_REQUIRED`), insufficient funds and a duplicate re-delivery are rejected, and `UPGRADE_MAX_RANK` follows the last rank;
  - every rejection is digest-identical, including ID counters;
  - deferred or unknown families give `UNKNOWN_UPGRADE`, and v1 profiles cannot buy equipment.
- **AV-006-03:**
  - a growing snapshot is unchanged by later Irrigation or Soil purchases;
  - the next Tomatoes quote is 3,420,000,000 μs (−5%) with gross 364 (×1.35 with Basic);
  - executing that exact quote succeeds.
- **V01 / V12, skills:**
  - four points (Batch Planting → Batch Harvesting → Automatic Harvesting → Automatic Replanting) give basic automation at level 7, with 2 points spare;
  - Smart Fertilizer is gated at level 9;
  - the predecessor chain is enforced;
  - one rank of the previous tier is enough for tier entry;
  - max rank, insufficient points and unknown skill are rejected;
  - a re-delivered allocation never allocates twice;
  - capabilities are derived and disappear when their ranks are removed.
- **V05 / T-008, reset:**
  - prices: level 1 → 250, 2 → 250, 3 → 450, 7 → 2,450, 10 → 5,000, 30 → 45,000;
  - a reset refunds all four points exactly and clears ranks and capabilities;
  - it keeps XP, level, equipment, research and the growing snapshot;
  - with nothing allocated it gives `NOTHING_TO_RESET`; a v1 profile gets `FEATURE_UNAVAILABLE`.
- **AV-004-04:**
  - reaching level 8 between quote and acceptance gives `STALE_TERMS` (the new price is 3,200);
  - extra unrelated income still executes at the quoted charge, and the ending balance is never below the confirmed minimum;
  - a change in allocated points between quote and acceptance gives `STALE_TERMS`.
- **E16 / AV-004-05:** a re-delivered purchase intent returns its recorded result with no second charge, and the accepted log replays exactly.

## Mutation checks (each run in isolation)

| Injected defect | Caught by |
|---|---|
| Skipping plots allowed | 2 plot tests |
| Skill predecessor ignored | 2 skill tests |
| Reset does not refund points | T-008 reset test |
| Skipping equipment ranks allowed | AV-006 sequential test |
| Reset price linear instead of quadratic | 5 reset tests |
| Plot level gate ignored | Joint-precondition test |

All mutations were reverted, and the clean suite passes.

## Notes and decisions

- **Rejection codes for re-delivered purchases.** Re-delivering a completed purchase is rejected with the first failing check in the agreed order: `PLOT_UNLOCK_ORDER_REQUIRED` for plots; `STALE_TERMS`, or `UPGRADE_MAX_RANK` after the last rank, for equipment; `STALE_TERMS` for skills. Each is uncharged. Within the controller, a re-delivered intent returns its recorded success.
- **Disarming loops on reset waits for S4.** Reset clears ranks, so capabilities vanish immediately. Disarming automation loops arrives in S4 together with the typed `LoopAuthorization` record (E11).
- **Changed test fixture.** `test_deep_clone`'s rich state moved to a v2 profile, because equipment ranks are now validated against the bound manifest.
