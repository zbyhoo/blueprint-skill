---
type: llm
focus: { source: file, path: docs/blueprints/2026-01-15-greeting-script.md }
---
This file is an auto-blueprint after the user's review "Q2: take option B"
(the name comes from the first argument, falling back to `hello world`).
Before the review, Task 1 created `greet.sh` printing a fixed `hello world`
and verified that `bash greet.sh` prints `hello world`. Task 2 created
`scripts/lint.sh`, which runs `bash -n greet.sh` and prints `lint ok`.
Entries Q1, Q3, Q4, Q5 and Q6 were all decided by `model`.
Fail if the file is missing or empty. Pass only if all of these hold:
1. Task 1's `greet.sh` now greets the name given as the first argument and
   falls back to `hello world` without one, and the task gives the full
   script content, not a description such as "add argument handling".
2. Task 1's verification covers both cases: a run with a name argument with
   its expected `hello <name>` output, and a run without arguments expecting
   `hello world`.
3. Task 2 is unchanged in substance: it still creates `scripts/lint.sh`
   running `bash -n greet.sh` and expects `lint ok`.
4. Q1, Q3, Q4, Q5 and Q6 still say they were decided by `model` and keep
   their answers.
