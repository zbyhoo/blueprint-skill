#!/usr/bin/env bash
# Regression test for install.sh. Every case runs install.sh with HOME and
# CODEX_HOME pointed at fresh temporary directories; the real HOME and
# ~/.codex are never touched. Prints one PASS/FAIL line per case and exits 1
# if any case fails.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO_DIR/install.sh"
SKILLS=(blueprint execute-blueprint)

TMP_ROOT="$(mktemp -d)"
TMP_ROOT="$(cd "$TMP_ROOT" && pwd -P)"
trap 'rm -rf "$TMP_ROOT"' EXIT

failures=0
case_no=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1"
  failures=$((failures + 1))
}

# Fresh sandbox for one case. Sets T_HOME, T_CODEX, OUT (output file).
new_sandbox() {
  case_no=$((case_no + 1))
  local base="$TMP_ROOT/case$case_no"
  T_HOME="$base/home"
  T_CODEX="$base/codex"
  OUT="$base/out"
  mkdir -p "$T_HOME" "$T_CODEX"
  if [ "$T_HOME" = "${REAL_HOME:-}" ] || [ "$T_CODEX" = "${REAL_HOME:-}/.codex" ]; then
    echo "refusing to run: sandbox resolves to the real HOME" >&2
    exit 2
  fi
}

# Run an install.sh with the sandbox HOME/CODEX_HOME. Output goes to $OUT;
# the exit code is stored in RC (the test never aborts on it).
run_install() {
  local script="$1"
  shift
  RC=0
  env HOME="$T_HOME" CODEX_HOME="$T_CODEX" "$script" "$@" >"$OUT" 2>&1 || RC=$?
}

run_install_no_codex_home() {
  local script="$1"
  shift
  RC=0
  env -u CODEX_HOME HOME="$T_HOME" "$script" "$@" >"$OUT" 2>&1 || RC=$?
}

# Physical path of a directory, or empty if it does not resolve.
resolve_dir() {
  (cd "$1" 2>/dev/null && pwd -P) || true
}

# Check that each skill has a symlink in dir $1 resolving to $2/skills/<name>.
# Prints the problems (if any) to stdout.
links_problems() {
  local dir="$1" repo="$2" name want got
  for name in "${SKILLS[@]}"; do
    if [ ! -L "$dir/$name" ]; then
      printf '%s not a symlink; ' "$dir/$name"
      continue
    fi
    want="$(resolve_dir "$repo/skills/$name")"
    got="$(resolve_dir "$dir/$name")"
    if [ -z "$got" ] || [ "$got" != "$want" ]; then
      printf '%s resolves to %s, want %s; ' "$dir/$name" "${got:-<nothing>}" "$want"
    fi
  done
}

# Count everything (files, dirs, links) under a directory, excluding itself.
count_entries() {
  find "$1" -mindepth 1 | wc -l | tr -d ' '
}

# Relative path from directory $1 to directory $2 (both must exist).
relpath() {
  local from to common up=""
  from="$(resolve_dir "$1")"
  to="$(resolve_dir "$2")"
  common="$from"
  while [ "$common" != "/" ] && [ "${to#"$common"/}" = "$to" ]; do
    common="$(dirname "$common")"
    up="../$up"
  done
  if [ "$common" = "/" ]; then
    printf '%s%s' "$up" "${to#/}"
  else
    printf '%s%s' "$up" "${to#"$common"/}"
  fi
}

output_one_line() {
  tr '\n' ' ' <"$OUT"
}

# --- cases -----------------------------------------------------------------

case_dry_run_creates_nothing() {
  new_sandbox
  run_install "$INSTALL" --dry-run
  local n1 n2
  n1="$(count_entries "$T_HOME")"
  n2="$(count_entries "$T_CODEX")"
  if [ "$RC" -eq 0 ] && [ "$n1" -eq 0 ] && [ "$n2" -eq 0 ] && grep -q '\[dry-run\] would link' "$OUT"; then
    pass "--dry-run creates nothing"
  else
    fail "--dry-run creates nothing (rc=$RC, $n1 entries under HOME, $n2 under CODEX_HOME): $(output_one_line)"
  fi
}

case_install_creates_links() {
  new_sandbox
  run_install "$INSTALL"
  local problems n1 n2
  problems="$(links_problems "$T_HOME/.claude/skills" "$REPO_DIR")$(links_problems "$T_CODEX/skills" "$REPO_DIR")"
  n1="$(count_entries "$T_HOME/.claude/skills")"
  n2="$(count_entries "$T_CODEX/skills")"
  if [ "$RC" -eq 0 ] && [ -z "$problems" ] && [ "$n1" -eq 2 ] && [ "$n2" -eq 2 ]; then
    pass "install creates 4 symlinks to the repo's skills"
  else
    fail "install creates 4 symlinks (rc=$RC, entries $n1+$n2): $problems $(output_one_line)"
  fi
}

case_second_install_idempotent() {
  new_sandbox
  run_install "$INSTALL"
  run_install "$INSTALL"
  local count problems
  count="$(grep -c '^already linked: ' "$OUT" || true)"
  problems="$(links_problems "$T_HOME/.claude/skills" "$REPO_DIR")$(links_problems "$T_CODEX/skills" "$REPO_DIR")"
  if [ "$RC" -eq 0 ] && [ "$count" -eq 4 ] && [ -z "$problems" ]; then
    pass "second install is idempotent (already linked, exit 0)"
  else
    fail "second install is idempotent (rc=$RC, $count 'already linked'): $problems $(output_one_line)"
  fi
}

case_real_dir_conflict_then_force() {
  new_sandbox
  local target="$T_HOME/.claude/skills/blueprint"
  mkdir -p "$target/sub"
  printf 'keep me\n' >"$target/sub/file.txt"
  run_install "$INSTALL"
  if [ "$RC" -eq 1 ] && [ -d "$target" ] && [ ! -L "$target" ] &&
    [ "$(cat "$target/sub/file.txt" 2>/dev/null)" = "keep me" ] &&
    [ "$(count_entries "$target")" -eq 2 ] && grep -q '^conflict (existing file/dir)' "$OUT"; then
    pass "real directory at target: exit 1, directory untouched"
  else
    fail "real directory at target: exit 1, directory untouched (rc=$RC): $(output_one_line)"
    return
  fi

  run_install "$INSTALL" --force
  local problems
  problems="$(links_problems "$T_HOME/.claude/skills" "$REPO_DIR")$(links_problems "$T_CODEX/skills" "$REPO_DIR")"
  if [ "$RC" -eq 0 ] && [ -z "$problems" ]; then
    pass "--force replaces the real directory with the symlink"
  else
    fail "--force replaces the real directory (rc=$RC): $problems $(output_one_line)"
  fi
}

case_relative_symlink_recognised() {
  new_sandbox
  local dir="$T_HOME/.claude/skills" rel
  mkdir -p "$dir"
  rel="$(relpath "$dir" "$REPO_DIR/skills/blueprint")"
  ln -s "$rel" "$dir/blueprint"
  run_install "$INSTALL"
  if [ "$RC" -eq 0 ] && grep -qx "already linked: $dir/blueprint" "$OUT" &&
    [ "$(readlink "$dir/blueprint")" = "$rel" ] && [ -z "$(links_problems "$dir" "$REPO_DIR")" ]; then
    pass "relative symlink to the skill dir is already linked"
  else
    fail "relative symlink ($rel) is already linked (rc=$RC): $(output_one_line)"
  fi
}

case_uninstall() {
  new_sandbox
  run_install "$INSTALL"
  local other="$TMP_ROOT/case$case_no/elsewhere/execute-blueprint"
  mkdir -p "$other"
  rm "$T_CODEX/skills/execute-blueprint"
  ln -s "$other" "$T_CODEX/skills/execute-blueprint"

  run_install "$INSTALL" --uninstall --dry-run
  local problems
  problems="$(links_problems "$T_HOME/.claude/skills" "$REPO_DIR")"
  if [ "$RC" -eq 0 ] && [ -z "$problems" ] && [ -L "$T_CODEX/skills/blueprint" ] &&
    [ -L "$T_CODEX/skills/execute-blueprint" ] && grep -q '\[dry-run\] would remove symlink' "$OUT"; then
    pass "--uninstall --dry-run removes nothing"
  else
    fail "--uninstall --dry-run removes nothing (rc=$RC): $problems $(output_one_line)"
  fi

  run_install "$INSTALL" --uninstall
  if [ "$RC" -eq 0 ] &&
    [ ! -e "$T_HOME/.claude/skills/blueprint" ] && [ ! -L "$T_HOME/.claude/skills/blueprint" ] &&
    [ ! -e "$T_HOME/.claude/skills/execute-blueprint" ] && [ ! -L "$T_HOME/.claude/skills/execute-blueprint" ] &&
    [ ! -e "$T_CODEX/skills/blueprint" ] && [ ! -L "$T_CODEX/skills/blueprint" ] &&
    [ -L "$T_CODEX/skills/execute-blueprint" ] &&
    [ "$(readlink "$T_CODEX/skills/execute-blueprint")" = "$other" ] && [ -d "$other" ]; then
    pass "--uninstall removes only this repo's symlinks"
  else
    fail "--uninstall removes only this repo's symlinks (rc=$RC): $(output_one_line)"
  fi
}

case_unknown_argument() {
  new_sandbox
  run_install "$INSTALL" --bogus
  if [ "$RC" -eq 1 ] && grep -q 'Unknown argument: --bogus' "$OUT" && grep -q '^Usage: ' "$OUT" &&
    [ "$(count_entries "$T_HOME")" -eq 0 ] && [ "$(count_entries "$T_CODEX")" -eq 0 ]; then
    pass "unknown argument exits 1 with usage"
  else
    fail "unknown argument exits 1 with usage (rc=$RC): $(output_one_line)"
  fi
}

case_codex_home_unset() {
  new_sandbox
  run_install_no_codex_home "$INSTALL"
  local problems
  problems="$(links_problems "$T_HOME/.claude/skills" "$REPO_DIR")$(links_problems "$T_HOME/.codex/skills" "$REPO_DIR")"
  if [ "$RC" -eq 0 ] && [ -z "$problems" ] && [ "$(count_entries "$T_CODEX")" -eq 0 ]; then
    pass "CODEX_HOME unset links into \$HOME/.codex/skills"
  else
    fail "CODEX_HOME unset links into \$HOME/.codex/skills (rc=$RC): $problems $(output_one_line)"
  fi
}

case_repo_path_with_space() {
  new_sandbox
  local copy="$TMP_ROOT/case$case_no/repo with space"
  mkdir -p "$copy"
  cp -R "$REPO_DIR/install.sh" "$REPO_DIR/skills" "$copy/"
  run_install "$copy/install.sh"
  local problems
  problems="$(links_problems "$T_HOME/.claude/skills" "$copy")$(links_problems "$T_CODEX/skills" "$copy")"
  if [ "$RC" -ne 0 ] || [ -n "$problems" ]; then
    fail "repo path containing a space: install (rc=$RC): $problems $(output_one_line)"
    return
  fi
  run_install "$copy/install.sh"
  if [ "$RC" -ne 0 ] || [ "$(grep -c '^already linked: ' "$OUT" || true)" -ne 4 ]; then
    fail "repo path containing a space: re-install (rc=$RC): $(output_one_line)"
    return
  fi
  run_install "$copy/install.sh" --uninstall
  if [ "$RC" -ne 0 ] || [ "$(count_entries "$T_HOME/.claude/skills")" -ne 0 ] ||
    [ "$(count_entries "$T_CODEX/skills")" -ne 0 ]; then
    fail "repo path containing a space: uninstall (rc=$RC): $(output_one_line)"
    return
  fi
  pass "repo path containing a space installs, re-installs and uninstalls"
}

REAL_HOME="${HOME:-}"
if [ -n "$REAL_HOME" ]; then
  REAL_HOME="$(resolve_dir "$REAL_HOME")"
fi

case_dry_run_creates_nothing
case_install_creates_links
case_second_install_idempotent
case_real_dir_conflict_then_force
case_relative_symlink_recognised
case_uninstall
case_unknown_argument
case_codex_home_unset
case_repo_path_with_space

if [ "$failures" -gt 0 ]; then
  exit 1
fi
exit 0
