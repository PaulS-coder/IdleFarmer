# M02 S1 — Content, modifiers, fertilizer pricing and quotes (M02-T01, T02)

Recorded: 2026-10-30 UTC, branch `m02-implementation`. Default suite from a clean import: exit 0, **259 tests, 10,007 assertions, 0 failures** (`run_s1_suite/`).

## Delivered

| Area | Files |
|---|---|
| Definitions | `core/content/upgrade_definition.gd`, `fertilizer_definition.gd`, `expansion_band.gd`, `economy_parameters.gd`; `skill_definition.gd` gains `effect_kind`, `effect_bp_per_rank` and `capability_id`; `content_manifest.gd` gains the M02 tables |
| Registry | `content_registry.gd`: M02 accessors and validation (contiguous ranks, fertilizer tiers with mandatory `none`, bands covering exactly plots 25–32, economy ranges, skill-effect rules, all-or-nothing tables, **DEC-008 deferred IDs rejected**) |
| Data | `data/skills/skill_catalog_v2.gd`, `data/upgrades/upgrade_catalog_v1.gd`, `data/fertilizers/fertilizer_catalog_v1.gd`, `data/economy/expansion_v1.gd`, `data/economy/economy_parameters_v1.gd`, `data/manifests/content_m02_v1.gd` |
| Modifiers and quotes | `core/economy/modifier_snapshot.gd`, `fertilizer_pricing.gd`; `planting_quote.gd` (fertilizer terms, incremental net, cap waste, profit); `economy_system.gd` (snapshot-based quote; the code growth-cap constant is removed and the cap comes from the manifest) |
| Planting with fertilizer | `farm_system.gd`: `UNKNOWN_FERTILIZER`; seed and fertilizer charged together; separate `fertilizer_purchase` transaction; `CropCycle.fertilizer_transaction_id`; ID headroom for three IDs. `PlantCropCommand` and `RawIntent` carry `fertilizer_id` and `fertilizer_cost`. |
| Oracle | `tools/oracles/m02_oracle.py` adds an independent FRS transcription with 84 modifier/quote vectors and 60 price vectors |
| Tests | `tests/unit/test_content_registry_v2.gd`, `test_invalid_content_v2.gd`, `test_modifier_snapshot.gd`, `test_plant_fertilizer.gd` |

## Validation coverage

- **V02 / T-004:**
  - Tomatoes with Basic: seed 55, fertilizer 41, gross 337, XP 70, profit 241. Executed end to end: wallet 1,000 → 904 → 1,241 after harvest.
  - The snapshot is unchanged after a later Improved Soil purchase.
- **V09 (data part):**
  - Irrigation total is 1,874,750 and Improved Soil 783,900, with exact rank costs and effects.
  - The expansion bands sum to 34,500.
  - The full growth stack (50% skills + 30% Irrigation) caps at 60%, giving Wheat 192,000,000 μs and Tomatoes 1,440,000,000 μs; the 20% waste is reported.
- **V14 (content part):** exactly four fertilizers. Seed Efficiency, Research Facilities and Growth Booster are absent, and injecting them fails validation with `DEFERRED_CONTENT`.
- **Oracle:**
  - all 84 random and named modifier/quote combinations match (growth capped and uncapped, duration, gross with and without fertilizer, XP, price, incremental net, profit);
  - the 15 × 4 price table matches;
  - coin bonuses never change XP.
- **AV-003 (content part):**
  - `content_m02_v1` keeps every `content_m01_v1` row unchanged;
  - both manifests coexist in one catalog;
  - a v1 profile has identity modifiers even with stored ranks;
  - a v1 profile cannot buy a v2 fertilizer (`UNKNOWN_FERTILIZER`, state unchanged).
- **AV-004-02 (fertilizer part):** a changed fertilizer, price or boosted reward gives `STALE_TERMS` with no charge.
- **Replay:** a controller planting with Premium replays exactly from its accepted log.

## Mutation checks (each run in isolation)

| Injected defect | Caught by |
|---|---|
| Equipment effects ignored | 4 tests (oracle, cap and waste, snapshot keys, snapshot immutability) |
| Fertilizer price floor uses min instead of max | 6 tests (oracle, price table, T-004 ×2, affordability, controller replay) |
| Incremental-gain baseline drops skill/Soil bonuses | Oracle quotes |
| Deferred-content check disabled | `test_deferred_families_rejected` |
| Affordability checks the seed only | `test_insufficient_coins_covers_seed_plus_fertilizer` |

All mutations were reverted, and the clean suite passes.

## Decisions and notes

- **B3 amended by the owner:** uniform threshold 5 ms (measured 3.0 ms), and identical-input caching is added to S5.
- **`CropCycle.fertilizer_id` defaults to `none`.** A cycle has a `fertilizer_transaction_id` exactly when its fertilizer is not `none` (validated).
- **Equipment ranks a v1 profile has stored have no effect**, because its manifest defines no equipment (AV-003).
- **Not yet in S1, as planned:** confirmation terms for fallback, plan digest and manual reserve override arrive with automation in S4. Purchase commands are S2.
