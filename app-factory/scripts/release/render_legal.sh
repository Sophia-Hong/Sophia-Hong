#!/usr/bin/env bash
# Render privacy policy + terms for an app. Usage: bash scripts/release/render_legal.sh <slug>
set -euo pipefail
cd "$(dirname "$0")/../.."
SLUG="${1:?slug}"; ST="pipeline/state/$SLUG.json"
NAME=$(python3 -c "import json;print(json.load(open('$ST'))['name'])")
BID=$(python3 -c "import json;print(json.load(open('$ST'))['bundle_id'])")
[ -f .env ] && BASE=$(grep -E '^PRIVACY_POLICY_BASE_URL=' .env | cut -d= -f2) || BASE=""
BASE="${BASE:-https://example.com/legal}"
EMAIL=$(grep -E '^APPLE_ID=' .env 2>/dev/null | cut -d= -f2 || true); EMAIL="${EMAIL:-support@example.com}"
DATE=$(date +%Y-%m-%d)
mkdir -p "apps/$SLUG/legal" "apps/$SLUG/fastlane/metadata/en-US"
for f in privacy terms; do
  sed -e "s/__APP_NAME__/$NAME/g" -e "s/__BUNDLE_ID__/$BID/g" -e "s/__DATE__/$DATE/g" -e "s/__EMAIL__/$EMAIL/g" -e "s#__BASE_URL__#$BASE#g" -e "s/__SLUG__/$SLUG/g" \
    "templates/legal/$f.md" > "apps/$SLUG/legal/$f.md"
done
echo "$BASE/$SLUG/privacy" > "apps/$SLUG/fastlane/metadata/en-US/privacy_url.txt"
echo "$BASE/$SLUG/support" > "apps/$SLUG/fastlane/metadata/en-US/support_url.txt"
echo "rendered apps/$SLUG/legal/{privacy,terms}.md — publish them at $BASE/$SLUG/ (e.g. copy to your GitHub Pages repo)"
