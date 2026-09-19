---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-verbose-flag.md }
---
This is a blueprint file written by the auto-blueprint skill. Fail if the
file is missing or empty. Pass only if all of these hold:
1. "Assumptions" contains numbered question entries (`### Q1: ...`,
   `### Q2: ...`, and so on), at least six of them.
2. Every entry has all of these fields: Topic, Options, Answer, Reasoning,
   Evidence, Confidence (a percentage), Decided by, Affects.
3. Every entry lists at least two options, each with a cost or a risk, and
   its Answer names one of those options.
4. Every entry says it was decided by `model`.
5. Across the entries, each of these topics appears at least once: purpose,
   scope, constraints, success criteria, error handling, testing.
