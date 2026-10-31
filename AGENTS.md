# CE project workflow

## Scope and startup

Use this as a repository-level baseline across Codex, Claude Code, Cursor and other harnesses. Keep harness-specific instruction files as imports or entry points to this policy. Discover project-specific commands, contracts and authoritative documents from the current repository and approved plan; do not assume another project's tools, paths or branch names.

Before acting, identify the repository or workspace, current branch, working-tree changes, applicable instructions, current work source and last completed checkpoint. Preserve unrelated work. On resumption, state the checkpoint, authorized continuation and any decision needed. Do not restart completed stages or infer approval from an artifact's existence or readiness label.

Invoke installed Compound Engineering (CE) skills through the harness's supported mechanism and read their required references. Skill names below do not imply universal slash-command support or install CE. If a required skill/reference cannot be read, report it rather than reconstructing it from memory. Follow the recovery and optional-simplification rules below; never silently replace required code review.

Observe the harness's instruction hierarchy. Automatic orchestration may proceed only within the authorization below; a workflow's ability to continue does not grant additional authority.

The current coordinating agent owns this sequence and invokes the named CE skills directly. Neither `ce-compound` nor `ce-test-browser` requires `lfg`. Do not automatically invoke or offer `lfg` at any stage. Use it only when the owner explicitly requests it, reconciling the requested scope with these approval gates before starting; it must not silently take over the staged workflow.

## Approval and document boundaries

- Offer `ce-brainstorm` and then `ce-plan`, waiting for the owner's go-ahead unless already requested. Present the implementation plan for approval before implementation. Approval with a go-ahead to implement authorizes the approved Units, quality checks, in-scope fixes, learning capture, commits, pushes and PR creation/updates. Do not seek routine approval between Units or before publication. Obtain final explicit approval before merging.
- Ask unresolved owner questions one at a time. Investigate facts available in the project before asking; give a recommendation and material tradeoffs when a decision is needed.
- Distinguish owner-directed decisions, agent proposals approved by the owner, engineering decisions within approved scope, unaccepted proposals and unresolved questions. Record genuine owner decisions with their date, confirmation/source and scope. Do not promote agent inference into owner approval.
- Protect authoritative specifications, roadmaps, decision records and the approved Product Contract. Before editing, renaming, replacing or deleting protected content, propose exact files/sections, changes and reasons and obtain explicit approval. Implementation or code-review authority does not authorize changing these sources.
- Starting `ce-plan` on a requirements-only artifact authorizes adding/refining its implementation sections in place. It does not authorize changing approved product behavior or settled decisions. This narrowly scoped enrichment is distinct from a protected requirements change.
- Record discovered specification inconsistencies as proposed fixes in chat or authorized working evidence. Recommend resolutions without applying them to protected sources. Stop affected work if a conflict requires an owner decision.
- Keep plans as decision artifacts. During implementation, record verification and progress in Git, CE execution receipts and evidence artifacts rather than editing plan status or maintaining completion checklists. A plan change log, when useful, records approved material planning changes rather than routine Unit completion. Propose material plan revisions for approval separately.
- Pushes and PR creation/updates for approved work need no additional approval. Merge readiness is not merge authorization: never merge or enable auto-merge without final explicit approval for the reviewed PR state. Material changes after approval require renewed approval. Do not weaken these instructions or harness settings to bypass the gates.

## Ordered CE workflow

### 1. Requirements: `ce-brainstorm`

Offer the skill and wait unless already requested. Resolve open product questions one at a time. Keep the result requirements-only: outcomes, scope/non-goals, constraints, success criteria, applicable stable requirement IDs and genuine owner decisions. List inconsistencies and proposed source fixes without editing those sources.

Use CE's default sizing: lightweight work may finish in chat. When a durable artifact is warranted, save a clean requirements-only unified plan after the dialogue is complete, before `ce-plan` begins. Do not save an epic revision after each question. Use the installed skill's artifact contract and location rules: normally `docs/plans/`, or the valid configured `docs_root`. Use the project/user's local date/time where a timestamp is required.

Complete CE's Ready for Planning check for written artifacts before declaring readiness. Follow the applicable chat handoff for lightweight work. Summarize the result, offer `ce-plan` with that same artifact or brief and wait for the owner's go-ahead.

### 2. Implementation planning: `ce-plan`

Follow CE's unified-plan model: enrich the existing requirements-only plan in place with implementation sections. Keep its approved Product Contract and settled decisions intact. Do not create a separate requirements/implementation pair merely to distinguish planning stages. A lightweight chat brief can be used directly; let CE select its appropriate output contract rather than forcing an intermediate epic.

Keep externally authoritative specifications and decisions as references. Preserve the installed CE artifact contract and the Product Contract, Planning Contract, Implementation Units, Verification Contract and Definition of Done where a durable implementation plan is warranted. Ask unresolved owner questions one at a time and clearly distinguish their decisions from the agent's engineering choices.

A durable plan must provide the necessary file responsibilities/layout, interfaces and invariants, ordered Implementation Units with bounded scope and prerequisites, concrete acceptance/test cases, risks and stop conditions, and project-appropriate verification commands and evidence. Use CE's Unit IDs and "Unit" terminology without an additional grouping layer. Size detail to the work and avoid duplicating information already authoritative elsewhere.

Decide browser-verification applicability during planning. For browser-facing changes, include the affected pages/flows, expected behavior and browser evidence in the Verification Contract, or in the brief when no durable plan is needed. For other surfaces, identify their appropriate verification and record why browser testing is not applicable. Browser evidence does not replace native application, API, command-line or other required checks.

Complete CE's applicable confidence and document-review checks, then present the plan for approval to implement through review and PR publication. Do not integrate changes to protected requirements or decisions without approval. Wait for implementation authority before changing code.

### 3. Implementation: `ce-work`, automatic progression through Units

Use CE's workspace and feature-branch rules to resolve the actual default/base branch and preserve existing work; do not assume it is named `main`. Follow the harness's branch-naming requirements. Resume an approved feature branch when appropriate instead of recreating it. Never silently reset/rebase work, overwrite another branch or include unrelated changes.

For an approved implementation-plan file, invoke `ce-work` in `mode:return-to-caller` with its path. That mode requires a file path. For CE output that remains a chat brief, use the installed skill's supported brief execution route rather than inventing return-to-caller syntax, and carry this policy's subsequent gates into that route. Implement approved Units in dependency order. The coordinating agent owns the subsequent quality, learning-capture, applicable browser-verification and publication stages below; return-to-caller mode does not omit them from this workflow.

Discover the project's test runners, independent oracles, empirical checks and other evidence methods from its current code, configuration, documentation and approved plan. Preserve verification guarantees. Adding tests, strengthening assertions and routine test maintenance within the approved scope may proceed automatically. Obtain approval before removing independent evidence, reducing required coverage, weakening acceptance criteria or changing a settled verification guarantee. Never report unrun checks as passed.

For each Unit:

1. Inspect existing tests and select the evidence strategy before behavior changes. Follow CE's applicable test-first/characterization guidance, or record a justified exception and replacement verification.
2. Implement the Unit, run its agreed checks and relevant regressions, and record commands, results, evidence paths, limitations and blockers in execution receipts/evidence artifacts.
3. Use Git and verified receipts to establish completion. Do not maintain a competing mutable lifecycle in the plan. Reconcile work after reverts or branch changes before reporting it complete.
4. Follow CE's adaptive commit boundaries: aim for a complete, valuable change, using Units as a guide. Split a large Unit or combine small related Units when justified, and briefly report the reason. Never commit failing work or absorb unrelated staged files. Name only owned files; do not silently rewrite published history.
5. Report completed work, commits, evidence and remaining risks, then proceed automatically to the next ready Unit. After implementation, continue to the quality stages without routine acceptance prompts.

Pause when results require an additional owner decision: scope or contract changes, a protected-document amendment, an unresolved qualification failure, or evidence invalidating a settled decision. Resolve ordinary engineering problems within approved scope without asking. After the decision is resolved, resume the authorized flow without repeating routine approvals.

### 4. Quality: conditional `ce-simplify-code`, then `ce-code-review`

Run the established final checks. Apply the installed standalone `ce-work` shipping workflow's simplification applicability rules and threshold rather than requiring the skill for every diff. When applicable, invoke `ce-simplify-code` in caller/pipeline mode on the current changes, preserve settled structure and supply the evidence's proof tests. When simplification is inapplicable or its documented availability rules permit a manual pass, record the disposition and continue. Do not mislabel a failed required reference read as a permitted fallback.

Behavior-bearing changes require a completed `ce-code-review` result. Small size alone never waives review. Purely mechanical work may use CE's documented mechanical skip, recorded explicitly; behavior, control-flow, error handling and behavioral-test changes are not mechanical. Let the skill select review depth. If required CE review cannot complete after its documented recovery, stop publication rather than substituting a mental review or treating an unavailable-review skip as success.

Use read-only CE review followed by caller-applied justified fixes, or its explicitly authorized local-apply mode; `mode:agent` remains read-only. Apply fixes within the approved outcome, rerun affected checks and obtain review coverage for material corrections. Report retained findings and their dispositions. A required-outcome blocker prevents publication; an owner decision or protected-document change pauses affected work.

Record quality evidence and coherent follow-up commits. Before publication, recheck the approved work source, requirements, verification contract and Definition of Done against the actual change. Publish only a verified state with the required review evidence or legitimate mechanical skip.

### 5. Learning capture: `ce-compound`, before publication

After implementation, simplification and review fixes are verified, directly invoke `ce-compound mode:non-interactive` before `ce-commit-push-pr`; do not invoke `lfg` to reach this step. The eligibility assessment is a required pre-publication checkpoint, while writing a learning is conditional. Preserve CE's eligibility bar: document only solved, verified problems with durable reasoning absent from the final code, tests or existing documentation. A deliberate no-qualifying-learning result completes the checkpoint successfully; do not create a document just to satisfy it. When several problems qualify, follow CE's one-learning-per-run rule with separate sequential invocations. Include resulting learning files in the same implementation PR so they receive review before merge.

Record the capture result or the reason no learning qualified in the completion evidence. A missing skill/reference, failed validation or unresolved execution failure is a blocker, not a no-learning result. The skill returns control to the coordinating agent, which continues the remaining gates.

Complete `ce-compound`'s own required validation. Its position after code review does not imply that CE automatically reruns `ce-code-review` on new learning documents. Include those documents in the final PR review scope; material code or contract changes discovered during learning capture must return through the applicable quality gates. Protected-document approval still applies, including instruction-file changes requiring consent under that skill. Keep the learning changes on the implementation branch and include them in publication; do not defer their capture to an unreviewed post-merge change.

### 6. Browser verification: `ce-test-browser`, when applicable

When the approved Verification Contract or brief requires browser evidence, directly invoke `ce-test-browser mode:pipeline` for the affected browser surfaces. This is a call by the coordinating agent, not a handoff to `lfg`. Follow the skill's required references and driver/server rules; retain the results and evidence in the completion record.

When browser testing is not applicable, record that disposition and perform the required verification for the actual surface. Reassess applicability if implementation reveals browser-facing changes not covered by the plan; do not silently omit required browser evidence. Required failures, inaccessible required flows or unavailable browser tooling block publication until resolved or the owner approves a concrete change to the verification requirement. A tool-reported skip is not proof that a required check passed. Fixes discovered here must pass the affected verification and review gates again; reassess learning capture if they reveal a newly solved problem worth recording.

### 7. Publication: `ce-commit-push-pr`, then final merge approval

Automatically run `ce-commit-push-pr` only after the quality gates, required learning assessment and applicable browser-verification gates complete. Preserve the implementation and quality commits; include any validated learning changes and prepare the PR description, evidence and remaining-risk summary. Push and create/update the PR for the approved scope without another publication approval. Follow CE's applicable PR checks and follow-on workflow. If `ce-babysit-pr` runs, use a non-merging posture (`target` for this PR); never infer `stack-land` authorization from this flow.

When the PR is ready, present its URL, reviewed head commit, verification results, captured learnings and any unresolved non-blocking findings. Ask for final explicit approval before merging and wait. Do not enable auto-merge in advance. Before an approved merge, recheck the PR head and required checks; material changes invalidate the earlier approval. Approval for one PR does not authorize merging another.

## Policy limits and existing work

This policy supplements installed CE workflows; it is not an executable approval lock or a CE installation. Carry its approval boundaries into delegated work and retain them in the coordinating agent.

Apply changes prospectively. Preserve existing approved artifacts, identifiers, evidence locations, decisions and commits. Do not split/merge old plans, rename historical artifacts, restart completed work or rewrite history merely to retrofit this baseline; propose a migration separately if needed.
