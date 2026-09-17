---
name: execute-blueprint
description: Use when you have a written blueprint (e.g. one produced by the blueprint skill, at docs/blueprints/*.md) to execute task by task with verification checkpoints. Use when the user says "execute the blueprint", "implement this blueprint", or points at a saved blueprint file.
---

# Execute Blueprint: Run a Saved Blueprint Task by Task

Load a written blueprint, review it critically, then execute it one task
at a time with verification at each step. Respond in the user's language,
but follow the blueprint's content (typically English) as written.

## Step 1: Load and Review

1. Read the blueprint file in full.
2. Review it critically before starting: does the task order make sense?
   Are file paths, dependencies, and verification commands concrete rather
   than vague? Is anything a placeholder ("TBD", "add appropriate
   handling") instead of real content?
3. If you find real gaps or contradictions, raise them with the user
   before starting rather than guessing your way through - a blueprint
   that needs 30 seconds of clarification now saves far more time than
   discovering the gap mid-task.
4. If the blueprint is workable, track the tasks (as a todo list,
   checkboxes in the blueprint file, or whatever tracking your
   environment supports) and proceed.

## Step 2: Execute Tasks in Order

For each task:
1. Mark it as in progress in whatever tracking you're using.
2. Follow its steps exactly, in order. Each step is small by design -
   don't batch several steps together or skip ahead.
3. Run every verification command the blueprint specifies and check the
   actual result against the expected one stated in the blueprint. A step
   is not done until its verification passes.
4. Mark the task complete only after its own verification checkmark
   passes, then move to the next task.

## When to Stop and Ask

Stop immediately, rather than improvising, when:
- A verification fails and retrying the same step doesn't fix it.
- A step's instructions are ambiguous or contradict what you find in the
  actual code.
- The blueprint has a gap that blocks the current task (missing file,
  missing dependency, undefined function it assumes exists).

Report exactly what you tried and what happened, then ask for direction.
Don't guess past a blocker and don't silently change the blueprint's
approach.

## When to Go Back

Return to Step 1 (re-review) if the user changes the blueprint
mid-execution or if a blocker reveals that the overall approach - not just
one task - needs to change. Don't patch around a wrong approach task by
task.

## After All Tasks Are Done

Summarize what was built, which verifications passed, and anything the
blueprint called out as a follow-up or out of scope. If your environment
has a standard way to finish a branch (running the full test suite,
opening a review, etc.), use it now; otherwise tell the user the blueprint
is complete and let them decide next steps.
