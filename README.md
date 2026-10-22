# AL Agent Harness

A harness for coding agents working on Business Central AL. Clone it, use it Monday.

An agent without a harness writes decent AL - and nothing checks any of it. It picks its own
object IDs and reserves none, decides the design without asking, never compiles and never runs
its tests. The model is fine. It just has no idea what we consider done. A harness tells it: the always-on file,
the guardrails, the skills it loads on demand, the agents that run your process, and a
definition of done a machine can check.

This repo was built live at Directions EMEA 2026 ("Stop Inventing Your Own Way .. Let's Build
the AL Agent Harness Together"). It is what works for us, not The Truth. Take what you
believe in, delete the rest.

## What is in here

Three parts, one commit per step, a branch and a tag per step.

| Part | Step | Branch / tag | Adds |
|------|------|--------------|------|
| A | 00 | `step-00-intro` | the sample app, the test app, VS Code config. No harness. |
| A | 01 | `step-01-instructions` | `AGENTS.md` (+ a thin `CLAUDE.md`), the Never-list, a permission deny list, a hook that blocks hardcoded UI text |
| A | 02a | `step-02a-objectid-regex` | a first skill: a regex "ID oracle" script - the joke |
| A | 02b | `step-02b-objectid-al-tool` | the same skill on the AL extension's `al_getnextobjectid` (and its limitation) |
| A | 03 | `step-03-objectid-mcp` | AL Object ID Ninja MCP; the same skill now reserves through it |
| A | 04 | `step-04-agents-build-validation` | build validation skill (build, diagnose, fix) + the `al-build-fixer` agent |
| A | 05 | `step-05-knowledge` | BC knowledge: the BC Observatory plugin (Observatory, Code Atlas, Learn), BCQuality, the `al-lookup` agent |
| B | 06 | `step-06-specs` | `specs/`, the interactive `al-spec` agent, `/spec` |
| B | 07 | `step-07-coding` | the `al-coder` agent (subagent, applies BCQuality) |
| B | 08 | `step-08-dod` | `DEFINITION-OF-DONE.md`, `/done`, the `al-reviewer` agent |
| C | 09 | `step-09-company-rules` | `rules/` (example rules from one partner) + company rules skill |
| C | 10 | `step-10-sdd` | the `al-sdd` agent (spec -> test -> RED -> business logic -> GREEN -> mutation -> RED -> GREEN), DoD with tests run, `/pr`, chat export |
| C | 11 | `step-11-plugin` | the whole harness as a Claude Code plugin (`plugin/` + `.claude-plugin/marketplace.json`) |

- **Part A - what every BC dev needs.** No opinions. Object IDs, a green build, BC knowledge.
- **Part B - the process.** Spec, code, done. Opinionated, but partner-neutral.
- **Part C - make it yours.** Your company rules, your tooling, your plugin. This is the part
  that should never be generic.

`main` is the final state (step 11). Prefer a plugin over a clone?

```bash
claude plugin marketplace add waldo1001/waldo.BCObservatory
claude plugin marketplace add waldo1001/DirectionsEmea.ALAgentHarness
claude plugin install al-agent-harness@al-agent-harness   # brings bc-observatory along
```

## Prerequisites

| What | Why | Install |
|------|-----|---------|
| Claude Code | the agent host this repo is built for | <https://claude.com/claude-code> (Copilot: see `docs/PORTING.md`) |
| VS Code + AL Language extension | editing, F5, symbols | Marketplace: `ms-dynamics-smb.al` |
| Node.js 20+ | the hook script, `npx` MCP servers | <https://nodejs.org> |
| `al` CLI | build fallback, AL MCP server, test runs | `dotnet tool install --global microsoft.dynamics.businesscentral.development.tools --prerelease` |
| AL Object ID Ninja | object ID reservations | MCP server via `.mcp.json` (npx, nothing to install); VS Code extension `vjeko.vjeko-al-objid` optional |
| BCQuality | curated BC/AL knowledge and the `al-code-review` skill | in Claude Code: `/plugin marketplace add microsoft/BCQuality` then `/plugin install bcquality@bcquality` |
| A BC SaaS sandbox | publishing and running tests | fill `environmentName` in `.vscode/launch.json` |
| GitHub CLI | `/pr` opens the pull request | <https://cli.github.com>, then `gh auth login` |

## Clone it

```bash
git clone <this repo> al-agent-harness
cd al-agent-harness
git fetch --all --tags
claude            # approve the project MCP servers when asked
```

## Demo it

`demo.sh` walks the steps so nobody types branch names on stage.

```bash
./demo.sh list        # all steps, current one marked
./demo.sh goto 00     # start at the empty repo
./demo.sh next        # one step forward (prints the step title)
./demo.sh prev        # one step back
./demo.sh reset       # stash local edits (recoverable) and go back to step 00
```

The carrier task used in both demo runs is in `docs/TASK.md`. The full talk flow is in
`docs/DEMO-FLOW.md`.

## Make it yours

1. Change the affix in `app/AppSourceCop.json` and the ranges in `app.json` / `.objidconfig`
   (or point the harness at your own app folders and delete `app/` and `test/`).
2. Empty `rules/` and write your own rules: one short article plus a `.good.al` and a
   `.bad.al` per rule. The company rules skill and `/done` pick them up automatically.
3. Read `AGENTS.md` and delete every line you do not believe in. Keep it short.
4. Replace `/pr` with whatever talks to your shop (GitHub, Azure DevOps, Jira, ...).
5. Switching tools is mechanical: `AGENTS.md`, `rules/`, `specs/` and the skills are shared
   markdown. Only agents, commands, MCP config and hooks are tool-specific. See
   `docs/PORTING.md`.
