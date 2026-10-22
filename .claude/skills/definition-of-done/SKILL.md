---
name: definition-of-done
description: 'Check a change against DEFINITION-OF-DONE.md mechanically: every line gets a command or tool call as evidence, then one word, done or not done. Use when: /done, "is it done?", "can I open a PR?", before handing work to review, after the al-coder agent finishes. Read-only: reports, never fixes.'
---

# Definition of Done

Run every line of `DEFINITION-OF-DONE.md` and show the evidence. A line without evidence is
red. You report; you do not fix (fixing is the `al-coder` agent's job or the developer's).

## When to use

- `/done`, "is it done?", "ready for a PR?".
- After the `al-coder` agent hands off, and again after every fix.

## Procedure

### 0. Scope

- `BASE` = the base the user gives, else `git merge-base HEAD main`.
- Changed files = `git diff --name-only $BASE` plus `git ls-files --others --exclude-standard`.
- The spec = the path the user gives, else the `specs/*.md` among the changed files. None or
  several: D5 is red and says so.
- Changed AL = changed files ending in `.al`, excluding `*.good.al` / `*.bad.al`.

### 1. D1 - build green

Follow `al-build-validation` on `app/` then `test/`. Green = zero errors in both. Paste its
report line.

### 2. D2 - every new ID reserved

1. New declarations in changed AL: object lines
   `^\s*(table|tableextension|page|pageextension|codeunit|report|reportextension|enum|enumextension|query|xmlport|permissionset|permissionsetextension)\s+(\d+)`
   and field lines `^\s*field\((\d+);` that are added since `BASE`
   (`git diff $BASE -- <file>` for tracked files, the whole file for untracked ones).
2. Each (type, ID) must be a row in the spec's `## Reserved IDs`.
3. Each ID must fall inside the `idRanges` of the `app.json` of the app it lives in.
4. No (type, ID) may be declared twice in the same app:
   `grep -rniE "^\s*<type>\s+<id>\b" <app>/`.

Evidence: a table with ID, type, file, reserved yes/no, in range yes/no.

### 3. D3 - no literal UI text

```bash
grep -niE "\b(Error|Message|Confirm)\s*\(\s*(StrSubstNo\s*\(\s*)?'" <changed AL files>
```

Zero hits = green. Every hit is listed as `file:line`.

### 4. D4 - nothing outside the scope

Every changed file must start with `app/` or `test/`, or be the spec itself, or
`specs/README.md` (the spec index). List every other path. (Build output and `.alpackages/` are git-ignored and never show up.)

### 5. D5 - the spec

The spec file exists, its frontmatter has `status: implemented`, `## Open questions` is empty
(or "none"), and `## Reserved IDs` has rows when D2 found new declarations.

### 6. D6 - tests

Only when changed AL in `app/` declares a codeunit, or adds a procedure or event subscriber to
one. Then: a changed file in `test/` with `Subtype = Test` and `[Test]` methods, and every test
name from the spec's `## Tests` table appears as a procedure there. Not applicable = green,
with the reason.

### 7. D7 - company rules

Follow the `company-rules` skill in checking mode on the changed AL. Every rule file in
`rules/` gets its own line: PASS, FAIL or N/A. Any FAIL makes D7 red. A rule added a minute
ago shows up here without any other change.

### 8. Report

```
Definition of Done - specs/<feature>.md   base <short sha>   files <n>
  [x] D1 build green          app 0 errors / test 0 errors (al_build)
  [x] D2 IDs reserved         5 of 5 in Reserved IDs, all in range, no duplicates
  [ ] D3 no literal UI text   app/src/DIRCarrierCheck.Codeunit.al:14  Error('No carrier')
  [x] D4 scope                9 files, all under app/ test/ specs/preferred-carrier.md
  [x] D5 spec                 implemented, 0 open questions
  [x] D6 tests                DIRCarrierTests.Codeunit.al: 3 of 3 spec tests present
  [x] D7 company rules        5 rules: 4 PASS, 1 N/A
         PASS tableextension-pte-suffix   DIRCustomer.TableExt.al:5
         ...
  [-] not proven yet          tests ran and passed (no line in this DoD runs them)
Verdict: NOT DONE (1 red: D3)
```

Every line carries its evidence. The verdict is one word, **DONE** or **NOT DONE**, and lists
the red lines. Nothing is "mostly done". Always print the `not proven yet` line from
`DEFINITION-OF-DONE.md`: DONE means compiled and checked, not that the tests ran.

## Never

- Never mark a line green without having run its check in this session.
- Never fix while checking. Report, then the developer decides who fixes.

## Related

- `al-build-validation` - D1.
- `al-object-id-assignment` - fills the `## Reserved IDs` table D2 compares against.
- `company-rules` - D7.
- `al-reviewer` agent - the judgment calls this checklist deliberately leaves out.
