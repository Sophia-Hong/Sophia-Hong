#!/usr/bin/env bash
# Prints pipeline state summary into the session context at start.
cd "$(dirname "$0")/../.." || exit 0
echo "== App Factory session =="
echo "host: $(uname -s) $( [ "$(uname -s)" = Darwin ] && echo '(build/ship enabled)' || echo '(NO Xcode: build/ship stages will be left pending-mac)')"
for t in xcodegen xcodebuild fastlane swiftlint; do
  command -v "$t" >/dev/null 2>&1 && echo "tool: $t ok" || echo "tool: $t MISSING"
done
[ -f .env ] && echo "env: .env present" || echo "env: .env missing (copy .env.example)"
if ls pipeline/state/*.json >/dev/null 2>&1; then
  echo "-- pipeline state --"
  for f in pipeline/state/*.json; do
    python3 - "$f" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
print(f"{d.get('slug')}: stage={d.get('stage')} gates={ {k:v.get('result') for k,v in d.get('gates',{}).items()} } updated={d.get('updated')}")
PY
  done
else
  echo "-- no apps in pipeline yet. Run /scout then /new-app --"
fi
exit 0
