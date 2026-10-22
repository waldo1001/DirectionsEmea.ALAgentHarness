---
bc-version: [all]
domain: style
keywords: [meth-codeunit, business-logic, public-procedure, table, tableextension, architecture]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Table business logic lives in a Meth codeunit with exactly one public procedure

## Description

Business logic that belongs to a table (validation, calculation, a check before a document
moves on) is not written in the table, the page or a general "management" codeunit. Each
piece of logic gets its own Meth codeunit, named `<Affix> <Table> <Action> Meth`, for example
`"DIR Customer CheckCarrier Meth"`.

A Meth codeunit has **exactly one** procedure without `local`: its entry point. Everything
else in it is `local`. The table (or tableextension) exposes one public procedure that calls
the Meth codeunit, and every other object (page, report, event subscriber) calls that table
procedure, never the Meth codeunit directly.

Check: count the procedures without `local` in each codeunit whose name ends in `Meth`
(exactly one; integration events are `local` too). Search for the Meth codeunit's name
outside its table: only the table or tableextension may declare a variable of it.

## Best Practice

One public entry point that raises `OnBefore...` (with `var IsHandled`) and `OnAfter...`
integration events around a local `Do...` procedure, called from a one-line table procedure.
One reason to change per codeunit, one place to look, one seam to subscribe to.

See sample: [`meth-codeunit-single-public-procedure.good.al`](meth-codeunit-single-public-procedure.good.al).

## Anti Pattern

A codeunit with several public helpers, or a page action or event subscriber that calls the
Meth codeunit directly. Every public helper becomes API that other extensions start to depend
on, and logic called from many places can no longer be changed in one.

See sample: [`meth-codeunit-single-public-procedure.bad.al`](meth-codeunit-single-public-procedure.bad.al).
