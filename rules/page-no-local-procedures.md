---
bc-version: [all]
domain: ui
keywords: [page, pageextension, local-procedure, business-logic, action, trigger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pages and page extensions have no local procedures

## Description

A page shows data and starts actions. It does not compute, validate or decide. So a `page`
or `pageextension` declares **no `local procedure`** at all, and its triggers (`OnAction`,
`OnValidate`, `OnAfterGetRecord`, ...) contain at most a call to a public procedure of the
source table or tableextension, which in turn uses a Meth codeunit
(see `meth-codeunit-single-public-procedure`).

Check: no line matching `local procedure` in a file that declares a `page` or
`pageextension`; no page trigger longer than a call plus, at most, a `CurrPage.Update()`.

## Best Practice

The action calls `Rec.CheckPreferredCarrierPTE()`. The logic can be tested without opening
the page, reused by an API page or a job queue, and found in one place.

See sample: [`page-no-local-procedures.good.al`](page-no-local-procedures.good.al).

## Anti Pattern

A local procedure on the page that does the work, called from an action. The logic is now
reachable only through the UI: no test can call it, no API page can reuse it, and the next
developer copies it to the second page that needs it.

See sample: [`page-no-local-procedures.bad.al`](page-no-local-procedures.bad.al).
