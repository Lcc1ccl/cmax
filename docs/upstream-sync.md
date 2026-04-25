# cmax upstream sync policy

This fork no longer mirrors all upstream repository content. Keep the fork lean and bring over only required functional changes.

## Remotes

```bash
git remote add upstream https://github.com/manaflow-ai/cmux.git
git fetch upstream --tags
```

## Default sync strategy

- Do **not** merge upstream `main` blindly.
- Prefer targeted `git cherry-pick -x <commit>` for needed functional fixes.
- When a larger upstream release is needed, review the tag diff first and cherry-pick only the required code/test/docs changes for the app itself.

## Paths intentionally trimmed from this fork

The fork no longer carries these upstream areas by default:

- `web/`
- `homebrew-cmux/`
- `.claude/`
- non-essential GitHub workflows (nightly, homebrew, Claude bot, depot/e2e, extra compatibility lanes)
- translated `README.*.md` variants

## Safe pull scope

Prefer updates under these areas when bringing functionality forward:

- `Sources/`
- `CLI/`
- `Resources/`
- `daemon/`
- `scripts/` that are required for build or release
- `tests/`, `cmuxTests/`, `cmuxUITests/` when they protect imported behavior
- `ghostty` and `vendor/bonsplit` submodule pointers only when the feature depends on them

## Post-sync checks

1. Re-run the minimal CI workflow.
2. Confirm `.release-policy.json` still matches the intended upstream baseline.
3. Verify release scripts still point at `Lcc1ccl/cmax` rather than upstream cmux.
