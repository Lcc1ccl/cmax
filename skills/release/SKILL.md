---
name: release
description: "Prepare and ship a cmax release end-to-end: map the fork version from the upstream sync target, update the changelog, bump app/build metadata, tag the release, and verify published Sparkle assets. Use when asked to cut, prepare, publish, or tag a cmax release."
---

# Release

Run this workflow to prepare and publish a cmax release.

## Workflow

1. Determine the target version:
- Read `.release-policy.json` and `docs/fork-release.md`.
- Default to `./scripts/bump-version.sh --upstream <x.y.z>` when the user gives an upstream cmux version.
- Use `./scripts/bump-version.sh <product-version>` only when the user explicitly wants a specific cmax version.

2. Create a release branch:
- `git checkout -b release/vX.Y.Z`

3. Gather user-facing changes since the last tag:
- `git describe --tags --abbrev=0`
- `git log --oneline <last-tag>..HEAD --no-merges`
- Keep only end-user visible changes (features, bug fixes, UX/perf behavior, release-surface cleanup).
- If no user-facing changes exist, confirm with the user before continuing.

4. Update release docs:
- Update `CHANGELOG.md`.
- Include the upstream base or sync target in the release notes when relevant (for example `Based on cmux 0.63.3`).
- Do not maintain a separate website changelog in this fork.

5. Bump app version metadata:
- Prefer `./scripts/bump-version.sh --upstream <x.y.z>`.
- Ensure both `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` are updated.
- Confirm `.release-policy.json` was updated when using `--upstream`.

6. Commit and push branch:
- Stage release files (policy/changelog/version updates).
- Commit with a Lore-format message.
- `git push -u origin release/vX.Y.Z`.

7. Create release PR:
- `gh pr create --title "Release vX.Y.Z" --body "..."`
- Include a concise changelog summary and the upstream cmux baseline/sync target.

8. Watch CI and resolve failures:
- `gh pr checks --watch`
- Fix failing checks, push, and wait for green.

9. Merge and sync `main`:
- `gh pr merge --squash --delete-branch`
- `git checkout main && git pull --ff-only`

10. Run the pre-tag guard, then create and push tag:
- `./scripts/release-pretag-guard.sh`
- If it fails, run `./scripts/bump-version.sh ...`, commit the build-number bump, push/merge that change, and retry the tag.
- `git tag vX.Y.Z`
- `git push origin vX.Y.Z`

11. Verify release workflow and assets:
- `gh run watch --repo Lcc1ccl/cmax`
- Confirm GitHub Releases contains `cmax-macos.dmg`, `appcast.xml`, and the remote-daemon assets for the tag.
- Confirm `https://github.com/Lcc1ccl/cmax/releases/latest/download/appcast.xml` is updated only if the repository owner actually matches; otherwise use the canonical repo from `.release-policy.json`.

## cmax Fork Rules

- Version mapping follows `docs/fork-release.md` and `.release-policy.json`.
- Keep the release surface lean: no website, no Homebrew tap, no nightly lane.
- Do not reintroduce upstream-wide release steps that depend on deleted paths such as `web/`, `homebrew-cmux/`, or extra release workflows.
- Release notes should stay user-facing and mention upstream cmux sync only when it matters to users.

## Required secrets

- `SPARKLE_PRIVATE_KEY`
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_RELEASE_PROVISIONING_PROFILE_BASE64`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `APPLE_TEAM_ID`
