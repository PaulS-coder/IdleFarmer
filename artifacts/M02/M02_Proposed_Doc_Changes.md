# M02 — Proposed changes to existing documentation (awaiting approval)

Date: 2026-10-30 · Status: **all 9 items applied 2026-10-30.** Owner approval: "All C1–C9".

Applied as dated, additive notes; no earlier approval text, task text, gameplay rule or provisional value was rewritten:

- **M02 plan:** implementation status note (C4), the Q3 ruling at T10 (C1), the T07 "level gate" wording note (C2), and historical notes on the Group 1 sentence and the expected-deliverables line (C3).
- **Roadmap:** M02 row, D-04/06–12/20/25 rows, an M02 completion section, and the new TRS SHA-256 in §1 (C5).
- **Decision Register:** DEC-009 measured evidence (C6) and DEC-024 automated pacing evidence (C7). Index statuses are unchanged.
- **TRS:** non-normative notes in §4.1 (M02 failure codes and precedence, C8) and §20.3 (manifest freeze, C9).

New TRS SHA-256: `29B49763F59314972B72E13F2E100680B80A1A6450D73FD7CE01DD04F39953BD`. The FRS is unchanged (`2FDF6A93…A310`).

Every item would be applied as a dated, additive note. None of them:

- rewrites earlier approval text or task text;
- changes a gameplay rule or a provisional value;
- tunes pacing.

C1–C3 come from [M02_Readiness_Findings.md](../../docs/implementation/M02_Readiness_Findings.md) §4. C4–C9 come from the M02 implementation ([M02_Handoff.md](M02_Handoff.md)).

| # | Document | Proposed change | Why |
|---|---|---|---|
| C1 | `docs/implementation/02_M02_Economy_Skills_Research_Automation.md` | Record the Q3 ruling in a dated note. Seed protection and custom priorities: allocator logic and level-15 gates are implemented and tested with fixtures in M02; their configuration commands return `FEATURE_UNAVAILABLE` until M05; all plots have equal priority in M02 gameplay. | Resolves the staging conflict over these two features (findings §4). |
| C2 | Same M02 plan, T07 | Change "level+research gates" to "level gate", noting that research projects have no research prerequisites (DVS-033). | The wording describes a gate that does not exist. |
| C3 | Same M02 plan, L7 and L261 | Add a dated note marking two lines as historical, superseded by G2/G3: "not approved" for the skill, budget and optimizer decisions, and "D-04/06–12/20/25 decisions" listed as future outputs. | Stale planning-era lines. |
| C4 | Same M02 plan, top | Add a dated "M02 implementation status" note: T01–T18 done; V01–V15 pass within the stated scope; V11 is reported (focused strategy 3.65 active h, met; mixed growth/profit 5.48 h, missed); link to `artifacts/M02/M02_Handoff.md`. | Keeps the plan's status current without rewriting history. |
| C5 | `docs/implementation/00_IdleFarmer_Master_Roadmap.md` | Mark M02 complete with a link to the handoff. Update the D-04/06–12/20/25 rows to "implemented and tested in M02", with evidence links. | The roadmap expects decision-log updates at milestone close. |
| C6 | `docs/decisions/Decision_Register.md`, DEC-009 | Add a dated "M02 measured evidence" entry. It states the exact MP/BP guarantee (`RateFrontier`, certified bound plus a BigInt fallback; oracle-verified) separately from the measured benchmark: 3.27 ms uniform, 17.5 ms mixed, 40.3 ms worst case; B3 gate amended to 5 ms by the owner. It also notes identical-input caching. | DEC-009 asked for the guarantee and the benchmark to be recorded separately (T18). |
| C7 | `docs/decisions/Decision_Register.md`, DEC-024 (or FRS §12.1 evidence note) | Add a dated "M02 automated pacing evidence" entry. It links the S7 report, keeps the result marked as automated economics only (human engagement unobserved), and names the binding constraint: the level 7 XP threshold, not coins. It does not tune anything. | DEC-024 requires reporting met, missed or insufficient evidence explicitly. |
| C8 | `docs/architecture/IdleFarmer_Technical_v1.5.md` §4.1 (optional) | Add a non-normative note listing the failure codes added in M02 and their place in the precedence order: `UNKNOWN_FERTILIZER`, `UNKNOWN_SKILL`, `UNKNOWN_UPGRADE`, `UNKNOWN_RESEARCH`, `INVALID_CONFIGURATION`, `SKILL_NOT_UNLOCKED`, `RESEARCH_ACTIVE`, `RESEARCH_DONE`, `NO_ACTIVE_RESEARCH`, `BOOST_USED`, `NO_TIME_SAVED`, `PLOTS_FULL`, `FEATURE_UNAVAILABLE`, and the others in `FailureCode.PRECEDENCE`. | Same reason as the M01 item 8: keeps M03+ consistent with the actual set. |
| C9 | Same TRS, §20.3 (optional) | Add a non-normative note: `content_m02_v1` is frozen at M02-T18, and both manifests are pinned by a canonical content digest in `tests/unit/test_manifest_freeze.gd`. | Records how "never edited in place" is enforced. |

**Recommendation:** C1–C7 are recommended; C8–C9 are optional clarifications.
