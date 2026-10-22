# Porting the harness to GitHub Copilot

The harness is built in Claude Code. Most of it is plain markdown that any agent host reads.
This is what moves where.

| Claude Code | GitHub Copilot (VS Code) | Notes |
|-------------|--------------------------|-------|
| `AGENTS.md` | `AGENTS.md` | Shared as-is: recent Copilot versions load `AGENTS.md` by default. `CLAUDE.md` stays for Claude Code and only imports it. |
| `.claude/skills/*/SKILL.md` | same folder, or `.github/skills/` | Shared where the host supports skills; keep the `description` frontmatter, it is the trigger. |
| `.claude/agents/<name>.md` | `.github/agents/<name>.agent.md` | Same body. Map `model` and the tool list to Copilot's frontmatter. |
| `.claude/commands/<name>.md` | `.github/prompts/<name>.prompt.md` | Same body; add `agent:` frontmatter where the command starts an agent. |
| `.mcp.json` | `.vscode/mcp.json` | Same servers. Copilot uses `"servers"` instead of `"mcpServers"`. The Ninja VS Code extension already exposes its tools to Copilot, no MCP needed. |
| `.claude/settings.json` permissions | none | Copilot asks per tool call; there is no repo-level deny list. |
| `.claude/hooks/*` | none | No equivalent. The rule stays in `AGENTS.md` (instruction only) and `/done` still greps for it. |
| `specs/`, `rules/`, `DEFINITION-OF-DONE.md` | same | Tool-neutral. |
| AL extension tools (`al_getnextobjectid`, `al_build`, ...) via the `al` MCP server (`al launchmcpserver`) | the same tools, built into the AL extension | Copilot needs no MCP for them. |
| `al_run_tests` (AL MCP server) or `al runtests` | the built-in `runTests` tool | `runTests` drives the AL extension's Test Explorer ("AL Tests"). |
| a plugin (`plugin/`, `.claude-plugin/marketplace.json`, step 11) | agent plugins (Preview): a local clone registered in `chat.pluginLocations` | VS Code reads the same `.claude-plugin/` manifests. Hooks in a plugin: check what your VS Code version runs. |
| BC Observatory plugin (step 05) | its MCP servers in `.vscode/mcp.json` | Copilot gets the servers; the bcobs skills come with the agent plugin. |

Tool names differ per host. Skills name the tool by what it does ("the AL build tool,
`al_build`") and tell the agent to use whatever the session actually exposes, so they port
without edits.
