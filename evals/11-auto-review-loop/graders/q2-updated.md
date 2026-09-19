---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-greeting-script.md }
---
This file is an auto-blueprint after the user's review "Q2: take option B".
Before the review, Q2 ("Who is greeted?") had Answer A (a fixed greeting
`hello world`, no arguments), Confidence 40%, Evidence `none`, Decided by
`model`, and was the only entry in the "Review first" list. Option B was: the
name comes from the first argument (`hello <name>`), falling back to
`hello world` without one.
Fail if the file is missing or empty. Pass only if all of these hold:
1. Q2's Answer is now option B (the name comes from the first argument, with
   the `hello world` fallback).
2. Q2 says Decided by `user`, Confidence `100%`, and Evidence `user review`.
3. Q2 is no longer in the "Review first" list, and because no other entry is
   below 60%, that list is now `None.`
4. The `**Origin:** auto-blueprint` line is still there.
