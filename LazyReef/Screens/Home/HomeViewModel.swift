import SwiftUI

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - State
    private(set) var recentDevices: [ConnectedDevice] = []
    private(set) var folders: [DeviceFolder] = []
    private(set) var allFolders: [DeviceFolder] = []
    private(set) var allAquariums: [Aquarium] = []
    private(set) var rootAquariums: [Aquarium] = []
    private(set) var aquariumsByFolder: [UUID: [Aquarium]] = [:]
    private(set) var devicesByAquarium: [UUID: [ConnectedDevice]] = [:]
    private(set) var ungroupedDevices: [ConnectedDevice] = []
    private(set) var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let repository: any DeviceRepository

    init(repository: any DeviceRepository = CoreDataDeviceRepository()) {
        self.repository = repository
    }

    // MARK: - Intents

    func onAppear() async {
        isLoading = true
        defer { isLoading = false }
        await fetchData()
    }

    func refresh() async {
        let start = ContinuousClock.now
        await fetchData()
        let elapsed = ContinuousClock.now - start
        if elapsed < .milliseconds(600) {
            try? await Task.sleep(for: .milliseconds(600) - elapsed)
        }
    }

    private func fetchData() async {
        errorMessage = nil

        do {
            let repo = repository

            let (fetchedFolders, fetchedAquariums, devicesGroupedByAquarium, aquariumsGroupedByFolder, recent, ungrouped) =
                try await Task.detached(priority: .userInitiated) {
                    async let fetchFolders = try await repo.fetchAllFolders()
                    async let fetchAquariums = try await repo.fetchAllAquariums()
                    async let fetchDevices = try await repo.fetchAllDevices()
                    let (f, a, d) = try await (fetchFolders, fetchAquariums, fetchDevices)

                    var devicesByAq = [UUID: [ConnectedDevice]]()
                    var noAquarium = [ConnectedDevice]()
                    for device in d {
                        if let id = device.parentAquariumID {
                            devicesByAq[id, default: []].append(device)
                        } else {
                            noAquarium.append(device)
                        }
                    }

                    var aquariumsByFol = [UUID: [Aquarium]]()
                    for aquarium in a {
                        if let id = aquarium.parentFolderID {
                            aquariumsByFol[id, default: []].append(aquarium)
                        }
                    }

                    let sorted = d.sorted { $0.connectedDate > $1.connectedDate }
                    return (f, a, devicesByAq, aquariumsByFol, sorted, noAquarium)
                }.value

            recentDevices = Array(recent.prefix(2))
            allFolders = fetchedFolders
            folders = fetchedFolders.filter { $0.parentFolderID == nil }
            allAquariums = fetchedAquariums
            rootAquariums = fetchedAquariums.filter { $0.parentFolderID == nil }
            aquariumsByFolder = aquariumsGroupedByFolder
            devicesByAquarium = devicesGroupedByAquarium

            let recentIDs = Set(recentDevices.map(\.id))
            ungroupedDevices = ungrouped.filter { !recentIDs.contains($0.id) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var isEmpty: Bool {
        recentDevices.isEmpty
            && folders.isEmpty
            && rootAquariums.isEmpty
            && ungroupedDevices.isEmpty
    }

    func subFolders(for folder: DeviceFolder) -> [DeviceFolder] {
        allFolders.filter { $0.parentFolderID == folder.id }
    }

    func aquariums(in folder: DeviceFolder) -> [Aquarium] {
        aquariumsByFolder[folder.id] ?? []
    }

    func devices(in aquarium: Aquarium) -> [ConnectedDevice] {
        devicesByAquarium[aquarium.id] ?? []
    }
}

#if DEBUG
extension HomeViewModel {
    static var mock: HomeViewModel {
        let folderID1 = UUID()
        let folderID2 = UUID()
        return HomeViewModel(
            repository: PreviewDeviceRepository(
                folders: [
                    DeviceFolder(
                        id: folderID1,
                        name: "Living Room",
                        iconName: "folder",
                        createdDate: .now,
                        updatedDate: .now
                    ),
                    DeviceFolder(
                        id: folderID2,
                        name: "Office",
                        iconName: "desktopcomputer",
                        createdDate: .now,
                        updatedDate: .now
                    )
                ],
                devices: [
                    ConnectedDevice(
                        id: UUID(),
                        deviceName: "Smart Speaker",
                        inputName: "BLE-Speaker-01",
                        deviceDescription: "",
                        category: "Audio",
                        connectionType: .bluetooth,
                        connectedDate: .now.addingTimeInterval(-3600),
                        lastUpdate: .now,
                        parentFolderID: folderID1,
                        parentAquariumID: nil
                    ),
                    ConnectedDevice(
                        id: UUID(),
                        deviceName: "TV Box",
                        inputName: "BLE-TV-01",
                        deviceDescription: "",
                        category: "Media",
                        connectionType: .bluetooth,
                        connectedDate: .now.addingTimeInterval(-7200),
                        lastUpdate: .now,
                        parentFolderID: folderID1,
                        parentAquariumID: nil
                    ),
                    ConnectedDevice(
                        id: UUID(),
                        deviceName: "TV Box",
                        inputName: "BLE-TV-02",
                        deviceDescription: "",
                        category: "Media",
                        connectionType: .bluetooth,
                        connectedDate: .now.addingTimeInterval(-600),
                        lastUpdate: .now,
                        parentFolderID: folderID1,
                        parentAquariumID: nil
                    ),
                    ConnectedDevice(
                        id: UUID(),
                        deviceName: "Home Camera",
                        inputName: "CAM-192.168.1.10",
                        deviceDescription: "",
                        category: "Security",
                        connectionType: .wifi,
                        connectedDate: .now,
                        lastUpdate: .now,
                        parentFolderID: folderID2,
                        parentAquariumID: nil
                    ),
                    ConnectedDevice(
                        id: UUID(),
                        deviceName: "Desk Lamp",
                        inputName: "BLE-Lamp-01",
                        deviceDescription: "",
                        category: "Lighting",
                        connectionType: .bluetooth,
                        connectedDate: .now.addingTimeInterval(-1800),
                        lastUpdate: .now,
                        parentFolderID: nil,
                        parentAquariumID: nil
                    )
                ]
            )
        )
    }
}

private final class PreviewDeviceRepository: DeviceRepository, @unchecked Sendable {
    private let foldersMock: [DeviceFolder]
    private let devicesMock: [ConnectedDevice]
    private let aquariumsMock: [Aquarium]

    init(folders: [DeviceFolder], devices: [ConnectedDevice], aquariums: [Aquarium] = []) {
        self.foldersMock = folders
        self.devicesMock = devices
        self.aquariumsMock = aquariums
    }

    func fetchAllDevices() async throws -> [ConnectedDevice] { devicesMock }
    func fetchDevices(inFolder folderID: UUID?) async throws -> [ConnectedDevice] {
        devicesMock.filter { $0.parentFolderID == folderID }
    }
    func fetchDevices(inAquarium aquariumID: UUID?) async throws -> [ConnectedDevice] {
        devicesMock.filter { $0.parentAquariumID == aquariumID }
    }
    func save(_ device: ConnectedDevice) async throws {}
    func update(_ device: ConnectedDevice) async throws {}
    func delete(deviceID: UUID) async throws {}
    func fetchAllFolders() async throws -> [DeviceFolder] { foldersMock }
    func save(_ folder: DeviceFolder) async throws {}
    func update(_ folder: DeviceFolder) async throws {}
    func delete(folderID: UUID) async throws {}
    func fetchAllAquariums() async throws -> [Aquarium] { aquariumsMock }
    func fetchAquariums(inFolder folderID: UUID?) async throws -> [Aquarium] {
        aquariumsMock.filter { $0.parentFolderID == folderID }
    }
    func save(_ aquarium: Aquarium) async throws {}
    func update(_ aquarium: Aquarium) async throws {}
    func delete(aquariumID: UUID) async throws {}
}
#endif
