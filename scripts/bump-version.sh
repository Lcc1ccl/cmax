#!/usr/bin/env bash
set -euo pipefail

PROJECT_FILE="GhosttyTabs.xcodeproj/project.pbxproj"
POLICY_FILE=".release-policy.json"

if [[ ! -f "$PROJECT_FILE" ]]; then
  echo "Error: $PROJECT_FILE not found. Run from repo root." >&2
  exit 1
fi

if [[ ! -f "$POLICY_FILE" ]]; then
  echo "Error: $POLICY_FILE not found. Run from repo root." >&2
  exit 1
fi

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/bump-version.sh --upstream 0.64.0
  ./scripts/bump-version.sh 1.0.1

Options:
  --upstream X.Y.Z   Calculate the cmax product version from the fork release policy
USAGE
}

CURRENT_MARKETING=$(grep -m1 'MARKETING_VERSION = ' "$PROJECT_FILE" | sed 's/.*= \(.*\);/\1/')
CURRENT_BUILD=$(grep -m1 'CURRENT_PROJECT_VERSION = ' "$PROJECT_FILE" | sed 's/.*= \(.*\);/\1/')
MIN_BUILD="$CURRENT_BUILD"
APPCAST_URL=$(python3 - <<'PY'
import json
from pathlib import Path
print(json.loads(Path('.release-policy.json').read_text())['stableAppcastUrl'])
PY
)

LATEST_RELEASE_BUILD="$({
  curl -fsSL --max-time 8 "$APPCAST_URL" 2>/dev/null || true
} | sed -n 's#.*<sparkle:version>\([0-9][0-9]*\)</sparkle:version>.*#\1#p' | head -n1)"
if [[ "$LATEST_RELEASE_BUILD" =~ ^[0-9]+$ ]] && (( LATEST_RELEASE_BUILD > MIN_BUILD )); then
  MIN_BUILD="$LATEST_RELEASE_BUILD"
fi

if [[ $# -eq 2 && "$1" == "--upstream" ]]; then
  TARGET_UPSTREAM="$2"
  NEW_MARKETING=$(python3 - "$TARGET_UPSTREAM" <<'PY'
import json, sys
from pathlib import Path
policy = json.loads(Path('.release-policy.json').read_text())
base_product = tuple(map(int, policy['baseProductVersion'].split('.')))
base_upstream = tuple(map(int, policy['baseUpstreamVersion'].split('.')))
upstream = tuple(map(int, sys.argv[1].split('.')))
if upstream[0] != base_upstream[0]:
    raise SystemExit('Only upstream 0.y.z is supported by the current policy')
if upstream < base_upstream:
    raise SystemExit('Target upstream version is below the configured base')
product_major = base_product[0]
product_minor = base_product[1] + (upstream[1] - base_upstream[1])
if upstream[1] == base_upstream[1]:
    product_patch = base_product[2] + (upstream[2] - base_upstream[2])
else:
    product_patch = upstream[2]
if product_patch < 0:
    raise SystemExit('Computed product patch would be negative')
print(f"{product_major}.{product_minor}.{product_patch}")
PY
)
  python3 - "$NEW_MARKETING" "$TARGET_UPSTREAM" <<'PY'
import json, sys
from pathlib import Path
path = Path('.release-policy.json')
policy = json.loads(path.read_text())
policy['productVersion'] = sys.argv[1]
policy['upstreamVersion'] = sys.argv[2]
path.write_text(json.dumps(policy, indent=2) + '\n')
PY
elif [[ $# -eq 1 && "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  NEW_MARKETING="$1"
else
  usage >&2
  exit 1
fi

NEW_BUILD=$((MIN_BUILD + 1))

echo "Current: MARKETING_VERSION=$CURRENT_MARKETING, CURRENT_PROJECT_VERSION=$CURRENT_BUILD"
echo "New:     MARKETING_VERSION=$NEW_MARKETING, CURRENT_PROJECT_VERSION=$NEW_BUILD"

sed -i '' "s/MARKETING_VERSION = $CURRENT_MARKETING;/MARKETING_VERSION = $NEW_MARKETING;/g" "$PROJECT_FILE"
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_BUILD;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" "$PROJECT_FILE"

UPDATED_MARKETING=$(grep -m1 'MARKETING_VERSION = ' "$PROJECT_FILE" | sed 's/.*= \(.*\);/\1/')
UPDATED_BUILD=$(grep -m1 'CURRENT_PROJECT_VERSION = ' "$PROJECT_FILE" | sed 's/.*= \(.*\);/\1/')
if [[ "$UPDATED_MARKETING" != "$NEW_MARKETING" ]] || [[ "$UPDATED_BUILD" != "$NEW_BUILD" ]]; then
  echo "Error: Version update failed!" >&2
  exit 1
fi

echo "Updated $PROJECT_FILE successfully."
