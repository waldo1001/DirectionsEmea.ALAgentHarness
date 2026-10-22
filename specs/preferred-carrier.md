---
title: Preferred Carrier
status: implemented    # draft | approved | implemented
depends-on: []         # other specs (file names) that must be implemented first
source: docs/TASK.md
---

# Preferred Carrier

## Context

Sales orders get released without anyone having decided how the goods will travel. Each
customer gets a Preferred Carrier, picked from the existing `Table 50100 "DIR Carrier"` and
maintained on the Customer Card in the Shipping group. A sales order can only be released when
its sell-to customer has a usable (not blocked) preferred carrier. Picking the carrier also
fills the customer's Shipping Agent Code, so the standard shipping fields stay consistent.

## Decisions

- D1 - The check uses the **Sell-to Customer** of the order; the Bill-to Customer is ignored
  (asked: shipping belongs to the receiving customer).
- D2 - A preferred carrier that is **Blocked** also blocks the release, with its own error
  (asked).
- D3 - Validating the Preferred Carrier on the customer **fills the customer's "Shipping Agent
  Code"** from the carrier's "Shipping Agent Code" (asked).
- D4 - D3 only copies a non-empty value: a carrier without a Shipping Agent Code, or clearing
  the Preferred Carrier, leaves the customer's Shipping Agent Code unchanged (decided: never
  wipe data the user entered with an empty value).
- D5 - The customer's "Shipping Agent Code" is set with `Validate`, so its standard OnValidate
  logic still runs (decided: extend, never bypass base behavior).
- D6 - The field is `"DIR Preferred Carrier"` Code[20] with `TableRelation = "DIR Carrier"`
  (decided: the carrier table exists in `app/` and its primary key is Code[20]).
- D7 - Only `Document Type = Order` is checked; quotes, invoices, return orders and other
  sales documents release as before (decided: the task says "Sales Order").
- D8 - The check runs in a subscriber to `OnBeforeReleaseSalesDoc`, so it covers the manual
  Release action and the release that posting does (decided: that event fires in the release
  routine that every release path goes through).
- D9 - Choosing a blocked carrier on the customer is allowed; the block applies at release
  (decided: D2 asks for a release block, not a master-data block).
- D10 - The field is placed `addlast(Shipping)` on the Customer Card (decided: the task names
  the Shipping group).
- D11 - The validate logic and the release check live in one codeunit; the field's OnValidate
  only calls it (decided: AGENTS.md, business logic in codeunits).
- D12 - No permission set change: no new table is added, and the existing permission set
  `PermissionSet 50100 "DIR Directions Demo"` already covers "DIR Carrier" (decided).
- D13 - decided by al-coder: if the sell-to customer cannot be found, or the preferred carrier
  code no longer exists in "DIR Carrier", the release check treats a missing customer as "not
  my check" (the standard release checks report it) and a missing carrier as no preferred
  carrier (NoPreferredCarrierErr). The spec did not cover these two edge cases.
- D14 - decided by al-coder: the test codeunit repeats the two error label texts as its own
  Labels, because the Labels in "DIR Preferred Carrier Mgt." are private to that codeunit.

## Acceptance criteria

- AC1 - Given a customer, when "DIR Preferred Carrier" is validated with a code that does not
  exist in "DIR Carrier", then an error is raised and the value is not stored.
- AC2 - Given the Customer Card is open for a customer and a carrier exists, when the user
  enters that carrier in the Preferred Carrier field on the Shipping group, then the customer
  record stores it.
- AC3 - Given an open sales order whose sell-to customer has an empty "DIR Preferred
  Carrier", when the order is released, then the error NoPreferredCarrierErr is raised and
  the order stays Open.
- AC4 - Given an open sales order whose sell-to customer's preferred carrier is Blocked, when
  the order is released, then the error PreferredCarrierBlockedErr is raised and the order
  stays Open.
- AC5 - Given an open sales order whose sell-to customer has a preferred carrier that is not
  blocked, when the order is released, then the order's Status is Released.
- AC6 - Given an open sales order whose sell-to customer has a valid preferred carrier and
  whose different bill-to customer has none, when the order is released, then the order's
  Status is Released.
- AC7 - Given an open sales invoice whose sell-to customer has no preferred carrier, when the
  invoice is released, then its Status is Released.
- AC8 - Given a carrier with a Shipping Agent Code, when it is validated as the customer's
  "DIR Preferred Carrier", then the customer's "Shipping Agent Code" equals the carrier's.
- AC9 - Given a customer with a Shipping Agent Code and a carrier with an empty Shipping Agent
  Code, when that carrier is validated as the customer's "DIR Preferred Carrier", then the
  customer's "Shipping Agent Code" is unchanged.

## Objects

| Type | ID | Name | Purpose |
|------|----|------|---------|
| tableextension | `<Ninja>` | "DIR Customer" | extends Table 18 "Customer" with "DIR Preferred Carrier" |
| pageextension | `<Ninja>` | "DIR Customer Card" | extends Page 21 "Customer Card": the field `addlast(Shipping)` |
| codeunit | `<Ninja>` | "DIR Preferred Carrier Mgt." | fills Shipping Agent Code on validate (D3-D5); release check subscriber (D1, D2, D7, D8) |
| codeunit (test app) | `<Ninja>` | "DIR Preferred Carrier Tests" | Subtype = Test; the tests below |

New fields:

| Table | ID | Field | Type | Notes |
|-------|----|-------|------|-------|
| Table 18 "Customer" | `<Ninja>` | "DIR Preferred Carrier" | Code[20] | Caption 'Preferred Carrier'; TableRelation "DIR Carrier"; DataClassification CustomerContent; OnValidate calls "DIR Preferred Carrier Mgt." |

Page field: ToolTip 'Specifies the carrier that ships orders to this customer. A sales order
can only be released when its sell-to customer has a preferred carrier that is not blocked.'

## Events and extension points

Verified against the BC 29.0 symbols (`app/app.json`).

- `Codeunit 414 "Release Sales Document"/OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean)` -
  raised before every release of a sales document; the subscriber checks Document Type =
  Order and the sell-to customer's preferred carrier. It does not touch IsHandled.
- `Table 18 "Customer"/"Shipping Agent Code"` (Code[10]) - the field D3 fills, through
  Validate.
- `Page 21 "Customer Card"/Shipping` (group control) - the anchor for `addlast`.
- `Table 50100 "DIR Carrier"` ("Code", "Shipping Agent Code", "Blocked") - existing, reused.

## User-facing text

| Label | Text | Comment (placeholders) |
|-------|------|------------------------|
| NoPreferredCarrierErr | 'You cannot release sales order %1 because customer %2 has no preferred carrier.' | %1 = sales order No.; %2 = Sell-to Customer No. |
| PreferredCarrierBlockedErr | 'You cannot release sales order %1 because preferred carrier %2 of customer %3 is blocked.' | %1 = sales order No.; %2 = carrier Code; %3 = Sell-to Customer No. |

## Tests

| Test | Covers | Given / When / Then |
|------|--------|---------------------|
| PreferredCarrierMustExist | AC1 | Given a customer / When Validate "DIR Preferred Carrier" with a non-existing code / Then an error is raised, the field is empty |
| CustomerCardShowsPreferredCarrier | AC2 | Given a carrier and TestPage "Customer Card" on a customer / When the Preferred Carrier field is set / Then the customer record holds the carrier |
| ReleaseOrderWithoutPreferredCarrierFails | AC3 | Given an order for a customer without carrier / When released / Then error NoPreferredCarrierErr, Status Open |
| ReleaseOrderWithBlockedCarrierFails | AC4 | Given an order for a customer with a blocked carrier / When released / Then error PreferredCarrierBlockedErr, Status Open |
| ReleaseOrderWithPreferredCarrierSucceeds | AC5 | Given an order for a customer with a non-blocked carrier / When released / Then Status Released |
| ReleaseOrderChecksSellToCustomerOnly | AC6 | Given an order, sell-to with carrier, bill-to without / When released / Then Status Released |
| ReleaseInvoiceWithoutPreferredCarrierSucceeds | AC7 | Given an invoice for a customer without carrier / When released / Then Status Released |
| PreferredCarrierFillsShippingAgentCode | AC8 | Given a carrier with a Shipping Agent Code / When validated on the customer / Then the customer's Shipping Agent Code equals it |
| EmptyCarrierShippingAgentKeepsCustomerValue | AC9 | Given a customer with Shipping Agent Code A and a carrier without one / When validated / Then the customer's Shipping Agent Code is still A |

## Reserved IDs

| Type | ID | Name | App |
|------|----|------|-----|
| tableextension | 50104 | "DIR Customer" | app |
| field (Table 18 "Customer", `table_18`) | 50104 | "DIR Preferred Carrier" | app |
| pageextension | 50104 | "DIR Customer Card" | app |
| codeunit | 50107 | "DIR Preferred Carrier Mgt." | app |
| codeunit | 80104 | "DIR Preferred Carrier Tests" | test |

## Open questions

None.
