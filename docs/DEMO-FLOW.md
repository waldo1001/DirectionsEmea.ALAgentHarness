# Demo flow - "Stop Inventing Your Own Way .. Let's Build the AL Agent Harness Together"

Directions EMEA 2026, Paris. Speakers: waldo and AJ, alternating per step (table below).
Slot: 105 minutes.

## The one-liner

We take an empty AL repo, give an agent a real task, and watch what a strong model does
without a harness: decent code, and nothing that checks it - its own object IDs with nothing
reserved, design decisions nobody asked for, no build, tests that never ran. Then we build the
harness, one commit at a time, in three parts: **what every BC dev needs** (no opinions),
**the process** (spec, code, done), and **make it yours** (your company rules, your tooling,
your plugin). Then we run the same task again. Same prompt, same model, different result.
Attendees clone `main` - or install the plugin.

This is NOT an iFacto workshop. Parts A and B contain nothing iFacto-specific. Part C shows
iFacto's layer only as an example of what "your own" looks like, and ends with "now delete
ours and write yours".

## Format

- Linear git history on `main`. Every step is ONE commit. Every commit also gets a branch
  `step-NN-<name>` (and a tag) pointing at it, so on stage we `./demo.sh goto 04` and VS Code
  shows exactly the state after that step. Nothing else changes.
- A tiny `demo.sh next|prev|goto NN|reset|list` script does the checkout so nobody types
  branch names on stage.
- Every step has the same rhythm: **why** (the pain, 30s) -> **what** (the file(s) the commit
  adds, show the diff) -> **prove it** (one quick interaction or the effect on the agent) ->
  next.
- Every step has a **pre-recorded replay** (chat-replayer HTML, next to the deck in
  `recordings/`, linked from the slide): the agent's narration says *why* it picks an instruction,
  skill, agent or ID, and what happens inside subagents is shown nested under the hand-off.
  We run live if the clock allows; the replays are the safety net and do not depend on wifi.
- Open with the disclaimer (this is what works for us, not The Truth) and the promise
  (clone it, use it Monday).

## The sample app and the task

Sample app: `app/` - a tiny PTE "Directions Demo" (affix `DIR`, idRanges 50100-50149) with one
existing table + page so there is "existing code" to respect. `test/` - an empty test app
(80100-80149) so the test story is possible. Both compile against current BC symbols. No customer
code. The publisher is "iFacto Business Solutions NV" only because AL Object ID Ninja reserves
IDs per publisher under a subscription; say so once on stage, it is not an iFacto opinion.

The task (same prompt both runs, saved as `docs/TASK.md`):

> Add a "Preferred Carrier" (Code[20]) field on Customer, show it on the Customer Card
> in the Shipping group, and block releasing a Sales Order when the customer has no
> Preferred Carrier. Include a test.

Why this task: it forces a tableextension, a pageextension, an event subscriber on release
(do not touch the base app), an Error (translatable text), a codeunit, 4-5 new IDs, several
files, and a test. Small enough to read on a slide, big enough to go wrong.

## Step overview

| Part | Step | Branch / tag | Speaker | Adds | Min |
|------|------|--------------|---------|------|-----|
| - | intro | - | both | disclaimer, what is a harness, Claude vs Copilot | 10 |
| A | 00 | `step-00-intro` | waldo | sample app, empty test app, no harness | 4 |
| A | run | `run-00-without-harness` | waldo | the task with no harness | 6 |
| A | 01 | `step-01-instructions` | AJ | AGENTS.md + CLAUDE.md, Never-list, deny list, hook | 6 |
| A | 02a | `step-02a-objectid-regex` | waldo | a skill with a regex "ID oracle" script - the joke | 3 |
| A | 02b | `step-02b-objectid-al-tool` | waldo | the same skill on the AL extension's `al_getnextobjectid` | 3 |
| A | 03 | `step-03-objectid-mcp` | AJ | Object ID Ninja MCP, same skill now reserves | 5 |
| A | 04 | `step-04-agents-build-validation` | waldo | first agent + build validation skill (loop engineering) | 6 |
| A | 05 | `step-05-knowledge` | AJ | BC Observatory plugin (Observatory, Code Atlas, Learn), BCQuality, cheap lookup agent | 7 |
| - | interlude | - | to divide | same repo in Copilot, `docs/PORTING.md` | 3 |
| B | 06 | `step-06-specs` | waldo | `/spec` + interactive spec writer, template, index | 8 |
| B | 07 | `step-07-coding` | AJ | `al-coder` agent (subagent, no command) | 5 |
| B | 08 | `step-08-dod` | waldo | DoD, `/done`, `al-reviewer` | 7 |
| C | 09 | `step-09-company-rules` | AJ | `rules/` + company-rules skill | 6 |
| C | 10 | `step-10-sdd` | waldo | SDD agent: spec -> test -> RED -> business logic -> GREEN -> mutation -> RED -> GREEN; DoD with tests run, `/pr`, chat export | 9 |
| C | 11 | `step-11-plugin` | to divide | the whole harness as a Claude Code plugin | 6 |
| C | run | `run-99-with-harness` | to divide | the task with the harness + compare with run 00 | 5 |
| - | close | `main` | both | clone it or install the plugin, make it yours, Q&A | 6 |
| | | | | | **105** |

The SDD loop, written out the same way everywhere in this repo:
**spec -> test -> RED (the test fails) -> business logic -> GREEN (the test passes) ->
mutation (break the logic on purpose) -> RED (the test catches it) -> GREEN (revert, the
test passes again).**

## Part A - What every BC dev needs (generic, zero opinions)

### Step 00 - `step-00-intro` : the empty repo (waldo, 4 min)
Sample app + test app, `.vscode/launch.json`, `.gitignore`, `README.md` with the promise,
`demo.sh`, `docs/`. No agent files at all. "This is where everybody starts. Every. Single.
Time."

### Run 00 - `run-00-without-harness` (waldo, 6 min, live or branch)
Give the agent the task text and nothing else. What it really does (replay
`run-00-without-harness`): it reads `app.json`, takes the first number of the range as object ID
and says so - nothing reserved -, decides the design on its own (sell-to customer, orders only), writes the release event from memory without checking the
symbols, never compiles (no compiler without a harness) and never runs the tests. It does use a
Label. Do not oversell the mess: modern models write reasonable code. The gap is that nothing
proves it.
Point: the model is fine. It just had no idea what we consider done.

### Step 01 - `step-01-instructions` : the always-on file and its guardrails (AJ, 6 min)
`AGENTS.md`, plus a thin `CLAUDE.md` that only contains `@AGENTS.md`. Recent GitHub Copilot
versions load `AGENTS.md` by default; `CLAUDE.md` stays for Claude Code. One file, both
tools. Deliberately short: what this repo is, where the apps live, the affix comes from
`app/AppSourceCop.json`, IDs are never picked by hand, the base app is extended never
modified, always identify AL objects as `Type ID "Name"`, and a `## Never` section: never
invent an ID, never hardcode user-facing text, never edit outside `app/` and `test/`, never
rewrite git history, never report done without a green build.
Then enforcement where the tool allows it: a permission deny list in
`.claude/settings.json` (`git push --force`, `git reset --hard`, `rm -rf`, ...) and a
PreToolUse hook that refuses to write a `.al` file with a literal in `Error(`, `Message(`
or `Confirm(` - also when the content goes into a `.al` file through the shell (heredoc,
`echo >`, `tee`). Instructions are advice. Hooks are law. Know which is which.
Prove it: "what affix do we use, and may I change Codeunit 414?" -> correct answers. Then
ask it to hardcode an Error -> blocked by the hook.

### Step 02a - `step-02a-objectid-regex` : a skill, and a joke (waldo, 3 min)
What a skill is - a folder with a `SKILL.md` that the agent loads only when the task needs it -
shown with the simplest possible object ID skill: `.claude/skills/al-object-id-assignment/`
with `scripts/next-id.sh`, the "Next-Free-Object-ID Oracle(TM)": parses `idRanges` out of
`app.json` with a regex, scans every `.al` file with perl and returns max+1. Enterprise grade.
Zero dependencies. The skill itself says what is wrong with it: this disk, this branch, nothing
reserved, regex parsing. Better than a guess, not a reservation. The joke is the point: a skill
can carry a script, and a script is only as good as what it can see.
Prove it: "create a table" -> the skill loads, runs the script, the ID comes from the script.

### Step 02b - `step-02b-objectid-al-tool` : the same skill on a real tool (waldo, 3 min)
The same skill, now on `al_getnextobjectid`, built into the AL extension (Copilot calls it
directly; Claude Code reaches it through the AL CLI's MCP server, `al launchmcpserver`,
registered in `.mcp.json`). Fields of a new table are 1, 2, 3; only tableextension fields need
an ID from the range. Still the same limitation, said out loud by the skill: the tool only sees
**your local repo** and reserves nothing. Two developers on two branches get the same "next
free" ID. That is the setup for step 03.
Prove it: same prompt -> the ID comes from a visible tool call, and the answer says
"local repo only, not reserved".

### Step 03 - `step-03-objectid-mcp` : Object ID Ninja via MCP (AJ, 5 min)
The AL Object ID Ninja MCP server in `.mcp.json`, and the step 02 skill rewritten to use it:
reserve, check, write, release what you do not use, hard stop when Ninja is not there (no
fallback to `idRanges`, no "safe-looking number"). `al_getnextobjectid` goes on the deny
list: it is not wrong, it is just not a reservation.
Point on stage: **an MCP is a data source; the skill describes how to use it.** Same skill
file, different source, and the team-wide collision is gone.
Prove it: "create a table" -> the ID comes from a visible Ninja tool call.

### Step 04 - `step-04-agents-build-validation` : the first agent, and done means it compiles (waldo, 6 min)
`.claude/skills/al-build-validation/SKILL.md`: build -> diagnostics -> **fix** -> rebuild
until zero errors, with a fixed report. Not "it compiles in theory", and not just a compile:
the skill fixes what the diagnostics say. Said explicitly in the skill: this does **not**
run tests; a green build proves the code compiles, not that it works (that is step 10).
The first agent: `.claude/agents/al-build-fixer.md`, a subagent that runs that loop in its
own context and returns only the short report, so the main conversation does not fill up
with diagnostics. Message: a skill is how, an agent is who (and with which context).
Prove it: break a semicolon, ask "does it build?" -> the subagent fixes it and reports.

### Step 05 - `step-05-knowledge` : BC knowledge on demand (AJ, 7 min)
Where BC knowledge comes from without stuffing it in the always-on file. The **BC Observatory
plugin** (`waldo1001/waldo.BCObservatory`) brings three MCP servers - bc-observatory (facts:
objects, IDs, fields, events, versions, what changed, localizations, Learn pages), bc-code-atlas
(the real base-app source: procedure bodies, who calls what, exact event signatures) and
Microsoft Learn - plus its own skills (`bcobs-lookup`, `bcobs-grounding`, `bcobs-whats-new`,
`bcobs-localization`). Enabled for the repo in `.claude/settings.json`
(`extraKnownMarketplaces` + `enabledPlugins`). BCQuality stays the source for patterns and
reviews. `.claude/skills/al-knowledge/SKILL.md` routes each question to the right source;
`.claude/agents/al-lookup.md` answers simple questions on a cheaper model (Haiku), so the main
conversation keeps a short context.
Message: a plugin is a package of skills + MCP servers; a skill is how, an MCP is a data source.
Mind the token cost (the DevOps MCP example: 43 tools, 3 used).
Prove it (three replays): **05a grounding** - "which parameters does OnBeforeReleaseSalesDoc get and
where is it raised in Codeunit 414?" -> al-lookup -> al-knowledge -> bcobs-grounding -> bc-code-atlas
returns the real signature and body; **05b what changed** - "what changed in Codeunit 80
"Sales-Post" between BC 28 and 29?" -> bcobs-whats-new -> one `diff_object` call (the
alternative: download two symbol packages and diff a codeunit of thousands of lines); **05c a
cheap lookup** - "how should I handle the text of an Error so it can be translated?" -> al-lookup
on Haiku -> BCQuality articles + Learn. Show 05a and 05b in full; 05c only its hand-off and answer.

### Interlude - same harness, other tool (4 min)
The same repo is opened in VS Code with Copilot: AGENTS.md is read as-is, the skills folder
is picked up, the agents and `.mcp.json` need their Copilot twin (`docs/PORTING.md`,
`.github/agents`, `.vscode/mcp.json`), hooks have no equivalent. Tip: monthly
subscriptions, so you can switch.

## Part B - The process (opinionated workflow, still partner-neutral)

### Step 06 - `step-06-specs` : spec first (waldo, 8 min)
`specs/` folder with `specs/README.md` (lifecycle + an index of every spec) and
`specs/TEMPLATE.md` with frontmatter (`status: draft | approved | implemented`,
`depends-on:`), sections: context, acceptance criteria, objects by type + name with
`<Ninja>` as ID, tests, open questions. **Every acceptance criterion maps to exactly one
test, and every test to exactly one acceptance criterion.**
`.claude/agents/al-spec.md`, started with `/spec`: the spec writer is interactive and
user-facing, so it runs **in your session, not as a subagent**. It reads the task, does
reconnaissance, asks the 3-4 questions that change the design in ONE round, writes the spec,
never writes AL, never writes an ID.
Point: the spec is the contract and lives in the PR. Independent specs build in parallel.
Live: `/spec docs/TASK.md`. The ROOM answers the agent's questions (hands up per option).
Show `specs/preferred-carrier.md`: their decisions, in the contract.

### Step 07 - `step-07-coding` : code from the spec (AJ, 5 min)
`.claude/agents/al-coder.md`. No command: it is picked up automatically on "implement the
spec" and runs as a **subagent**. It finds the approved spec, applies BCQuality explicitly
while coding (the `al-knowledge` skill, best practice + anti-pattern per concern), reserves
IDs, implements, runs the build loop, flips the spec to `implemented`, hands off.
Live: "implement specs/preferred-carrier.md", let it run in the background while we do
step 08.

### Step 08 - `step-08-dod` : a definition of done a machine can check (waldo, 7 min)
`DEFINITION-OF-DONE.md` (for humans) + `.claude/skills/definition-of-done/SKILL.md` +
`/done` that checks every line mechanically: build green, every new ID matches a Ninja
reservation, no literal in `Error(`, nothing changed outside `app/` and `test/`, spec
exists and is `implemented`, a test exists per acceptance criterion. Output: checklist with
evidence per line, one word: DONE / NOT DONE.
Honest about what is proven at this step: it **compiles** and it is **reviewed**. That the
tests **run and pass** is not proven yet: the DoD says so in a "Not proven yet" line. Step 10
closes that gap.
`.claude/agents/al-reviewer.md` on top: read-only, findings first, applies BCQuality
explicitly (the `al-code-review` skill), every finding names a rule or says `opinion`,
severity blocking / should-fix / nit.
Live: `/done` on the coder's result: a checklist with evidence and the honest "tests ran: not
proven yet" line. Then "review my changes": the reviewer finds what `/done` cannot (patterns,
BCQuality, test preconditions).

## Part C - Make it yours (this is where the partner stuff lives, and only here)

### Step 09 - `step-09-company-rules` : your company rules as a layer (AJ, 7 min)
`rules/` folder: one article per company rule, each with `.good.al` / `.bad.al` samples,
and `.claude/skills/company-rules/SKILL.md` that enumerates the folder, reads what applies
in full, applies it as a constraint and reports PASS/FAIL per rule. Company rules come
**on top of BCQuality**: BCQuality is the general layer, your rules win where they disagree.
The spec writer, `al-coder` and `al-reviewer` all reference the skill; the DoD gains a line.
We seed it with a handful of iFacto rules **as an example**: Meth codeunit with one public
procedure, tableextension `PTE` suffix, no local procedures on pages, Label naming
`<Context>Err/Msg/Qst`, single object per file. Say it out loud: these are OUR opinions.
Yours will be different. The point is the mechanism: a markdown file in a folder changes
what the agent writes, no prompt surgery.
Prove it: ask the room for a rule THEY enforce. Write `rules/<their-rule>.md` live with a
.good/.bad sample -> re-run `/done` -> the new check appears.

### Step 10 - `step-10-sdd` : spec-driven development, tests that actually run (waldo, 10 min)
`.claude/agents/al-sdd.md`, a session agent (`claude --agent al-sdd`), with the full loop:
**spec -> test -> RED (the test fails) -> business logic -> GREEN (the test passes) ->
mutation (break the logic on purpose) -> RED (the test catches it) -> GREEN (revert, the
test passes again).** Tests actually run: in VS Code (Copilot) through the built-in
`runTests` tool on the AL extension's Test Explorer; in Claude Code through `al_run_tests`
from the AL CLI's MCP server, fallback `al runtests`.
The DoD changes: "done" now includes **tests ran and passed** on the sandbox, so the
"Not proven yet" line of step 08 becomes a real check.
Shown: `/pr` writes a standardised PR description from the spec and the `/done` report and
opens it with the GitHub CLI (no DevOps MCP needed; ours talks to Azure DevOps + Jira, yours
talks to whatever), and a `chat-export` skill so your devlead sees which skills never
triggered. All on `main`, all optional, all replaceable.
Message: the harness is the place where your shop's process becomes executable.
Replay: `/al-sdd` on the approved spec against a real BC 29 sandbox: the loop runs, tests go RED
and GREEN for real. Without a sandbox in `.vscode/launch.json` the agent stops at its gate and
refuses to fake GREEN - that is the fallback story.

### Step 11 - `step-11-plugin` : the harness as a plugin (to divide, 6 min)
Everything we built, packaged like BC Observatory: `plugin/` with `.claude-plugin/plugin.json`,
`skills/`, `agents/`, `commands/`, `hooks/` (the guardrail + a SessionStart hook that injects
the always-on rules, because a plugin cannot ship an AGENTS.md) and `.mcp.json` (Ninja, the AL
MCP server), plus `.claude-plugin/marketplace.json` at the repo root. What stays in the project:
`AGENTS.md` (affix, folders, BC version), `rules/`, `specs/` and your own
`DEFINITION-OF-DONE.md` - the skills read them when present, the plugin's templates otherwise.
Install: `claude plugin marketplace add waldo1001/DirectionsEmea.ALAgentHarness`, then
`claude plugin install al-agent-harness@al-agent-harness`. Versioning: bump `plugin.json` and
`marketplace.json` together.
Message: a harness in a repo helps one repo; a harness in a plugin helps every repo - and every
developer, the same day you change it.
Prove it: an empty AL repo with only the plugin loaded -> "create a table" -> the plugin's skill
and Ninja do the work.

### Run 99 - `run-99-with-harness` (7 min)
Same task text, same main model (the al-coder subagent runs on the cheaper model). Side by side
with run 00: questions asked, IDs reserved, a
build, company rules, an honest `/done` verdict. Mark which wins came from Part A (everyone gets these), Part B, and Part C (yours
differ).

### Close (9 min)
Clone `main`, or install the plugin. Change the affix. Empty `rules/` and write your own. Delete what you do not
believe in. Tool switch is mechanical: AGENTS.md, `rules/`, `specs/` and skills are shared
markdown; only agents/commands, MCP config and hooks are tool-specific (`docs/PORTING.md`).

## Timing (105 min slot)

| Block | Speaker | Min | Running |
|-------|---------|-----|---------|
| Intro, disclaimer, what is a harness, Claude vs Copilot | both | 10 | 10 |
| Step 00 + run 00 | waldo | 10 | 20 |
| Step 01 instructions + guardrails | AJ | 6 | 26 |
| Step 02a a skill, and a joke | waldo | 3 | 29 |
| Step 02b the same skill on the AL tool | waldo | 3 | 32 |
| Step 03 object ID Ninja MCP | AJ | 5 | 37 |
| Step 04 first agent + build validation (loop engineering) | waldo | 6 | 43 |
| Step 05 BC knowledge: the BC Observatory plugin | AJ | 7 | 50 |
| Interlude: same repo in Copilot | to divide | 3 | 53 |
| Step 06 specs with the room | waldo | 8 | 61 |
| Step 07 coder in the background | AJ | 5 | 66 |
| Step 08 DoD live | waldo | 7 | 73 |
| Step 09 company rules with the room | AJ | 6 | 79 |
| Step 10 SDD (spec -> test -> RED -> business logic -> GREEN -> mutation -> RED -> GREEN) + /pr and chat export | waldo | 9 | 88 |
| Step 11 the harness as a plugin | to divide | 6 | 94 |
| Run 99 + compare with run 00 | to divide | 5 | 99 |
| Close: clone it or install it, make it yours, Q&A | both | 6 | 105 |

Buffers: run 00 and run 99 are replays anyway (saves ~5 each when live is skipped); the SDD live run
can become "show the SDD loop report" (saves 5). That is 15 minutes of slack hidden in the plan
without dropping a step. If we are ahead: a second task in run 99 (a report, or a Meth
codeunit refactor) to show the harness is not tuned to one prompt.

## Open points

1. **Who presents** the interlude, step 11 and run 99.
2. **A sandbox** for step 10 and run 99: a BC 29 sandbox where table 50100 is free, so the SDD
   loop and `/done` D8 can run for real; until then those replays stop at the sandbox gate.
3. **Repo visibility** - private until the session, public on `main` when we say "clone it";
   the plugin install only works once the repo is public.
