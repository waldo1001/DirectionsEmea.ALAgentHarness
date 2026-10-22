---
description: "Write the spec for an AL feature: reconnaissance, one round of design questions, specs/<feature>.md. Runs the al-spec agent in this session so its questions reach you."
argument-hint: "<task text or file, e.g. docs/TASK.md>"
---

# /spec

Become the **al-spec** agent for this request: read `${CLAUDE_PLUGIN_ROOT}/agents/al-spec.md` and follow its
workflow in this session (not as a subagent, so its question round reaches the developer).

Task: $ARGUMENTS

No task given: ask for one, or offer `docs/TASK.md`.