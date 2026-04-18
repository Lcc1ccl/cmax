import XCTest

#if canImport(cmux_DEV)
@testable import cmux_DEV
#elseif canImport(cmux)
@testable import cmux
#endif

final class ProjectResolverTests: XCTestCase {
    func testResolveExplicitSelectionHonorsUserPath() {
        let result = ProjectResolver.resolve(
            directory: "/Users/tester/work/app/Sources/Feature",
            resolutionMode: .explicitSelection,
            environment: .init(
                homeDirectoryPath: "/Users/tester",
                directoryExists: { _ in true },
                gitRootResolver: { _ in
                    XCTFail("Explicit user selection must not be rewritten to git root")
                    return nil
                }
            )
        )

        XCTAssertEqual(
            result,
            ProjectResolver.Result(
                rootPath: "/Users/tester/work/app/Sources/Feature",
                displayName: "Feature",
                missingProject: nil
            )
        )
    }

    func testResolveInferredWorkspacePrefersGitRootForNestedDirectory() {
        let result = ProjectResolver.resolve(
            directory: "/Users/tester/work/app/Sources/Feature",
            resolutionMode: .inferredWorkspace,
            environment: .init(
                homeDirectoryPath: "/Users/tester",
                directoryExists: { _ in true },
                gitRootResolver: { path in
                    XCTAssertEqual(path, "/Users/tester/work/app/Sources/Feature")
                    return "/Users/tester/work/app"
                }
            )
        )

        XCTAssertEqual(
            result,
            ProjectResolver.Result(
                rootPath: "/Users/tester/work/app",
                displayName: "app",
                missingProject: nil
            )
        )
    }

    func testResolveExpandsTildeBeforeDeduping() {
        let result = ProjectResolver.resolve(
            directory: "~/work/app",
            resolutionMode: .explicitSelection,
            environment: .init(
                homeDirectoryPath: "/Users/tester",
                directoryExists: { path in
                    XCTAssertEqual(path, "/Users/tester/work/app")
                    return true
                },
                gitRootResolver: { _ in nil }
            )
        )

        XCTAssertEqual(result?.rootPath, "/Users/tester/work/app")
        XCTAssertEqual(result?.displayName, "app")
    }

    func testResolveReturnsMissingProjectWhenDirectoryDoesNotExist() {
        let result = ProjectResolver.resolve(
            directory: "/Users/tester/work/missing-app",
            resolutionMode: .explicitSelection,
            environment: .init(
                homeDirectoryPath: "/Users/tester",
                directoryExists: { _ in false },
                gitRootResolver: { _ in nil }
            )
        )

        XCTAssertEqual(
            result,
            ProjectResolver.Result(
                rootPath: "/Users/tester/work/missing-app",
                displayName: "missing-app",
                missingProject: MissingProject(
                    requestedPath: "/Users/tester/work/missing-app",
                    displayName: "missing-app"
                )
            )
        )
    }
}

final class ProjectStoreTests: XCTestCase {
    func testUpsertDedupesAbsoluteAndTildePathsToOneProject() {
        let store = ProjectStore(
            environment: .init(
                homeDirectoryPath: "/Users/tester",
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )

        let first = store.upsert(directory: "/Users/tester/work/app", resolutionMode: .explicitSelection)
        let second = store.upsert(directory: "~/work/app", resolutionMode: .explicitSelection)

        XCTAssertEqual(first, second)
        XCTAssertEqual(store.projects.count, 1)
        XCTAssertEqual(store.projects.first?.rootPathCached, "/Users/tester/work/app")
    }

    func testUpsertGeneratesStableProjectIdIndependentFromPath() {
        let store = ProjectStore(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )

        let project = store.upsert(directory: "/tmp/app", resolutionMode: .explicitSelection)

        XCTAssertNotNil(project)
        XCTAssertEqual(project?.rootPathCached, "/tmp/app")
        XCTAssertFalse(project?.projectId.isEmpty ?? true)
        XCTAssertNotEqual(project?.projectId, project?.rootPathCached)
    }

    func testUpsertMissingProjectIndexesByMissingIdentifier() {
        let store = ProjectStore(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in false },
                gitRootResolver: { _ in nil }
            )
        )

        let project = store.upsert(directory: "/tmp/missing-project", resolutionMode: .explicitSelection)

        XCTAssertEqual(store.project(id: project?.projectId), project)
        XCTAssertEqual(project?.missingProject?.requestedPath, "/tmp/missing-project")
    }

    func testRepairKeepsProjectIdWhileUpdatingRootPath() {
        let store = ProjectStore(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { path in
                    path != "/tmp/missing-project"
                },
                gitRootResolver: { _ in nil }
            )
        )

        let missingProject = store.upsert(directory: "/tmp/missing-project", resolutionMode: .explicitSelection)
        let repairedProject = store.repair(
            projectId: missingProject?.projectId ?? "",
            directory: "/tmp/repaired-project/subdir"
        )

        XCTAssertEqual(repairedProject?.projectId, missingProject?.projectId)
        XCTAssertEqual(repairedProject?.rootPathCached, "/tmp/repaired-project/subdir")
        XCTAssertNil(repairedProject?.missingProject)
    }
}

final class WorkspaceBindingStoreTests: XCTestCase {
    func testBindAndUnbindWorkspaceProject() {
        let workspaceId = UUID()
        let store = WorkspaceBindingStore()

        store.bind(workspaceId: workspaceId, projectId: "project-1")
        XCTAssertEqual(store.projectId(for: workspaceId), "project-1")

        store.unbind(workspaceId: workspaceId)
        XCTAssertNil(store.projectId(for: workspaceId))
    }
}

final class ActiveProjectResolverTests: XCTestCase {
    func testResolvePrefersExistingWorkspaceBinding() {
        let workspaceId = UUID()
        let focusedPanelId = UUID()
        let projectStore = ProjectStore(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )
        let boundProject = projectStore.upsert(directory: "/tmp/bound", resolutionMode: .explicitSelection)!
        _ = projectStore.upsert(directory: "/tmp/focused", resolutionMode: .explicitSelection)

        let bindings = WorkspaceBindingStore()
        bindings.bind(workspaceId: workspaceId, projectId: boundProject.id)

        let result = ActiveProjectResolver.resolve(
            context: .init(
                workspaceId: workspaceId,
                focusedPanelId: focusedPanelId,
                orderedPanelIds: [focusedPanelId],
                panelDirectories: [focusedPanelId: "/tmp/focused"],
                requestedPanelDirectories: [:],
                currentDirectory: "/tmp/current"
            ),
            projectStore: projectStore,
            workspaceBindingStore: bindings
        )

        XCTAssertEqual(result, boundProject)
    }

    func testResolveFallsBackFromFocusedPanelToRequestedAndCurrentDirectory() {
        let workspaceId = UUID()
        let focusedPanelId = UUID()
        let otherPanelId = UUID()
        let projectStore = ProjectStore(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { path in
                    path != "/tmp/missing"
                },
                gitRootResolver: { _ in nil }
            )
        )

        let result = ActiveProjectResolver.resolve(
            context: .init(
                workspaceId: workspaceId,
                focusedPanelId: focusedPanelId,
                orderedPanelIds: [focusedPanelId, otherPanelId],
                panelDirectories: [focusedPanelId: "/tmp/missing"],
                requestedPanelDirectories: [focusedPanelId: "/tmp/requested"],
                currentDirectory: "/tmp/current"
            ),
            projectStore: projectStore,
            workspaceBindingStore: WorkspaceBindingStore()
        )

        XCTAssertEqual(result?.rootPathCached, "/tmp/requested")
    }
}

@MainActor
final class ProjectModelControllerTests: XCTestCase {
    func testSyncWorkspaceBindingLeavesNilProjectWorkspaceUnboundAndClearsStaleBinding() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in "/tmp/app" }
            )
        )
        let workspace = Workspace(title: "Tmp", workingDirectory: "/tmp/app")

        let boundProject = controller.bindUserSelectedProject(to: workspace, directory: "/tmp/app")
        XCTAssertEqual(workspace.projectId, boundProject?.projectId)
        XCTAssertEqual(controller.project(for: workspace.id)?.projectId, boundProject?.projectId)

        workspace.projectId = nil

        let resolved = controller.syncWorkspaceBinding(workspace)

        XCTAssertNil(resolved)
        XCTAssertNil(workspace.projectId)
        XCTAssertNil(controller.project(for: workspace.id))
    }

    func testDisplayProjectUsesSharedTmpSentinelForNilProjectWorkspaces() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )
        let firstWorkspace = Workspace(title: "One", workingDirectory: "/tmp/one")
        let secondWorkspace = Workspace(title: "Two", workingDirectory: "/tmp/two")

        let firstDisplay = controller.displayProject(for: firstWorkspace)
        let secondDisplay = controller.displayProject(for: secondWorkspace)

        XCTAssertEqual(firstDisplay?.projectId, secondDisplay?.projectId)
        XCTAssertEqual(firstDisplay?.displayName, secondDisplay?.displayName)
        XCTAssertNil(firstDisplay?.missingProject)
        XCTAssertNil(secondDisplay?.missingProject)
    }

    func testSidebarSectionsGroupWorkspacesByResolvedProject() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { path in
                    if path.hasPrefix("/tmp/app") {
                        return "/tmp/app"
                    }
                    return nil
                }
            )
        )
        let firstWorkspace = Workspace(title: "One", workingDirectory: "/tmp/app")
        let secondWorkspace = Workspace(title: "Two", workingDirectory: "/tmp/app/feature")

        _ = controller.bindUserSelectedProject(to: firstWorkspace, directory: "/tmp/app")
        _ = controller.syncWorkspaceBinding(secondWorkspace)

        let sections = controller.sidebarSections(for: [firstWorkspace, secondWorkspace])

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.project.rootPathCached, "/tmp/app")
        XCTAssertEqual(sections.first?.workspaces.map(\.id), [firstWorkspace.id, secondWorkspace.id])
    }

    func testSidebarSectionsMergeNilProjectWorkspacesIntoSharedTmpSection() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )
        let firstWorkspace = Workspace(title: "One", workingDirectory: "/tmp/one")
        let secondWorkspace = Workspace(title: "Two", workingDirectory: "/tmp/two")

        let sections = controller.sidebarSections(for: [firstWorkspace, secondWorkspace])

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.workspaces.map(\.id), [firstWorkspace.id, secondWorkspace.id])
        XCTAssertNil(sections.first?.project.missingProject)
    }

    func testActiveProjectReturnsNilForTmpWorkspace() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in "/tmp/app" }
            )
        )
        let tabManager = TabManager(initialWorkingDirectory: "/tmp/app")

        let activeProject = controller.activeProject(for: tabManager)

        XCTAssertNil(activeProject)
        XCTAssertNil(tabManager.selectedWorkspace?.projectId)
    }

    func testSnapshotProjectsSkipsTmpWorkspaceWithoutDurableBinding() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { path in
                    path.hasPrefix("/tmp/durable") ? "/tmp/durable" : nil
                }
            )
        )
        let tmpWorkspace = Workspace(title: "Tmp", workingDirectory: "/tmp/tmp-only")
        let durableWorkspace = Workspace(title: "Durable", workingDirectory: "/tmp/durable")
        let durableProject = controller.bindUserSelectedProject(to: durableWorkspace, directory: "/tmp/durable")

        let snapshots = controller.snapshotProjects(for: [tmpWorkspace, durableWorkspace])

        XCTAssertEqual(snapshots.map(\.projectId), [durableProject?.projectId].compactMap { $0 })
        XCTAssertEqual(snapshots.map(\.rootPathCached), ["/tmp/durable"])
        XCTAssertNil(tmpWorkspace.projectId)
    }

    func testSnapshotProjectsRoundTripsStableProjectId() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )
        let workspace = Workspace(title: "One", workingDirectory: "/tmp/app")
        let boundProject = controller.bindUserSelectedProject(to: workspace, directory: "/tmp/app")

        let snapshots = controller.snapshotProjects(for: [workspace])
        let restoredController = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in nil }
            )
        )
        restoredController.restoreProjectCatalog(snapshots)
        restoredController.restoreWorkspaceBindings(
            snapshot: SessionTabManagerSnapshot(
                selectedWorkspaceIndex: 0,
                workspaces: [
                    SessionWorkspaceSnapshot(
                        processTitle: "Terminal",
                        customTitle: nil,
                        customDescription: nil,
                        customColor: nil,
                        isPinned: false,
                        terminalScrollBarHidden: nil,
                        currentDirectory: "/tmp/app",
                        projectId: boundProject?.projectId,
                        focusedPanelId: nil,
                        layout: .pane(SessionPaneLayoutSnapshot(panelIds: [], selectedPanelId: nil)),
                        panels: [],
                        statusEntries: [],
                        logEntries: [],
                        progress: nil,
                        gitBranch: nil
                    )
                ]
            ),
            tabManager: {
                let manager = TabManager(initialWorkingDirectory: "/tmp/app")
                return manager
            }()
        )

        XCTAssertEqual(restoredController.project(id: boundProject?.projectId)?.rootPathCached, "/tmp/app")
        XCTAssertEqual(snapshots.first?.projectId, boundProject?.projectId)
    }

    func testRestoreWorkspaceBindingsKeepsNilProjectWorkspaceUnbound() {
        _ = NSApplication.shared
        let controller = ProjectModelController(
            environment: .init(
                homeDirectoryPath: nil,
                directoryExists: { _ in true },
                gitRootResolver: { _ in "/tmp/app" }
            )
        )
        let tabManager = TabManager(initialWorkingDirectory: "/tmp/app")
        guard let workspace = tabManager.selectedWorkspace else {
            XCTFail("Expected selected workspace")
            return
        }

        let boundProject = controller.bindUserSelectedProject(to: workspace, directory: "/tmp/app")
        XCTAssertEqual(controller.project(for: workspace.id)?.projectId, boundProject?.projectId)

        controller.restoreWorkspaceBindings(
            snapshot: SessionTabManagerSnapshot(
                selectedWorkspaceIndex: 0,
                workspaces: [
                    SessionWorkspaceSnapshot(
                        processTitle: "Terminal",
                        customTitle: nil,
                        customDescription: nil,
                        customColor: nil,
                        isPinned: false,
                        terminalScrollBarHidden: nil,
                        currentDirectory: "/tmp/app",
                        projectId: nil,
                        focusedPanelId: nil,
                        layout: .pane(SessionPaneLayoutSnapshot(panelIds: [], selectedPanelId: nil)),
                        panels: [],
                        statusEntries: [],
                        logEntries: [],
                        progress: nil,
                        gitBranch: nil
                    )
                ]
            ),
            tabManager: tabManager
        )

        XCTAssertNil(workspace.projectId)
        XCTAssertNil(controller.project(for: workspace.id))
    }
}
