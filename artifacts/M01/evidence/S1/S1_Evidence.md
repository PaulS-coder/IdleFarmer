# S1 — Integer math, canonical codec, content and XP curve (M01-T02, T03 data, T04)

Recorded: 2026-10-30 UTC, branch `m01-implementation`. Run: `tools/run_tests.ps1`, exit 0, **58 tests, 1,656 assertions, 0 failures** (`run_s1_pass/`).

## Delivered

| Area | Files |
|---|---|
| Checked int64 arithmetic (T04) | `core/economy/integer_math.gd`, `math_result.gd` |
| Canonical codec + SHA-256 digest (P5) | `core/state/canonical_codec.gd` |
| Content model (T02) | `core/content/crop_definition.gd`, `research_definition.gd`, `skill_definition.gd`, `level_curve_definition.gd`, `content_manifest.gd`, `content_registry.gd`, `manifest_catalog.gd` |
| Source data (T02/T03) | `data/crops/crop_catalog_v1.gd` (FRS §4.2 and §8), `data/levels/level_curve_v1.gd` (FRS §5.1 and §5.1.1), `data/skills/skill_catalog_v1.gd` (FRS §§5.2–5.4), `data/manifests/content_m01_v1.gd` |
| Independent oracle | `tools/oracles/generate_oracle_vectors.py` → `tests/fixtures/oracle_vectors.gd` (generated) |
| Tests | `tests/unit/test_integer_math.gd`, `test_canonical_codec.gd`, `test_content_registry.gd`, `test_invalid_content.gd`, `test_level_curve.gd` |

## Validation coverage (partial; S1 owns the data and math portions)

- **V05:**
  - integer price/reward/rounding/cap vectors: Tomato +25% gives 337, Basic fertilizer costs 41, the 60% cap gives 24 min, minimum 1 μs;
  - maximum-value arithmetic;
  - 142 `mul_div` oracle vectors, including 120 seeded overflow cases;
  - malformed content rejected with 24 specific error codes;
  - below/at/above every threshold for levels 2–30.
- **V11 (data part):** all 30 FRS thresholds are unchanged, and the option B continuation is defined separately.
- **V13 (data part):**
  - levels 31–40 match exactly;
  - the closed-form float adversary (L35 = 871,044, L40 = 1,436,402) is rejected;
  - all 349 representable thresholds match the Python oracle;
  - `level_for_xp(INT64_MAX)` = 349, which gives 348 points;
  - the level-350 threshold returns −1 as a representation boundary, not a cap.
- **T02:** all 15 crops, 14 research projects and 14 skills (34 ranks/nodes) are transcribed and independently re-checked against FRS rows. Wheat is the only start unlock. Registry getters return copies.

## Mutation checks (tests detect real defects)

| Injected defect | Result before fix | Result after fix |
|---|---|---|
| Level 13 threshold 29,334 → 29,333 | 2 tests failed (caught) | — |
| `_mul_div_small` carry `>=` → `>` | **Not caught**: all tests passed | Added an exhaustive x, y < d ≤ 24 test and 120 seeded overflow vectors; the defect is now caught (1 failing test) |

Both mutations were reverted, and the clean suite passes.

## Notes

- The log line `Unicode parsing error … Invalid UTF-8 leading byte (ff)` is expected. It comes from the codec test that feeds invalid UTF-8 on purpose. It does not match the script-error guard patterns.
- Two files were added beyond the plan's layout (`math_result.gd`, `research_definition.gd`). The build plan change log records this.
