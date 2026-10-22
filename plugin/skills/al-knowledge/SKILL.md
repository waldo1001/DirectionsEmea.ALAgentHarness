---
name: al-knowledge
description: 'Find sourced Business Central / AL guidance instead of answering from memory. Use when: asked "how should I ..." about AL or BC, choosing a pattern (events, error handling, labels, permissions, performance, upgrade, testing), checking what an object, field, event or procedure is or does in this BC version, finding the base-app event to subscribe to, asking what changed between BC versions, or reviewing AL against best practice. Routes to the BC Observatory plugin, BCQuality or the symbols, and cites the source.'
---

# AL Knowledge

A skill tells you how to do X and is loaded only when X comes up. An MCP server adds context
and tools, and every tool it exposes costs context on every turn whether you use it or not.
Keep both lean: this skill decides **which source answers which question**, so BC knowledge
does not have to live in `AGENTS.md`.

## When to use

- A "how should I ..." or "what is the right way to ..." question about AL or BC.
- Before choosing a pattern you are not certain of: events, error handling, labels,
  permissions, performance, upgrade code, tests.
- Checking an object, field, event or procedure in the BC version in `app/app.json`, or what
  the base app actually does there.
- "What changed in ... between BC 28 and 29?"
- A review of AL code against best practice.

## Procedure

### 1. Classify the question, pick the source

| Question | Source | How |
|----------|--------|-----|
| Which object / field / event / procedure, its ID, where it is documented | **BC Observatory** | load the `bc-observatory:bcobs-lookup` skill (`bc_search`, `bc_get_object`) |
| What the base app *actually does*: a procedure body, who calls it, who subscribes, the exact event signature | **BC Observatory + BC Code Atlas** | load the `bc-observatory:bcobs-grounding` skill and follow it (`bc_get_object` for identity, then `bcatlas_resolve_node` / `bcatlas_get_signature` / `bcatlas_get_procedure_body`) |
| What changed between versions, what is new | **BC Observatory** | load the `bc-observatory:bcobs-whats-new` skill (`bc_diff_object`, `bc_whats_new`) |
| Best practice, pattern, anti-pattern ("how should I handle this Error for translation?") | **BCQuality** knowledge | step 2 |
| Review AL code against best practice | **BCQuality** `al-code-review` skill | scoped to the changed files |
| Official behavior: syntax, property, method, platform limits | **Microsoft Learn** (comes with the BC Observatory plugin) | `microsoft_docs_search`, then `microsoft_docs_fetch` |
| Does it exist in *our* symbols, will it compile here | **symbols** | `al_symbolsearch` (AL MCP server) |

Load the skill named in the row with the Skill tool before you call its tools: it knows the
right tool order. BC Code Atlas answers from BC 28 unless you pass a version: resolve the
version in `app/app.json` (`bcatlas_resolve_version`, `bcatlas_list_warm_versions`) and pass its
`commit_sha`; say which version an answer comes from. An event publisher is declared
`[IntegrationEvent(...)] local procedure`: when a signature shows no attribute, read the
declaration with `bcatlas_get_object_source` instead of guessing. Two sources apply? Use both: BCQuality for the pattern, BC Observatory / Atlas / symbols for
the facts. Never take an ID or a signature from memory or from Learn prose.

### 2. Read BCQuality

Locate the installed plugin: the folder that contains `plugin.json`, `knowledge-index.json` and
`microsoft/knowledge/` (an installed plugin lives under `~/.claude/plugins/`; one loaded for this
session is listed as an additional working directory).

1. Search `knowledge-index.json`, or the frontmatter `keywords` and the titles in `microsoft/knowledge/**` and
   `community/knowledge/**` for the concern (for example `label`, `error`, `translation`).
2. Read every matching article **in full**, plus its sibling `.good.al` / `.bad.al`.
3. Apply only the `## Best Practice` and `## Anti Pattern` sections as guidance.

Company rules are not here: they live in `rules/` and win over BCQuality when the two disagree.

### 3. Answer with the source

```
Answer: <the guidance, applied to the user's code or question>
Sources:
  - bc-observatory: codeunit/414 "Release Sales Document" (official)
  - bc-code-atlas (w1-28): Release Sales Document.OnBeforeReleaseSalesDoc - signature
  - bcquality microsoft/knowledge/error-handling/<article>.md (+ .good.al)
Not found: <what you searched and did not find, if anything>
```

## Missing source

- **BC Observatory plugin not loaded:** say so and give the install:
  `claude plugin marketplace add waldo1001/waldo.BCObservatory`, then
  `claude plugin install bc-observatory@bc-observatory`. Fall back to the symbols and label the
  answer "base-app body not checked".
- **BCQuality not installed:** say so (`/plugin marketplace add microsoft/BCQuality`, then
  `/plugin install bcquality@bcquality`) and label the answer "not checked against BCQuality".

Never present memory as a sourced answer.

## Running it cheap

A simple lookup ("which event fires before a sales document is released?", "what is the
Label pattern for an error with a placeholder?") does not need the expensive model or the
main conversation's context. Hand it to the `al-lookup` agent: it runs on a cheaper model
(haiku), in its own context, and returns only the answer and its sources. Pass it the
developer's question as asked: never your own answer, never a list of what to find.

## Related

- `al-lookup` agent - runs this skill on a cheaper model for simple questions.
- BC Observatory plugin skills: `bcobs-lookup`, `bcobs-grounding`, `bcobs-whats-new`, `bcobs-localization`.
- `al-build-validation` - the compiler is the final judge of whether the guidance compiled.
- `company-rules` - your own rules, which override general guidance.