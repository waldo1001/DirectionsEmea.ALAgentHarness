---
name: company-rules
description: 'Load and apply the company AL rules in rules/ as mandatory constraints, and report PASS / FAIL per rule. Use BEFORE writing or designing any AL code, when reviewing AL, and for /done line D7. Enumerates the folder every time: a new rule file applies without editing this skill.'
---

# Company Rules

The rules in `rules/` are this company's opinions about AL, one article per rule, each with a
`.good.al` and a `.bad.al` sample. They are **mandatory**.

They come **on top of BCQuality**, not instead of it. BCQuality is the general layer
(Microsoft + community best practice) and still applies in full; the company rules add what
your shop decided on top. Where the two disagree, the company rule wins.

This skill returns rules, not answers: after reading them, **you** apply each one to the code
at hand.

## When to use

- Before writing AL (the `al-coder` and `al-sdd` agents), before designing (`al-spec`).
- Reviewing AL (`al-reviewer`), and `/done` line D7.

## Procedure

### 1. Enumerate the folder

List `rules/*.md` except `README.md`. **Never work from a remembered or fixed list**: the
folder is the list. An empty folder is fine: report "no company rules" and stop.

### 2. Select what applies

Read each article's frontmatter `keywords` and its `## Description`. A rule applies when the
code at hand contains what it talks about (a tableextension, a page, a Label, a Meth
codeunit, any `.al` file). In doubt, include it: a rule is cheap to check and expensive to
miss.

### 3. Read the selected rules in full

The whole article plus its `.good.al` and `.bad.al`. The samples are the authoritative form.
Normative are `## Best Practice` and `## Anti Pattern`; the `## Description` says how to check.

### 4. Apply

- **Writing code:** follow the `.good.al` pattern as you write; never emit the `.bad.al`
  pattern.
- **Designing:** list each applicable rule in the spec under `## Decisions` as a constraint
  ("D5 - rule tableextension-pte-suffix: field is \"Preferred Carrier PTE\"").
- **Checking:** run the check from the rule's Description on every changed `.al` file.

### 5. Report (checking)

```
Company rules (rules/, 5 found, 4 applicable)
  PASS  tableextension-pte-suffix          app/src/DIRCustomer.TableExt.al:5 "Preferred Carrier PTE"
  FAIL  label-naming                       app/src/DIRCustomerCheckCarrierMeth.Codeunit.al:22
        CarrierLabel passed to Error() -> rename to NoPreferredCarrierErr
  PASS  single-object-per-file             6 files, 1 object each
  PASS  page-no-local-procedures           app/src/DIRCustomerCard.PageExt.al: no local procedure
  N/A   meth-codeunit-single-public-procedure   no Meth codeunit in the change
```

Every line has evidence (`file:line`) or, for N/A, the reason. A FAIL on a company rule blocks
done.

## Never

- Never add a rule to this skill. A rule is a file in `rules/`.
- Never soften a rule because general guidance says otherwise: the company rule wins.

## Related

- `rules/README.md` - how to write a rule.
- `definition-of-done` - D7 runs step 5 of this skill.
- `al-knowledge` - general guidance, which these rules override.