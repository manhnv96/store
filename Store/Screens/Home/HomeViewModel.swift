import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    
    // MARK: - State
    private(set) var recentDevices: [ConnectedDevice] = []
    private(set) var folders: [DeviceFolder] = []
    private(set) var devicesByFolder: [UUID: [ConnectedDevice]] = [:]
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
            
            let (fetchedFolders, groupedDevices, recent, ungrouped) = try await Task.detached(priority: .userInitiated) {
                async let fetchFolders = try await repo.fetchAllFolders()
                async let fetchDevices = try await repo.fetchAllDevices()
                let (f, d) = try await (fetchFolders, fetchDevices)
                
                var grouped = [UUID: [ConnectedDevice]]()
                var noFolder = [ConnectedDevice]()
                for device in d {
                    if let id = device.parentFolderID {
                        grouped[id, default: []].append(device)
                    } else {
                        noFolder.append(device)
                    }
                }
                let sorted = d.sorted { $0.connectedDate > $1.connectedDate }
                return (f, grouped, sorted, noFolder)
            }.value
            
            recentDevices = Array(recent.prefix(2))
            folders = fetchedFolders
            devicesByFolder = groupedDevices

            let recentIDs = Set(recentDevices.map(\.id))
            ungroupedDevices = ungrouped.filter { !recentIDs.contains($0.id) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var isEmpty: Bool {
        recentDevices.isEmpty && folders.isEmpty
    }

    func devices(for folder: DeviceFolder) -> [ConnectedDevice] {
        devicesByFolder[folder.id] ?? []
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
                        parentFolderID: folderID1
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
                        parentFolderID: folderID1
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
                        parentFolderID: folderID1
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
                        parentFolderID: folderID2
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
                        parentFolderID: nil
                    )
                ]
            )
        )
    }
}

private final class PreviewDeviceRepository: DeviceRepository, @unchecked Sendable {
    private let foldersMock: [DeviceFolder]
    private let devicesMock: [ConnectedDevice]
    
    init(folders: [DeviceFolder], devices: [ConnectedDevice]) {
        self.foldersMock = folders
        self.devicesMock = devices
    }
    
    func fetchAllDevices() async throws -> [ConnectedDevice] { devicesMock }
    func fetchDevices(inFolder folderID: UUID?) async throws -> [ConnectedDevice] {
        devicesMock.filter { $0.parentFolderID == folderID }
    }
    func save(_ device: ConnectedDevice) async throws {}
    func update(_ device: ConnectedDevice) async throws {}
    func delete(deviceID: UUID) async throws {}
    func fetchAllFolders() async throws -> [DeviceFolder] { foldersMock }
    func save(_ folder: DeviceFolder) async throws {}
    func update(_ folder: DeviceFolder) async throws {}
    func delete(folderID: UUID) async throws {}
}
#endif
