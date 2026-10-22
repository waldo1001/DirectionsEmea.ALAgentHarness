#!/usr/bin/env node
// PreToolUse hook (Write | Edit | MultiEdit | Bash): refuses .al content that passes a literal
// string to Error(, Message( or Confirm( - also through StrSubstNo('...'), and also when the
// content is written through a shell command (heredoc, echo > file.al, tee file.al).
// Instructions are advice. This is law. Exit code 2 blocks the tool call; stderr goes to
// the agent. No dependencies.

let input = '';
process.stdin.on('data', (chunk) => (input += chunk));
process.stdin.on('end', () => {
  let event;
  try {
    event = JSON.parse(input);
  } catch {
    process.exit(0); // not our business: never break the session on bad input
  }

  const toolInput = event.tool_input ?? {};
  const literal = /\b(Error|Message|Confirm)\s*\(\s*(StrSubstNo\s*\(\s*)?'/i;
  let texts = [];

  if (event.tool_name === 'Bash') {
    const cmd = String(toolInput.command ?? '');
    // only shell commands that write into an .al file (.bad.al samples are allowed)
    const writesAl = /(>>?|\btee\b(\s+-a)?)\s*["']?[^\s"'|;&]*(?<!\.bad)\.al\b/i.test(cmd);
    if (!writesAl) process.exit(0);
    texts = [cmd];
  } else {
    const filePath = String(toolInput.file_path ?? '').toLowerCase();
    // .bad.al samples in rules/ show the anti-pattern on purpose.
    if (!filePath.endsWith('.al') || filePath.endsWith('.bad.al')) process.exit(0);
    texts = [toolInput.content, toolInput.new_string, ...(toolInput.edits ?? []).map((e) => e.new_string)];
  }

  for (const text of texts) {
    if (typeof text !== 'string') continue;
    const line = text.split(/\r?\n/).find((l) => literal.test(l) && !l.trim().startsWith('//'));
    if (line) {
      console.error(
        `Blocked: literal text in Error/Message/Confirm ("${line.trim()}"). ` +
          `Declare a Label (e.g. NoPreferredCarrierErr: Label '...') and pass that. See AGENTS.md > Never.`
      );
      process.exit(2);
    }
  }
  process.exit(0);
});
