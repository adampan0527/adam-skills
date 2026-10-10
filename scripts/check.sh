#!/usr/bin/env bash
# check.sh — repo consistency checks for the adam-skills plugin marketplace.
#
# Validates the invariants that _AGENTS.md declares as hard red lines, so they
# are enforced by a script instead of by memory:
#
#   1. no `$schema` in any plugin/marketplace manifest (breaks plugin loading)
#   2. every marketplace plugin entry points at a real plugin directory
#   3. every plugin ships BOTH .claude-plugin/plugin.json and .codex-plugin/plugin.json
#   4. the two manifests agree on name / version / description
#   5. marketplace version == plugin manifest version
#   6. every SKILL.md starts with YAML frontmatter carrying name + description
#
# Usage:  bash scripts/check.sh
# Env:    REPO_ROOT  (defaults to the repo root derived from this script's path)
# Requires: bash 3.2+ and POSIX userland (find/grep/sed/awk). No node, jq, or python.

set -uo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/.." && pwd -P)}"
cd "$REPO_ROOT" || exit 2

MARKETPLACE=".claude-plugin/marketplace.json"
failures=0
entry_count=0
skill_count=0
manifest_count=0

fail() {
  printf 'FAIL: %s %s\n' "$1" "$2" >&2
  failures=$((failures + 1))
}

# Extract a top-level scalar field from a flat JSON manifest without jq.
# Handles "key": "value" and "key": bare-token (numbers) on a single line.
json_field() {
  sed -n "s/^[[:space:]]*\"$2\"[[:space:]]*:[[:space:]]*\(.*\)$/\1/p" "$1" \
    | head -n 1 \
    | sed -e 's/[[:space:]]*$//' -e 's/,$//' -e 's/^"\(.*\)"$/\1/'
}

# Flatten the "plugins": [ {...}, {...} ] array of a marketplace file into
# TAB-separated records:  <index>\t<key>\t<value>.  One pass over the file, so
# callers never depend on awk early-exit behaviour.
marketplace_records() {
  awk '
    /"plugins"[[:space:]]*:[[:space:]]*\[/ { inarr = 1; next }
    !inarr { next }
    {
      if ($0 ~ /^[[:space:]]*\{[[:space:]]*$/) { idx++; next }
      if ($0 ~ /^[[:space:]]*\}/) { next }
      if ($0 ~ /^[[:space:]]*"[A-Za-z0-9_$-]+"[[:space:]]*:/) {
        key = $0
        sub(/^[[:space:]]*"/, "", key)
        sub(/".*$/, "", key)
        val = $0
        sub(/^[^:]*:[[:space:]]*/, "", val)
        sub(/[[:space:]]*,?[[:space:]]*$/, "", val)
        gsub(/^"|"$/, "", val)
        printf "%d\t%s\t%s\n", idx, key, val
      }
    }
  ' "$1"
}

echo "==> checking $REPO_ROOT"

# ------------------------------------------------------------------ rule 1 ---
# $schema anywhere in a manifest breaks plugin loading in both harnesses.
for mf in \
  "$MARKETPLACE" \
  plugins/*/.claude-plugin/plugin.json \
  plugins/*/.codex-plugin/plugin.json
do
  [ -f "$mf" ] || continue
  manifest_count=$((manifest_count + 1))
  if grep -q '"[$]schema"' "$mf"; then
    fail "no-\$schema" "$mf"
  fi
done
[ "$manifest_count" -eq 0 ] && fail "manifest-scan" "found no manifests to check (wrong REPO_ROOT?)"

# -------------------------------------------------------------- rules 2-5 ---
if [ ! -f "$MARKETPLACE" ]; then
  fail "marketplace-present" "$MARKETPLACE not found"
else
  records="$(marketplace_records "$MARKETPLACE")"
  if [ -z "$records" ]; then
    fail "marketplace-entries" "$MARKETPLACE declares no plugins"
  fi

  entry_count="$(printf '%s\n' "$records" | awk -F'\t' '{print $1}' | sort -n -u | awk 'END{print NR+0}')"

  i=1
  while [ "$i" -le "$entry_count" ]; do
    field() { printf '%s\n' "$records" | awk -F'\t' -v i="$i" -v k="$1" '$1==i && $2==k {print $3; exit}'; }

    pname="$(field name)"
    psrc="$(field source)"
    pver="$(field version)"

    if [ -z "$pname" ]; then
      fail "marketplace-name" "entry #$i in $MARKETPLACE has no name"
    fi

    dir="${psrc#./}"
    if [ -z "$psrc" ] || [ ! -d "$dir" ]; then
      fail "marketplace-source" "$pname -> '$psrc' (expected an existing directory)"
    fi

    claude_manifest="$dir/.claude-plugin/plugin.json"
    codex_manifest="$dir/.codex-plugin/plugin.json"

    [ -f "$claude_manifest" ] || fail "claude-manifest-present" "$claude_manifest not found"
    [ -f "$codex_manifest" ] || fail "codex-manifest-present" "$codex_manifest not found"

    if [ -f "$claude_manifest" ] && [ -f "$codex_manifest" ]; then
      for f in name version description; do
        cv="$(json_field "$claude_manifest" "$f")"
        xv="$(json_field "$codex_manifest" "$f")"
        [ "$cv" = "$xv" ] || fail "manifest-parity:$f" "$pname claude='$cv' codex='$xv'"
      done
    fi

    if [ -f "$claude_manifest" ] && [ -n "$pver" ]; then
      mv="$(json_field "$claude_manifest" version)"
      [ "$mv" = "$pver" ] || fail "version-parity" "$pname marketplace='$pver' manifest='$mv'"
    fi

    i=$((i + 1))
  done
fi

# ------------------------------------------------------------------ rule 6 ---
# SKILL.md must start with frontmatter carrying name + description.
for skill in plugins/*/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  skill_count=$((skill_count + 1))

  if [ "$(head -n 1 "$skill")" != "---" ]; then
    fail "skill-frontmatter-open" "$skill (does not start with '---')"
    continue
  fi

  fm="$(awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$skill")"
  printf '%s\n' "$fm" | grep -q '^name:[[:space:]]*[^[:space:]]' \
    || fail "skill-frontmatter-name" "$skill (missing 'name:')"
  printf '%s\n' "$fm" | grep -q '^description:[[:space:]]*[^[:space:]]' \
    || fail "skill-frontmatter-description" "$skill (missing 'description:')"
done

# ----------------------------------------------------------------- summary ---
echo "==> checked $manifest_count manifest(s), $entry_count marketplace entry/entries, $skill_count skill(s)"
if [ "$failures" -gt 0 ]; then
  echo "==> FAILED with $failures problem(s)" >&2
  exit 1
fi
echo "==> OK"
exit 0
