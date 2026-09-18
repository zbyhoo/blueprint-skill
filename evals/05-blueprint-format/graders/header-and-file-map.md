---
type: llm
focus: trace
---
Grade the blueprint file the assistant wrote under docs/blueprints/ (the
content of its Write tool call, or the final content if it was built up with
several edits). Fail if no such file was written.
Pass only if all of these hold:
1. It starts with a `# <Feature Name> Blueprint` title followed by a
   `**Goal:**` line (one sentence) and an `**Approach:**` line.
2. Before the first task it has a file map listing every file to create or
   modify, including at least `cli.py` and `tests/test_cli.py`, each with a
   one-line responsibility.
