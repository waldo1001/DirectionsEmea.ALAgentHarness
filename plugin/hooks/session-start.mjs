#!/usr/bin/env node
// SessionStart hook: a plugin cannot ship an always-on CLAUDE.md / AGENTS.md, so the harness's
// always-on rules travel this way. The project's own AGENTS.md (affix, folders, BC version) still
// applies on top. Plain stdout from a SessionStart hook becomes session context.
const root = process.env.CLAUDE_PLUGIN_ROOT || '';
console.log(`AL agent harness (plugin) - always-on rules:
- Extend, never modify the base app: tableextension, pageextension, event subscribers.
- Business logic lives in codeunits, not in page triggers.
- Text shown by Error, Message and Confirm is a Label variable, never a literal (a hook blocks literals).
- Object, field and enum-value IDs come from the al-object-id-assignment skill (Ninja). Never invent one.
- Identify AL objects as Type ID "Name": Table 18 "Customer", Codeunit 414 "Release Sales Document".
- Never report done without a green build; "done" is the definition-of-done skill (/done).
- Read the project's AGENTS.md for the affix, the folders and the BC version.
Templates when the project has none: ${root}/templates (spec template, DEFINITION-OF-DONE.md, rules README).`);
