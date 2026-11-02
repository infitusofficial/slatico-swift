#!/usr/bin/env bash
# Builds and runs a clean, external SwiftPM consumer of SlaticoIcons.
#
#   bash .github/consumer/run-consumer.sh local  <path-to-slatico-swift-checkout>
#   bash .github/consumer/run-consumer.sh remote <git-url> <exact-version>
#
# `local` compiles the README examples against the checked-out sources (pre-release gate).
# `remote` resolves the published Git tag from scratch and verifies the pinned revision.
set -euo pipefail

MODE="${1:?usage: run-consumer.sh local <dir> | remote <url> <version>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${RUNNER_TEMP:-$(mktemp -d)}/slatico-consumer"

case "$MODE" in
  local)
    PKG_DIR="$(cd "${2:?missing package directory}" && pwd)"
    if [ "$(basename "$PKG_DIR")" != "slatico-swift" ]; then
      echo "::error::Local package directory must be named 'slatico-swift' so its SwiftPM identity matches the published URL (got '$(basename "$PKG_DIR")')."
      exit 1
    fi
    DEP=".package(path: \"$PKG_DIR\")"
    ;;
  remote)
    URL="${2:?missing git url}"
    VERSION="${3:?missing exact version}"
    DEP=".package(url: \"$URL\", exact: \"$VERSION\")"
    ;;
  *)
    echo "::error::Unknown mode '$MODE'"
    exit 1
    ;;
esac

rm -rf "$WORK"
mkdir -p "$WORK"
cp -R "$HERE/Sources" "$WORK/Sources"
TEMPLATE="$(cat "$HERE/Package.swift.template")"
printf '%s\n' "${TEMPLATE/__SLATICO_DEPENDENCY__/$DEP}" > "$WORK/Package.swift"

cd "$WORK"
echo "Consumer manifest dependency: $DEP"

swift package resolve

if [ "$MODE" = "remote" ]; then
  EXPECTED_REVISION="$(git ls-remote "$URL" "refs/tags/$VERSION^{}" | cut -f1)"
  if [ -z "$EXPECTED_REVISION" ]; then
    EXPECTED_REVISION="$(git ls-remote "$URL" "refs/tags/$VERSION" | cut -f1)"
  fi
  python3 - "$VERSION" "$EXPECTED_REVISION" <<'PY'
import json, sys
version, expected = sys.argv[1], sys.argv[2]
pins = json.load(open("Package.resolved"))["pins"]
pin = next(p for p in pins if p["identity"] == "slatico-swift")
state = pin["state"]
print(f"Resolved {pin['location']} -> version {state.get('version')} @ {state.get('revision')}")
assert state.get("version") == version, f"expected version {version}, got {state.get('version')}"
assert expected and state.get("revision") == expected, f"expected revision {expected}, got {state.get('revision')}"
PY
fi

swift build
swift run SlaticoConsumerCheck

xcodebuild build \
  -scheme SlaticoConsumer \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  COMPILER_INDEX_STORE_ENABLE=NO
