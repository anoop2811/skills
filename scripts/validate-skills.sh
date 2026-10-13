#!/usr/bin/env bash
# Validate every skill directory against the agentskills.io basics:
#   - a SKILL.md exists
#   - it starts with YAML frontmatter containing name and description
#   - name matches the directory, is lowercase, and uses only [a-z0-9-]
#   - description is non-empty and at most 1024 characters
#   - the file is at most 500 lines
# Prints one line per problem and exits 1 if any were found.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
problems=0

for dir in "$root"/kubevela-*/; do
  skill="$(basename "$dir")"
  file="$dir/SKILL.md"
  if [ ! -f "$file" ]; then
    echo "$skill: missing SKILL.md"; problems=$((problems+1)); continue
  fi
  if [ "$(head -n1 "$file")" != "---" ]; then
    echo "$skill: SKILL.md does not start with frontmatter"; problems=$((problems+1)); continue
  fi
  front="$(awk 'NR==1{next} /^---$/{exit} {print}' "$file")"
  name="$(printf '%s\n' "$front" | awk -F': *' '$1=="name"{print $2}')"
  desc="$(printf '%s\n' "$front" | awk -F': *' '$1=="description"{sub(/^[^:]*: */,""); print}')"
  if [ -z "$name" ]; then
    echo "$skill: frontmatter has no name"; problems=$((problems+1))
  elif [ "$name" != "$skill" ]; then
    echo "$skill: frontmatter name '$name' does not match directory"; problems=$((problems+1))
  elif ! printf '%s' "$name" | grep -Eq '^[a-z0-9][a-z0-9-]{0,63}$'; then
    echo "$skill: name must be lowercase letters, digits and hyphens"; problems=$((problems+1))
  fi
  if [ -z "$desc" ]; then
    echo "$skill: frontmatter has no description"; problems=$((problems+1))
  elif [ "${#desc}" -gt 1024 ]; then
    echo "$skill: description is ${#desc} characters, limit 1024"; problems=$((problems+1))
  fi
  lines="$(wc -l < "$file")"
  if [ "$lines" -gt 500 ]; then
    echo "$skill: SKILL.md is $lines lines, limit 500"; problems=$((problems+1))
  fi
done

if [ "$problems" -gt 0 ]; then
  echo "validate-skills: $problems problem(s)"; exit 1
fi
echo "validate-skills: ok"
