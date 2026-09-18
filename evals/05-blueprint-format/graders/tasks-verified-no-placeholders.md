---
type: llm
focus: trace
---
Grade the blueprint file the assistant wrote under docs/blueprints/ (the
content of its Write tool call, or the final content if it was built up with
several edits). Fail if no such file was written.
Pass only if all of these hold:
1. The work is split into numbered tasks, and every task ends with a
   verification step that gives an exact command to run (for example a
   pytest invocation) and the expected result.
2. It contains no placeholder language: no "TBD", "TODO", "add appropriate
   error handling", "handle edge cases", "similar to Task N", or steps that
   describe a code change without giving the code or a complete description
   of it.
