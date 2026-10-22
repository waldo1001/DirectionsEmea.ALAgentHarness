---
bc-version: [all]
domain: style
keywords: [tableextension, naming, suffix, pte, field, procedure]
technologies: [al]
countries: [w1]
application-area: [all]
---

# New fields and procedures in a tableextension end in PTE

## Description

Every **new** field and every **new** procedure in a `tableextension` carries the suffix
`PTE`, in capitals, after the name: `"DIR Preferred Carrier PTE"` for a field (a space before
`PTE` inside the quotes), `CheckPreferredCarrierPTE()` for a procedure. It marks, in any list,
any debugger and any upgrade diff, what is ours and what is the base application's.

Applies to tableextensions only. Not to base tables of the app, not to pages, page
extensions or codeunits, and not to existing fields you only modify. The extension object
itself is named with the affix as usual (`"DIR Customer"`). The suffix comes on top of the
mandatory affix, it does not replace it: `"DIR Preferred Carrier PTE"`.

Check: every `field(<id>; "<name>"; ...)` and every `procedure` declared in a
`tableextension` ends in `PTE` exactly (case-sensitive).

## Best Practice

`field(50100; "DIR Preferred Carrier PTE"; Code[20])` and `procedure CheckPreferredCarrierPTE()`.
Captions stay clean (`Caption = 'Preferred Carrier'`): the suffix is for developers, not
for users.

See sample: [`tableextension-pte-suffix.good.al`](tableextension-pte-suffix.good.al).

## Anti Pattern

No suffix, a prefix instead of a suffix, or the wrong case (`Pte`, `pte`). The field is no
longer recognisable as an extension field, and it can collide with a field Microsoft adds to
the base table with the same name in a later version.

See sample: [`tableextension-pte-suffix.bad.al`](tableextension-pte-suffix.bad.al).