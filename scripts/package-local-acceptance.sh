#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/package-local-acceptance.sh [options]

Build a real local Release package for acceptance without uploading/signing for
GitHub Release production use.

Options:
  --output-dir <dir>     Output directory. Defaults to a temp dir.
  --release-tag <tag>    Tag recorded into the embedded remote-daemon manifest.
                         Defaults to local-acceptance-<UTC timestamp>.
  --repo <owner/repo>    Release repo for remote-daemon URLs.
                         Defaults to .release-policy.json releaseRepo.
  --skip-dmg             Build the Release app bundle only, skip DMG creation.
  -h, --help             Show this help.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

OUTPUT_DIR=""
RELEASE_TAG=""
RELEASE_REPO=""
SKIP_DMG="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --release-tag)
      RELEASE_TAG="${2:-}"
      shift 2
      ;;
    --repo)
      RELEASE_REPO="${2:-}"
      shift 2
      ;;
    --skip-dmg)
      SKIP_DMG="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

read_release_policy() {
  local field="$1"
  python3 - "$field" <<'PY'
import json
import sys
from pathlib import Path

field = sys.argv[1]
policy_path = Path(".release-policy.json")
if not policy_path.exists():
    print("error: .release-policy.json not found", file=sys.stderr)
    raise SystemExit(1)

policy = json.loads(policy_path.read_text(encoding="utf-8"))
value = policy.get(field, "")
if not value:
    print(f"error: .release-policy.json missing {field}", file=sys.stderr)
    raise SystemExit(1)

print(value)
PY
}

require_tool() {
  local tool="$1"
  command -v "$tool" >/dev/null 2>&1 || {
    echo "error: missing required tool: $tool" >&2
    exit 1
  }
}

if [[ -z "$RELEASE_REPO" ]]; then
  RELEASE_REPO="$(read_release_policy releaseRepo)"
fi

if [[ -z "$RELEASE_TAG" ]]; then
  RELEASE_TAG="local-acceptance-$(date -u +%Y%m%dT%H%M%SZ)"
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/cmax-local-package.XXXXXX")"
else
  mkdir -p "$OUTPUT_DIR"
fi
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

WORK_DIR="$OUTPUT_DIR/.work"
BUILD_DIR="$WORK_DIR/build-universal"
SOURCE_PACKAGES_DIR="${CMUX_PACKAGE_SOURCE_PACKAGES_DIR:-$WORK_DIR/.spm-cache}"
REMOTE_ASSETS_DIR="$OUTPUT_DIR/remote-daemon-assets"
APP_BUNDLE_OUT="$OUTPUT_DIR/cmux.app"
DMG_OUT="$OUTPUT_DIR/cmax-macos-local.dmg"
BUILD_INFO_OUT="$OUTPUT_DIR/package-info.json"

mkdir -p "$WORK_DIR" "$SOURCE_PACKAGES_DIR" "$REMOTE_ASSETS_DIR"

require_tool xcodebuild
require_tool python3
require_tool go
require_tool zig
require_tool codesign
require_tool ditto
require_tool hdiutil
if [[ ! -x /usr/libexec/PlistBuddy ]]; then
  echo "error: missing required tool: /usr/libexec/PlistBuddy" >&2
  exit 1
fi

if [[ ! -d "GhosttyKit.xcframework" ]]; then
  echo "==> GhosttyKit.xcframework missing, preparing local xcframework cache"
  ./scripts/ensure-ghosttykit.sh
fi

echo "==> building Release app bundle"
xcodebuild -project GhosttyTabs.xcodeproj -scheme cmux -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  -destination 'generic/platform=macOS' \
  -clonedSourcePackagesDirPath "$SOURCE_PACKAGES_DIR" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$BUILD_DIR/Build/Products/Release/cmux.app"
APP_PLIST="$APP_PATH/Contents/Info.plist"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: Release app bundle not found at $APP_PATH" >&2
  exit 1
fi

APP_VERSION="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PLIST"
)"
APP_BUILD="$(
  /usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PLIST"
)"

echo "==> building remote daemon release assets"
./scripts/build_remote_daemon_release_assets.sh \
  --version "$APP_VERSION" \
  --release-tag "$RELEASE_TAG" \
  --repo "$RELEASE_REPO" \
  --output-dir "$REMOTE_ASSETS_DIR"

BUNDLED_REMOTE_ASSETS_DIR="$APP_PATH/Contents/Resources/remote-daemon-assets"
echo "==> bundling remote daemon assets into app"
rm -rf "$BUNDLED_REMOTE_ASSETS_DIR"
ditto "$REMOTE_ASSETS_DIR" "$BUNDLED_REMOTE_ASSETS_DIR"

MANIFEST_JSON="$(
  python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1], encoding="utf-8")), separators=(",",":")))' \
    "$REMOTE_ASSETS_DIR/cmuxd-remote-manifest.json"
)"
plutil -remove CMUXRemoteDaemonManifestJSON "$APP_PLIST" >/dev/null 2>&1 || true
plutil -insert CMUXRemoteDaemonManifestJSON -string "$MANIFEST_JSON" "$APP_PLIST"

echo "==> applying ad-hoc codesign for local launch"
/usr/bin/codesign --force --sign - --timestamp=none --deep "$APP_PATH"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_PATH"

rm -rf "$APP_BUNDLE_OUT"
ditto "$APP_PATH" "$APP_BUNDLE_OUT"

if [[ "$SKIP_DMG" != "true" ]]; then
  echo "==> creating DMG"
  rm -f "$OUTPUT_DIR"/*.dmg
  hdiutil create \
    -volname "cmax" \
    -srcfolder "$APP_BUNDLE_OUT" \
    -ov \
    -format UDZO \
    "$DMG_OUT" >/dev/null
fi

python3 - <<'PY' "$BUILD_INFO_OUT" "$APP_VERSION" "$APP_BUILD" "$RELEASE_TAG" "$RELEASE_REPO" "$APP_BUNDLE_OUT" "$DMG_OUT" "$SKIP_DMG"
import json
import sys
from pathlib import Path

out, version, build, tag, repo, app_path, dmg_path, skip_dmg = sys.argv[1:]
payload = {
    "appVersion": version,
    "appBuild": build,
    "releaseTag": tag,
    "releaseRepo": repo,
    "appBundlePath": app_path,
    "dmgPath": None if skip_dmg == "true" else dmg_path,
}
Path(out).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

echo
echo "==> local acceptance package ready"
echo "Output directory: $OUTPUT_DIR"
echo "App bundle: $APP_BUNDLE_OUT"
if [[ "$SKIP_DMG" != "true" ]]; then
  echo "DMG: $DMG_OUT"
fi
echo "Remote daemon assets: $REMOTE_ASSETS_DIR"
echo "Metadata: $BUILD_INFO_OUT"
