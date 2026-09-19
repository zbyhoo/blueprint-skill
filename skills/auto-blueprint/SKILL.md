---
name: auto-blueprint
description: Produces a written, step-by-step blueprint saved under docs/blueprints/ without asking the user anything - it runs the blueprint interview against itself, answers every question on its own, and records each assumed answer (options, reasoning, evidence, confidence) in the file for later review. Use only when the user, or the operator brief of an autonomous agent, explicitly asks for an "auto-blueprint", an "automatic blueprint", or a blueprint made "without asking me questions" / "decide yourself", or names the auto-blueprint skill directly; also use it when the user corrects or confirms the assumptions of an existing auto-blueprint. A plain "blueprint this feature" belongs to the blueprint skill, not this one - never start this on your own initiative for an ordinary coding task, even a multi-step one.
---

# Auto-Blueprint: A Blueprint From a Self-Answered Interview

Turn an idea into a concrete, reviewable blueprint in one unattended pass.
This is the blueprint interview run against yourself: you raise the
questions a careful interviewer would ask, answer each one yourself, and
record every answer as an assumption a person can review later. It has to
work the same whether or not anyone is available to reply, so it never
depends on a reply. Respond in the user's language throughout, but keep
any saved blueprint file in English so it stays portable across tools and
teammates.

**Never ask the user anything during a run.** Do not call
`AskUserQuestion` or any other interactive picker, do not pose a question
in your message text, and do not end your final message with a question.
Whenever you notice you want to ask something, turn it into an entry
under "Assumptions" instead. The only exception is "When the User
Reviews" below, where a person is present by definition.

Do not write implementation code or scaffold a project. The only file
this skill writes is the blueprint; executing it is a separate request.

## Phase 1: Interview Yourself

**Gather evidence first.** Read the request closely, then explore the
codebase: existing files, docs, and recent history for the area you're
changing. These two are your only sources of evidence. Follow established
patterns; call out places where existing code has problems that affect
this work, but don't plan unrelated cleanup.

**Assess scope.** If the request bundles multiple independent pieces
(e.g. "build chat, billing, and analytics"), split it the way a careful
interviewer would and write one complete blueprint file per independent
piece. In each of those files the split itself is assumption Q1, and
your final message gives the order in which to execute the files.

**Raise real questions only.** Questions are about purpose, constraints,
and success criteria - decisions a person would have had to make.
Anything you can settle by reading the code is not a question: state it
as a fact in the "Design" section, with the path you read it from.

**Cover the mandatory topics.** Record at least one question for each of:
purpose, scope boundaries (what is explicitly NOT included), constraints,
success criteria, error handling, and testing approach. Then add every
task-specific question a real interview would need. There is no target
number: don't pad with filler questions, and don't drop a real one to
stay short.

**Answer each question from real options.** For every question write 2-3
real options with honest trade-offs (what each costs, what each risks),
not a single option dressed up as a menu. Then pick one, in this order
of precedence:
1. What the request says, literally.
2. What the repository shows (an existing pattern, dependency, or
   convention).
3. What convention or context makes most likely.
4. When none of these settles it: the option with the smallest scope
   that is easiest to undo. Say in the reasoning that this rule decided
   it.

**Rate confidence by evidence, not by feel.** Every answer carries a
confidence percentage and an evidence line, and the band is tied to the
evidence:
- 90-100%: the answer is stated in the request or is a fact in the
  repository. The evidence line quotes the request or names the path.
- 60-89%: the answer is inferred from a convention or from context. The
  evidence line names that convention or context.
- Below 60%: nothing supports the answer. The evidence line is `none`,
  and precedence rule 4 chose the answer.

Never write 90% or more when the evidence is inferred or `none`, and
never write 60% or more when the evidence is `none`.

**Always finish.** A question you cannot answer responsibly still gets an
answer - the smallest, most reversible one - with a confidence below
60%. Never leave an open question, never skip the tasks that depend on
it, and never stop without a blueprint. If the request is too vague to
plan well, plan the smallest reasonable reading of it, rate the purpose
question below 60%, and say under "Objections" that the request is
underspecified.

**Be critical, not agreeable.** Evaluate the requested approach on its
merits. If it has a real weakness - a missing edge case, a scaling
problem, a simpler alternative - record it under "Objections": the
concrete failure mode, then the alternative, in one or two sentences.
Then plan what was asked anyway. The user's words are the strongest
evidence you have, and silently building something else while nobody is
watching is the worse failure. Don't soften a real objection into a
compliment, and don't invent one to fill the section.

**Settle the design.** Once the questions are answered, decide the design
the tasks will follow: architecture, components and data flow, error
handling, testing approach. Scale each part to its complexity - a couple
of sentences when it's straightforward, more when it's subtle. Design
for isolation: prefer smaller units with one clear purpose and a
well-defined interface over large units that do many things.

## Phase 2: Write the Blueprint

Write the blueprint assuming its executor has zero context on this
codebase and average judgment: it must be possible to follow the
blueprint without having seen your reasoning in Phase 1.

**Save location:** `docs/blueprints/YYYY-MM-DD-<feature-name>.md`, using
today's date and a short kebab-case feature name. If the user names a
different location, use that instead. Never overwrite an existing file:
if the path is taken, append `-2`, `-3`, and so on to the feature name.
If the file cannot be written at all, put the complete blueprint in your
final message and say plainly that it was not saved.

**Blueprint layout** - every auto-blueprint has these parts, in this
order:

````markdown
# <Feature Name> Blueprint

**Goal:** <one sentence>
**Approach:** <2-3 sentences on the overall strategy>
**Constraints:** <project-wide requirements that apply to every step below - versions, naming rules, platforms, etc.; omit if none>
**Origin:** auto-blueprint - the interview answers below were assumed by the model, not given by a person. Review "Assumptions" before relying on this blueprint.

## How to Execute
Work through the tasks below in order. If your environment provides an
"execute-blueprint" skill or equivalent, use it; otherwise follow each
task's steps and verification commands directly.

## Assumptions

**Review first (confidence below 60%):**
- Q<n> (<number>%) - <the answer in a few words> - affects Tasks <numbers>

### Q1: <the question>
- **Topic:** <purpose | scope | constraints | success criteria | error handling | testing | other>
- **Options:**
  - A: <option> - <what it costs or risks>
  - B: <option> - <what it costs or risks>
- **Answer:** <letter> - <the chosen option in a few words>
- **Reasoning:** <why this option, and which precedence rule decided it>
- **Evidence:** <quote from the request | path in the repository | the convention or context relied on | none>
- **Confidence:** <number>%
- **Decided by:** model
- **Affects:** Tasks <numbers> (or "none")

## Objections
<each objection: the concrete failure mode, then the alternative; or "None.">

## Design
### Architecture
### Components and data flow
### Error handling
### Testing approach

## File Map
<every file to create or modify, with its one-line responsibility>

## Tasks
### Task 1: <name>
````

"Review first" lists every entry whose confidence is below 60%, in
question order, each with the tasks it affects, and nothing else. When
there is no such entry, the list is the single line `None.`

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

**Self-review before saving.** Check the blueprint against Phase 1:
- Does every answer show up in a task or in "Design", and does every
  "Affects" line name the tasks that really depend on that answer?
- Is every entry below 60% listed under "Review first" with its tasks,
  and nothing else?
- Does every confidence sit in the band its evidence line allows?
- Are all six mandatory topics covered?
- Search for placeholder language and fix it. Check that names,
  signatures, and types used in later tasks match what earlier tasks
  defined.

Fix issues inline; no need for a second pass.

**When you're done:** tell the user, without asking anything: where each
blueprint was saved (and in which order to execute them, if there are
several); how many assumptions were recorded and how many are under
"Review first"; that they can correct or confirm any assumption by its
number (for example "Q4: take option B") and you will update the
blueprint; and that execution can proceed with the execute-blueprint
skill (if their environment has it) or by following the blueprint's
tasks directly.

## When the User Reviews

When the user later corrects or confirms assumptions in an existing
auto-blueprint, update that same file - this is the one case where an
existing blueprint is edited in place:
1. For each assumption the user addressed, update **Answer** and
   **Reasoning**, and set **Decided by:** to `user`, **Confidence:** to
   `100%`, and **Evidence:** to `user review`. If the user picks
   something that was not among the options, add it as a new option
   first.
2. Rewrite every task named in that entry's **Affects** line so it
   matches the new answer, and update "Design" and "File Map" if they
   change. The Phase 2 writing rules still apply: full content, no
   placeholders.
3. Remove the entry from "Review first"; when the list becomes empty,
   write `None.`
4. If the user approves everything at once, apply step 1 to every entry
   still decided by the model, keeping its answer, and empty "Review
   first".
5. Leave entries the user did not mention untouched.
6. Repeat the self-review, save, and tell the user which entries and
   tasks changed.

A person is present here, so if a correction is ambiguous or names a
question number that does not exist, say so and ask before changing
anything - one question at a time.
