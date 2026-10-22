# specs/

One spec per feature. The spec is the contract between the person who wants the feature and
the agent that builds it, and it travels with the PR.

## Lifecycle

| status | Set by | Means |
|--------|--------|-------|
| `draft` | the `al-spec` agent | written, not yet agreed |
| `approved` | the developer (never an agent on its own) | agreed: this is what gets built |
| `implemented` | the `al-coder` agent, after a green build | code matches the spec; `/done` checks it |

## Rules

- File name: the feature in kebab-case, `specs/preferred-carrier.md`. Start from
  `TEMPLATE.md`.
- Objects are named by type and name. IDs are `<Ninja>` until the implementing agent fills
  `## Reserved IDs`.
- `depends-on:` lists the specs that must be implemented first. Specs without a dependency
  between them can be built in parallel, each on its own branch.
- Acceptance criteria and tests map one-to-one: one test per criterion, one criterion per
  test.
- A spec with open questions stays `draft`.
- Write one with `/spec <task or file>`. The spec writer adds it to the index below.

## Index

Every spec in this folder, one row each. Kept in sync by the `al-spec` agent; the status here
follows the spec's frontmatter.

| Spec | Title | Status | Depends on |
|------|-------|--------|------------|
| [preferred-carrier.md](preferred-carrier.md) | Preferred Carrier | implemented | - |
