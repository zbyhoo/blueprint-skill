# blueprint-skill

Two [Agent Skills](https://agentskills.io/specification) for turning an idea
into a written implementation blueprint, and then executing that blueprint
task-by-task — working the same way in **Claude Code** and **Codex CLI**.

- `skills/blueprint` — a critical, question-by-question interview to
  understand what you're building, followed by a bite-sized, verifiable
  blueprint saved to `docs/blueprints/YYYY-MM-DD-<feature>.md`.
- `skills/execute-blueprint` — loads a saved blueprint, reviews it
  critically, then executes it task by task with a verification checkpoint
  after every step.

## Why not "plan"?

The skill (and this repo) used to be named `plan`. That collided with two
things it needs to coexist with: Claude Code's own plan mode, and the
`--plan` flags several coding tools already use for their own planning
step. An agent (or a human skimming skill names) can't tell "plan" the
skill apart from "plan" the built-in mode by name alone, so it renamed
itself out of the collision entirely. "Blueprint" doesn't shadow anything.

## Where this comes from

The planning mechanics are extracted and adapted from the `brainstorming`,
`writing-plans`, and `executing-plans` skills of the
[superpowers](https://github.com/obra/superpowers) plugin by Jesse Vincent
(obra), MIT licensed. Everything else in superpowers (TDD workflow, code
review, git worktree management, subagent-driven development, etc.) is
intentionally left out — this repo is just the planning loop, made
harness-agnostic so it works outside Claude Code too. See `LICENSE` for the
full attribution and license text.

## Install

Requires `bash`. Clone this repo somewhere permanent (the skills are
symlinked from where you clone it, not copied), then run:

```bash
git clone git@github.com:zbyhoo/blueprint-skill.git ~/projects/blueprint-skill
cd ~/projects/blueprint-skill
./install.sh
```

This creates a symlink for each skill under `skills/` into both:
- `~/.claude/skills/<name>` (Claude Code)
- `~/.codex/skills/<name>` (Codex CLI — `~/.agents/skills/<name>` also works
  as a cross-runtime alias if your Codex setup uses that instead; symlink it
  there yourself if so)

Set `CODEX_HOME` before running if your Codex config lives somewhere other
than `~/.codex`.

Re-running `install.sh` is safe (idempotent) — it recognizes its own
existing symlinks and leaves them alone. It will refuse to touch a
conflicting file or symlink unless you pass `--force`. Use `--dry-run` to
preview changes, and `--uninstall` to remove only the symlinks this script
created (never a conflicting file it declined to touch).

```bash
./install.sh --dry-run       # preview
./install.sh --force         # overwrite conflicting targets
./install.sh --uninstall     # remove this repo's symlinks
```

### As a Claude Code plugin

`.claude-plugin/plugin.json` lets you install this repo as a Claude Code
plugin instead (`/plugin marketplace add <this-repo-url>` /
local-path add, then `/plugin install blueprint-skill`). `skills/` remains
the single source of truth either way — the plugin manifest doesn't
duplicate skill content.

## Usage

Just ask, in either tool:

> "Blueprint this feature: add a `--verbose` flag to the CLI."

The `blueprint` skill will ask clarifying questions one at a time, push
back on weak approaches instead of agreeing by default, and present 2-3
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
question falls back to plain text — the options listed in the message,
with a stated recommendation — so the interview behaves the same either
way, just rendered differently. Open-ended questions (no fixed set of
options) are always plain text, in both tools.

## Verifying the Codex install manually

`codex exec` (non-interactive) does not expose a way to force-load a skill
from a test harness — the `$<skill>` invocation syntax only works in the
interactive TUI, and pointing a temporary `CODEX_HOME`'s `config.toml` at
`skills/blueprint/SKILL.md` via `[[skills.config]]` did not make a plain
one-shot `codex exec` prompt pick it up (skill discovery/search appears to
be an interactive-session behavior). To verify the Codex side yourself:

1. Run `./install.sh` so `~/.codex/skills/blueprint` and
   `~/.codex/skills/execute-blueprint` exist.
2. Start an interactive `codex` session in any repo.
3. Type `$blueprint` to open the skill autocomplete and confirm
   `blueprint` (and separately `execute-blueprint`) appear and load.
4. Send a prompt like "blueprint this feature: add a --verbose flag", and
   confirm Codex asks a clarifying question instead of jumping straight to
   a blueprint.

## Configuration

- **Blueprint location:** defaults to
  `docs/blueprints/YYYY-MM-DD-<feature>.md`. Tell the assistant a different
  path earlier in the conversation (e.g. "save blueprints to `specs/`")
  and it will use that instead — this is a convention in the skill's
  instructions, not a config file.
- **Language:** skill instructions are written in English for portability,
  but both skills tell the assistant to respond in the user's own language.
