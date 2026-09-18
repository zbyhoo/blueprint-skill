# blueprint-skill

Two [Agent Skills](https://agentskills.io/specification) that turn an idea
into a written implementation blueprint and then execute that blueprint
task by task. They work the same way in **Claude Code** and **Codex CLI**.

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

The blueprint skill only runs when you ask for it explicitly; it never starts on its own for ordinary coding tasks.

Just ask, in either tool:

> "Blueprint this feature: add a `--verbose` flag to the CLI."

The `blueprint` skill asks clarifying questions one at a time, pushes back
on weak approaches instead of agreeing by default, and presents 2-3
trade-off options with a recommendation before writing anything to disk.
Once you approve the design, it writes the blueprint to `docs/blueprints/`.

> "Execute the blueprint at docs/blueprints/2026-01-15-verbose-flag.md"

The `execute-blueprint` skill reviews the blueprint, then works through it
task by task, running each step's verification command before moving on,
and stops to ask if something doesn't check out.

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
and `install.sh` is syntactically valid; `claude plugin validate` and
shellcheck run when those tools are on PATH.

### Versioning and releases

The version lives in four fields: `.claude-plugin/plugin.json` `.version`,
`.claude-plugin/marketplace.json` `.metadata.version` and
`.plugins[0].version`, and `.codex-plugin/plugin.json` `.version`. Any
commit that changes files under `skills/` or a plugin manifest bumps the
patch version in all four fields in that same commit (main is the release
channel for both marketplaces, and plugin installs are cached by version,
so an unbumped change never reaches plugin users). Bigger or
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

Run it from the repo root:

```bash
claude plugin eval . --runs 1 --no-publish
```

Every run spends Claude quota: each case is a full Claude Code session, the
LLM graders call a judge model (haiku by default; `--judge-model` changes
it), and by default each case also runs a second time without the plugin as
a baseline, where the "skill was used" checks are reported but not scored.
Add `--ablation none` to skip the baseline (half the cost), or
`--case <glob>` / `--tag <tag>` to run a subset. The first run in a
directory asks you to confirm that you trust the plugin; answer it yourself
rather than scripting `--trust-plugin`. Results and the HTML report go to
`evals/results/`, which is git-ignored.

## License

MIT. See `LICENSE`, which includes the superpowers copyright notice.
