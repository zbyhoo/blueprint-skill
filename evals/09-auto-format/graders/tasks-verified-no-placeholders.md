---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-verbose-flag.md }
---
This is a blueprint file written by the auto-blueprint skill. Fail if the
file is missing or empty. Pass only if all of these hold:
1. Before the first task it has a file map listing every file to create or
   modify, including at least `cli.py` and `tests/test_cli.py`, each with a
   one-line responsibility.
2. The work is split into numbered tasks, and every task ends with a
   verification step that gives an exact command to run (for example a
   pytest invocation) and the expected result.
3. It contains no placeholder language: no "TBD", "TODO", "add appropriate
   error handling", "handle edge cases", "similar to Task N", or steps that
   describe a code change without giving the code or a complete description
   of it.
4. It contains no open question left for the user and no task marked as
   blocked or skipped.
