# M01-T01 — Toolchain artifact verification evidence

Recorded: 2026-10-29. Performed by: Claude Code at the owner's request ("Yes, download all").

Scope: this record covers the **verification-only** probes required by the R2-C1 dependency-adoption gate (M01 plan, M01-T01). It does not create the `idle_farmer/` project and does not change any existing document. The status of each item is labeled **Selected** (named by DEC-001/C1) or **Verified** (evidence below).

## 1. Summary

| Artifact | Selected | Verified |
|---|---|---|
| Godot 4.7.2-stable standard (non-.NET) editor, Windows x86_64 | Yes | **Yes**: SHA-256/512 match publisher, Authenticode valid, reports `4.7.2.stable.official.ed1daf0bf` |
| Matching standard 4.7.2-stable export templates | Yes | **Yes** (package integrity and inventory). Not installed into the Godot data directory; export itself is not exercised until M04/M06. |
| GUT v9.7.1 | Yes | **Yes**: tag resolves to full commit, plugin.cfg reports 9.7.1, MIT license present |
| Headless runner: empty suite / passing suite / deliberate failure | — | **Yes**: exit codes 0 / 0 / 1 |
| Compatibility renderer in headless run | Yes | **Yes**: `rendering_method=gl_compatibility`, audio driver `Dummy`, display `headless` |
| Native SQLite (godot-sqlite v4.9) | M03 candidate only | Not acquired (out of M01 scope) |

Result: **M01-T01 artifact gate passes for adoption into the M01 project.** Two parts of T01 remain:

- creating the project skeleton inside the repo, which needs P1–P4 approval (see [M01_Readiness_Findings.md](../../docs/implementation/M01_Readiness_Findings.md));
- repeating the empty-suite check in that skeleton.

## 2. Provenance and hashes

**Downloaded from:**

- Godot: `https://github.com/godotengine/godot/releases/download/4.7.2-stable/<file>`. This is the official GitHub release; the godotengine.org archive page for 4.7.2-stable links to it.
- GUT: `https://github.com/bitwes/Gut/archive/refs/tags/v9.7.1.zip`

**Local paths:**

- archives: `C:\_\tools\downloads\…`
- editor: `C:\_\tools\godot\4.7.2-stable\`
- GUT: `C:\_\tools\gut\9.7.1\Gut-9.7.1\`

### Archives

| File | Bytes | SHA-256 (local) | Publisher check |
|---|---|---|---|
| `Godot_v4.7.2-stable_win64.exe.zip` | 86,013,866 | `731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953` | Equals GitHub asset digest. SHA-512 `83decd58…259993` **OK** against `SHA512-SUMS.txt` |
| `Godot_v4.7.2-stable_export_templates.tpz` | 1,281,349,702 | `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011` | Equals GitHub asset digest. SHA-512 `ca4d71c4…b84079` **OK** against `SHA512-SUMS.txt` |
| `SHA512-SUMS.txt` (publisher manifest) | 5,682 | `b8bdff6704f833e7a021df16ec08e1478edd5a285c1f894929b91a7f74a5c7c0` | Equals GitHub asset digest; copy in `t01_logs/` |
| `Gut-v9.7.1.zip` (GitHub tag archive) | 1,118,303 | `14969aa46adc84aa08cdd21b9f6d1a64addd92ae60b36f02d0521ed305aa4086` | No publisher checksum is published. The archive's embedded commit equals the tag commit (below). |

### Extracted binaries and identities

| Item | Identity |
|---|---|
| `Godot_v4.7.2-stable_win64.exe` | 180,858,888 bytes, SHA-256 `ab1824f85bfd8e0e4128182c000c4003a3e042245b2967848d089b2a04b22424`. Authenticode **Valid**, signer `CN=Prehensile Tales B.V.` (NL), Certum timestamp. |
| `Godot_v4.7.2-stable_win64_console.exe` | 198,152 bytes, SHA-256 `c8f0a6bc45a19b33541501e57f6f7cd972ab18453743266339d495cbbe846643`. Authenticode **Valid**, same signer. |
| Editor-reported version | `4.7.2.stable.official.ed1daf0bf` |
| Godot tag `4.7.2-stable` full commit | `ed1daf0bf001b61586d9930840f2f1394092c079` (GitHub API). Matches the reported short hash. |
| GUT tag `v9.7.1` full commit | `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605` (GitHub API and zip archive comment) |
| GUT `addons/gut/plugin.cfg` | `version="9.7.1"`, author Butch Wesley |

### Export templates

The package has 35 entries, and `templates/version.txt` = `4.7.2.stable`. The intended Windows x86_64 templates are:

| Entry | Bytes | SHA-256 |
|---|---|---|
| `windows_release_x86_64.exe` | 109,268,480 | `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562` |
| `windows_release_x86_64_console.exe` | 188,928 | `52bdcae9068e8d23b840e5c63b0c1798ffe2cb66144e5c4bc7af11fb8c8600df` |
| `windows_debug_x86_64.exe` | 103,176,704 | `51498b72b3a237f882ebd7d1787f06a4bc1eaf0572daab93837adcfd3cfdc107` |
| `windows_debug_x86_64_console.exe` | 188,928 | `5514c7645ee897a01f540d3cf22ede5badf92394521a08bfab66a54d7369e6e6` |

The package also contains arm64, x86_32 and non-Windows templates, which are unused.

## 3. License and notice inventory

- **Godot engine:** MIT (Expat).
  - The full engine text and the third-party component list were dumped from the binary with `Engine.get_license_text()` / `get_copyright_info()`; see `t01_logs/godot_license_inventory.txt`.
  - Component license families: Apache-2.0, BSD-2/3-clause, BSL-1.0, CC0-1.0, CC-BY-4.0, Expat, glslang, FTL, HarfBuzz, IJG, MPL-2.0, MIT-0, OFL-1.1, Unicode, Unlicense, WOL, X11, Zlib.
  - A shipped game must include this notice set. That is M06 release work.
- **GUT:** MIT. See `addons/gut/LICENSE.md`, copied to `t01_logs/gut_LICENSE.md`.
  - The GUT tag archive contains only `addons/` because of `.gitattributes` export-ignore, so the repo-root LICENSE.md is not in the zip. The addon-bundled copy is authoritative for the vendored files.
  - The fonts bundled with GUT are under SIL OFL 1.1 (`t01_logs/gut_fonts_OFL.txt`).
  - GUT is a test harness only. It must not be included in release exports (TRS/C1: "GUT belongs to harness").

## 4. Runner commands and exit behavior

The probe project is a throwaway Compatibility-renderer project: `t01_logs/probe_project.godot`, with GUT copied into `addons/gut`. Commands, run from the probe root with `G = C:\_\tools\godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe`:

| Step | Command | Exit | Log |
|---|---|---|---|
| Import | `G --headless --path . --import` | 0 | `01_import.log` |
| Empty suite | `G --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests_empty -gexit -gjunit_xml_file=res://logs/junit_empty.xml` | **0** | `02_run_empty.log`, `junit_empty.xml` |
| Passing suite | same, `-gdir=res://tests_pass` | **0** | `02_run_pass.log`, `junit_pass.xml` (1/1 passed) |
| Deliberate failure | same, `-gdir=res://tests_fail` (`assert_eq(1, 2)`) | **1** | `02_run_fail.log`, `junit_fail.xml` (1 failing) |
| Driver/license probe | `G --headless --path . -s res://license_dump.gd` | 0 | `03_license_dump.log`, `godot_license_inventory.txt` |

ANSI color codes were stripped from the copied logs.

**Observations for the build plan:**

1. **Use the `_console.exe` binary.** The non-console GUI executable detaches from the shell on Windows, so its exit code is not reliable for CI or scripts.
2. **An empty suite exits 0.** GUT prints `[GUT ERROR] Nothing was run.` but does not fail. A wrong `-gdir` would therefore pass silently. Proposal: the project's `tools/run_tests.ps1` should fail when the JUnit test count is 0.
3. **`--import` loads editor layout steps even in headless mode.** This is harmless, but it requires the editor binary, not an export template.
4. **GUT temporary output** goes to `%APPDATA%\Godot\app_userdata\<project name>`.

## 5. Candidate reference hardware (record only; DEC-023 baseline selection stays Open until M04)

| Component | Value |
|---|---|
| CPU | AMD Ryzen 5 7600X3D 6-Core |
| RAM | 63.1 GB |
| GPU | NVIDIA GeForce RTX 4080 SUPER; AMD Radeon integrated |
| OS | Windows 11 Pro 10.0.26200 |

Driver versions and storage were not recorded.

## 6. Not done / remaining

- The `idle_farmer/` project skeleton and the vendored `addons/gut` are not yet created in the repo. They are waiting on approval of P1–P4.
- The export templates are verified as a package only and are not installed. An actual export is M04/M06.
- No DEC-001 closure entry was written to the Decision Register. That is an edit to an existing document and needs owner approval.
