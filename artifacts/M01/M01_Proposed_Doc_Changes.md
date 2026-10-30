# M01 — Proposed changes to existing documentation (awaiting approval)

Date: 2026-10-30 · Status: **proposal only; nothing below has been applied.** Under the Decision Register change-control workflow, each item needs explicit owner approval with its exact scope. After approval, update the current FRS/TRS hashes recorded in RM §1 if those files change.

| # | Document | Proposed change | Why |
|---|---|---|---|
| 1 | `docs/decisions/Decision_Register.md`, DEC-001 | Add a dated "M01-T01 artifact verification" entry. It records the verified Godot 4.7.2-stable editor, the templates package and GUT 9.7.1 with their SHA-256 values, full commits, signatures and licenses, linking `artifacts/M01/T01_Toolchain_Evidence.md`. The DEC-001 subpart "actual artifact verification" changes from Open to Verified for the editor, templates (package level) and GUT. The godot-sqlite (M03) and actual export subparts stay Open. | DEC-001 is Open only for this evidence, which now exists. |
| 2 | `docs/implementation/01_M01_Headless_Simulation_Foundation.md` | Add a dated "M01 implementation status" note at the top: all tasks are done; V01–V14 pass within the stated scope; links to `artifacts/M01/M01_Handoff.md`. The task text stays unchanged. | Keeps the plan's status current without rewriting history. |
| 3 | Same M01 plan, V14 row and A1 crosswalk | Record ruling I1: M01 owns AV-002-01/02/05 and AV-003-01–03. AV-002-03/04 and AV-003-04 belong to M03, matching the existing crosswalk. AV-004-03/04 belong to M02. | Resolves the V14 vs crosswalk inconsistency. |
| 4 | Same M01 plan, file table | Add `core/application/` (GameController, RawIntent, CommitSink) per ruling I2, and note `core/math/` for IntegerMath/MathResult. | The file table had no controller; checked math is now an independent module. |
| 5 | Same M01 plan, T05 | Note ruling I3: skill allocations are represented as `PlayerState.skill_ranks` (data only) for AV-003 point-conservation tests. | Records the data-only skill fixture decision. |
| 6 | `docs/implementation/00_IdleFarmer_Master_Roadmap.md` | Mark M01 complete with a link to the handoff. Update the D-01/02/03/05/06 rows with "implemented and tested in M01" and evidence links. | The roadmap expects decision-log updates at M01 close. |
| 7 | `docs/architecture/IdleFarmer_Technical_v1.5.md` §9.4 (optional) | Add a non-normative note that M01 selected a canonical codec (typed tags, decimal integers, sorted keys, SHA-256) for digests and snapshots. Godot JSON is excluded for int64 state. | TRS says no codec was selected; M03 builds on this choice. |
| 8 | `docs/architecture/IdleFarmer_Technical_v1.5.md` §4.1 (optional) | List the additional failure codes in use: `UNKNOWN_PLOT`, `UNKNOWN_CROP`, `NO_CYCLE`, `CYCLE_MISMATCH`, `MALFORMED_ENVELOPE`, `STALE_TERMS`, `NUMERIC_LIMIT`. Add the precedence order (P11). | The TRS list is "typical"; recording the actual set keeps M02+ consistent. |

Items 1–6 are recommended. Items 7–8 are optional clarifications. None changes gameplay rules, approved decisions or provisional values.
