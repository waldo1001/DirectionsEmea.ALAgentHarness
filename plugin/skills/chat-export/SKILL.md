---
name: chat-export
description: 'Export an agent session and turn it into a short diagnose report for whoever maintains the harness: which skills, agents and MCP servers were available versus actually used, which tools failed, where the agent looped. Use when: "export this chat", "why did it not use the skill", "send this session to the devlead", the developer says the tooling (not the code) is failing them. Never runs unasked.'
---

# Chat Export

A session where the harness failed is the best bug report the harness will ever get, and it
is gone when the session is. This skill keeps it and turns it into something a devlead can
read in two minutes.

A skill that was available but never triggered is the strongest signal there is: its
`description` does not match how developers ask. That is a fix to the skill, not to the
developer.

## When to use

- The developer asks to export or capture the session.
- The developer says the tooling is failing them ("you keep doing that", "why did you not
  use X"). Offer it once, in one line; never run it unasked. An export contains code and
  command output: the developer decides.

Not for ordinary code problems: a red build or a failing test is not harness friction.

## Procedure

### 1. Get the transcript

Use what the host offers:

| Host | How |
|------|-----|
| Claude Code | the developer runs `/export <file>` (a slash command only they can run), or you read the session file under `~/.claude/projects/<project>/<session-id>.jsonl` |
| GitHub Copilot (VS Code) | **Chat: Export Chat...** from the command palette, saves JSON |

Save it **outside the repo** (for example `~/Downloads/`), so it can never be committed.

### 2. Analyse

Read the transcript and collect, with turn numbers:

- **Offered vs used:** skills and agents listed as available, and which were invoked.
  Every one that applied to the request but never ran gets a line.
- **MCP servers:** connected, failed to connect, tools called per server.
- **Tool errors:** the failing call and the error, once per distinct error.
- **Loops:** the same tool or the same fix tried three or more times.
- **The ask:** the developer's requests, quoted short, so the reader can judge what should
  have triggered.

### 3. Write the report

Next to the export, `<name>-diagnose.md`:

```
Chat export - <date> - <one-line topic>
Ask:        "<the developer's request>" (turn 1)
Skills:     offered 9, used 3   never triggered: al-object-id-assignment (turn 4: new table)
Agents:     al-coder (subagent, turn 6)
MCP:        al-object-id-ninja failed to connect; microsoft-learn 2 calls
Errors:     al_build "project not loaded" x3 (turns 7-9)
Loops:      same build fix 3 times (turns 7-9)
Suggested:  al-object-id-assignment description lacks "create a table"
```

### 4. Hand over

Give the developer the two file paths and one line to send with them: what they tried to do,
what they expected the agent to do, what it did instead. Only they know the last part.

## Never

- Never run this unasked, never commit an export, never send it anywhere yourself.
- Never paste secrets: redact tokens, keys and passwords in the report.

## Related

- `AGENTS.md` - the skill table whose descriptions this report tests.