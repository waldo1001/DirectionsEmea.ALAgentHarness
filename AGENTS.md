# AGENTS.md

Always-on instructions for every coding agent in this repo. GitHub Copilot loads this file by
default; Claude Code reads it through `CLAUDE.md`. Keep it short: if something is a workflow,
it is a skill in `.claude/skills/`, not a paragraph here.

## This repo

- `app/` - "Directions Demo", a Business Central per-tenant extension (PTE) in AL.
- `test/` - its test app. Depends on `app/`.
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
- Never edit files outside `app/` and `test/` for an AL task.
- Never rewrite git history: no force push, no rebase or reset of commits others may have.
- Never report done without a green build.

## Skills (loaded on demand)

| When | Skill |
|------|-------|
| a new object, field or enum value; deleting one you reserved | `al-object-id-assignment` |
| after changing any `.al` file or `app.json`; before saying done | `al-build-validation` |
| a "how should I" question about AL/BC; checking an event, property or pattern | `al-knowledge` |

## Agents

| Step | How |
|------|-----|
| build and fix until green, without filling this conversation with diagnostics | the `al-build-fixer` agent (subagent) |
| a simple BC/AL knowledge question (pattern, event, property) | the `al-lookup` agent (subagent on the cheaper haiku model; pass the developer's question as asked) |