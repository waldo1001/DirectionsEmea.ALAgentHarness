# al-agent-harness (Claude Code plugin)

The AL agent harness from the Directions EMEA 2026 session, packaged so every repo - and every
developer - gets the same harness without copying files.

## Install

```bash
claude plugin marketplace add waldo1001/waldo.BCObservatory
claude plugin marketplace add waldo1001/DirectionsEmea.ALAgentHarness
claude plugin install al-agent-harness@al-agent-harness
```

BC Observatory (BC knowledge: Observatory, Code Atlas, Learn) is a dependency: installing the
harness installs it too, once its marketplace is known - hence the first line.

Or per repo, in `.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`), so a
colleague is offered both plugins when they open the repo.

## What is inside

| Part | What |
|------|------|
| `skills/` | al-object-id-assignment, al-build-validation, al-knowledge, definition-of-done, company-rules, chat-export |
| `agents/` | al-build-fixer, al-lookup, al-spec, al-coder, al-reviewer, al-sdd |
| `commands/` | /spec, /sdd, /done, /pr |
| `hooks/` | SessionStart: the always-on rules. PreToolUse: blocks a literal in Error/Message/Confirm, also via the shell |
| `.mcp.json` | AL Object ID Ninja, the AL MCP server (`al launchmcpserver`, path-less: the skills load the project with `al_addproject`) |
| `templates/` | spec template, DEFINITION-OF-DONE.md, rules README - used when the project has none |

## What stays in your project

A plugin cannot carry what is *yours*: `AGENTS.md` (affix, folders, BC version), `rules/` (your
company rules), `specs/` (your specs) and, if you want your own, `DEFINITION-OF-DONE.md`. The
skills read them from the project when they exist.

## Versioning

Bump `version` in `plugin/.claude-plugin/plugin.json` and in `.claude-plugin/marketplace.json`
together. Users get it with `claude plugin marketplace update` (or auto-update).
