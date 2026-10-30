# M01 — Coding readiness findings and proposed decisions

Date: 2026-10-29 · Status: **working note, non-authoritative** · Scope: is the documentation sufficient to plan and code M01, what must be installed, and how to proceed.

This note does not change FRS, TRS, the roadmap, the M01 plan or either decision register.

**Owner approval, 2026-10-29: "Approve all".** P1–P13 (section 4) and rulings I1–I3 (section 5) are approved as working implementation decisions for M01. They are recorded in [M01_Build_Plan.md](M01_Build_Plan.md). They are not yet synchronized into the existing specs; any such sync requires a separate, specific change approval.

Sources reviewed: [M01 plan](01_M01_Headless_Simulation_Foundation.md), [roadmap](00_IdleFarmer_Master_Roadmap.md), [FRS v1.0](../requirements/IdleFarmer_Functional_v1.0.md), [TRS v1.5](../architecture/IdleFarmer_Technical_v1.5.md), [Decision Register](../decisions/Decision_Register.md), [Audit Decision Register](../decisions/Audit_Decision_Register.md), Round 2 audit reports, and Round 1 Design Validation Scenarios.

## 1. Verdict

**The documentation is sufficient to plan M01 coding, but not to code it directly.**

- **Gameplay data is complete and unambiguous.** This covers all 15 crops, XP levels 1–30 plus the option B continuation, the 32-plot map, the initial state, rounding rules and the scheduler phase list.
- **The M01 plan is an acceptance contract, not a build plan.** It explicitly leaves signatures, the runner command, the project layout, the serialization/digest format and identity formats to the implementer. About 60% of its text is approval history (G1–C2 blocks), and its acceptance criteria are spread across the TRS (§15.1, §20), the Audit Decision Register and the DVS file.
- **No new gameplay decision is needed.** About a dozen *software* decisions (section 4) must be made and recorded before coding. A developer can make them; they just need to be written down once.
- **Three real inconsistencies** inside the M01 scope need an owner ruling (section 5). None of them blocks starting T01.

**Recommendation:** do not edit the existing specs to start. Add **one new developer-facing document**, the M01 build plan / interface sheet (section 6), that references FRS/TRS rather than restating them. Then implement in vertical slices.

## 2. Toolchain status

The approved toolchain (DEC-001 / C1, TRS §1.1) is:

- Godot 4.7.2-stable, the standard non-.NET build, for Windows x86_64
- the matching standard export templates
- GUT v9.7.1
- the Compatibility renderer
- typed GDScript

SQLite (godot-sqlite v4.9) is **M03** and is not needed for M01.

| Item | Upstream status (checked 2026-10-29 via GitHub API) | Local status |
|---|---|---|
| Godot 4.7.2-stable editor `Godot_v4.7.2-stable_win64.exe.zip` | Published 2026-08-18; 86,013,866 bytes; GitHub asset digest sha256 `731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953`; release also ships `SHA512-SUMS.txt` | **Not installed** (not on PATH; no Godot*.exe found in common locations) |
| Export templates `Godot_v4.7.2-stable_export_templates.tpz` | Published; 1,281,349,702 bytes (~1.3 GB); sha256 `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011` | Not installed |
| GUT v9.7.1 | Published 2026-07-10; tag `v9.7.1` → commit `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605` | Not present |
| git, Python 3.12, winget | Present | OK |
| Hardware (for the T01 candidate-hardware record) | AMD Ryzen 5 7600X3D, 63 GB RAM, NVIDIA RTX 4080 SUPER + AMD integrated graphics, Windows 11 Pro 26200 | Recordable as-is |

The GitHub digests above are *upstream-declared*. T01 still requires locally computed SHA-256 values for the archives and extracted binaries, a comparison with `SHA512-SUMS.txt`, license inventories, the version the editor reports, and logs of a passing empty suite and a deliberately failing suite.

**Who installs:** Claude can download, verify, hash and unpack all three artifacts and produce the T01 evidence. Downloading requires your explicit go-ahead. Godot is a portable zip, so no installer or admin rights are needed. Proposed locations:

- the editor outside the repo, e.g. `C:\_\tools\godot\4.7.2-stable\`
- GUT vendored into `idle_farmer/addons/gut/` (MIT)

You only need to act yourself if you prefer to download manually. If so, Claude will then hash and verify what you place.

**Templates:** they are 1.3 GB and are only needed for export, starting in M04/M06. T01's wording still requires inventorying them. Proposed: download them in T01 for the evidence record, but do not install them into the Godot data directory until export work begins.

## 3. What is already fully specified (no decision needed)

- **Crops** (FRS §4.2): Wheat 8 min / free / 16 coins / 6 XP. Corn 30 min / 18 / 110 / 32. All 15 rows plus research costs (FRS §8).
- **XP:** levels 1–30 (FRS §5.1). Option B continuation: first step after level 30 is 57,500, each later step is `p + ceil(p/10)`. Vectors: L31 = 577,500, L32 = 640,750, L35 = 871,045, L40 = 1,436,418. The int64 boundary is around L349.
- **Plot geometry:** `row = 1 + (id−1) div 8`, `col = 1 + (id−1) mod 8`. IDs 1–24 unlocked, 25–32 locked. Unlocked IDs must always be a contiguous prefix 1..N.
- **Initial state** (DEC-003): zero coins, XP and points. Level 1. Only Wheat is unlocked.
- **Rounding** (DEC-005, TRS §4.4): reward floor; price ceil; duration ceil to μs with a 1 μs minimum; basis points; provisional 60% growth cap.
- **Scheduler:** the source tuple and the 9-phase order (TRS §4.2, DEC-006).
- **Identity:** command = (save_id, writer epoch UUID, counter); entity = (save_id, allocation namespace, counter).
- **AV-001/002/003/004 obligations** (TRS §15.1/§20):
  - namespaced IDs ordered by counter
  - candidate-on-clone with a fake sink that returns COMMITTED / NOT_COMMITTED / UNKNOWN
  - a durable revision counter separate from gameplay IDs
  - manifest-bound content lookup
  - due work runs before the controller stamps the accepted time
  - an immutable replay envelope

## 4. Proposed implementation decisions (need approval; to be recorded in the build plan)

| # | Topic | Gap in docs | Proposed decision |
|---|---|---|---|
| P1 | Project root | "Suggested" `idle_farmer/` (TRS §13) | Godot project in `idle_farmer/` subfolder of the repo; docs stay in `docs/`. |
| P2 | Folder layout | TRS §13, roadmap and M01 table differ slightly | Use the M01 table as the base. Add `core/application/` for the controller (see I2). Leave M02+ folders unused until they are needed. |
| P3 | Test runner / command | Not given anywhere | Use the GUT CLI. Import with `godot --headless --path idle_farmer --import`, then run `godot --headless --path idle_farmer -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`. Wrap both in `tools/run_tests.ps1`, which saves logs and a JUnit XML. A nonzero exit on failure is verified in T01. |
| P4 | Evidence location | Roadmap example `artifacts/Mnn/` | `artifacts/M01/`. Commit the T01 manifest, test logs and digest reports. Do not commit binaries. |
| P5 | Canonical serialization + digest | **Not specified** (TRS §9.4 says no codec selected) | A custom canonical encoder: sorted keys, type tags, and integers emitted as decimal strings. Godot `JSON` converts integers to float and breaks int64 values, so it cannot be used. Digest is SHA-256 via `HashingContext`. Two projections: a *gameplay digest* and a *durable/clock-metadata digest* (V14). |
| P6 | Checked int64 arithmetic | No technique given; GDScript `int` wraps silently | Pre-check add/sub against INT64 bounds. Check multiplication by division. Compute `mul_div`/basis-point operations with 32-bit-limb 128-bit intermediates, so a representable quotient succeeds. Use an independent Python oracle for test vectors. |
| P7 | Stable content IDs | Only display names exist | Lowercase snake_case crop IDs (`wheat`, `carrots`, … `saffron`). Research IDs are `unlock_<crop_id>`. Manifest ID is `content_m01_v1`. |
| P8 | Growth stage formula | "Proposed 0/25/50/75/100%"; inclusivity undefined | `stage = min(3, floor(elapsed×4/duration))` while growing; stage 4 = Ready when `elapsed ≥ duration`. Stage is derived and never stored. |
| P9 | Event → phase mapping, numeric phase codes, `numeric_entity_order` | Not specified | Phase codes 1–9 in TRS §4.2 order. Only research completion (phase 1) and maturity (phase 2) are queued events. Phases 3–9 are steps inside a batch. `numeric_entity_order` = entity counter of the cycle/research. |
| P10 | Identity UUIDs | Unclear whether the writer epoch and allocation namespace are the same | Same UUID per writer epoch, injected in tests. Counters stay separate (command counter vs entity counter). |
| P11 | Failure codes and precedence | List is "typical", not exhaustive | Add `UNKNOWN_CROP`, `UNKNOWN_PLOT`, `NO_CYCLE`, `CYCLE_MISMATCH`, `MALFORMED_ENVELOPE`, `NUMERIC_LIMIT`, `STALE_TERMS`. Precedence: envelope → identity/replay → target existence → state → gates → affordability → arithmetic. |
| P12 | Response-cache bound | "Bounded", no number | 256 entries per writer epoch, configurable in tests (V10 eviction case). |
| P13 | Git workflow | None | Branch `m01-implementation` from current `audit-round-02` (or `main` after merge). One commit per slice. |

## 5. Inconsistencies needing an owner ruling (proposed corrections — not applied)

| ID | Issue | Proposed ruling |
|---|---|---|
| I1 | **V14 vs the A1 crosswalk.** M01-V14 (plan L223) lists AV-002-01–05 and AV-003-01–04. The crosswalk (L245–246) lists only AV-002-01/02/05 and AV-003-01–03. AV-002-03/04 (backup, shutdown, migration, settings saves) and AV-003-04 (schema migration) are persistence work. | Follow the crosswalk. M01 covers AV-002-01/02/05 and AV-003-01–03. AV-002-03/04 and AV-003-04 belong to M03. |
| I2 | **No controller in the M01 file table**, yet T06/T13/T14 and AV-004 require controller time-stamping, command counter issuance and intent dedupe. | Add an in-memory `GameController` (`core/application/game_controller.gd`) to M01, with no UI or durable storage. |
| I3 | **AV-003-01/03 reference skill allocations** ("Auto Replant", allocated points), but skills are M02. | Add a minimal *data-only* skill allocation record plus fixture so the point-conservation and manifest-binding tests can run. Skill behavior stays in M02. |
| I4 | (Low) The R2 readiness "Precise conditions" #1 cites A1-era FRS/TRS hashes; current hashes are in the R2-C1 addendum. | No action needed. Use the current hashes. |

If approved, I1–I3 can be recorded in the build plan as rulings, with optional later synchronization into the M01 plan through the Decision Register change-control workflow.

## 6. Guidance on documents

**Existing specs:** sufficient as the authority. Do not rewrite them.

**Add one new document:** `docs/implementation/M01_Build_Plan.md` (name proposed). It is non-authoritative and is a working developer plan. Contents:

1. The approved P1–P13 and I1–I3 rulings.
2. Concrete GDScript class and method signatures per task: state records, ContentRegistry, IntegerMath, commands/results/events, EventScheduler, SimulationClock/TimeProvider, FarmSystem, ProgressionSystem, SimulationEngine and GameController.
3. A test map: each M01-V01–V14 row and each AV/DVS case → GUT test file, with exact oracle vectors.
4. The T01 evidence manifest template (`artifacts/M01/toolchain_manifest.md`).
5. Slice order and done criteria.

`/ce-plan` can produce this from this note once the decisions are approved.

**At M01 close (T16):** the roadmap expects decision records (D-01/02/03/05/06) and a DEC-001 closure entry. Those *are* edits to existing docs. Propose them as a specific change list for your approval at that point.

## 7. Proposed implementation slices

| Slice | Tasks | Exit evidence |
|---|---|---|
| S0 Toolchain | T01 | Artifact hashes and licenses, editor version, empty suite exits 0, failing suite exits nonzero, runner script |
| S1 Content + math | T02, T03, T04 | Registry/fixture validation, all XP thresholds (V05, V11, V13), arithmetic boundary vectors |
| S2 State + commands + scheduler | T05, T06, T07 | Clone isolation (V07), rejection equality (V03), tie ordering and restore (V04) |
| S3 Clock + farming + XP | T08–T12 | Wheat/Corn exact timing and rewards (V02), clock partitions (V06), multi-level grants |
| S4 Engine + controller + replay | T13, T14 | Headless scenario, 1×/60×/partition equivalence over 32 plots (V08), AV-001/002/004 fakes (V10, V14) |
| S5 Boundaries + handoff | T15, T16 | Dependency audit (V09, V12), M03-T18 probe recipe, API inventory, test logs, limitations |

Each slice is a reviewable commit with green tests. S0 is the hard gate for the rest (R2-C1).
