# cmax fork release policy

This fork ships independent product versions while tracking cmux as the upstream codebase.

## Version policy

- First cmax release: `1.0.0`
- Upstream base for `1.0.0`: `0.63.2`
- Product major stays on `1` for the current fork line
- Upstream `0.63.3` maps to cmax `1.0.1`
- Upstream `0.64.0` maps to cmax `1.1.0`
- For later upstream updates, compare the upstream `Y.Z` delta against the recorded base in `.release-policy.json`

## Release steps

1. Sync or cherry-pick the required upstream functional changes.
2. Update `.release-policy.json` with the target upstream version.
3. Run `./scripts/bump-version.sh --upstream <upstream-version>` or pass an explicit cmax product version when needed.
4. Update `CHANGELOG.md` and include `Based on cmux <upstream-version>`.
5. Merge to `main`, run `./scripts/release-pretag-guard.sh`, then tag `v<product-version>`.
6. Push the tag to trigger `.github/workflows/release.yml`.

## Build number rule

`CURRENT_PROJECT_VERSION` must always be strictly greater than the latest published Sparkle build in this fork's stable appcast. Never decrement it after merging upstream.
