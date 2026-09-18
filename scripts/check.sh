#!/usr/bin/env bash
# Repo consistency checks. Run from any cwd; always operates on the repo
# that contains this script.
#
# Add a check: write a check_* function (print one PASS/FAIL/SKIP line)
# and append its name to CHECKS below.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

failures=0

pass() {
  printf 'PASS: %s\n' "${1//$'\n'/ }"
}

fail() {
  printf 'FAIL: %s\n' "${1//$'\n'/ }"
  failures=$((failures + 1))
}

skip() {
  printf 'SKIP: %s\n' "${1//$'\n'/ }"
}

have_jq() {
  command -v jq >/dev/null 2>&1
}

# Join arguments with "; ".
join_issues() {
  local out="" item
  for item in "$@"; do
    if [ -n "$out" ]; then
      out="$out; $item"
    else
      out="$item"
    fi
  done
  printf '%s' "$out"
}

# Print YAML frontmatter body (between the opening and closing ---).
# Fails if the file does not start with --- or the closing --- is missing.
extract_frontmatter() {
  awk '
    {
      sub(/\r$/, "")
    }
    NR == 1 {
      if ($0 != "---") { exit 1 }
      next
    }
    $0 == "---" { ok = 1; exit 0 }
    { print }
    END { if (!ok) exit 1 }
  ' "$1"
}

# Read a single-line YAML scalar `key: value` from frontmatter on stdin.
yaml_scalar() {
  awk -v key="$1" '
    {
      sub(/\r$/, "")
      s = $0
      sub(/^[ \t]+/, "", s)
      prefix = key ":"
      if (index(s, prefix) != 1) next
      val = substr(s, length(prefix) + 1)
      sub(/^[ \t]+/, "", val)
      sub(/[ \t]+$/, "", val)
      n = length(val)
      if (n >= 2 && substr(val, 1, 1) == "\"" && substr(val, n, 1) == "\"") {
        val = substr(val, 2, n - 2)
      }
      print val
      exit
    }
  '
}

check_json() {
  if ! have_jq; then
    fail "jq required"
    return
  fi

  local d
  for d in .claude-plugin .codex-plugin .agents/plugins; do
    if [ ! -d "$d" ]; then
      fail "json parse: missing directory $d"
      return
    fi
  done

  local -a files=()
  local f
  while IFS= read -r f; do
    files+=("$f")
  done < <(find .claude-plugin .codex-plugin .agents/plugins -type f -name '*.json' | sort)

  if [ "${#files[@]}" -eq 0 ]; then
    fail "json parse: no JSON files found under .claude-plugin/, .codex-plugin/, .agents/plugins/"
    return
  fi

  local -a invalid=()
  for f in "${files[@]}"; do
    if ! jq empty "$f" >/dev/null 2>&1; then
      invalid+=("$f")
    fi
  done

  if [ "${#invalid[@]}" -gt 0 ]; then
    fail "json parse: invalid JSON: $(join_issues "${invalid[@]}")"
  else
    pass "json files parse (${#files[@]} files)"
  fi
}

check_versions() {
  if ! have_jq; then
    fail "plugin versions: jq required"
    return
  fi

  local plugin_ver meta_ver mp_ver codex_ver
  plugin_ver="$(jq -r '.version // empty' .claude-plugin/plugin.json 2>/dev/null || true)"
  meta_ver="$(jq -r '.metadata.version // empty' .claude-plugin/marketplace.json 2>/dev/null || true)"
  mp_ver="$(jq -r '.plugins[0].version // empty' .claude-plugin/marketplace.json 2>/dev/null || true)"
  codex_ver="$(jq -r '.version // empty' .codex-plugin/plugin.json 2>/dev/null || true)"

  local report
  report=".claude-plugin/plugin.json .version=${plugin_ver} .claude-plugin/marketplace.json .metadata.version=${meta_ver} .claude-plugin/marketplace.json .plugins[0].version=${mp_ver} .codex-plugin/plugin.json .version=${codex_ver}"

  if [ "$plugin_ver" = "$meta_ver" ] &&
    [ "$plugin_ver" = "$mp_ver" ] &&
    [ "$plugin_ver" = "$codex_ver" ] &&
    [[ "$plugin_ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    pass "plugin versions identical and valid (${plugin_ver})"
  else
    fail "plugin versions disagree or invalid: ${report}"
  fi
}

check_names() {
  if ! have_jq; then
    fail "plugin names: jq required"
    return
  fi

  local n_plugin n_market n_codex n_agents
  n_plugin="$(jq -r '.name // empty' .claude-plugin/plugin.json 2>/dev/null || true)"
  n_market="$(jq -r '.plugins[0].name // empty' .claude-plugin/marketplace.json 2>/dev/null || true)"
  n_codex="$(jq -r '.name // empty' .codex-plugin/plugin.json 2>/dev/null || true)"
  n_agents="$(jq -r '.plugins[0].name // empty' .agents/plugins/marketplace.json 2>/dev/null || true)"

  local report
  report=".claude-plugin/plugin.json .name=${n_plugin} .claude-plugin/marketplace.json .plugins[0].name=${n_market} .codex-plugin/plugin.json .name=${n_codex} .agents/plugins/marketplace.json .plugins[0].name=${n_agents}"

  if [ "$n_plugin" = "blueprint-skill" ] &&
    [ "$n_market" = "blueprint-skill" ] &&
    [ "$n_codex" = "blueprint-skill" ] &&
    [ "$n_agents" = "blueprint-skill" ]; then
    pass "plugin names are blueprint-skill"
  else
    fail "plugin name is not blueprint-skill: ${report}"
  fi
}

check_frontmatter() {
  local -a files=()
  local f
  shopt -s nullglob
  files=(skills/*/SKILL.md)
  shopt -u nullglob

  if [ "${#files[@]}" -eq 0 ]; then
    fail "skill frontmatter: no skills/*/SKILL.md found"
    return
  fi

  local -a problems=()
  for f in "${files[@]}"; do
    local dir fm name desc
    dir="$(basename "$(dirname "$f")")"
    if ! fm="$(extract_frontmatter "$f")"; then
      problems+=("$f missing YAML frontmatter")
      continue
    fi
    name="$(printf '%s\n' "$fm" | yaml_scalar name || true)"
    desc="$(printf '%s\n' "$fm" | yaml_scalar description || true)"

    local -a file_issues=()
    if [ -z "$name" ]; then
      file_issues+=("missing name")
    else
      if [ "$name" != "$dir" ]; then
        file_issues+=("name '$name' != directory '$dir'")
      fi
      if ! [[ "$name" =~ ^[a-z0-9-]{1,64}$ ]]; then
        file_issues+=("name '$name' does not match ^[a-z0-9-]{1,64}$")
      fi
    fi
    if [ -z "$desc" ]; then
      file_issues+=("description empty")
    elif [ "${#desc}" -gt 1024 ]; then
      file_issues+=("description is ${#desc} characters (max 1024)")
    fi
    if [ "${#file_issues[@]}" -gt 0 ]; then
      problems+=("$f $(join_issues "${file_issues[@]}")")
    fi
  done

  if [ "${#problems[@]}" -gt 0 ]; then
    fail "skill frontmatter: $(join_issues "${problems[@]}")"
  else
    local -a names=()
    for f in "${files[@]}"; do
      names+=("$(basename "$(dirname "$f")")")
    done
    pass "skill frontmatter (${names[*]})"
  fi
}

check_install_syntax() {
  if [ ! -f install.sh ]; then
    fail "install.sh syntax: install.sh not found"
    return
  fi
  local out
  if out="$(bash -n install.sh 2>&1)"; then
    pass "install.sh syntax (bash -n)"
  else
    fail "install.sh syntax: ${out}"
  fi
}

check_install_test() {
  if [ ! -x tests/install_test.sh ]; then
    fail "install.sh regression test: tests/install_test.sh not found or not executable"
    return
  fi
  local out
  if out="$(tests/install_test.sh 2>&1)"; then
    pass "install.sh regression test (tests/install_test.sh)"
  else
    fail "install.sh regression test: $(printf '%s\n' "$out" | grep -v '^PASS: ')"
  fi
}

check_claude_validate() {
  if ! command -v claude >/dev/null 2>&1; then
    skip "claude plugin validate (claude not on PATH)"
    return
  fi

  local out1="" out2="" rc=0
  out1="$(claude plugin validate . </dev/null 2>&1)" || rc=1
  out2="$(claude plugin validate .claude-plugin/plugin.json </dev/null 2>&1)" || rc=1
  if [ "$rc" -eq 0 ]; then
    pass "claude plugin validate"
  else
    fail "claude plugin validate: ${out1} ${out2}"
  fi
}

check_shellcheck() {
  if ! command -v shellcheck >/dev/null 2>&1; then
    skip "shellcheck (shellcheck not on PATH)"
    return
  fi

  local -a scripts=(install.sh)
  local f
  while IFS= read -r f; do
    scripts+=("$f")
  done < <(find scripts tests -maxdepth 1 -type f -name '*.sh' | sort)

  local out rc=0
  out="$(shellcheck "${scripts[@]}" 2>&1)" || rc=$?
  if [ "$rc" -eq 0 ]; then
    pass "shellcheck ${scripts[*]}"
  else
    fail "shellcheck: ${out}"
  fi
}

CHECKS=(
  check_json
  check_versions
  check_names
  check_frontmatter
  check_install_syntax
  check_install_test
  check_claude_validate
  check_shellcheck
)

for check in "${CHECKS[@]}"; do
  "$check"
done

if [ "$failures" -gt 0 ]; then
  exit 1
fi
exit 0
