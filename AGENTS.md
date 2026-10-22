# AGENTS.md

Always-on instructions for every coding agent in this repo. GitHub Copilot loads this file by
default; Claude Code reads it through `CLAUDE.md`. Keep it short: if something is a workflow,
it is a skill in `.claude/skills/`, not a paragraph here.

## This repo

- `app/` - "Directions Demo", a Business Central per-tenant extension (PTE) in AL.
- `test/` - its test app. Depends on `app/`.
- `specs/` - one spec per feature: the contract for the implementation (`specs/README.md`).
- `rules/` - company rules, one article + `.good.al` / `.bad.al` each. On top of BCQuality; they win where the two disagree.
- The base application is Microsoft's. You extend it; you never modify it.

## Look it up, never assume

- **Affix:** `mandatoryAffixes` in `app/AppSourceCop.json`. Every new object name carries it.
- **Object IDs:** reserved with AL Object ID Ninja, never picked. Do not read `idRanges`.
- **BC version:** `application` and `runtime` in `app/app.json`.

## How we write AL

- Extend, never modify: `tableextension`, `pageextension`, event subscribers.
- Business logic lives in codeunits, not in page triggers.
- Text shown by `Error`, `Message` and `Confirm` is a `Label` variable, never a literal.
- Identify AL objects as `Type ID "Name"`: `Table 18 "Customer"`,
  `Codeunit 414 "Release Sales Document"`.

## Never

- Never invent an object, field or enum-value ID. No guess, no "next free number".
- Never hardcode user-facing text. A literal in `Error(`, `Message(` or `Confirm(` is blocked.
- Never edit files outside `app/`, `test/` and the feature's spec in `specs/` for an AL task.
- Never rewrite git history: no force push, no rebase or reset of commits others may have.
- Never report done without a green build. "Done" is `DEFINITION-OF-DONE.md`, checked by `/done`.

## Skills (loaded on demand)

Skills, agents, commands, the guardrail hook and the MCP servers come from the
`al-agent-harness` plugin (`plugin/`). This file keeps what is specific to this repo.

| When | Skill |
|------|-------|
| a new object, field or enum value; deleting one you reserved | `al-object-id-assignment` |
| after changing any `.al` file or `app.json`; before saying done | `al-build-validation` |
| a "how should I" question about AL/BC; checking an event, property or pattern | `al-knowledge` |
| "is it done?", before review or a PR | `definition-of-done` |
| before writing, designing or reviewing AL | `company-rules` |

## Agents and commands

| Step | How |
|------|-----|
| spec a feature | `/spec <task>` - the `al-spec` agent, interactive, in your own session |
| implement an approved spec | "implement the spec" - the `al-coder` agent, as a subagent (no command) |
| check it is done | `/done` - every DoD line with evidence, then DONE or NOT DONE |
| review it | the `al-reviewer` agent - read-only, findings first, applies BCQuality |
| implement test-first on a sandbox | `/sdd <spec>` (or `claude --agent al-sdd`), in your own session only: spec -> test -> RED (the test fails) -> business logic -> GREEN (the test passes) -> mutation (break the logic) -> RED (the test catches it) -> GREEN (revert, passes again) |
| open the PR | `/pr` - standard description from the spec and the `/done` report, opened with the GitHub CLI |
| capture a session where the harness failed | the `chat-export` skill, only when the developer asks |
| build and fix until green, without filling this conversation with diagnostics | the `al-build-fixer` agent (subagent) |
| a simple BC/AL knowledge question (pattern, event, property) | the `al-lookup` agent (subagent on the cheaper haiku model; pass the developer's question as asked) |