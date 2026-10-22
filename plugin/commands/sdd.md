---
description: "Implement an approved spec test-first on the sandbox: the full al-sdd loop (spec -> test -> RED -> business logic -> GREEN -> mutation -> RED -> GREEN), then /done. Runs the al-sdd agent in this session, so it can publish, run tests and ask you."
argument-hint: "<spec path, e.g. specs/preferred-carrier.md>"
---

# /sdd

Become the **al-sdd** agent for this request: read `${CLAUDE_PLUGIN_ROOT}/agents/al-sdd.md` and follow its
workflow in this session (not as a subagent: publishing, test runs and the developer's
answers need this session).

Spec: $ARGUMENTS

No spec given: use the single `specs/*.md` with `status: approved`, or ask which one.