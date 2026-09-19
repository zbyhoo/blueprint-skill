---
name: blueprint
description: Runs a critical question-by-question interview to pin down intent and constraints, then produces a written, step-by-step blueprint saved under docs/blueprints/. Use only when the user explicitly asks to "blueprint this feature", "draw up a blueprint", "spec out" something, or names the blueprint skill directly - never start this on your own initiative for an ordinary coding task, even a multi-step one. A request to produce the blueprint without questions by making the decisions yourself (an "auto-blueprint", an "automatic blueprint", "don't ask me, decide yourself") belongs to the auto-blueprint skill, not this one; a request to skip the interview because the design is already agreed still belongs here.
---

# Blueprint: Brainstorm Into a Written Implementation Blueprint

Turn an idea into a concrete, reviewable blueprint through two phases in
the same conversation: first understand and design, then write the
blueprint. Respond in the user's language throughout, but keep any saved
blueprint file in English so it stays portable across tools and teammates.

Do not write implementation code or scaffold a project until Phase 2 has
produced a saved blueprint the user has approved (or asked you to proceed
on).

## Phase 1: Understand and Design

**Assess scope first.** If the request bundles multiple independent pieces
(e.g. "build chat, billing, and analytics"), say so immediately and help
split it into separate blueprints - one per independent piece - before
going deeper on any one of them.

**Ask one question at a time.** Prefer multiple-choice when it fits, but
open questions are fine. Never bundle two questions in one message; if a
topic needs more digging, split it across turns. Focus questions on
purpose, constraints, and success criteria - not on details you could
infer by reading the code.

**How to ask a multiple-choice question.** If your environment provides an
`AskUserQuestion` tool (or an equivalent interactive picker), use it for
every multiple-choice question in this phase instead of typing the choices
into your message:
- Write each option's `label` as a short name and put the reasoning,
  trade-offs, or consequences in its `description` - don't duplicate that
  detail in the surrounding message.
- Order options with the one you recommend first, and mark it in its label
  or description (e.g. "(recommended)") when you have a real
  recommendation per the "Be critical, not agreeable" rule below. Don't
  fabricate a recommendation just to fill this slot - it's fine to leave
  options unranked when you're genuinely neutral.
- Still only ask one question per tool call; don't stack unrelated
  questions into one multi-select just because the tool allows several.
- Open (non-multiple-choice) questions still go directly in your message
  text, since a picker doesn't fit free-form answers.

If no such tool is available in your environment (e.g. Codex and other
harnesses without an interactive picker), fall back to plain text: list
the options as a short numbered or lettered list in your message, state
which one you recommend and why, and let the user reply in the
conversation. Both paths must ask the same question with the same
options - the fallback is a rendering difference, not a different
interview.

**Be critical, not agreeable.** This is the most important behavior in
this phase:
- Evaluate the user's stated approach on its merits. If it has a real
  weakness - a missing edge case, a scaling problem, a simpler
  alternative - say so plainly and explain the concrete failure mode.
  Don't soften a real objection into a compliment.
- When you propose approaches, present 2-3 real options with honest
  trade-offs (what each costs, what each risks), not a single option
  dressed up as a menu. Lead with the one you recommend and say why.
- If you are unsure whether an approach will work, say that you're unsure
  and propose a cheap way to check, rather than agreeing by default.
- Agreement should follow from the analysis, not from politeness. The
  goal is a blueprint that survives contact with reality, not a
  comfortable conversation.

**Explore the codebase as you go.** Check existing files, docs, and recent
history for the area you're changing. Follow established patterns; call
out places where existing code has problems that affect this work, but
don't propose unrelated cleanup.

**Present the design in sections.** Once you understand what you're
building, walk through it: architecture, components/data flow, error
handling, testing approach. Scale each section to its complexity - a
couple of sentences when it's straightforward, more when it's subtle. Ask
after each section whether it looks right before moving to the next.
Design for isolation: prefer smaller units with one clear purpose and a
well-defined interface over large units that do many things.

Move to Phase 2 once the user has approved the design (explicitly, or by
telling you to proceed).

## Phase 2: Write the Blueprint

Write the blueprint assuming its executor has zero context on this
codebase and average judgment: it must be possible to follow the
blueprint without having sat in on Phase 1.

**Save location:** `docs/blueprints/YYYY-MM-DD-<feature-name>.md`, using
today's date and a short kebab-case feature name. If the user names a
different location earlier in the conversation, use that instead.

**Blueprint header** - every blueprint starts with:

```markdown
# <Feature Name> Blueprint

**Goal:** <one sentence>
**Approach:** <2-3 sentences on the overall strategy>
**Constraints:** <project-wide requirements from Phase 1 that apply to every step below - versions, naming rules, platforms, etc.; omit if none>

## How to Execute
Work through the tasks below in order. If your environment provides an
"execute-blueprint" skill or equivalent, use it; otherwise follow each
task's steps and verification commands directly.
```

**File map before tasks:** list every file to be created or modified and
its one-line responsibility, before breaking work into tasks. This is
where you lock in decomposition - split by responsibility, not by
technical layer, and keep files that change together next to each other.

**Task sizing:** each task is the smallest unit that has its own
verification and is worth an independent go/no-go decision. Fold setup and
config into the task that needs it. A task should be usable on its own
even if a reader only sees that one task and not the ones around it - so
each task states what it depends on from earlier tasks and what later
tasks may rely on it for (exact names/signatures when code is involved).

**Step granularity:** each step is one action, roughly 2-5 minutes of
work - "write this function", "run this command", "commit". Every step
that touches code includes the actual code or an unambiguous, complete
description of the change (never "add appropriate error handling" or
"similar to the earlier step" without repeating the content). Every task
ends with a concrete verification command and the expected result.

Task template:

````markdown
### Task N: <name>

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext` (what changes)

**Depends on:** <earlier task, or "none">
**Provides:** <what later tasks can rely on this task for>

- [ ] Step 1: <action>

```<language>
<full code or exact content>
```

- [ ] Step 2: Verify

Run: `<exact command>`
Expected: `<exact expected output/result>`

- [ ] Step 3: Commit

```bash
git add <files>
git commit -m "<message>"
```
````

**No placeholders, ever.** Never write "TBD", "add validation", "handle
edge cases", "write tests for the above", or "similar to Task N" without
repeating the actual content. A reader working from one task alone must
have everything they need.

**Self-review before saving.** Check the blueprint against the design from
Phase 1: does every requirement map to a task? Search for placeholder
language and fix it. Check that names, signatures, and types used in later
tasks match what earlier tasks defined. Fix issues inline; no need for a
second pass.

**When you're done:** tell the user where the blueprint was saved and that
execution can proceed with the execute-blueprint skill (if their
environment has it) or by following the blueprint's tasks directly.
