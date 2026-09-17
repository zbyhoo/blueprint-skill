#!/usr/bin/env bash
# Idempotent installer: symlinks skills/* into the Claude Code and Codex
# skills directories. Safe to re-run. Honors HOME and CODEX_HOME from the
# environment so it can be tested against temporary directories.
#
# Usage:
#   ./install.sh              install (symlink) all skills
#   ./install.sh --force      overwrite conflicting non-symlink targets
#   ./install.sh --dry-run    print what would happen, change nothing
#   ./install.sh --uninstall  remove only symlinks this script created
#   ./install.sh --uninstall --dry-run
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"

FORCE=0
DRY_RUN=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--force] [--dry-run] [--uninstall]" >&2
      exit 1
      ;;
  esac
done

HOME_DIR="${HOME:?HOME must be set}"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME_DIR/.codex}"
CLAUDE_SKILLS_DIR="$HOME_DIR/.claude/skills"
CODEX_SKILLS_DIR="$CODEX_HOME_DIR/skills"

link_one() {
  local target_dir="$1"   # e.g. ~/.claude/skills
  local name="$2"         # e.g. blueprint
  local source_dir="$SKILLS_DIR/$name"
  local link_path="$target_dir/$name"

  if [ "$UNINSTALL" -eq 1 ]; then
    if [ -L "$link_path" ]; then
      local current_target
      current_target="$(cd "$(dirname "$link_path")" && readlink "$link_path" || true)"
      # Resolve relative symlink targets against the link's directory.
      case "$current_target" in
        /*) ;;
        *) current_target="$target_dir/$current_target" ;;
      esac
      if [ "$(cd "$current_target" 2>/dev/null && pwd -P || echo "$current_target")" = "$(cd "$source_dir" && pwd -P)" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
          echo "[dry-run] would remove symlink: $link_path"
        else
          rm "$link_path"
          echo "removed symlink: $link_path"
        fi
      else
        echo "skip (points elsewhere): $link_path"
      fi
    else
      echo "skip (not our symlink): $link_path"
    fi
    return
  fi

  mkdir -p "$target_dir"

  if [ -L "$link_path" ]; then
    local current_target
    current_target="$(cd "$(dirname "$link_path")" && readlink "$link_path" || true)"
    case "$current_target" in
      /*) ;;
      *) current_target="$target_dir/$current_target" ;;
    esac
    if [ "$(cd "$current_target" 2>/dev/null && pwd -P || echo "$current_target")" = "$(cd "$source_dir" && pwd -P)" ]; then
      echo "already linked: $link_path"
      return
    fi
    if [ "$FORCE" -ne 1 ]; then
      echo "conflict (existing symlink to something else), use --force: $link_path" >&2
      return 1
    fi
  elif [ -e "$link_path" ]; then
    if [ "$FORCE" -ne 1 ]; then
      echo "conflict (existing file/dir), use --force: $link_path" >&2
      return 1
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] would link: $link_path -> $source_dir"
    return
  fi

  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    rm -rf "$link_path"
  fi
  ln -s "$source_dir" "$link_path"
  echo "linked: $link_path -> $source_dir"
}

status=0
for skill_path in "$SKILLS_DIR"/*/; do
  name="$(basename "$skill_path")"
  link_one "$CLAUDE_SKILLS_DIR" "$name" || status=1
  link_one "$CODEX_SKILLS_DIR" "$name" || status=1
done

exit "$status"
