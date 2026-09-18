---
tags: [blueprint, format]
runs: 1
max_turns: 20
timeout_seconds: 420
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

We've already agreed on the design, so skip the interview and write the
blueprint now. Don't implement anything.

Feature name: verbose-flag. The code is not in this workspace; write the
blueprint from this description.

Approved design:
- The project is a single-file Python 3 CLI, `cli.py`, using argparse, with
  the entry point `main(argv=None) -> int`.
- Add `-v/--verbose`. When it is set, configure the standard `logging` module
  at DEBUG level, otherwise at WARNING. Right after parsing, log one debug
  line: `parsed args: <namespace>`.
- Tests use pytest, in `tests/test_cli.py`: one test that `main(["--verbose"])`
  returns 0 and emits the debug line (via caplog), and one that without the
  flag no debug line is emitted.
- No other behaviour changes.
