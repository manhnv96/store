//
//  ConnectView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 20/3/26.
//

import SwiftUI
import CoreBluetooth

struct ConnectView: View {
    @State var title: String = Language.Import.title
    var types: [ImportType] = ImportType.allCases
    @State var selectedImportType: ImportType?

    let titleSelectConnection = Language.Import.connectionLabel
    
    let connectionTypes = ConnectionType.allCases
    @State var selectedConnection: ConnectionType?


    let preselectedFolderID: UUID?
    let preselectedAquariumID: UUID?
    @State private var folders: [DeviceFolder] = []
    @State private var aquariums: [Aquarium] = []
    @State private var selectedFolder: DeviceFolder?
    @State private var selectedAquarium: Aquarium?
    private let repository: any DeviceRepository
    @Binding var navigationPath: NavigationPath

    init(
        preselectedFolderID: UUID? = nil,
        preselectedAquariumID: UUID? = nil,
        preselectedImportType: ImportType? = nil,
        preselectedConnectionType: ConnectionType? = nil,
        repository: any DeviceRepository = CoreDataDeviceRepository(),
        navigationPath: Binding<NavigationPath>
    ) {
        self.preselectedFolderID = preselectedFolderID
        self.preselectedAquariumID = preselectedAquariumID
        self._selectedImportType = State(initialValue: preselectedImportType ?? ImportType.allCases.first)
        self._selectedConnection = State(initialValue: preselectedConnectionType)
        self.repository = repository
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            SegmentedPicker(items: types, selection: $selectedImportType)
            switch selectedImportType {
            case .equipment:
                equipmentView
            case .aquarium:
                aquariumView
            case .folder:
                folderView
            case nil:
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(title).font(.title3).fontWeight(.medium)
            }
        }
        .task {
            do {
                let repo = repository
                let (f, a) = try await Task.detached(priority: .userInitiated) {
                    async let folders = try await repo.fetchAllFolders()
                    async let aquariums = try await repo.fetchAllAquariums()
                    return try await (folders, aquariums)
                }.value
                folders = f
                aquariums = a
                selectedFolder = f.first { $0.id == preselectedFolderID }
                selectedAquarium = a.first { $0.id == preselectedAquariumID }
            } catch {}
        }
    }
    
    var equipmentView: some View {
        Group {
            // QR Scan — primary option
            qrScanButton

            Divider().padding(.vertical, 4)

            // Manual connection — secondary
            AquariumPickerField(
                aquariums: aquariums,
                folders: folders,
                selectedAquarium: $selectedAquarium
            )
            selectConnection
            switch selectedConnection {
            case .bluetooth:
                ConnectViaBleView(
                    selectedAquariumID: selectedAquarium?.id,
                    repository: repository,
                    navigationPath: $navigationPath
                )
            case .wifi:
                ConnectViaWifiView(
                    selectedAquariumID: selectedAquarium?.id,
                    repository: repository,
                    navigationPath: $navigationPath
                )
            case .none:
                Spacer()
            }
        }
    }

    private var qrScanButton: some View {
        NavigationLink(value: ScanDestination(aquariumID: selectedAquarium?.id)) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Scan QR Code")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Quick setup by scanning the device QR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
    
    var selectConnection: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(titleSelectConnection)
                .font(.title3)
                .foregroundStyle(Color.primary)
            Spacer()
            ForEach(connectionTypes, id: \.self) { type in
                Toggle(isOn: Binding(
                    get: { selectedConnection == type },
                    set: { _ in selectedConnection = type }
                )) {
                    Text(type.title)
                }
                .font(.headline.weight(.medium))
                .toggleStyle(RadioToggleStyle())
            }
        }
    }
    
    var folderView: some View {
        CreateFolderView(
            selectedParent: selectedFolder,
            folders: folders,
            repository: repository,
            navigationPath: $navigationPath,
            onCreated: {
                Task {
                    let repo = repository
                    folders = (try? await Task.detached(priority: .userInitiated) {
                        try await repo.fetchAllFolders()
                    }.value) ?? folders
                }
            }
        )
    }

    var aquariumView: some View {
        CreateAquariumView(
            selectedParent: selectedFolder,
            folders: folders,
            repository: repository,
            navigationPath: $navigationPath,
            onCreated: nil
        )
    }
}

// MARK: - QR Scan Destination

struct ScanDestination: Hashable {
    var aquariumID: UUID?
}

enum ImportType: String, CaseIterable, SegmentedPickerItem {
    case equipment
    case aquarium
    case folder

    var title: String {
        switch self {
        case .equipment: return Language.Import.typeEquipment
        case .aquarium: return Language.Import.typeAquarium
        case .folder: return Language.Import.typeFolder
        }
    }
}

enum ConnectionType: String, CaseIterable, Codable, Hashable {
    case bluetooth
    case wifi
    
    var title: String {
        switch self {
        case .bluetooth:
            return Language.ConnectionType.bluetooth
        case .wifi:
            return Language.ConnectionType.wifi
        }
    }
    
    var iconSystemName: String {
        switch self {
        case .bluetooth:
            return "personalhotspot"
        case .wifi:
            return "wifi"
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        ConnectView(navigationPath: $path)
    }
}
