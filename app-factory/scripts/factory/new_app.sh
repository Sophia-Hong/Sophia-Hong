#!/usr/bin/env bash
# Usage: bash scripts/factory/new_app.sh "Display Name" slug [--game]
set -euo pipefail
cd "$(dirname "$0")/../.."
NAME="${1:?display name}"; SLUG="${2:?slug}"; KIND="app"
[ "${3:-}" = "--game" ] && KIND="game"
[ -f .env ] && PREFIX=$(grep -E '^BUNDLE_ID_PREFIX=' .env | cut -d= -f2) || PREFIX=""
PREFIX="${PREFIX:-com.example}"
TARGET="apps/$SLUG"
[ -e "$TARGET" ] && { echo "exists: $TARGET" >&2; exit 1; }
SAFE=$(echo "$NAME" | tr -cd '[:alnum:]')          # Xcode target name
mkdir -p apps
cp -R "templates/ios-app" "$TARGET"
if [ "$KIND" = game ]; then
  cp -R templates/ios-game/Sources/. "$TARGET/Sources/"
  rm -f "$TARGET/Sources/ContentView.swift"
fi
# substitute placeholders
find "$TARGET" -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.txt' -o -name '*.md' -o -name '*.storekit' -o -name '*.xcprivacy' -o -name 'Fastfile' -o -name 'Appfile' -o -name 'Snapfile' -o -name 'Deliverfile' -o -name '*.xcstrings' \) \
  -exec sed -i.bak -e "s/__APP_NAME__/$NAME/g" -e "s/__TARGET__/$SAFE/g" -e "s/__SLUG__/$SLUG/g" -e "s/__BUNDLE_ID__/$PREFIX.$SLUG/g" {} \; -exec rm -f {}.bak \;
# state
mkdir -p pipeline/state
python3 - "$SLUG" "$NAME" "$PREFIX.$SLUG" "$KIND" <<'PY'
import json,sys,datetime
slug,name,bid,kind=sys.argv[1:5]
d={"slug":slug,"name":name,"bundle_id":bid,"kind":kind,"stage":"created",
   "created":datetime.date.today().isoformat(),"updated":datetime.datetime.utcnow().isoformat(timespec='seconds')+'Z',
   "gates":{"spec":{"result":"PENDING"},"build":{"result":"PENDING"},"qa":{"result":"PENDING"},"compliance":{"result":"PENDING"},"aso":{"result":"PENDING"}},
   "submission":None}
json.dump(d,open(f"pipeline/state/{slug}.json","w"),indent=2)
PY
echo "created $TARGET ($KIND) bundle=$PREFIX.$SLUG target=$SAFE"
echo "next: product-strategist writes $TARGET/SPEC.md"
