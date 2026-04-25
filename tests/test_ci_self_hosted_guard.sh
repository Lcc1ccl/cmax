#!/usr/bin/env bash
# Ensures the remaining paid CI jobs use WarpBuild runners.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CI_FILE="$ROOT_DIR/.github/workflows/ci.yml"
RELEASE_FILE="$ROOT_DIR/.github/workflows/release.yml"

check_warp_runner() {
  local file="$1" job="$2"
  if ! awk -v job="$job" '
    $0 ~ "^  "job":" { in_job=1; next }
    in_job && /^  [^[:space:]]/ { in_job=0 }
    in_job && /runs-on:.*warp-macos-.*-arm64/ { saw_warp=1 }
    END { exit !(saw_warp) }
  ' "$file"; then
    echo "FAIL: $job in $(basename "$file") must use a WarpBuild runner"
    exit 1
  fi
}

check_warp_runner "$CI_FILE" "tests"
check_warp_runner "$RELEASE_FILE" "build-sign-notarize"

echo "PASS: WarpBuild runners are pinned for the remaining macOS jobs"
