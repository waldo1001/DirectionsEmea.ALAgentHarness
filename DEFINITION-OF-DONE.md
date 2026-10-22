# Definition of Done

A change is done when every line below is green. Every line has a check a machine can run, so
"done" is a fact you can show, not a feeling. `/done` runs all of them and answers with one
word: **done** or **not done**.

| # | Done means | Proven by |
|---|------------|-----------|
| D1 | Both apps build with zero errors. | `al_build` + `al_getdiagnostics` on `app/` then `test/` (or `al compile`) |
| D2 | Every new object and field ID was reserved with Ninja. | IDs declared in the changed `.al` files = the spec's `## Reserved IDs`, each inside its app's `idRanges`, none declared twice |
| D3 | No hardcoded user-facing text. | no `Error(`, `Message(` or `Confirm(` with a literal (also via `StrSubstNo`) in the changed `.al` files |
| D4 | Nothing changed outside `app/`, `test/` and the feature's spec (plus its row in the `specs/README.md` index). | `git diff --name-only <base>` + untracked files |
| D5 | The spec exists, is `implemented` and has no open questions. | the spec's frontmatter and `## Open questions` |
| D6 | New business logic has tests, one per acceptance criterion. | a changed `Subtype = Test` codeunit in `test/` that contains every test named in the spec's `## Tests` |

## What this proves, and what it does not (yet)

Be honest about what "done" means here:

| | Proven by |
|---|---|
| It **compiles**, app and tests, with zero errors | D1 |
| IDs, UI text, scope, spec and the existence of tests are **checked** | D2-D6 |
| A reviewer **read** it | the `al-reviewer` agent, after `/done` |
| **Not proven yet: the tests ran and passed** | nothing. D6 proves the tests exist and compile. No line here publishes them to a sandbox or runs them, so a test that would fail still passes this DoD. |

`/done` prints that last line on every run, so nobody mistakes "compiles" for "works".

`<base>` is where the work started: `git merge-base HEAD main` unless you say otherwise.

Not on this list, on purpose: style preferences. Those are review findings (the `al-reviewer`
agent), not a gate. Add a line here only when you can name the check that proves it.
