---
title: <Feature name>
status: draft          # draft | approved | implemented
depends-on: []         # other specs (file names) that must be implemented first
source: <docs/TASK.md, an issue link, or "conversation">
---

# <Feature name>

## Context

Why this feature exists, for whom, and what it changes in their day. Two to five sentences.

## Decisions

What the developer decided in the question round, and what the spec agent decided itself.
One line each, with the reason.

- D1 - <decision> (asked / decided: <reason>)

## Acceptance criteria

Numbered and testable. **One-to-one with `## Tests`**: every criterion has exactly one test,
every test covers exactly one criterion. A criterion you can not test is not finished.

- AC1 - Given <state>, when <action>, then <observable result>.

## Objects

Every new or extended object, by type and name. The ID is always `<Ninja>`: it is reserved
at implementation time, never here.

| Type | ID | Name | Purpose |
|------|----|------|---------|
| tableextension | `<Ninja>` | "DIR <Name>" | extends Table <ID> "<Base table>" |

New fields:

| Table | ID | Field | Type | Notes |
|-------|----|-------|------|-------|
| Table <ID> "<Base table>" | `<Ninja>` | "DIR <Field>" | Code[20] | TableRelation, captions |

## Events and extension points

Base-app events or objects this feature hooks into, as a symbol path, verified against the
symbols of the BC version in `app/app.json`.

- `Codeunit <ID> "<Name>"/<EventName>(...)` - why this event

## User-facing text

Every Error, Message and Confirm, as the Label it will become.

| Label | Text | Comment (placeholders) |
|-------|------|------------------------|
| <Context>Err | '<text with %1>' | %1 = <meaning> |

## Tests

One row per acceptance criterion, in the same order. `/done` checks that every test named
here exists.

| Test | Covers | Given / When / Then |
|------|--------|---------------------|
| <TestName> | AC1 | ... |

## Reserved IDs

Filled by the implementing agent from its Ninja reservations. `/done` checks the code
against this table.

| Type | ID | Name | App |
|------|----|------|-----|

## Open questions

Anything still undecided. A spec with open questions stays `draft`.
