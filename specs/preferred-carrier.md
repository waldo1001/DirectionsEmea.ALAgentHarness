---
title: Preferred Carrier
status: implemented    # draft | approved | implemented
depends-on: []         # other specs (file names) that must be implemented first
source: conversation
---

# Preferred Carrier

## Context

Sales orders get released without anyone having decided how the goods will ship, and the
warehouse finds out too late. Every customer gets a Preferred Carrier (from the existing
`Table 50100 "DIR Carrier"`), visible on the Customer Card next to the other shipping
fields, and a Sales Order can only be released when its Sell-to Customer has a usable one.

## Decisions

- D1 - The Sell-to Customer of the order is checked, not the Bill-to Customer (asked: the
  customer the goods ship to is the one a carrier belongs to).
- D2 - A Preferred Carrier that is `Blocked` in "DIR Carrier" blocks the release too (asked).
- D3 - Enforced immediately, no setup toggle: open orders of customers without a carrier can
  not be released until the field is filled (asked).
- D4 - The field is `"DIR Preferred Carrier PTE"`, Code[20], Caption 'Preferred Carrier',
  `TableRelation = "DIR Carrier"`, `DataClassification = CustomerContent` (decided: rule
  `tableextension-pte-suffix`; "DIR Carrier"."Code" is Code[20] and exists for this).
- D5 - Only Document Type = Order is checked; quotes, invoices, credit memos, return orders
  and blanket orders release as before (decided: the task says Sales Order).
- D6 - The check runs in `PreviewMode` as well, and is skipped when another subscriber
  already set `IsHandled` to true (decided: preview shows the same error as the real
  release; a handled release does not run the standard release, so no check either).
- D7 - The logic lives in `Codeunit <Ninja> "DIR Customer CheckCarrier Meth"`, one public
  procedure with `OnBeforeCheckPreferredCarrier` (var IsHandled) / `OnAfterCheckPreferredCarrier`
  integration events around a local `DoCheckPreferredCarrier`, called only from
  `CheckPreferredCarrierPTE()` on the Customer tableextension. The event subscriber calls
  `Customer.CheckPreferredCarrierPTE()` (decided: rule `meth-codeunit-single-public-procedure`).
- D8 - The subscriber lives in its own codeunit `"DIR Release Sales Doc Subs"`; it filters on
  Document Type = Order, gets the Sell-to Customer and calls the table procedure, nothing else
  (decided: business logic in codeunits; rule `single-object-per-file`).
- D9 - The field is placed `addlast(Shipping)` on `Page 21 "Customer Card"`. Placement is
  proven by the build and the symbol `Customer Card/content/Shipping` (Group, verified on
  BC 29), not by a TestPage test (decided: TestPage tests can crash in the cloud runner).
- D10 - The page extension has no triggers and no local procedures (decided: rule
  `page-no-local-procedures`).
- D11 - `PermissionSet 50100 "DIR Directions Demo"` gets `X` on the two new codeunits
  (decided: every object of the app is in its permission set).
- D12 - Labels are named `<Context><Reason>Err` with a Comment for every placeholder
  (decided: rule `label-naming`). Files hold one object each (rule `single-object-per-file`).

## Acceptance criteria

- AC1 - Given a Sales Order whose Sell-to Customer has an empty Preferred Carrier, when the
  order is released, then the release fails with `NoPreferredCarrierErr` and the order
  status stays Open.
- AC2 - Given a Sales Order whose Sell-to Customer has a Preferred Carrier that is Blocked,
  when the order is released, then the release fails with `PreferredCarrierBlockedErr` and
  the order status stays Open.
- AC3 - Given a Sales Order whose Sell-to Customer has a Preferred Carrier that is not
  Blocked, when the order is released, then the order status is Released.
- AC4 - Given a Sales Quote whose Sell-to Customer has an empty Preferred Carrier, when the
  quote is released, then the quote status is Released.

## Objects

| Type | ID | Name | Purpose |
|------|----|------|---------|
| tableextension | `<Ninja>` | "DIR Customer" | extends Table 18 "Customer": the field and `CheckPreferredCarrierPTE()` |
| pageextension | `<Ninja>` | "DIR Customer Card" | extends Page 21 "Customer Card": the field, `addlast(Shipping)` |
| codeunit | `<Ninja>` | "DIR Customer CheckCarrier Meth" | the check, one public procedure (D7) |
| codeunit | `<Ninja>` | "DIR Release Sales Doc Subs" | subscribes to `OnBeforeReleaseSalesDoc` (D8) |
| permissionset | 50100 (existing) | "DIR Directions Demo" | add `X` on the two codeunits (D11) |
| codeunit (test app) | `<Ninja>` | "DIR Preferred Carrier Tests" | `Subtype = Test`, the four tests below |

New fields:

| Table | ID | Field | Type | Notes |
|-------|----|-------|------|-------|
| Table 18 "Customer" | `<Ninja>` | "DIR Preferred Carrier PTE" | Code[20] | Caption 'Preferred Carrier', TableRelation "DIR Carrier", ToolTip on the page |

## Events and extension points

Verified with `al_symbolsearch` against the BC 29.0 symbols (`app/app.json`).

- `Codeunit 414 "Release Sales Document"/OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean)`
  - runs before every release of a sales document, including preview; the place to refuse it.
- `Page 21 "Customer Card"/content/Shipping` (Group) - anchor for the field.
- New, raised by "DIR Customer CheckCarrier Meth": `OnBeforeCheckPreferredCarrier(var Customer: Record Customer; var IsHandled: Boolean)`
  and `OnAfterCheckPreferredCarrier(var Customer: Record Customer)`.

## User-facing text

| Label | Text | Comment (placeholders) |
|-------|------|------------------------|
| NoPreferredCarrierErr | 'Customer %1 has no preferred carrier. Set one on the customer card before you release the order.' | %1 = Customer No. |
| PreferredCarrierBlockedErr | 'Preferred carrier %1 of customer %2 is blocked.' | %1 = Carrier Code, %2 = Customer No. |

Field captions and the ToolTip ('Specifies the carrier that ships this customer''s orders.')
are properties, not Labels.

## Tests

Codeunit "DIR Preferred Carrier Tests" (test app), using `Library - Sales`, `Library - Utility`
and `Assert`; each test creates its own customer, carrier and document.

| Test | Covers | Given / When / Then |
|------|--------|---------------------|
| ReleaseOrderWithoutPreferredCarrierFails | AC1 | Customer with empty carrier, Sales Order with a line / `ReleaseSalesDocument` (asserterror) / error text = `NoPreferredCarrierErr` for that customer, Status = Open |
| ReleaseOrderWithBlockedPreferredCarrierFails | AC2 | Customer with a Blocked carrier, Sales Order with a line / release (asserterror) / error text = `PreferredCarrierBlockedErr`, Status = Open |
| ReleaseOrderWithPreferredCarrierSucceeds | AC3 | Customer with a non-blocked carrier, Sales Order with a line / release / Status = Released |
| ReleaseQuoteWithoutPreferredCarrierSucceeds | AC4 | Customer with empty carrier, Sales Quote with a line / release / Status = Released |

SDD notes:

- `guard`: ReleaseOrderWithPreferredCarrierSucceeds (AC3) and ReleaseQuoteWithoutPreferredCarrierSucceeds
  (AC4) passed at the first RED (normal path); the mutation run turned both red.
- The two failing-release tests `Commit()` the order before `asserterror`: the release error
  rolls back the uncommitted transaction, the order included, so its Status could not be read.
- Not covered by a test: the `IsHandled` skips (D6) in the subscriber and in the Meth codeunit.
  Removing them was caught by no test; covering them needs a test subscriber that sets
  `IsHandled` and a new acceptance criterion.

## Reserved IDs

Filled by the implementing agent from its Ninja reservations. `/done` checks the code
against this table.

| Type | ID | Name | App |
|------|----|------|-----|
| tableextension | 50100 | "DIR Customer" | app |
| field (Table 18) | 50100 | "DIR Preferred Carrier PTE" | app |
| pageextension | 50100 | "DIR Customer Card" | app |
| codeunit | 50100 | "DIR Customer CheckCarrier Meth" | app |
| codeunit | 50101 | "DIR Release Sales Doc Subs" | app |
| codeunit | 80100 | "DIR Preferred Carrier Tests" | test |

## Open questions

None.
