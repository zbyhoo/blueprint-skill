---
tags: [auto-blueprint, execute-blueprint, notice]
runs: 1
max_turns: 15
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, "Bash(bash:*)"]
---

Execute this blueprint. It isn't saved in a file; work from the text below.

# Greeting Script Blueprint

**Goal:** Provide a script that prints a greeting.
**Approach:** A small Bash script, checked by running it.
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

## Objections
None.

## Design
### Architecture
A single Bash script, `greet.sh`, with no dependencies.
### Components and data flow
`greet.sh` writes one line to stdout and reads no input.
### Error handling
`set -euo pipefail`; a failed write makes the script exit non-zero.
### Testing approach
Task 1 runs the script and compares its output.

## File Map
- Create: `greet.sh` - prints the greeting.

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
