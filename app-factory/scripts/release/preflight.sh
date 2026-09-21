#!/usr/bin/env bash
# Pre-submission checks. Usage: bash scripts/release/preflight.sh apps/<slug>   |   --metadata apps/<slug>
set -uo pipefail
cd "$(dirname "$0")/../.."
MODE=all; [ "${1:-}" = "--metadata" ] && { MODE=meta; shift; }
DIR="${1:?apps/<slug>}"; FAIL=0
ok(){ echo "PASS  $1"; }; bad(){ echo "FAIL  $1"; FAIL=1; }; na(){ echo "NA    $1"; }
len(){ python3 -c "import sys;print(len(open(sys.argv[1]).read().strip()))" "$1" 2>/dev/null || echo 0; }
M="$DIR/fastlane/metadata/en-US"

echo "== metadata =="
for f in name subtitle keywords description privacy_url support_url; do [ -s "$M/$f.txt" ] && ok "$f.txt present" || bad "$f.txt missing/empty"; done
[ -s "$M/name.txt" ] && { n=$(len "$M/name.txt"); [ "$n" -le 30 ] && ok "name ≤30 ($n)" || bad "name >30 ($n)"; }
[ -s "$M/subtitle.txt" ] && { n=$(len "$M/subtitle.txt"); [ "$n" -le 30 ] && ok "subtitle ≤30 ($n)" || bad "subtitle >30 ($n)"; }
[ -s "$M/keywords.txt" ] && { n=$(len "$M/keywords.txt"); [ "$n" -le 100 ] && ok "keywords ≤100 ($n)" || bad "keywords >100 ($n)"
  grep -q ', ' "$M/keywords.txt" && bad "keywords contain ', ' (wastes chars)" || ok "keywords no spaces after commas"
  grep -qiE '(^|,)(app|free|best|iphone|ios)(,|$)' "$M/keywords.txt" && bad "keywords contain banned generic words" || ok "keywords no banned words"; }
[ -s "$M/description.txt" ] && { n=$(len "$M/description.txt"); [ "$n" -le 4000 ] && ok "description ≤4000 ($n)" || bad "description >4000 ($n)"; }
[ -s "$M/promotional_text.txt" ] && { n=$(len "$M/promotional_text.txt"); [ "$n" -le 170 ] && ok "promo ≤170 ($n)" || bad "promo >170 ($n)"; }
grep -rqiE 'TODO|lorem|placeholder|__APP_NAME__' "$M" 2>/dev/null && bad "placeholder text in metadata" || ok "no placeholders in metadata"
if [ -s "$DIR/SPEC.md" ] && grep -qi 'subscription' "$DIR/SPEC.md" && [ -s "$M/description.txt" ]; then
  grep -qiE 'auto-?renew' "$M/description.txt" && ok "subscription disclosure in description" || bad "subscription app but no auto-renew disclosure in description"
fi
[ "$MODE" = meta ] && exit $FAIL

echo "== project =="
[ -s "$DIR/project.yml" ] && ok "project.yml" || bad "project.yml missing"
[ -s "$DIR/SPEC.md" ] && ok "SPEC.md" || bad "SPEC.md missing"
[ -s "$DIR/QA.md" ] && (grep -q '^Verdict: PASS' "$DIR/QA.md" && ok "QA verdict PASS" || bad "QA verdict not PASS") || bad "QA.md missing"
grep -rq '__BUNDLE_ID__\|__APP_NAME__\|__TARGET__' "$DIR/project.yml" "$DIR/Sources" 2>/dev/null && bad "unreplaced template placeholders" || ok "placeholders replaced"
grep -rqiE 'TODO|FIXME' "$DIR/Sources" 2>/dev/null && bad "TODO/FIXME in Sources" || ok "no TODO in Sources"
grep -rqE 'try!|as!' "$DIR/Sources" 2>/dev/null && bad "try!/as! in Sources (crash risk)" || ok "no try!/as!"

echo "== privacy =="
P="$DIR/Sources/PrivacyInfo.xcprivacy"
[ -s "$P" ] && ok "PrivacyInfo.xcprivacy present" || bad "PrivacyInfo.xcprivacy missing"
if grep -rq 'UserDefaults' "$DIR/Sources" "$(dirname "$DIR")/../packages/FactoryKit/Sources" 2>/dev/null; then
  grep -q 'CA92.1' "$P" 2>/dev/null && ok "UserDefaults reason CA92.1 declared" || bad "UserDefaults used but CA92.1 not in privacy manifest"
fi
grep -q 'NSPrivacyTracking</key>\s*<false' "$P" 2>/dev/null || grep -A1 'NSPrivacyTracking' "$P" 2>/dev/null | grep -q false && ok "no tracking declared" || bad "NSPrivacyTracking not false"
grep -q 'ITSAppUsesNonExemptEncryption' "$DIR/project.yml" && ok "export compliance key set" || bad "ITSAppUsesNonExemptEncryption missing in project.yml"
[ -s "$DIR/legal/privacy.md" ] && ok "privacy policy rendered" || bad "legal/privacy.md missing (run scripts/release/render_legal.sh)"
[ -s "$DIR/legal/terms.md" ] && ok "terms rendered" || bad "legal/terms.md missing"
if [ -s "$M/privacy_url.txt" ] && command -v curl >/dev/null; then
  code=$(curl -s -o /dev/null -w '%{http_code}' -m 10 "$(cat "$M/privacy_url.txt")") || code=000
  [ "$code" = 200 ] && ok "privacy_url reachable" || bad "privacy_url returned $code"
fi

echo "== IAP =="
SK="$DIR/Configuration/Products.storekit"
if [ -s "$SK" ]; then
  ok "Products.storekit present"
  ids=$(python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print(' '.join([p['productID'] for p in d.get('products',[])]+[s['productID'] for g in d.get('subscriptionGroups',[]) for s in g.get('subscriptions',[])]))" "$SK" 2>/dev/null)
  for id in $ids; do grep -rq "$id" "$DIR/Sources" && ok "product $id referenced in code" || bad "product $id not referenced in code"; done
  grep -rqi 'restore' "$DIR/Sources" "$(dirname "$DIR")/../packages/FactoryKit/Sources" 2>/dev/null && ok "restore purchases present" || bad "no restore purchases"
else na "no Products.storekit (free app?)"; fi

echo "== screenshots =="
S="$DIR/fastlane/screenshots/en-US"
c=$(ls "$S"/*.png 2>/dev/null | wc -l | tr -d ' ')
[ "$c" -ge 3 ] && ok "$c screenshots" || bad "need ≥3 screenshots in $S (have $c)"

echo; [ $FAIL = 0 ] && echo "PREFLIGHT: PASS" || echo "PREFLIGHT: FAIL"
exit $FAIL
