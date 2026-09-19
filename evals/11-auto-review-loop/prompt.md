---
tags: [auto-blueprint, review]
runs: 1
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Below is an auto-blueprint you wrote earlier; it isn't saved in a file yet.
My review of its assumptions: Q2: take option B.
Apply my review and save the updated blueprint as
docs/blueprints/2026-01-15-greeting-script.md. Don't execute anything.

# Greeting Script Blueprint

**Goal:** Provide a script that prints a greeting.
**Approach:** A small Bash script, checked by running it, plus a syntax check script.
**Origin:** auto-blueprint - the interview answers below were assumed by the model, not given by a person. Review "Assumptions" before relying on this blueprint.

## How to Execute
Work through the tasks below in order. If your environment provides an
"execute-blueprint" skill or equivalent, use it; otherwise follow each
task's steps and verification commands directly.

## Assumptions

**Review first (confidence below 60%):**
- Q2 (40%) - fixed greeting `hello world`, no arguments - affects Tasks 1

### Q1: What is the script for?
- **Topic:** purpose
- **Options:**
  - A: A demo script that prints a greeting to stdout - trivial, nothing to maintain
  - B: A reusable greeting library sourced by other scripts - more structure than the request suggests
- **Answer:** A - a demo script that prints to stdout
- **Reasoning:** The request says "a script that prints a greeting"; precedence rule 1.
- **Evidence:** "a script that prints a greeting"
- **Confidence:** 95%
- **Decided by:** model
- **Affects:** Tasks 1

### Q2: Who is greeted?
- **Topic:** scope
- **Options:**
  - A: A fixed greeting, `hello world`, with no arguments - smallest, but cannot greet anyone by name
  - B: The name comes from the first argument, `hello <name>`, falling back to `hello world` without one - slightly more code and one more case to verify
- **Answer:** A - fixed greeting, no arguments
- **Reasoning:** The request does not say; precedence rule 4 (smallest scope, easiest to undo) decided it.
- **Evidence:** none
- **Confidence:** 40%
- **Decided by:** model
- **Affects:** Tasks 1

### Q3: Which shell?
- **Topic:** constraints
- **Options:**
  - A: Bash, run as `bash greet.sh` - available wherever the team works, but not portable to plain POSIX sh
  - B: POSIX sh - portable, but loses `pipefail`
- **Answer:** A - Bash
- **Reasoning:** Shell scripts in small projects are Bash by convention; precedence rule 3.
- **Evidence:** convention: shell scripts default to Bash
- **Confidence:** 70%
- **Decided by:** model
- **Affects:** Tasks 1, 2

### Q4: What counts as done?
- **Topic:** success criteria
- **Options:**
  - A: `bash greet.sh` exits 0 and prints exactly one line to stdout - easy to verify
  - B: The script is also installed on PATH - more than was asked for
- **Answer:** A - exit 0 and one line on stdout
- **Reasoning:** The request only asks for a script that prints; precedence rule 1.
- **Evidence:** "prints a greeting"
- **Confidence:** 90%
- **Decided by:** model
- **Affects:** Tasks 1

### Q5: What happens if writing the greeting fails?
- **Topic:** error handling
- **Options:**
  - A: `set -euo pipefail` and let the script exit non-zero - no custom message
  - B: Trap the error and print a custom message - more code for a one-line script
- **Answer:** A - strict mode, non-zero exit
- **Reasoning:** Strict mode is the usual Bash convention; precedence rule 3.
- **Evidence:** convention: strict mode in Bash scripts
- **Confidence:** 75%
- **Decided by:** model
- **Affects:** Tasks 1, 2

### Q6: How is the script checked?
- **Topic:** testing
- **Options:**
  - A: Run it in the task's verification step, plus a `scripts/lint.sh` that runs `bash -n` - no new dependency
  - B: A bats test suite - adds a dependency for one line of output
- **Answer:** A - verification step plus `scripts/lint.sh`
- **Reasoning:** No test framework is mentioned, so the lightest check fits; precedence rule 3.
- **Evidence:** context: the request mentions no test framework
- **Confidence:** 65%
- **Decided by:** model
- **Affects:** Tasks 1, 2

## Objections
None.

## Design
### Architecture
Two Bash scripts with no dependencies: `greet.sh` and `scripts/lint.sh`.
### Components and data flow
`greet.sh` writes one line to stdout and reads no input. `scripts/lint.sh` syntax-checks `greet.sh`.
### Error handling
Both scripts use `set -euo pipefail`; any failure makes them exit non-zero.
### Testing approach
Task 1 runs `greet.sh` and compares its output; Task 2 runs the syntax check.

## File Map
- Create: `greet.sh` - prints the greeting.
- Create: `scripts/lint.sh` - syntax-checks `greet.sh`.

## Tasks

### Task 1: Greeting script

**Files:**
- Create: `greet.sh`

**Depends on:** none
**Provides:** `greet.sh`, which prints the greeting

- [ ] Step 1: Create `greet.sh` with exactly this content:

```bash
#!/usr/bin/env bash
set -euo pipefail
printf 'hello world\n'
```

- [ ] Step 2: Verify

Run: `bash greet.sh`
Expected: `hello world`

### Task 2: Syntax check script

**Files:**
- Create: `scripts/lint.sh`

**Depends on:** Task 1 (`greet.sh` exists)
**Provides:** `scripts/lint.sh`, which exits non-zero when `greet.sh` has a syntax error

- [ ] Step 1: Create `scripts/lint.sh` with exactly this content:

```bash
#!/usr/bin/env bash
set -euo pipefail
bash -n greet.sh
printf 'lint ok\n'
```

- [ ] Step 2: Verify

Run: `bash scripts/lint.sh`
Expected: `lint ok`
