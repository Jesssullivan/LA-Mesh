#!/usr/bin/env bash
# LA-Mesh: Update firmware manifest with latest upstream release
# Usage: ./tools/flash/update-manifest.sh [--version VERSION]
#
# Fetches the latest Meshtastic release metadata from GitHub,
# downloads firmware binaries, computes SHA256 hashes, and
# updates firmware/manifest.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$ROOT_DIR/firmware/manifest.json"
CACHE_DIR="${FIRMWARE_CACHE_DIR:-$ROOT_DIR/firmware/.cache}"

VERSION=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help)
            echo "Usage: $0 [--version VERSION] [--dry-run]"
            echo ""
            echo "Updates firmware/manifest.json with a new firmware version."
            echo "If --version is not specified, uses the latest GitHub release."
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check dependencies
for cmd in jq gh sha256sum; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: Required tool not found: $cmd"
        exit 1
    fi
done

# Get version
if [ -z "$VERSION" ]; then
    echo "Fetching latest Meshtastic release from GitHub..."
    VERSION=$(gh api repos/meshtastic/firmware/releases/latest --jq '.tag_name' | sed 's/^v//')
    if [ -z "$VERSION" ]; then
        echo "ERROR: Could not determine latest version. Is gh authenticated?"
        exit 1
    fi
fi

CURRENT=$(jq -r '.meshtastic.version' "$MANIFEST")
echo "Current version: v$CURRENT"
echo "Target version:  v$VERSION"

if [ "$CURRENT" = "$VERSION" ]; then
    echo "Already at v$VERSION. Use --version to specify a different version."
    exit 0
fi

if [ "$DRY_RUN" = "true" ]; then
    echo ""
    echo "[DRY RUN] Would update manifest from v$CURRENT to v$VERSION"
    echo "Run without --dry-run to apply."
    exit 0
fi

# Download firmware
echo ""
echo "Downloading firmware v$VERSION..."
"$SCRIPT_DIR/fetch-firmware.sh" --version "$VERSION" --force

# Update manifest version
echo ""
echo "Updating manifest..."
RELEASE_URL="https://github.com/meshtastic/firmware/releases/download/v${VERSION}/firmware-${VERSION}.zip"
RELEASE_NOTES="https://github.com/meshtastic/firmware/releases/tag/v${VERSION}"

jq \
    --arg ver "$VERSION" \
    --arg url "$RELEASE_URL" \
    --arg notes "$RELEASE_NOTES" \
    '.meshtastic.version = $ver |
     .meshtastic.release_url = $url |
     .meshtastic.release_notes = $notes' \
    "$MANIFEST" > "$MANIFEST.tmp"
mv "$MANIFEST.tmp" "$MANIFEST"

# Update binary names and SHA256 hashes
for device in $(jq -r '.meshtastic.devices | keys[]' "$MANIFEST"); do
    OLD_BINARY=$(jq -r ".meshtastic.devices[\"$device\"].binary" "$MANIFEST")
    # Replace version in binary name
    NEW_BINARY=$(echo "$OLD_BINARY" | sed "s/[0-9]\+\.[0-9]\+\.[0-9]\+/$VERSION/g")

    FIRMWARE_FILE="$CACHE_DIR/$NEW_BINARY"
    if [ -f "$FIRMWARE_FILE" ]; then
        HASH=$(sha256sum "$FIRMWARE_FILE" | cut -d' ' -f1)
    else
        # Try to find it in the extraction directory
        FIRMWARE_FILE=$(find "$CACHE_DIR" -name "$NEW_BINARY" -type f 2>/dev/null | head -1)
        if [ -n "$FIRMWARE_FILE" ]; then
            HASH=$(sha256sum "$FIRMWARE_FILE" | cut -d' ' -f1)
        else
            HASH="UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD"
            echo "  WARNING: Binary not found for $device: $NEW_BINARY"
        fi
    fi

    # Update littlefs name too
    OLD_LITTLEFS=$(jq -r ".meshtastic.devices[\"$device\"].littlefs" "$MANIFEST")
    NEW_LITTLEFS=$(echo "$OLD_LITTLEFS" | sed "s/[0-9]\+\.[0-9]\+\.[0-9]\+/$VERSION/g")

    jq \
        --arg dev "$device" \
        --arg bin "$NEW_BINARY" \
        --arg lfs "$NEW_LITTLEFS" \
        --arg sha "$HASH" \
        '.meshtastic.devices[$dev].binary = $bin |
         .meshtastic.devices[$dev].littlefs = $lfs |
         .meshtastic.devices[$dev].sha256 = $sha' \
        "$MANIFEST" > "$MANIFEST.tmp"
    mv "$MANIFEST.tmp" "$MANIFEST"

    echo "  $device: $NEW_BINARY (SHA256: ${HASH:0:16}...)"
done

echo ""
echo "Manifest updated: $MANIFEST"
echo ""
echo "Review changes:"
echo "  git diff firmware/manifest.json"
echo ""
echo "To commit:"
echo "  git add firmware/manifest.json"
echo "  git commit -m 'firmware: update Meshtastic to v$VERSION'"
