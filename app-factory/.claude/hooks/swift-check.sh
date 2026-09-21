#!/usr/bin/env bash
# PostToolUse (Edit|Write): lint + syntax-check edited Swift files; warn (never block) so the builder can iterate.
input=$(cat)
file=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
case "$file" in
  *.swift) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0
if command -v swiftlint >/dev/null 2>&1; then
  out=$(swiftlint lint --quiet --path "$file" 2>/dev/null | head -20)
  [ -n "$out" ] && echo "swiftlint: $out"
fi
if command -v swiftc >/dev/null 2>&1; then
  err=$(swiftc -parse "$file" 2>&1 | head -20)
  [ -n "$err" ] && echo "swiftc -parse: $err"
fi
exit 0
