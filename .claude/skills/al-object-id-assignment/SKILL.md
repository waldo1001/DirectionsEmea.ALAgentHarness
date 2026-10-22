---
name: al-object-id-assignment
description: 'Get the ID for a new AL object from the Next-Free-Object-ID Oracle (scripts/next-id.sh) BEFORE writing the artifact. Use when: creating any new AL object (table, tableextension, page, pageextension, codeunit, report, enum, enumextension, query, xmlport, permissionset, ...), adding a field through a tableextension, or adding an enum value through an enumextension. Never pick an ID yourself.'
---

# AL Object ID Assignment (the regex oracle)

Every new object gets its ID **from a tool, before the artifact is written**. Not from the
model's head: an ID the model picks is a guess.

Our tool for now: `scripts/next-id.sh` next to this skill, the Next-Free-Object-ID Oracle.
It parses `idRanges` out of `app.json` with a regular expression, scans every `.al` file for
declarations of the object type and returns the lowest free number. Regex powered. Zero
dependencies. What could possibly go wrong?

## Limitation - read this first

Plenty can go wrong, and you should say so every time you use it:

- **It only sees this disk, this branch.** A colleague on another branch gets the same number.
- **It reserves nothing.** Run it twice, get the same number twice.
- **It parses with regex.** Dependencies, other extensions on the sandbox, commented-out or
  oddly formatted objects: invisible or miscounted.

It is better than a guess. It is not a reservation.

## When to use

- Before creating any new AL object.
- Before adding a field through a tableextension, or a value through an enumextension.

Not needed when you edit the body of an existing object: it keeps its ID. Fields of a **new**
table are numbered 1, 2, 3 ...: a field ID only has to be unique within its own table.

## Procedure

### 1. List every artifact that needs an ID

Objects, fields added through a tableextension, values added through an enumextension. Per app:
`app/` and `test/` have their own ranges.

### 2. Ask the oracle, once per object

```bash
bash .claude/skills/al-object-id-assignment/scripts/next-id.sh <objecttype> <app-folder>
# e.g. bash .claude/skills/al-object-id-assignment/scripts/next-id.sh table app
```

It prints one number. Write that object's file before you ask for the next one of the same
type, or you get the same number back.

**Tableextension fields and enumextension values:** the oracle does not do fields. Ask the
developer for the ID, or stop. Never count up yourself.

### 3. Write the artifact with the returned ID

The ID goes verbatim into the declaration: `tableextension 50101 "DIR Customer"`. File name
per CodeCop AA0215, `<ObjectName>.<ObjectType>.al` without spaces.

### 4. Report

```
Object ID assignment (next-id.sh - local disk only, regex, not reserved)
  Table  "DIR Carrier Rating"  -> 50101  (app)
```

Always print "local disk only, not reserved".

## Hard stop

> ⛔ The script fails or prints nothing: **STOP** and report it. Never fall back to
> `idRanges` or "a safe-looking number" yourself.

## Related

- Step 02b replaces the oracle with the AL extension's own tool; step 03 with a real reservation.
