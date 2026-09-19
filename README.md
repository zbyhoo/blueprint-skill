# blueprint-skill

Three [Agent Skills](https://agentskills.io/specification) that turn an idea
into a written implementation blueprint - through an interview, or
unattended with every assumption written down - and then execute that
blueprint task by task. They work the same way in **Claude Code** and
**Codex CLI**.

> **Based on [superpowers](https://github.com/obra/superpowers) v6.3.0**
> (commit `b36e082`, 2026-08-12) by Jesse Vincent (obra). The planning
> mechanics here are extracted and adapted from its `brainstorming`,
> `writing-plans`, and `executing-plans` skills, used under the MIT
> License. Everything else in superpowers (TDD workflow, code review, git
> worktrees, subagent-driven development, ...) is intentionally left out:
> this repo is only the planning loop, made harness-agnostic so it also
> runs outside Claude Code. See `LICENSE`, which carries both copyright
> notices.

- `skills/blueprint` — a critical, question-by-question interview to
  understand what you're building, followed by a bite-sized, verifiable
  blueprint saved to `docs/blueprints/YYYY-MM-DD-<feature>.md`.
- `skills/auto-blueprint` — the same blueprint without the interview: it
  asks the user nothing, answers the interview questions itself, and
  records every assumed answer (options, reasoning, evidence, confidence)
  in the blueprint file for review. Made for autonomous agents and for a
  quick first draft.
- `skills/execute-blueprint` — loads a saved blueprint, reviews it
  critically, then executes it task by task with a verification checkpoint
  after every step.

Why "blueprint" and not "plan"? The name `plan` collides with Claude Code's
built-in plan mode and with the `--plan` flags of several coding tools, so
neither an agent nor a human skimming skill names could tell them apart.
"Blueprint" doesn't shadow anything.

## Install

Use either the plugin install or `install.sh`, not both. Using both
registers every skill twice.

### As a plugin (recommended)

The repo is its own single-plugin marketplace for both tools, so no clone is
needed.

Claude Code:

```
/plugin marketplace add zbyhoo/blueprint-skill
/plugin install blueprint-skill@blueprint-skill
```

Codex CLI:

```bash
codex plugin marketplace add zbyhoo/blueprint-skill
codex plugin add blueprint-skill@blueprint-skill
```

Plugin installs copy a snapshot of the skills. To pick up a new version run
`/plugin marketplace update blueprint-skill` (Claude Code) or
`codex plugin marketplace upgrade` (Codex).

Manifests live in `.claude-plugin/` (Claude Code) and `.codex-plugin/` +
`.agents/plugins/` (Codex). `skills/` is the single source of truth; the
manifests don't duplicate skill content.

### From a clone (symlinks, for hacking on the skills)

Requires `bash`. Clone the repo somewhere permanent (the skills are
symlinked from the clone, not copied), then run:

```bash
git clone https://github.com/zbyhoo/blueprint-skill.git
cd blueprint-skill
./install.sh
```

This symlinks each skill under `skills/` into both:
- `~/.claude/skills/<name>` (Claude Code)
- `~/.codex/skills/<name>` (Codex CLI; set `CODEX_HOME` first if your Codex
  config lives elsewhere)

Symlinked skills follow the clone's working tree (`git pull` in the clone
updates them). Plugin installs are cached by version and only update when
the version is bumped.

Re-running `install.sh` is safe: it recognizes its own symlinks and leaves
them alone, and refuses to touch a conflicting file or symlink unless you
pass `--force`.

```bash
./install.sh --dry-run       # preview
./install.sh --force         # overwrite conflicting targets
./install.sh --uninstall     # remove only this repo's symlinks
```

To check the install, start a new session and ask "blueprint this feature:
...". In Codex you can also type `$blueprint` to see the skill in the
autocomplete.

## Usage

The `blueprint` and `auto-blueprint` skills only run when you ask for them explicitly; they never start on their own for ordinary coding tasks.

Just ask, in either tool:

> "Blueprint this feature: add a `--verbose` flag to the CLI."

The `blueprint` skill asks clarifying questions one at a time, pushes back
on weak approaches instead of agreeing by default, and presents 2-3
trade-off options with a recommendation before writing anything to disk.
Once you approve the design, it writes the blueprint to `docs/blueprints/`.

> "Auto-blueprint this feature: add a `--verbose` flag to the CLI."

The `auto-blueprint` skill produces the same kind of blueprint in one pass
without asking you anything, so it also works when nobody is there to
answer (an autonomous agent, a CI job). It interviews itself instead of
you, and the file it saves carries, before the tasks:

- an `**Origin:** auto-blueprint` line, so nobody mistakes it for a
  blueprint that came out of a real interview;
- an "Assumptions" section with one entry per question: the options it
  weighed, the answer it picked, its reasoning, the evidence, a confidence
  percentage, who decided (`model` or `user`), and the tasks the answer
  affects. Confidence is tied to evidence: 90-100% only for something the
  request or the repository states, 60-89% for an inference from
  convention or context, below 60% when nothing supports the answer - in
  which case it picks the smallest, most reversible option. Entries below
  60% are repeated in a "Review first" list at the top of the section;
- an "Objections" section: if the approach you asked for has a real
  weakness, the blueprint still plans what you asked for and records the
  failure mode and the alternative there;
- a short "Design" section (architecture, components and data flow, error
  handling, testing approach).

To review, answer by question number ("Q4: take option B", "Q2 is fine").
The skill updates the entry (`Decided by: user`, 100%), rewrites the tasks
that depended on it, and shrinks the "Review first" list.

> "Execute the blueprint at docs/blueprints/2026-01-15-verbose-flag.md"

The `execute-blueprint` skill reviews the blueprint, then works through it
task by task, running each step's verification command before moving on,
and stops to ask if something doesn't check out. For a blueprint written
by `auto-blueprint` it first lists whatever is still under "Review first",
as a notice, and then carries on.

### Multiple-choice questions

In Claude Code, both skills ask multiple-choice questions (a design
trade-off, or what to do about a blocker) through the built-in
`AskUserQuestion` picker: an option per choice, each with a short label
and a description carrying the trade-off, the recommended option listed
first. In Codex and other harnesses without that picker, the same
question falls back to plain text (the options listed in the message,
with a stated recommendation), so the interview behaves the same either
way, just rendered differently. Open-ended questions (no fixed set of
options) are always plain text, in both tools.

## Configuration

- **Blueprint location:** defaults to
  `docs/blueprints/YYYY-MM-DD-<feature>.md`. Tell the assistant a different
  path earlier in the conversation (e.g. "save blueprints to `specs/`")
  and it will use that instead. This is a convention in the skill's
  instructions, not a config file.
- **Language:** skill instructions are written in English for portability,
  but both skills tell the assistant to respond in the user's own language.

## Development

### Checks

Run `./scripts/check.sh` before every commit. It checks that plugin JSON
parses, the four version fields agree and look like X.Y.Z, plugin names
are `blueprint-skill`, each `skills/*/SKILL.md` has valid frontmatter,
the blueprint-writing rules shared by `blueprint` and `auto-blueprint`
are identical, and `install.sh` is syntactically valid; `claude plugin
validate` and shellcheck run when those tools are on PATH.

`skills/auto-blueprint/SKILL.md` repeats the blueprint-writing rules of
`skills/blueprint/SKILL.md` (from `**File map before tasks:**` up to
`**Self-review before saving.**`), because each skill has to work on its
own. Change that block in both files at once; `check.sh` fails when they
differ.

### Versioning and releases

The version lives in four fields: `.claude-plugin/plugin.json` `.version`,
`.claude-plugin/marketplace.json` `.metadata.version` and
`.plugins[0].version`, and `.codex-plugin/plugin.json` `.version`. Any
commit that changes files under `skills/` or a plugin manifest bumps the
patch version in all four fields in that same commit (main is the release
channel for both marketplaces, and plugin installs are cached by version,
so an unbumped change never reaches plugin users). A commit that adds a
skill or another new feature bumps the minor version instead. Bigger or
behaviour-changing releases also get a git tag created with
`claude plugin tag` (format `blueprint-skill--vX.Y.Z`). `check.sh`
enforces that the four fields agree.

### Evals

`evals/` holds a small behavioural suite for Claude Code's
`claude plugin eval`, one directory per case (`prompt.md` plus
`graders/*.md`). It is run manually, not in CI. The cases check that:

- "Blueprint this feature: ..." loads the `blueprint` skill, the first reply
  asks exactly one question, and no files are written.
- An ordinary coding request ("add a --verbose flag to cli.py") does not load
  the skill.
- A design trade-off is asked as a multiple-choice question with the
  recommended option first (through the `AskUserQuestion` picker or the
  plain-text fallback).
- No implementation code or scaffolding is written before a blueprint is
  approved, even when the user says to start coding.
- When the design is already agreed, the blueprint is saved as
  `docs/blueprints/YYYY-MM-DD-<name>.md` with the Goal/Approach header, a
  file map, tasks that each end in a verification command, and no
  placeholder language.
- `execute-blueprint` stops and asks when a step's verification fails,
  instead of improvising a fix.
- "Auto-blueprint this feature: ..." loads the `auto-blueprint` skill and
  not `blueprint`, asks nothing, and saves a blueprint under
  `docs/blueprints/`; a plain-language request for a blueprint "without
  questions" does the same, and "Blueprint this feature: ..." never loads
  `auto-blueprint`.
- An auto-blueprint has the Origin line, complete assumption entries for
  all mandatory topics, confidence that matches the evidence, a "Review
  first" list, and the Objections and Design sections.
- A request whose approach has a real weakness is planned as asked, with
  the objection recorded.
- A review ("Q2: take option B") updates that entry, rewrites the affected
  task, and leaves the rest alone.
- `execute-blueprint` lists an auto-blueprint's "Review first" assumptions
  before it starts and is not blocked by them.

Run it from the repo root:

```bash
claude plugin eval . --allow-tools Write Edit "Bash(bash:*)" --runs 1 --no-publish
```

`--allow-tools` is required: eval runs remove `Write`, `Edit` and `Bash`
unless the operator grants them, and listing them in a case's
`allowed_tools` is not enough. Most cases save a blueprint or run a
verification command. Granted Bash commands run inside Claude Code's OS
sandbox, which on Linux needs `bubblewrap` and `socat`. Keep the target
(`.`) before `--allow-tools`.

Every run spends Claude quota: each case is a full Claude Code session, the
LLM graders call a judge model (haiku by default; `--judge-model` changes
it), and by default each case also runs a second time without the plugin as
a baseline, where the "skill was used" checks are reported but not scored.
Add `--ablation none` to skip the baseline (half the cost), or
`--case <glob>` / `--tag <tag>` to run a subset (the new cases are tagged
`auto-blueprint`). The first run in a
directory asks you to confirm that you trust the plugin; answer it yourself
rather than scripting `--trust-plugin`. Results and the HTML report go to
`evals/results/`, which is git-ignored.

## License

MIT. See `LICENSE`, which includes the superpowers copyright notice.
