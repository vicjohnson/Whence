# Releasing Whence

## Prerequisites

- A fine-grained GitHub PAT with **Contents: read and write** on `vicjohnson/Whence`, stored in the environment variable `WHENCE_RELEASE_TOKEN`

## Steps

1. Bump the version in Xcode and commit the change
2. Archive, notarize, and export `Whence.app` to `versions/vX.X.X/`
3. Run the release script:
   ```bash
   WHENCE_RELEASE_TOKEN=your_pat ./release.sh vX.X.X
   ```

The script handles everything from there: zipping, appcast generation, committing, tagging, pushing, and creating the GitHub release with all artifacts attached.

## What `release.sh` does

1. Zips `versions/vX.X.X/Whence.app` -> `versions/vX.X.X/Whence-vX.X.X.zip`
2. Copies the zip to `versions/sparkle/` and regenerates the appcast (including delta updates)
3. Rewrites download URLs in the appcast to match GitHub's per-version release structure
4. Copies the updated appcast to `docs/appcast.xml` (served via GitHub Pages)
5. Copies any generated delta files back to `versions/vX.X.X/`
6. Commits `docs/appcast.xml`, tags the release, and pushes both
7. Creates the GitHub release and uploads the zip and deltas
