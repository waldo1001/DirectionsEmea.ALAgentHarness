---
bc-version: [all]
domain: style
keywords: [label, naming, error, message, confirm, err, msg, qst, translation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Labels are named Context-Reason plus Err, Msg or Qst

## Description

Text for `Error`, `Message` and `Confirm` is always a `Label` (the harness enforces that).
This rule adds how the Label is **named**: `<Context><Reason>` in PascalCase, ending in the
suffix that says how it is used.

| Used in | Suffix | Example |
|---------|--------|---------|
| `Error()` | `Err` | `NoPreferredCarrierErr` |
| `Message()` | `Msg` | `CarrierAssignedMsg` |
| `Confirm()` | `Qst` | `ReleaseWithoutCarrierQst` |

A Label with placeholders has a `Comment` naming each one (`'%1 = Customer No.'`). Technical
text that must not be translated has `Locked = true` and is not used in these three calls.

Check: every Label passed to `Error` ends in `Err`, to `Message` in `Msg`, to `Confirm` in
`Qst`; every Label containing `%1` has a `Comment`.

## Best Practice

`NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier.', Comment = '%1 = Customer No.';`
The name tells the reader how it is shown; the Comment tells the translator what `%1` is.

See sample: [`label-naming.good.al`](label-naming.good.al).

## Anti Pattern

Names like `Text001`, `CarrierLabel` or `ErrorMsg`, a `Msg` Label passed to `Error`, or a
placeholder without a Comment. Translators guess what `%1` is, and reviewers cannot see from
the name what the user will get.

See sample: [`label-naming.bad.al`](label-naming.bad.al).
