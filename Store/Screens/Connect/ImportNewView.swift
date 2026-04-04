//
//  ImportNewView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 20/3/26.
//

import SwiftUI
import CoreBluetooth

struct ImportNewView: View {
    @State var title: String = Language.Import.title
    var types: [ImportType] = ImportType.allCases
    @State var selectedImportType: ImportType? = ImportType.allCases.first

    let titleSelectConnection = Language.Import.connectionLabel
    
    let connectionTypes = ConnectionType.allCases
    @State var selectedConnection: ConnectionType?
    
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
    }
    
    var equipmentView: some View {
        Group {
            selectConnection
            switch selectedConnection {
            case .bluetooth:
                BLEDiscoveryView()
            case .wifi:
                ConnectWifiView()
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
        Group {
            EmptyView()
        }
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

enum ConnectionType: String, CaseIterable {
    case bluetooth
    case wifi
    
    var title: String {
        switch self {
        case .bluetooth: return Language.ConnectionType.bluetooth
        case .wifi: return Language.ConnectionType.wifi
        }
    }
}

#Preview {
    ImportNewView()
}
