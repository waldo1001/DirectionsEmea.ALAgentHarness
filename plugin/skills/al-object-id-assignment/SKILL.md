---
name: al-object-id-assignment
description: 'Reserve object, field and enum-value IDs with AL Object ID Ninja BEFORE writing the AL artifact, and release IDs that end up unused. Use when: creating any new AL object (table, tableextension, page, pageextension, codeunit, report, enum, enumextension, query, xmlport, permissionset, ...), adding a field through a tableextension, adding an enum value through an enumextension, or deleting/reverting an object whose ID you reserved. Never pick an ID yourself.'
---

# AL Object ID Assignment (AL Object ID Ninja)

Every object, field and enum-value ID is **reserved from AL Object ID Ninja before the
artifact is written**. Ninja owns the ranges across every developer and branch. An ID you
pick yourself is not reserved: a colleague's next reservation collides with it, and you only
find out at publish time, in someone else's branch.

Guessed, hardcoded, incremented, counted-from-existing-files and `idRanges`-derived IDs are
**forbidden**. A tool in your list is not optional: it removes every excuse for inventing one.

Why Ninja and not `al_getnextobjectid`: that tool only sees your local repo and reserves
nothing, so two developers get the same "next free" ID. Ninja is a shared reservation
service. The MCP server is only the data source; this skill is how to use it.

## When to use

- Before creating any new AL object.
- Before adding a field through a tableextension, or a value through an enumextension.
- After deleting, renaming away or reverting an object whose ID you reserved (release it).

Not needed when you edit the body of an existing object: it keeps its ID.

## Procedure

### 1. List every artifact that needs an ID

Objects, fields added through a tableextension, values added through an enumextension. Fields of a
**new** table are numbered 1, 2, 3 ... and are **not** reserved: a field ID only has to be unique
within its own table. Per app: `app/` and `test/` have their own ranges, so
an ID is reserved against the app that will own the object.

### 2. Find the Ninja tool

Use what the session exposes; list your tools, do not assume a name.

| Host | Reserve | Release |
|------|---------|---------|
| Claude Code, Cursor, any MCP client (`.mcp.json` server `al-object-id-ninja`) | `ninja_assignObjectId` | `ninja_unassignObjectId` |
| GitHub Copilot in VS Code (Ninja extension, no MCP needed) | `ninjaNextId` | `ninjaUnassignId` |

No Ninja tool present? Go to the hard stop below. `al_getnextobjectid` (AL extension / AL MCP
server) is **not** a fallback: it reads your local workspace and reserves nothing, so it is
denied in `.claude/settings.json`.

### 3. Reserve one ID per artifact

Call the reserve tool once per artifact with:

- `objectType` - the object type in lower case (`table`, `tableextension`, `codeunit`, ...).
  For a **field**, `table_<tableId>` of the table that gets the field: a field added to
  `Table 18 "Customer"` through a tableextension is `table_18`. For an **enum value**,
  `enum_<enumId>`.
- `targetFilePath` - the absolute path of the owning app's `app.json` (`app/app.json` or
  `test/app.json`). Ninja only uses it to find the app; it says nothing about the object, so
  the file you are about to create does not need to exist. Say so when you call it.

Never reuse one returned ID for a second artifact and never increment a returned ID: the
next number was never reserved. Read the tool's input schema at call time; do not guess
parameter names.

### 4. Check the ID is really free locally

Search the owning app for the returned ID on the same object type (for example
`grep -rniE "^\s*table\s+50101\b" app/`). If it is already declared, Ninja has not been
synchronized with this app: **hard stop** (below). Do not ask for "the next one".

### 5. Write the artifact with the returned ID

The ID goes verbatim into the declaration: `tableextension 50101 "DIR Customer"`. Name the
file per CodeCop AA0215, `<ObjectName>.<ObjectType>.al` without spaces
(`DIRCustomer.TableExt.al`). No placeholder IDs, no `50000` "to be fixed later": a filler
that survives one build survives to production.

### 6. Release what you do not use

Object dropped from the design, deleted, reverted, a stub removed: call the release tool for
its ID. An unreleased ID stays consumed for everyone.

### 7. Report

```
Object ID reservation
  Table      "DIR Carrier Rating"              -> 50102  (app)
  field      "DIR Preferred Carrier" (Table 18) -> 50100  (app, table_18)
  Codeunit   "DIR Carrier Release Check"       -> 50103  (app)
  Codeunit   "DIR Carrier Tests"               -> 80100  (test)
  Released:  50104 (codeunit dropped from the design)
```

When a spec is in play, copy this list into the spec's `## Reserved IDs` table: that table
is what `/done` checks the code against.

## Hard stop - no fallback

> ⛔ No Ninja tool available, the call errors, or the returned ID is already declared in the
> app: **STOP and report it.** Do not fall back to `idRanges`, to the highest existing ID,
> or to "a safe-looking number". Tell the user how to unblock and wait:
>
> - Claude Code: approve the `al-object-id-ninja` server from `.mcp.json` (`/mcp`), or
>   `claude mcp add --scope project al-object-id-ninja -- npx -y @vjeko.com/al-object-id-ninja-mcp`
> - VS Code: install the extension `vjeko.vjeko-al-objid`.
> - ID already declared: run **Ninja: Synchronize Object IDs** in VS Code, then retry.

A blocked reservation costs one message. An invented ID costs a collision in someone else's
branch.

## Never

- Never write a concrete ID into a spec. Specs say `<Ninja>`; a guessed ID in a spec becomes
  a guessed ID in the code.
- Never treat a green build as proof the ID was free: the collision is with a reservation,
  not with your workspace.

## Related

- `al-build-validation` - run after the artifact is written.
- `.mcp.json` - registers the Ninja MCP server for Claude Code.
- `specs/TEMPLATE.md` - the `## Reserved IDs` table this skill fills (step 06).