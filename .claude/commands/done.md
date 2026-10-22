---
description: "Check the current change against DEFINITION-OF-DONE.md: evidence per line, then one word - DONE or NOT DONE. Read-only."
argument-hint: "[spec path] [base ref]"
---

# /done

Follow the **`definition-of-done`** skill for the current change.

- Arguments (optional): the spec path and/or the base ref. Defaults: the spec among the
  changed files, base `git merge-base HEAD main`.
- Print the report in the skill's format, evidence on every line, and the one-word verdict.
- Do not fix anything. When something is red, end with one line: who fixes it (the
  `al-coder` agent for code, the developer for the spec) and that `/done` runs again after.
