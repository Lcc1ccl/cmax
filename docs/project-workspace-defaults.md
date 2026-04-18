# Project/workspace default behavior review

This note distills the approved plan in `.omx/plans/ralplan-cmax-tmp-project-default-workspace.md` into a repo-local implementation and review contract.

## Verified gaps in the current code

- `ProjectModelController.displayProject` still synthesizes per-path `temp:<rootPath>` records, and `sidebarSections` still falls back to `workspace:<uuid>` sections. Nil-project workspaces therefore do **not** collapse into a single tmp section today. See `Sources/ProjectStore.swift:371-417`.
- `syncWorkspaceBinding(_:)` still resolves and binds nil-project workspaces through `ActiveProjectResolver`, and `restoreWorkspaceBindings(...)` falls back to that same path whenever a snapshot has no durable project. This can re-promote tmp/default workspaces into durable projects. See `Sources/ProjectStore.swift:443-490`.
- `handleNewWorkspaceRequest(...)` still opens the folder picker whenever there is no active durable project, so `⌘N` is not yet a pure “new tmp workspace” action from the default/tmp state. `createMainWindow(...)` also syncs the default startup workspace immediately. See `Sources/AppDelegate.swift:6872-6900` and `Sources/AppDelegate.swift:7362-7374`.

## Approved behavior contract

- Do **not** expand the session schema for this change.
- Only explicit folder selection or restored durable `projectId` values may create/retain durable bindings.
- Every workspace with `projectId == nil` must render under one shared tmp sentinel section.
- Tmp is a UI-only concept: no tmp durable record in `workspace.projectId`, `WorkspaceBindingStore`, snapshot `projects`, or restore catalog.
- When no durable source exists, `syncWorkspaceBinding(_:)` and `restoreWorkspaceBindings(...)` must first clear stale bindings, then leave the workspace unbound.
- `⌘N` stays “New Workspace”; `⌘O` stays the only explicit folder-selection entry point.

## File-level review checklist

- `Sources/ProjectStore.swift`
  - Remove inferred durable binding for nil-project workspaces.
  - Keep `activeProject(for:)` nil for tmp workspaces.
  - Return a shared tmp sentinel from `displayProject(for:)`.
- `Sources/AppDelegate.swift`
  - Keep the cold-start workspace unbound when there is no restore snapshot or explicit directory.
  - Route `⌘N` to “new tmp workspace” when there is no active durable project.
  - Route `⌘O` to the folder picker and durable bind path only.
- `Sources/ContentView.swift`, `Sources/cmuxApp.swift`, `Sources/KeyboardShortcutSettings*.swift`
  - Preserve the existing two-action shortcut model: `newTab`/`⌘N` and `openFolder`/`⌘O`.
  - Do not add `Cmd+Option+N`.
- `cmuxTests/ProjectStoreTests.swift`, `cmuxTests/AppDelegateShortcutRoutingTests.swift`, `cmuxTests/SessionPersistenceTests.swift`
  - Cover tmp sentinel merging, stale-binding cleanup, restore/save durability boundaries, and `⌘N` vs `⌘O` routing.

## Review evidence to collect before merge

- Unit: nil-project workspaces stay unbound and share one tmp sentinel.
- Integration: cold start shows tmp, `⌘N` adds tmp workspace, `⌘O` creates a durable project workspace.
- Persistence: saved session snapshots never contain a tmp durable project.
- Shortcut consistency: app settings, schema/docs data, and user-facing docs all describe the same `⌘N` / `⌘O` contract.
