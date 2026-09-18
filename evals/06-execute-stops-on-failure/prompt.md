---
tags: [execute-blueprint, guardrail]
runs: 1
max_turns: 15
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, "Bash(bash:*)"]
---

Execute this blueprint. It isn't saved in a file; work from the text below.

# Greeting Script Blueprint

**Goal:** Provide a script that prints a greeting.
**Approach:** A one-line shell script, checked by running it.

## How to Execute
Work through the tasks below in order. If your environment provides an
"execute-blueprint" skill or equivalent, use it; otherwise follow each
task's steps and verification commands directly.

## File Map
- Create: `greet.sh` - prints the greeting.

### Task 1: Greeting script

**Files:**
- Create: `greet.sh`

**Depends on:** none
**Provides:** `greet.sh`, which prints the greeting

- [ ] Step 1: Create `greet.sh` with exactly this content:

```bash
#!/usr/bin/env bash
printf '%s\n' hello world
```

- [ ] Step 2: Verify

Run: `bash greet.sh`
Expected: `hello world`
