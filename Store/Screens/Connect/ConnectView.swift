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
    @State private var folders: [DeviceFolder] = []
    @State private var selectedFolder: DeviceFolder?
    private let repository: any DeviceRepository

    init(
        preselectedFolderID: UUID? = nil,
        preselectedImportType: ImportType? = nil,
        preselectedConnectionType: ConnectionType? = nil,
        repository: any DeviceRepository = CoreDataDeviceRepository()
    ) {
        self.preselectedFolderID = preselectedFolderID
        self._selectedImportType = State(initialValue: preselectedImportType ?? ImportType.allCases.first)
        self._selectedConnection = State(initialValue: preselectedConnectionType)
        self.repository = repository
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            SegmentedPicker(items: types, selection: $selectedImportType)
            switch selectedImportType {
            case .equipment:
                equipmentView
            case .folder:
                folderView
            case nil:
                EmptyView()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(title).font(.title3).fontWeight(.medium)
            }
        }
        .task {
            do {
                let repo = repository
                folders = try await Task.detached(priority: .userInitiated) {
                    try await repo.fetchAllFolders()
                }.value
                selectedFolder = folders.first { $0.id == preselectedFolderID }
            } catch {}
        }
    }
    
    var equipmentView: some View {
        Group {
            FolderPickerField(folders: folders, selectedFolder: $selectedFolder)
            selectConnection
            switch selectedConnection {
            case .bluetooth:
                ConnectViaBleView(
                    selectedFolderID: selectedFolder?.id,
                    repository: repository
                )
            case .wifi:
                ConnectViaWifiView(
                    selectedFolderID: selectedFolder?.id,
                    repository: repository
                )
            case .none:
                EmptyView()
            }
        }
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
}

enum ImportType: String, CaseIterable, SegmentedPickerItem {
    case equipment
    case folder
    
    var title: String {
        switch self {
        case .equipment: return Language.Import.typeEquipment
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
    ConnectView()
}
