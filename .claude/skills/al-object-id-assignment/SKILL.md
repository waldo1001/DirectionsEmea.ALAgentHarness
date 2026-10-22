---
name: al-object-id-assignment
description: 'Get the ID for a new AL object from the AL extension''s own tool (al_getnextobjectid) BEFORE writing the artifact. Use when: creating any new AL object (table, tableextension, page, pageextension, codeunit, report, enum, enumextension, query, xmlport, permissionset, ...), adding a field through a tableextension, or adding an enum value through an enumextension. Never pick an ID yourself.'
---

# AL Object ID Assignment (AL extension tool)

Every new object gets its ID **from a tool, before the artifact is written**. An ID the
model picks itself is a guess: it collides with what is already in the app, and you only
find out at compile or publish time.

Guessed, hardcoded, incremented and counted-from-existing-files IDs are **forbidden**. A
tool in your list is not optional: it removes every excuse for inventing one.

## Limitation - read this first

`al_getnextobjectid` **only sees your local repo**. It scans the AL files of the project on
disk and returns the lowest number that is free *there*. It reserves nothing: two calls
without writing a file return the same ID, and so do two developers on two branches.
Both write `table 50101`, both builds are green, and the collision shows up at merge or
publish time, in someone else's branch.

It also has no answer for **fields and enum values**: it allocates object IDs only.

This is fine for one developer on one branch. It is not fine for a team. The fix is a
reservation service (step 03), not a better guess.

## When to use

- Before creating any new AL object.
- Before adding a field through a tableextension, or a value through an enumextension
  (see step 3: the tool can not do these).

Not needed when you edit the body of an existing object: it keeps its ID.

## Procedure

### 1. List every artifact that needs an ID

Objects, fields added through a tableextension, values added through an enumextension. Fields of a
**new** table are numbered 1, 2, 3 ... and need no ID from a tool: a field ID only has to be unique
within its own table. Per app: `app/` and `test/` have their own ranges, so
an ID is asked for the app that will own the object.

### 2. Find the tool

Use what the session exposes; list your tools, do not assume a name.

| Host | Tool |
|------|------|
| GitHub Copilot in VS Code | `al_getnextobjectid`, built into the AL extension (no MCP needed) |
| Claude Code | the same `al_getnextobjectid`, through the AL CLI's MCP server `al` in `.mcp.json` (`al launchmcpserver`) |

No tool present? Go to the hard stop below.

### 3. Ask once per object type

Call the tool with:

- `objectType` - `Table`, `TableExtension`, `Page`, `PageExtension`, `Codeunit`, `Enum`, ...
- `projectPath` - the owning app folder (`app` or `test`), required because both are loaded.
- `count` - the number of objects of that type you are about to create in this turn. Never
  call twice for the same type without writing the first file: you get the same ID back.

Read the tool's input schema at call time; do not guess parameter names. Show the tool's
`warnings` to the developer.

**Fields of a new table:** number them 1, 2, 3 ... - no tool needed. **Tableextension fields and
enumextension values:** the tool returns nothing for these. Do not count up from existing fields.
Ask the developer for the ID, or stop.

### 4. Write the artifact with the returned ID

The ID goes verbatim into the declaration: `tableextension 50101 "DIR Customer"`. Name the
file per CodeCop AA0215, `<ObjectName>.<ObjectType>.al` without spaces
(`DIRCustomer.TableExt.al`). No placeholder IDs, no `50000` "to be fixed later": a filler
that survives one build survives to production.

### 5. Report

```
Object ID assignment (al_getnextobjectid - local repo only, not reserved)
  TableExtension "DIR Customer"              -> 50101  (app)
  Codeunit       "DIR Carrier Release Check" -> 50102  (app)
  field          "DIR Preferred Carrier"     -> asked the developer: 50100
```

Always print "local repo only, not reserved": the developer must know a colleague can get
the same number.

## Hard stop - no fallback

> ⛔ No ID tool available, or the call errors: **STOP and report it.** Do not fall back to
> `idRanges`, to the highest existing ID, or to "a safe-looking number". Unblock with:
>
> - VS Code / Copilot: install or enable the AL Language extension (`ms-dynamics-smb.al`).
> - Claude Code: install the AL CLI
>   (`dotnet tool install --global microsoft.dynamics.businesscentral.development.tools --prerelease`)
>   and approve the `al` server from `.mcp.json` (`/mcp`).

## Never

- Never write a concrete ID that did not come from the tool or the developer.
- Never treat a green build as proof the ID is free for the team: the collision is with a
  colleague's branch, not with your workspace.

## Related

- `.mcp.json` - registers the AL CLI's MCP server for Claude Code.
