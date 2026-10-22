# Build prompt - paste this into Claude Code, started in this repo

Read `docs/DEMO-FLOW.md` first. It is the spec for what you are building: a generic AL
agent harness for Business Central, built as a linear series of git commits where every
commit is one demo step, with a branch and a tag per step. You are building the repo that
the audience of Directions EMEA 2026 will clone.

## Source material

The reference harness is iFacto's internal one at
`/Users/waldo/SourceCode/iFacto/iFactoAcademy/iFacto Playbook/BCCompanyGuidelines`
(read `claudefiles/CLAUDE.md`, `claudefiles/agents/*`, `claudefiles/skills/*/SKILL.md`,
`claudefiles/commands/*`, `bc-company-guidelines/topics/*`). Use it for structure, tone,
gates, hard-stop wording and the skill/agent discipline (subagents have no channel back,
batch questions in one AskUserQuestion round, recommend first, never "continue anyway?").

Generic-ise everything you take from it. In Parts A and B there must be **nothing**
company-specific: no iFacto, Distri, Jira, Azure DevOps, BCQuality custom layer, token
tracker, chat export, cost warnings, Dutch, PR attestation, specific people. Replace
`App/Docs/Instructions/*.design.md` with `specs/*.md`. Replace the BCQuality custom layer
with the `rules/` folder (Part C). Replace Jira gates with "if the task references an
issue, read it; otherwise proceed". Keep the public dependencies: AL Object ID Ninja (MCP),
the AL extension tools (`al_getnextobjectid`, `al_build`, `al_getdiagnostics`,
`al_run_tests`), microsoft/BCQuality plugin, Microsoft Learn MCP. BC Code Atlas is a marked
placeholder until its skill section and MCP config are delivered. Where a hard stop depends on a tool being present, keep the hard stop
and give the install command.

Only in Part C (`step-09-company-rules`) do iFacto rules appear, explicitly labelled as an
example layer: Meth codeunit with one public procedure, tableextension `PTE` suffix, no
local procedures on pages, Label naming `<Context>Err/Msg/Qst`, single object per file.
Rewrite them from `bc-company-guidelines/topics/*` as short articles (max ~60 lines each)
with a `.good.al` and `.bad.al` sibling. Strip every iFacto reference from the text itself;
the folder README says "example rules from one partner, replace with yours".

## Repo layout (final state on `main`)

```
AGENTS.md                      always-on, short, tool-neutral, incl. the Never-list (01)
CLAUDE.md                      contains only: @AGENTS.md (01)
DEFINITION-OF-DONE.md          human-readable DoD (08, tests-run line in 10)
README.md                      the promise, how to clone, how to demo (demo.sh), how to make it yours
demo.sh                        next | prev | goto NN | reset | list  (checks out step branches, prints the step title)
.mcp.json                      al (02b), al-object-id-ninja (03); BC knowledge via the BC Observatory plugin (05); moves into plugin/ (11)
.claude/settings.json          permission deny list + hooks (01; al_getnextobjectid denied in 03; BC Observatory enabled in 05; own plugin enabled in 11)
.claude/hooks/                 the hook script(s) (01)
.claude/skills/al-object-id-assignment/SKILL.md       (02a regex script, 02b AL tool, 03 rewritten for Ninja)
.claude/skills/al-build-validation/SKILL.md           (04)
.claude/skills/al-knowledge/SKILL.md                  (05, routes to the BC Observatory plugin, BCQuality, symbols)
.claude/skills/definition-of-done/SKILL.md            (08)
.claude/skills/company-rules/SKILL.md                 (09)
.claude/skills/chat-export/SKILL.md                   (10)
.claude/agents/al-build-fixer.md                      (04, subagent)
.claude/agents/al-lookup.md                           (05, subagent, cheap model)
.claude/agents/al-spec.md                             (06, runs in the session via /spec)
.claude/agents/al-coder.md                            (07, subagent, no command)
.claude/agents/al-reviewer.md                         (08, subagent)
.claude/agents/al-sdd.md                              (10, session agent)
.claude/commands/spec.md  done.md  pr.md              (06, 08, 10)
specs/TEMPLATE.md  specs/README.md (with the index)   (06)
rules/README.md + one .md/.good.al/.bad.al per rule   (09)
app/        "Directions Demo" PTE: app.json (publisher Directions, affix DIR via AppSourceCop.json, idRanges 50100-50149), one table + one list page, .objidconfig
test/       empty test app, app.json with 80100-80149, depends on app/
.vscode/launch.json  (one Sandbox config, placeholder environmentName) + settings.json (al.codeAnalyzers CodeCop/UICop/PerTenantExtensionCop)
.gitignore
docs/DEMO-FLOW.md  docs/BUILD-PROMPT.md  docs/TASK.md  docs/PORTING.md
plugin/ + .claude-plugin/marketplace.json   the whole harness as a plugin (11): skills, agents, commands, hooks, .mcp.json, templates
```

## Commit plan (strictly in this order, one commit per step)

Create them as a linear history on `main`. After each commit: `git branch step-NN-<name>`
and `git tag step-NN-<name>` on that commit. Commit messages: `step NN: <name>`, with a 2-4
line body saying what the step adds and why. `docs/`, `demo.sh` and `README.md` go into step
00 so they exist, identical, in every checkout.

| Step | Branch / tag | Speaker | Adds |
|------|--------------|---------|------|
| 00 | `step-00-intro` | waldo | sample app + empty test app, `docs/`, `demo.sh`, README. No harness. |
| 01 | `step-01-instructions` | AJ | `AGENTS.md` (incl. `## Never`), `CLAUDE.md` with `@AGENTS.md`, deny list in `.claude/settings.json`, the literal-UI-text hook. Recent Copilot loads `AGENTS.md` by default; `CLAUDE.md` stays for Claude. |
| 02a | `step-02a-objectid-regex` | waldo | `al-object-id-assignment` skill with `scripts/next-id.sh`: a regex "ID oracle" (parses idRanges, scans .al files, max+1). The joke: this disk, this branch, nothing reserved. |
| 02b | `step-02b-objectid-al-tool` | waldo | The same skill on `al_getnextobjectid` (the AL extension's own tool; in Claude Code via the `al` MCP server from `al launchmcpserver`). Fields of a new table 1, 2, 3. States its limitation: local repo only, two developers can get the same ID. |
| 03 | `step-03-objectid-mcp` | AJ | Ninja MCP in `.mcp.json`; the same skill rewritten to reserve through Ninja; `al_getnextobjectid` denied. An MCP is a data source, the skill says how to use it. |
| 04 | `step-04-agents-build-validation` | waldo | `al-build-validation` skill (build, diagnose, **fix**, rebuild; explicitly does not run tests) + the `al-build-fixer` subagent. |
| 05 | `step-05-knowledge` | AJ | The BC Observatory plugin enabled for the repo (bc-observatory, bc-code-atlas, Microsoft Learn + its bcobs skills), BCQuality, the `al-knowledge` skill routing between them, the `al-lookup` subagent on a cheaper model. |
| 06 | `step-06-specs` | waldo | `/spec` + the interactive `al-spec` agent (in the session, not a subagent), `specs/TEMPLATE.md`, `specs/README.md` with the index. Acceptance criteria map one-to-one to tests. |
| 07 | `step-07-coding` | AJ | `al-coder` agent: no command, picked up on "implement the spec", runs as a subagent, applies BCQuality explicitly. |
| 08 | `step-08-dod` | waldo | `DEFINITION-OF-DONE.md`, `definition-of-done` skill, `/done`, `al-reviewer` (applies BCQuality explicitly). Honest: compiles and reviewed are proven, tests run is not yet. |
| 09 | `step-09-company-rules` | AJ | `rules/` + `company-rules` skill, iFacto rules as the example, on top of BCQuality; spec writer, coder and reviewer reference it. |
| 10 | `step-10-sdd` | waldo | `al-sdd` with the full loop (spec -> test -> RED -> business logic -> GREEN -> mutation -> RED -> GREEN) and tests that actually run (`runTests` in VS Code, `al_run_tests` / `al runtests` in Claude Code); DoD adds "tests ran and passed"; `/pr` via the GitHub CLI; `chat-export` skill. |
| 11 | `step-11-plugin` | to divide | The whole harness as a plugin: `plugin/` (`.claude-plugin/plugin.json`, skills, agents, commands, `hooks/hooks.json` with the guardrail and a SessionStart hook for the always-on rules, `.mcp.json`, templates) + `.claude-plugin/marketplace.json`. The repo keeps AGENTS.md, rules/, specs/, DoD and enables the plugin. |

Do NOT create the `run-00` / `run-99` branches; those are produced by actually running the
agents, which waldo does afterwards.

## Quality bar

- `AGENTS.md` under 80 lines. If something is a workflow, it is a skill, not a paragraph.
- Every skill has a frontmatter `description` that says WHEN to use it (that is what
  triggers it), a numbered procedure, a fixed output format and a Related section.
- Every agent: frontmatter (name, description, model), constraints (what it never does),
  workflow with explicit gates, "running as a subagent" paragraph, hand-off section.
- `/done` must be checkable: for every DoD line say which command or tool call proves it
  (e.g. `git diff --name-only main...HEAD` for the "nothing outside app/ and test/" check,
  grep for `Error('` / `Message('` / `Confirm('` with a literal, a build result, the Ninja
  reservation list vs object IDs in changed files, spec frontmatter status).
- The step-01 hook: a PreToolUse hook on Write/Edit/Bash that rejects `.al` content containing
  `Error('`, `Message('` or `Confirm('` followed by a quote (a literal, not a Label), with
  a one-line message pointing at the rule. Keep it a small script, bash or node, no deps.
- The sample app must compile. If the `al` compiler or symbols are not available in this
  session, write the code so it would and say so in the final report.
- No em-dashes anywhere. Use a plain hyphen.
- `docs/PORTING.md`: the Copilot mapping table (AGENTS.md shared; `.claude/agents/*` ->
  `.github/agents/*.agent.md`; commands -> `.github/prompts/*.prompt.md`; `.mcp.json` ->
  `.vscode/mcp.json`; hooks -> no equivalent, instructions only; skills folder shared where
  the host supports it). Short.

## How to work

1. Read `docs/DEMO-FLOW.md`, then the iFacto source folders listed above.
2. Propose the AGENTS.md text and the DoD lines before writing the rest; those two shape
   everything else. Ask at most one round of questions, only for things you can not decide
   from the demo flow.
3. Build step 00 and compile the sample app first. Then one step at a time, committing and
   branching as you go. Run `./demo.sh list` at the end and show the branch/tag list.
4. Finish with a short report: what each step adds, anything that could not be verified
   (compile, Ninja call, hook), and what waldo must do by hand (fill environmentName,
   produce the run-00 / run-99 branches, decide on the tool port).
