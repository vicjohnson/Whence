#!/bin/bash

# Packages, signs the appcast, and publishes a GitHub release for Whence.
# Usage: WHENCE_RELEASE_TOKEN=<pat> ./release.sh vX.X.X
#
# Prerequisites:
#   - Whence.app already archived, notarized, and exported to versions/vX.X.X/
#   - WHENCE_RELEASE_TOKEN set to a fine-grained PAT with Contents read/write on vicjohnson/Whence
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh v0.0.5"
    exit 1
fi

if [ -z "$WHENCE_RELEASE_TOKEN" ]; then
    echo "Error: WHENCE_RELEASE_TOKEN is not set"
    exit 1
fi

REPO="vicjohnson/Whence"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_DIR="$ROOT_DIR/versions/$VERSION"
SPARKLE_DIR="$ROOT_DIR/versions/sparkle"
DOCS_DIR="$ROOT_DIR/docs"
ZIP_NAME="Whence-$VERSION.zip"

# Ensure the working tree is clean so the release commit only contains appcast changes.
if [ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]; then
    echo "Error: uncommitted changes present"
    exit 1
fi

if [ ! -d "$VERSION_DIR/Whence.app" ]; then
    echo "Error: $VERSION_DIR/Whence.app not found"
    exit 1
fi

# Zip with ditto to preserve macOS metadata and code signature.
echo "Zipping Whence.app..."
ditto -c -k --sequesterRsrc --keepParent "$VERSION_DIR/Whence.app" "$VERSION_DIR/$ZIP_NAME"

# Sparkle's generate_appcast reads all zips in the directory to produce the appcast and deltas.
echo "Copying zip to sparkle directory..."
cp "$VERSION_DIR/$ZIP_NAME" "$SPARKLE_DIR/$ZIP_NAME"

echo "Generating appcast..."
generate_appcast --download-url-prefix "https://github.com/$REPO/releases/download/" "$SPARKLE_DIR"

# generate_appcast produces flat URLs; rewrite them to match GitHub's per-version release structure.
echo "Fixing download URLs..."
sed -i '' 's|download/Whence-\([^"]*\)\.zip|download/\1/Whence-\1.zip|g' "$SPARKLE_DIR/appcast.xml"
sed -i '' 's|download/Whence\([0-9.]*\)-\([0-9.]*\)\.delta|download/v\1/Whence\1-\2.delta|g' "$SPARKLE_DIR/appcast.xml"

# docs/appcast.xml is served via GitHub Pages and is what Sparkle polls for updates.
echo "Copying appcast to docs..."
cp "$SPARKLE_DIR/appcast.xml" "$DOCS_DIR/appcast.xml"

# Keep deltas alongside the zip so everything for this version is in one place.
echo "Copying deltas to version directory..."
find "$SPARKLE_DIR" -name "*.delta" -exec cp {} "$VERSION_DIR/" \;

echo "Committing and tagging..."
git -C "$ROOT_DIR" add docs/appcast.xml
git -C "$ROOT_DIR" commit -m "Release $VERSION"
git -C "$ROOT_DIR" tag "$VERSION"
git -C "$ROOT_DIR" push
git -C "$ROOT_DIR" push origin "$VERSION"

# Upload the zip and any delta files to the GitHub release.
echo "Creating GitHub release..."
RELEASE_FILES=("$VERSION_DIR/$ZIP_NAME")
for delta in "$VERSION_DIR"/*.delta; do
    [ -f "$delta" ] && RELEASE_FILES+=("$delta")
done
GH_TOKEN=$WHENCE_RELEASE_TOKEN gh release create "$VERSION" "${RELEASE_FILES[@]}" --title "Whence $VERSION"

echo ""
echo "Done. $VERSION is live."
