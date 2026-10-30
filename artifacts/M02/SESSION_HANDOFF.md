# M02 session handoff (written 2026-10-30, after S2)

Read this first in a new chat. It is a pointer document; the authorities are the files it links.

## Where things stand

- **M01 is complete and merged to `main`** (PaulS-coder/IdleFarmer#2).
- **M02 is in progress on branch `m02-implementation`.** Nothing is pushed.

| Commit | Content |
|---|---|
| `2931520` | Readiness findings and build plan |
| `d337d9d` | S0: exact rate solver (`RateFrontier`, `BigInt`), `CommandFactory`, M01 carry-over fixes |
| `f159551` | S1: `content_m02_v1`, `ModifierSnapshot`, fertilizer pricing, PlantCrop with fertilizer |
| `d68e2e3` | S2: PurchasePlot, AllocateSkill, ResetSkills, PurchaseUpgrade, `Capabilities` |

- The suite is green: 281 tests, about 14 s.
- **Remaining:** S3 (research), S4 (automation core: settings, authorization, batch pipeline, allocator), S5 (Smart Fertilizer modes, oracle, caching), S6 (accounting and committed-harvest port), S7 (strategy harness, pacing report, handoff).

## Read in this order

1. [`docs/implementation/M02_Build_Plan.md`](../../docs/implementation/M02_Build_Plan.md):
   - §1 decisions (Q1–Q3, E1–E18, B1–B6; B3 amended by the owner);
   - §3 contracts;
   - §4 slices;
   - §5 V01–V15 test map with exact values;
   - §9 change log.
2. [`docs/implementation/M02_Readiness_Findings.md`](../../docs/implementation/M02_Readiness_Findings.md): owner approvals and the remaining doc fixes C1–C3. Those fixes are *not applied* and need separate approval.
3. `artifacts/M02/evidence/S0`–`S2/*_Evidence.md`: what each slice delivered, mutation checks, notes.
4. [`docs/implementation/02_M02_Economy_Skills_Research_Automation.md`](../../docs/implementation/02_M02_Economy_Skills_Research_Automation.md): task text T01–T18 and V01–V15. FRS/TRS remain the authority.

## Carried obligations (do not lose)

- **S4:**
  - Reset must disarm automation loops: typed `LoopAuthorization` (E11).
  - PlantCrop terms gain `fallback_accepted`, `plan_digest` (Q1) and `min_ending_balance` (manual reserve override).
  - `PlotState` flat settings fields move into typed tri-state settings (E10). Log the schema change in §9.
  - Multi-member commands must be plan-then-apply, so nothing is partially committed (carry-over 3).
- **S5:** identical-input result caching for the solver (owner condition for the B3 amendment). Capital Efficiency ranks by per-cycle ROI (Q2).
- **S6:** committed-harvest port (carry-over 1 from M01-T13).
- **Q3:** seed protection and custom priorities are tested through fixtures only; their config commands return `FEATURE_UNAVAILABLE`.

## How to work (proven conventions)

**Workflow per slice:**

1. Implement.
2. Run `tools/run_tests.ps1` until it is green.
3. Run 4–6 **isolated mutation checks**: a Python script backs up files, applies one mutation, runs the suite, then restores. See the S1/S2 scripts pattern in the evidence.
4. Clean-import run (`Remove-Item idle_farmer\.godot`).
5. Copy the run to `artifacts/M02/evidence/S<n>/` and write `S<n>_Evidence.md`.
6. Add a build-plan §9 change-log row.
7. Commit (attribution: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`).
8. Ask the owner before the next slice.

**Commands:**

- Tests: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1 [-Dir res://tests/unit] [-Select name]`.
  - Exit codes: 0 ok, 1 failures, 2 zero tests, 5 script/parse error, 6 leak.
  - Logs: `artifacts/M02/test_runs/<stamp>/test.log`.
- Solver benchmark: `-Dir res://balancing`.
- Oracle: `python -I tools/oracles/m02_oracle.py` regenerates `tests/fixtures/m02_oracle_vectors.gd`. Extend it for new exact values.
- Godot: `C:\_\tools\godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe`.

**Pitfalls already hit:**

- **Bash heredocs containing GDScript or Python sometimes fail to parse** (`unexpected EOF`). Write files with the Write tool, and put multi-edit Python scripts in the scratchpad, then run them.
- **Never pipe the runner through `Select-Object -First N`.** It kills the runner before the summary is written. Redirect to `$null` and read `test.log` instead.
- **GUT loads any `tests/**/test_*.gd` as a suite.** Helpers must not use that prefix.
- **GDScript specifics:**
  - `namespace` is reserved;
  - export primitives via `PrimitiveReader.plain()` (no typed containers);
  - `int` wraps silently, so use `IntegerMath`;
  - avoid floats, `JSON`, `Time`/`OS` in `core/` (the V09 audit enforces this);
  - lambdas capturing `self` inside RefCounted graphs leak, and the runner fails on leaks.
- **Fixtures:** `Fixtures.registry()` is v1 and `Fixtures.registry_v2()`/`new_game_v2()` are v2; `ManifestFixtures.catalog()` registers both. Use `Fixtures.command(state, type, terms, counter)` and `Fixtures.engine_for(state)`.
- **Precedence:** checks follow `FailureCode.PRECEDENCE`. Target-state checks precede `STALE_TERMS`.
