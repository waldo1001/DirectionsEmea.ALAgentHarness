---
bc-version: [all]
domain: style
keywords: [file, object, organization, naming, one-object-per-file]
technologies: [al]
countries: [w1]
application-area: [all]
---

# One AL object per file

## Description

Every `.al` file in `app/` and `test/` declares **exactly one** object or object extension.
No bundling, whatever the size of the objects or how closely they belong together. The file
is named after that one object (CodeCop AA0215: `<ObjectName>.<ObjectType>.al`).

Check: count the object declarations in each changed `.al` file, lines matching
`^\s*(table|tableextension|page|pageextension|codeunit|report|reportextension|enum|enumextension|interface|query|xmlport|permissionset|permissionsetextension|controladdin|profile|entitlement)\s`
(`interface` and `profile` have no ID). The count is 1. Sample files in `rules/` are exempt.

## Best Practice

`DIRCustomer.TableExt.al`, `DIRCustomerCard.PageExt.al` and
`DIRCustomerCheckCarrierMeth.Codeunit.al` as three files. A diff shows per file which object
changed, merge conflicts stay small, and a reviewer can say "this object" by naming a file.

See sample: [`single-object-per-file.good.al`](single-object-per-file.good.al).

## Anti Pattern

One `PreferredCarrier.al` that holds the tableextension, the pageextension and the codeunit.
Every change to one object conflicts with every change to the others, and the file name no
longer tells anyone what is inside.

See sample: [`single-object-per-file.bad.al`](single-object-per-file.bad.al).
