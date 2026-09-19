---
tags: [auto-blueprint, format]
runs: 1
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Auto-blueprint this feature and save the blueprint as
docs/blueprints/2026-01-15-verbose-flag.md. The code is not in this
workspace; work from this description.

- The project is a single-file Python 3 CLI, `cli.py`, using argparse, with
  the entry point `main(argv=None) -> int`.
- Add `-v/--verbose`. When it is set, configure the standard `logging` module
  at DEBUG level, otherwise at WARNING.
- Tests use pytest, in `tests/test_cli.py`.
