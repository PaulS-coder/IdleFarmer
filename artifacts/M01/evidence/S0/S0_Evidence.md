# S0 — Project skeleton and runner evidence (completes M01-T01)

Recorded: 2026-10-30 UTC, branch `m01-implementation`. Toolchain: Godot `4.7.2.stable.official.ed1daf0bf` (console binary), GUT 9.7.1 (commit `aeb5d4f3…`). Artifact verification is in [T01_Toolchain_Evidence.md](../../T01_Toolchain_Evidence.md).

## Delivered

- **`idle_farmer/project.godot`:**
  - Compatibility renderer (desktop and mobile);
  - `untyped_declaration` warning set to **Error**, with `exclude_addons=true`;
  - no autoloads and no main scene.
- **`idle_farmer/addons/gut/`:** byte-identical copy of the verified GUT 9.7.1 addon (`diff -r` against the verified extraction: identical).
- **`idle_farmer/.gutconfig.json`:** test dir `res://tests/`, subdirectories included, prefix `test_`.
- **`idle_farmer/.gitattributes`:** LF line endings for Godot sources.
- **`idle_farmer/tests/unit/test_smoke.gd`:** one typed smoke test.
- **`tools/run_tests.ps1`:** headless import, then GUT, then JUnit. It adds a script-error guard and a zero-test guard on top of GUT. Exit codes:

  | Exit | Meaning |
  |---|---|
  | 0 | Pass |
  | 1 | Test failures |
  | 2 | Zero tests ran |
  | 3 | Godot binary not found |
  | 4 | Import failed |
  | 5 | Script load or parse error |

- **`.gitignore`:** excludes `idle_farmer/.godot/` and `artifacts/*/test_runs/`.

## Runner verification

| Run | Test set | Expected | Actual exit | Folder |
|---|---|---|---|---|
| Default suite | `res://tests/` (smoke) | 0 | **0** (1/1 passed) | `run_default_pass/` |
| Deliberate failure | `assert_eq(1, 2)` | 1 | **1** | `run_deliberate_fail/` |
| Empty dir | no tests | nonzero | **2** (zero-test guard; GUT itself exited 0) | `run_empty_zero_guard/` |
| Mixed valid + untyped | smoke + `var value = 1` | nonzero | **5** (script-error guard; GUT exited 0 with 1/1 passed) | `run_mixed_script_error_guard/` |

The probe test files are kept in `probe_tests/`. They were removed from the project after the runs.

## Findings

1. **GUT silently skips scripts that fail to parse.** It logs `Ignoring script … does not extend GutTest`, runs the remaining tests, and exits 0. Without the script-error guard, an untyped or broken test file would drop out of a green run. The guard scans both the import log and the test log.
2. **The untyped-declaration Error setting works and does not affect GUT.** The parse error is `Variable "value" has no static type. (Warning treated as error.)`. GUT's own scripts are excluded as addons.
3. **`--import` does not compile GDScript files.** A broken core script is only caught when a test loads it. S5's dependency audit should load every `core/**/*.gd` so that every script is parsed at least once.
4. **Import generates `.uid` files next to each script** (Godot 4.4+). They are committed so resource UIDs stay stable.
