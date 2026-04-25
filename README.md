<h1 align="center">cmax</h1>
<p align="center">A lean fork of cmux focused on the macOS app, agent workflows, and release stability.</p>

<p align="center">
  <a href="https://github.com/Lcc1ccl/cmax/releases/latest/download/cmax-macos.dmg">
    <img src="./docs/assets/macos-badge.png" alt="Download cmax for macOS" width="180" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/Lcc1ccl/cmax"><img src="https://img.shields.io/github/stars/Lcc1ccl/cmax?style=flat&logo=github&label=stars&color=4c71f2" alt="GitHub stars" /></a>
  <a href="https://github.com/Lcc1ccl/cmax/issues"><img src="https://img.shields.io/badge/Issues-555?logo=github" alt="GitHub Issues" /></a>
</p>

<p align="center">
  <img src="./docs/assets/main-first-image.png" alt="cmax screenshot" width="900" />
</p>

## What this fork ships

- Native macOS terminal app built on Ghostty + Swift/AppKit
- Vertical workspace tabs, notifications, browser pane, and agent-oriented automation
- Independent Sparkle release feed and GitHub Releases under `Lcc1ccl/cmax`
- Trimmed repository scope: no website, no Homebrew tap mirror, no nightly pipeline

## Install

### DMG (recommended)

<a href="https://github.com/Lcc1ccl/cmax/releases/latest/download/cmax-macos.dmg">
  <img src="./docs/assets/macos-badge.png" alt="Download cmax for macOS" width="180" />
</a>

Open the `.dmg` and drag `cmux.app` to your Applications folder. This fork publishes updates through Sparkle from its own GitHub release feed, so you only need to install once.

On first launch, macOS may ask you to confirm opening an app from an identified developer. Click **Open** to proceed.

## Release baseline

- Current cmax version: `1.0.0`
- Based on upstream cmux: `0.63.2`

See [`docs/fork-release.md`](./docs/fork-release.md) for the fork versioning and release policy, and [`docs/upstream-sync.md`](./docs/upstream-sync.md) for the upstream sync rules.

## Documentation

Repository documentation now lives directly under [`docs/`](./docs). Useful entry points:

- [`CHANGELOG.md`](./CHANGELOG.md)
- [`docs/notifications.md`](./docs/notifications.md)
- [`docs/project-workspace-defaults.md`](./docs/project-workspace-defaults.md)
- [`docs/remote-daemon-spec.md`](./docs/remote-daemon-spec.md)

## Keyboard Shortcuts


### Workspaces

| Shortcut | Action |
|----------|--------|
| ⌘ N | New workspace |
| ⌘ O | Open folder |
| ⌘ 1–8 | Jump to workspace 1–8 |
| ⌘ 9 | Jump to last workspace |
| ⌃ ⌘ ] | Next workspace |
| ⌃ ⌘ [ | Previous workspace |
| ⌘ ⇧ W | Close workspace |
| ⌘ ⇧ R | Rename workspace |
| ⌘ B | Toggle sidebar |

Use **⌘O** when you want to explicitly choose a folder for the next workspace.

### Surfaces

| Shortcut | Action |
|----------|--------|
| ⌘ T | New surface |
| ⌘ ⇧ ] | Next surface |
| ⌘ ⇧ [ | Previous surface |
| ⌃ Tab | Next surface |
| ⌃ ⇧ Tab | Previous surface |
| ⌃ 1–8 | Jump to surface 1–8 |
| ⌃ 9 | Jump to last surface |
| ⌘ W | Close surface |

### Split Panes

| Shortcut | Action |
|----------|--------|
| ⌘ D | Split right |
| ⌘ ⇧ D | Split down |
| ⌥ ⌘ ← → ↑ ↓ | Focus pane directionally |
| ⌘ ⇧ H | Flash focused panel |

### Browser

Browser developer-tool shortcuts follow Safari defaults and are customizable in `Settings → Keyboard Shortcuts`.

| Shortcut | Action |
|----------|--------|
| ⌘ ⇧ L | Open browser in split |
| ⌘ L | Focus address bar |
| ⌘ [ | Back |
| ⌘ ] | Forward |
| ⌘ R | Reload page |
| ⌥ ⌘ I | Toggle Developer Tools (Safari default) |
| ⌥ ⌘ C | Show JavaScript Console (Safari default) |

### Notifications

| Shortcut | Action |
|----------|--------|
| ⌘ I | Show notifications panel |
| ⌘ ⇧ U | Jump to latest unread |

### Find

| Shortcut | Action |
|----------|--------|
| ⌘ F | Find |
| ⌘ G / ⌘ ⇧ G | Find next / previous |
| ⌘ ⇧ F | Hide find bar |
| ⌘ E | Use selection for find |

### Terminal

| Shortcut | Action |
|----------|--------|
| ⌘ K | Clear scrollback |
| ⌘ C | Copy (with selection) |
| ⌘ V | Paste |
| ⌘ + / ⌘ - | Increase / decrease font size |
| ⌘ 0 | Reset font size |

### Window

| Shortcut | Action |
|----------|--------|
| ⌘ ⇧ N | New window |
| ⌘ , | Settings |
| ⌘ ⇧ , | Reload configuration |
| ⌘ Q | Quit |

## Contributing

- Open issues or pull requests in [Lcc1ccl/cmax](https://github.com/Lcc1ccl/cmax).
- Follow [`CONTRIBUTING.md`](./CONTRIBUTING.md) for local setup.
- Keep upstream syncs narrow and functional; see [`docs/upstream-sync.md`](./docs/upstream-sync.md).

## License

This fork remains available under the repository license.
