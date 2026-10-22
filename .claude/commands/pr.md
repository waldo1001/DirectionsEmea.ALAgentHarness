---
description: "Write the pull request description from the spec and the /done report, and open the PR on request. Example wiring: GitHub (gh). Replace it with whatever your shop uses."
argument-hint: "[spec path] [target branch, default main]"
---

# /pr

This command is the example of "your tooling". It talks to GitHub through `gh`. Yours may
talk to Azure DevOps, GitLab, Jira or a ticket system: keep steps 1-3, swap step 4.

## 1. Done first (gate)

Run the `definition-of-done` skill. **NOT DONE: stop**, print the report, and name who fixes
what. No PR description for an unfinished change, and no "open it anyway".

## 2. Collect

- The spec (argument, or the `specs/*.md` among the changed files): context, decisions,
  acceptance criteria, `## Reserved IDs`.
- The change: `git diff --stat <base>` and `git log --oneline <base>..HEAD`, base
  `git merge-base HEAD <target>`.
- The task references an issue: link it. Otherwise leave the line out.

## 3. Write the description

```
# <Feature title from the spec>

## Why
<the spec's Context, two to four sentences>

## What changed
- <Type ID "Name"> - <one line>   (every object from Reserved IDs)

## Decisions
- <the spec's decisions, one line each>

## Acceptance criteria
- AC1 <text> - covered by <test name>

## Definition of Done
<the /done report, verbatim>

Spec: specs/<feature>.md
```

Facts only: no invented test results, no claims the DoD report does not back. Show the
description to the developer.

## 4. Open the PR (only when asked)

Opening a PR is outward-facing: do it only when the developer says so in this turn.

```bash
git push -u origin HEAD
gh pr create --base <target> --title "<feature title>" --body-file <temp file with the description>
```

`gh` missing or not logged in: say so (`gh auth login`) and hand over the description to
paste. Never approve, merge or bypass a branch protection: review is someone else's job.
