# S5 — Architecture boundary, serialization coverage and handoff (M01-T15, T16)

Recorded: 2026-10-30 UTC, branch `m01-implementation`. Final run from a **clean import** (the `.godot` cache was deleted first): `tools/run_tests.ps1`, exit 0, **210 tests, 6,354 assertions, 0 failures**, with no script errors and no leaks (`run_s5_final/`).

## Delivered

| Area | Files |
|---|---|
| Dependency audit (T15, V09) | `tests/architecture/test_core_dependencies.gd`. Loads and compiles every `core/**` and `data/**` script, which also closes the S0 gap where `--import` does not compile GDScript. Forbids, with comments and strings stripped: scene/Node bases, scene-tree access, audio/display/rendering/input APIs, OS/Time/File/ProjectSettings/threads, SQL/native bridges, `Engine.` globals, `load`/`preload`, float/random/JSON, and test-only classes. `Resource` is allowed only in `core/content/`, and every class base is `RefCounted`, `Resource` or a core class. |
| Headless boot (T15, V09) | `tests/architecture/test_headless_boot.gd`: display `headless`, audio driver `Dummy`, renderer `gl_compatibility`. A full core boot plus plant, offline advance and harvest adds no node to the SceneTree. |
| Field review (T16) | `tests/architecture/test_serialization_coverage.gd`: for 17 persisted record types, script variables equal the `to_primitive()` keys, so a future field cannot escape clone, digest or snapshot. |
| Dependency report and API inventory (T15/T16) | `tools/dependency_report.py` → [`M01_Dependency_Report.md`](../../M01_Dependency_Report.md): 49 scripts, **0 references outside core/data**, a module table and diagram, and public signatures per class. |
| Module hygiene | `IntegerMath` and `MathResult` moved from `core/economy/` to the independent `core/math/` (class names unchanged). This removes false content/state/time → economy edges. |
| Handoff (T16) | [`M01_Handoff.md`](../../M01_Handoff.md): task and V01–V14 status, D-01/02/03/05/06 records, API entry points, fixture manifest, portability assumptions, the M03-T18 probe recipe (not executed), known limitations and owners. |
| Doc change proposal | [`M01_Proposed_Doc_Changes.md`](../../M01_Proposed_Doc_Changes.md): eight proposed edits to existing docs, none applied. |

## Positive controls (the new checks detect real violations)

| Injected violation | Detected |
|---|---|
| `Time.get_ticks_usec()` in `core/time/simulation_clock.gd` | Yes: `simulation_clock.gd:105 platform/OS/file/time API` |
| `const RATIO: float = 1.1` in `data/levels/level_curve_v1.gd` | Yes: `level_curve_v1.gd:15 float/random/JSON in authoritative code` |
| Unserialized `var nickname` added to `PlayerState` | Yes: field list ≠ primitive keys |

All injections were reverted, and `git status` showed no changes in `core/` or `data/`.

## Totals across M01

| Slice | Tests (cumulative) | Assertions (cumulative) | Mutation/positive controls |
|---|---|---|---|
| S0 | 1 | 1 | runner exit-code probes (0/1/2/5) |
| S1 | 58 | 1,656 | 2 (one exposed a test gap, now closed) |
| S2 | 116 | 3,021 | 3 |
| S3 | 160 | 3,486 | 5 |
| S4 | 201 | 6,169 | 4 |
| S5 | 210 | 6,354 | 3 |
