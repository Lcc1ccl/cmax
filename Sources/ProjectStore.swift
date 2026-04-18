import Foundation

struct MissingProject: Equatable, Sendable {
    let requestedPath: String
    let displayName: String
}

struct ProjectRecord: Equatable, Identifiable, Sendable {
    let projectId: String
    let rootPathCached: String
    let displayName: String
    let missingProject: MissingProject?

    var id: String { projectId }
    var isMissing: Bool { missingProject != nil }
}

private enum TemporaryProjectSentinel {
    static let projectId = "temp:shared-tmp"
    static let rootPathCached = "tmp"
    static let displayName = "tmp"

    static let record = ProjectRecord(
        projectId: projectId,
        rootPathCached: rootPathCached,
        displayName: displayName,
        missingProject: nil
    )
}

enum ProjectPathResolutionMode: Sendable {
    case explicitSelection
    case inferredWorkspace
}

enum ProjectResolver {
    struct Environment {
        var homeDirectoryPath: String?
        var directoryExists: (String) -> Bool
        var gitRootResolver: (String) -> String?

        init(
            homeDirectoryPath: String?,
            directoryExists: @escaping (String) -> Bool = { path in
                var isDirectory: ObjCBool = false
                return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
            },
            gitRootResolver: @escaping (String) -> String? = { path in
                ProjectResolver.defaultGitRootResolver(path: path)
            }
        ) {
            self.homeDirectoryPath = homeDirectoryPath
            self.directoryExists = directoryExists
            self.gitRootResolver = gitRootResolver
        }
    }

    struct Result: Equatable, Sendable {
        let rootPath: String
        let displayName: String
        let missingProject: MissingProject?
    }

    static func resolve(
        directory: String?,
        resolutionMode: ProjectPathResolutionMode,
        environment: Environment
    ) -> Result? {
        guard let candidate = normalizedPath(directory, homeDirectoryPath: environment.homeDirectoryPath) else {
            return nil
        }

        let resolvedRoot: String
        switch resolutionMode {
        case .explicitSelection:
            resolvedRoot = candidate
        case .inferredWorkspace:
            resolvedRoot = normalizedPath(
                environment.gitRootResolver(candidate) ?? candidate,
                homeDirectoryPath: environment.homeDirectoryPath
            ) ?? candidate
        }

        let displayName = projectDisplayName(for: resolvedRoot)
        if environment.directoryExists(resolvedRoot) {
            return Result(
                rootPath: resolvedRoot,
                displayName: displayName,
                missingProject: nil
            )
        }

        return Result(
            rootPath: resolvedRoot,
            displayName: displayName,
            missingProject: MissingProject(
                requestedPath: resolvedRoot,
                displayName: displayName
            )
        )
    }

    private static func normalizedPath(_ path: String?, homeDirectoryPath: String?) -> String? {
        guard let path else { return nil }
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let expanded: String
        if trimmed == "~", let homeDirectoryPath {
            expanded = homeDirectoryPath
        } else if trimmed.hasPrefix("~/"), let homeDirectoryPath {
            expanded = NSString(string: homeDirectoryPath)
                .appendingPathComponent(String(trimmed.dropFirst(2)))
        } else {
            expanded = trimmed
        }

        let standardized = NSString(string: expanded).standardizingPath
        let normalized = standardized.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? nil : normalized
    }

    private static func projectDisplayName(for rootPath: String) -> String {
        let lastComponent = URL(fileURLWithPath: rootPath, isDirectory: true).lastPathComponent
        if !lastComponent.isEmpty {
            return lastComponent
        }
        return rootPath
    }

    private static func defaultGitRootResolver(path: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "-C", path, "rev-parse", "--show-toplevel"]

        let output = Pipe()
        let error = Pipe()
        process.standardOutput = output
        process.standardError = error

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0 else { return nil }
        let data = output.fileHandleForReading.readDataToEndOfFile()
        guard let text = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }
}

final class ProjectStore {
    private let environment: ProjectResolver.Environment
    private var projectIdByRootPath: [String: String] = [:]
    private(set) var projectsById: [String: ProjectRecord] = [:]

    init(environment: ProjectResolver.Environment) {
        self.environment = environment
    }

    var projects: [ProjectRecord] {
        projectsById.values.sorted { $0.rootPathCached < $1.rootPathCached }
    }

    func project(id: String?) -> ProjectRecord? {
        guard let id else { return nil }
        return projectsById[id]
    }

    func project(
        directory: String?,
        resolutionMode: ProjectPathResolutionMode
    ) -> ProjectRecord? {
        guard let result = ProjectResolver.resolve(
            directory: directory,
            resolutionMode: resolutionMode,
            environment: environment
        ) else {
            return nil
        }
        guard let projectId = projectIdByRootPath[result.rootPath] else {
            return nil
        }
        return projectsById[projectId]
    }

    func projectForDisplay(
        directory: String?,
        resolutionMode: ProjectPathResolutionMode
    ) -> ProjectRecord? {
        if let existingProject = project(directory: directory, resolutionMode: resolutionMode) {
            return existingProject
        }
        guard let result = ProjectResolver.resolve(
            directory: directory,
            resolutionMode: resolutionMode,
            environment: environment
        ) else {
            return nil
        }
        return ProjectRecord(
            projectId: "temp:\(result.rootPath)",
            rootPathCached: result.rootPath,
            displayName: result.displayName,
            missingProject: result.missingProject
        )
    }

    @discardableResult
    func upsert(
        directory: String?,
        resolutionMode: ProjectPathResolutionMode
    ) -> ProjectRecord? {
        guard let result = ProjectResolver.resolve(
            directory: directory,
            resolutionMode: resolutionMode,
            environment: environment
        ) else {
            return nil
        }
        let projectId = projectIdByRootPath[result.rootPath] ?? UUID().uuidString
        return upsertResolved(result: result, projectId: projectId)
    }

    @discardableResult
    func restore(projectId: String, directory: String?) -> ProjectRecord? {
        guard let result = ProjectResolver.resolve(
            directory: directory,
            resolutionMode: .explicitSelection,
            environment: environment
        ) else {
            return nil
        }

        if let conflictingProjectId = projectIdByRootPath[result.rootPath],
           conflictingProjectId != projectId {
            return nil
        }

        if let existingProject = projectsById[projectId] {
            projectIdByRootPath.removeValue(forKey: existingProject.rootPathCached)
        }

        return upsertResolved(result: result, projectId: projectId)
    }

    @discardableResult
    func repair(projectId: String, directory: String?) -> ProjectRecord? {
        restore(projectId: projectId, directory: directory)
    }

    private func upsertResolved(result: ProjectResolver.Result, projectId: String) -> ProjectRecord {
        let project = ProjectRecord(
            projectId: projectId,
            rootPathCached: result.rootPath,
            displayName: result.displayName,
            missingProject: result.missingProject
        )
        projectIdByRootPath[result.rootPath] = projectId
        projectsById[projectId] = project
        return project
    }
}

final class WorkspaceBindingStore {
    private var projectIdByWorkspaceId: [UUID: String] = [:]

    func bind(workspaceId: UUID, projectId: String) {
        projectIdByWorkspaceId[workspaceId] = projectId
    }

    func unbind(workspaceId: UUID) {
        projectIdByWorkspaceId.removeValue(forKey: workspaceId)
    }

    func projectId(for workspaceId: UUID) -> String? {
        projectIdByWorkspaceId[workspaceId]
    }
}

enum ActiveProjectResolver {
    struct Context {
        let workspaceId: UUID
        let focusedPanelId: UUID?
        let orderedPanelIds: [UUID]
        let panelDirectories: [UUID: String]
        let requestedPanelDirectories: [UUID: String]
        let currentDirectory: String?
    }

    static func resolve(
        context: Context,
        projectStore: ProjectStore,
        workspaceBindingStore: WorkspaceBindingStore
    ) -> ProjectRecord? {
        if let boundProjectId = workspaceBindingStore.projectId(for: context.workspaceId),
           let boundProject = projectStore.project(id: boundProjectId),
           !boundProject.isMissing {
            return boundProject
        }

        for candidate in candidateDirectories(context: context) {
            guard let project = projectStore.upsert(
                directory: candidate,
                resolutionMode: .inferredWorkspace
            ), !project.isMissing else {
                continue
            }
            workspaceBindingStore.bind(workspaceId: context.workspaceId, projectId: project.id)
            return project
        }

        return nil
    }

    static func candidateDirectories(context: Context) -> [String] {
        var candidates: [String] = []
        var seen: Set<String> = []

        func append(_ directory: String?) {
            guard let directory = directory?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !directory.isEmpty,
                  seen.insert(directory).inserted else {
                return
            }
            candidates.append(directory)
        }

        if let focusedPanelId = context.focusedPanelId {
            append(context.panelDirectories[focusedPanelId])
            append(context.requestedPanelDirectories[focusedPanelId])
        }

        for panelId in context.orderedPanelIds {
            append(context.panelDirectories[panelId])
            append(context.requestedPanelDirectories[panelId])
        }

        append(context.currentDirectory)
        return candidates
    }
}

struct SidebarProjectSection: Identifiable {
    let project: ProjectRecord
    var workspaces: [Workspace]

    var id: String { project.id }
}

@MainActor
final class ProjectModelController: ObservableObject {
    @Published private(set) var revision: UInt64 = 0

    private let projectStore: ProjectStore
    private let workspaceBindingStore = WorkspaceBindingStore()

    init(
        environment: ProjectResolver.Environment = .init(
            homeDirectoryPath: FileManager.default.homeDirectoryForCurrentUser.path
        )
    ) {
        self.projectStore = ProjectStore(environment: environment)
    }

    func project(id: String?) -> ProjectRecord? {
        projectStore.project(id: id)
    }

    func project(for workspaceId: UUID) -> ProjectRecord? {
        guard let projectId = workspaceBindingStore.projectId(for: workspaceId) else {
            return nil
        }
        return projectStore.project(id: projectId)
    }

    func displayProject(for workspace: Workspace) -> ProjectRecord? {
        if let projectId = workspace.projectId,
           let project = project(id: projectId) {
            return project
        }
        return TemporaryProjectSentinel.record
    }

    func sidebarSections(for workspaces: [Workspace]) -> [SidebarProjectSection] {
        var sections: [SidebarProjectSection] = []
        var indexByProjectId: [String: Int] = [:]

        for workspace in workspaces {
            let project = displayProject(for: workspace) ?? TemporaryProjectSentinel.record

            if let index = indexByProjectId[project.id] {
                sections[index].workspaces.append(workspace)
            } else {
                indexByProjectId[project.id] = sections.count
                sections.append(SidebarProjectSection(project: project, workspaces: [workspace]))
            }
        }

        return sections
    }

    @discardableResult
    func bindUserSelectedProject(to workspace: Workspace, directory: String?) -> ProjectRecord? {
        guard let project = projectStore.upsert(
            directory: directory,
            resolutionMode: .explicitSelection
        ) else {
            return nil
        }
        bind(project: project, to: workspace)
        return project
    }

    @discardableResult
    func syncWorkspaceBindings(_ workspaces: [Workspace]) -> [ProjectRecord] {
        var synced: [ProjectRecord] = []
        for workspace in workspaces {
            if let project = syncWorkspaceBinding(workspace) {
                synced.append(project)
            }
        }
        return synced
    }

    @discardableResult
    func syncWorkspaceBinding(_ workspace: Workspace) -> ProjectRecord? {
        if let projectId = workspace.projectId,
           let project = project(id: projectId) {
            bind(project: project, to: workspace, shouldPublish: false)
            return project
        }
        clearWorkspaceBinding(for: workspace)
        return nil
    }

    func activeProject(for tabManager: TabManager) -> ProjectRecord? {
        guard let workspace = tabManager.selectedWorkspace else {
            return nil
        }
        return syncWorkspaceBinding(workspace)
    }

    func restoreProjectCatalog(_ projects: [SessionProjectSnapshot]) {
        var didChange = false
        for project in projects {
            if projectStore.restore(projectId: project.projectId, directory: project.rootPathCached) != nil {
                didChange = true
            }
        }
        if didChange {
            publishChange()
        }
    }

    func restoreWorkspaceBindings(snapshot: SessionTabManagerSnapshot, tabManager: TabManager) {
        for (workspaceSnapshot, workspace) in zip(snapshot.workspaces, tabManager.tabs) {
            if let projectId = workspaceSnapshot.projectId,
               let project = projectStore.project(id: projectId) {
                bind(project: project, to: workspace, shouldPublish: false)
            } else {
                clearWorkspaceBinding(for: workspace, shouldPublish: false)
            }
        }
        publishChange()
    }

    func snapshotProjects(for workspaces: [Workspace]) -> [SessionProjectSnapshot] {
        _ = syncWorkspaceBindings(workspaces)
        let projectIds = Set(workspaces.compactMap(\.projectId))
        return projectIds
            .compactMap { projectId in
                projectStore.project(id: projectId).map { project in
                    SessionProjectSnapshot(
                        projectId: project.projectId,
                        rootPathCached: project.rootPathCached
                    )
                }
            }
            .sorted { lhs, rhs in
                if lhs.rootPathCached == rhs.rootPathCached {
                    return lhs.projectId < rhs.projectId
                }
                return lhs.rootPathCached < rhs.rootPathCached
            }
    }

    @discardableResult
    func repairMissingProject(projectId: String, directory: String?) -> ProjectRecord? {
        guard let repaired = projectStore.repair(projectId: projectId, directory: directory) else {
            return nil
        }
        publishChange()
        return repaired
    }

    private func bind(
        project: ProjectRecord,
        to workspace: Workspace,
        shouldPublish: Bool = true
    ) {
        workspace.projectId = project.projectId
        workspaceBindingStore.bind(workspaceId: workspace.id, projectId: project.projectId)
        if shouldPublish {
            publishChange()
        }
    }

    @discardableResult
    private func clearWorkspaceBinding(
        for workspace: Workspace,
        shouldPublish: Bool = true
    ) -> Bool {
        let didChange = workspace.projectId != nil || workspaceBindingStore.projectId(for: workspace.id) != nil
        workspace.projectId = nil
        workspaceBindingStore.unbind(workspaceId: workspace.id)
        if didChange && shouldPublish {
            publishChange()
        }
        return didChange
    }

    private func publishChange() {
        revision &+= 1
    }
}
