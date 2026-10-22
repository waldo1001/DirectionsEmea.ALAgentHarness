---
name: al-build-validation
description: 'Build, diagnose and fix AL code until the build is green. Use when: you created or changed any .al file or app.json, before saying a task is done, before a review or a PR, and when the user asks "does it compile". Provides the build -> diagnostics -> fix -> rebuild loop and a fixed report. Code is not finished until this is green. Does not run tests.'
---

# AL Build Validation

Code is **not finished until it compiles with zero errors**. Not "it should compile", not
"the syntax looks right": a build result you can show. And not just a compile: you read the
diagnostics and **fix** them, then build again.

## What this does not prove

This skill does **not run tests**. A green build proves the code compiles and the analyzers
are satisfied; it does not prove the code does what it should. Never report "tested" or
"works" on the strength of a green build. Running the tests is a separate step that needs a
sandbox.

## When to use

- After writing or changing AL code, `app.json` or a dependency.
- Before reporting done, before `/done`, before a review or a PR.
- Diagnostics-only (a reviewer collecting facts): run steps 1, 2 and 6, fix nothing.

## Procedure

### 1. Find the build tool

Use what the session exposes; list your tools, do not assume.

| Host | Build | Diagnostics |
|------|-------|-------------|
| Claude Code (`.mcp.json` server `al`, from `al launchmcpserver`) | `al_build` | `al_getdiagnostics` |
| GitHub Copilot in VS Code (AL extension tools) | `al_build` | `al_getdiagnostics` |
| No MCP tool (fallback) | `al compile` CLI, see below | the compiler output |

No tool and no `al` CLI? Hard stop, below.

### 2. Build in dependency order

`app/` first, then `test/` (the test app depends on the app): after a green `app/` build, copy
the `.app` it produced in `app/` into `test/.alpackages/`, or `test/` compiles against an old
version of the app. Pass `projectPath` as the
absolute path of the folder that holds `app.json`, with code analysis on. Unresolved symbols
(`Cannot find type`, missing package): download symbols for that project first
(`al_downloadsymbols`, or `al downloadsymbols --project <path> --globalsourcesonly`), then
build again. Never assume a missing symbol is your code's fault, or that it is not.

CLI fallback, per project, from the repo root:

```bash
al compile /project:app /packagecachepath:app/.alpackages /out:app/output.app
al compile /project:test /packagecachepath:test/.alpackages /out:test/output.app
```

(copy the app's `.app` into `test/.alpackages/` before building `test/`).

### 3. Collect diagnostics

`al_getdiagnostics` with `projectPath`, severities error and warning.

- **Errors** - must be fixed. No exceptions.
- **Warnings** - fix the ones that point at a real problem; list the rest with one line of
  rationale each.
- **Info** - ignore unless it is about code you wrote in this task.

### 4. Fix errors one by one

Read the file around the reported line, fix the cause (not the symptom), rebuild, re-read the
diagnostics. Repeat until zero errors. A fix that adds a new object or field goes through
`al-object-id-assignment` first.

### 5. Stop after three rounds on the same error

Same error three times: stop, report what you tried and why it fails. Do not delete code,
suppress analyzers or `#pragma` your way to green.

Errors that name **this app twice** (AL0275, AL0197: the same object in "Directions Demo" and
"Directions Demo") come from the build server, not from the code: the project is loaded twice
or a generated `.app` sits in the project folder. Remove that `.app` or add the project again
and rebuild. Never delete, move or recreate source files to make them go away.

### 6. Report

```
Build status: GREEN | RED
  app/   errors 0  warnings 1  (1 accepted: AA0xxx - <reason>)
  test/  errors 0  warnings 0
Errors fixed this run: 3
Tool: al_build (MCP) | al compile (CLI)
Tests: not run (this skill does not run tests)
```

## Hard stop

> ⛔ No build tool and no `al` CLI: **STOP** and report that the build could not run. Never
> report "done", "should compile" or "compiles in theory". Unblock with:
> `dotnet tool install --global microsoft.dynamics.businesscentral.development.tools --prerelease`

## Never

- Never report done on a red build, or on a build you did not run.
- Never silence a diagnostic to get green (no `#pragma warning disable`, no ruleset edits)
  unless the user asks for it.

## Related

- `al-build-fixer` agent - runs this loop as a subagent and returns only the report.
- `al-object-id-assignment` - before writing any new object or field.
- `definition-of-done` - "build green" is its first line (step 08).