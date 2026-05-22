# Releasing Whence

1. Bump version
2. Archive
3. Notarize
  1. Export `Whence.app` to `versions/vX.X.X`
4. `./release.sh vX.X.X`
5. Git commit/tag/push
6. Create release
  1. Upload `.zip` and `.delta`

## More about `release.sh`

```bash
./release.sh vX.X.X
```

This will:
- Zip `versions/vX.X.X/Whence.app` -> `versions/vX.X.X/Whence-vX.X.X.zip`
- Copy the zip to `versions/sparkle/` and regenerate the appcast
- Fix GitHub Releases download URLs in the appcast
- Copy the updated appcast to `docs/appcast.xml`
- Copy any generated delta files back to `versions/vX.X.X/`
