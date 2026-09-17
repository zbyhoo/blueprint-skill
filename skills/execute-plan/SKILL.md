---
name: execute-plan
description: Use when you have a written implementation plan (e.g. one produced by the plan skill, at docs/plans/*.md) to execute task by task with verification checkpoints. Use when the user says "execute the plan", "implement this plan", or points at a saved plan file.
---

# Execute Plan: Run a Saved Plan Task by Task

Load a written plan, review it critically, then execute it one task at a
time with verification at each step. Respond in the user's language, but
follow the plan's content (typically English) as written.

## Step 1: Load and Review

1. Read the plan file in full.
2. Review it critically before starting: does the task order make sense?
   Are file paths, dependencies, and verification commands concrete rather
   than vague? Is anything a placeholder ("TBD", "add appropriate
   handling") instead of real content?
3. If you find real gaps or contradictions, raise them with the user
   before starting rather than guessing your way through - a plan that
   needs 30 seconds of clarification now saves far more time than
   discovering the gap mid-task.
4. If the plan is workable, track the tasks (as a todo list, checkboxes in
   the plan file, or whatever tracking your environment supports) and
   proceed.

## Step 2: Execute Tasks in Order

For each task:
1. Mark it as in progress in whatever tracking you're using.
2. Follow its steps exactly, in order. Each step is small by design -
   don't batch several steps together or skip ahead.
3. Run every verification command the plan specifies and check the actual
   result against the expected one stated in the plan. A step is not done
   until its verification passes.
4. Mark the task complete only after its own verification checkmark
   passes, then move to the next task.

## When to Stop and Ask

Stop immediately, rather than improvising, when:
- A verification fails and retrying the same step doesn't fix it.
- A step's instructions are ambiguous or contradict what you find in the
  actual code.
- The plan has a gap that blocks the current task (missing file, missing
  dependency, undefined function it assumes exists).

Report exactly what you tried and what happened, then ask for direction.
Don't guess past a blocker and don't silently change the plan's approach.

## When to Go Back

Return to Step 1 (re-review) if the user changes the plan mid-execution or
if a blocker reveals that the overall approach - not just one task - needs
to change. Don't patch around a wrong approach task by task.

## After All Tasks Are Done

Summarize what was built, which verifications passed, and anything the
plan called out as a follow-up or out of scope. If your environment has a
standard way to finish a branch (running the full test suite, opening a
review, etc.), use it now; otherwise tell the user the plan is complete
and let them decide next steps.
