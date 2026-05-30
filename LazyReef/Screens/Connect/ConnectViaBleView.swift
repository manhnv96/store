//
//  ConnectViaBleView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 25/3/26.
//

import SwiftUI
import CoreBluetooth

struct ConnectViaBleView: View {
    
    let titleOfItem = Language.Device.nameTitle
    let titlePlaceholder = Language.Device.namePlaceholder
    @State var titleValue: String = ""

    let connect = Language.Action.connect
    @State var enableConnect: Bool = false
    
    @State var selectedConnection: String = "BLE"
    
    @State var bluetoothManager = BluetoothManager.shared
    @State var selectedPeripheral: CBPeripheral?
    
    @FocusState var editting

    var selectedAquariumID: UUID?
    var repository: any DeviceRepository
    @Binding var navigationPath: NavigationPath
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        BluetoothDiscoveryView(
                            bluetooth: $bluetoothManager,
                            selectedPeripheral: $selectedPeripheral
                        )
                        .padding(.vertical, 8)

                        if selectedPeripheral != nil {
                            SimpleTextField(
                                axis: .vertical,
                                title: titleOfItem,
                                placeholder: titlePlaceholder,
                                value: $titleValue
                            )
                            .focused($editting)
                            .id("deviceNameField")
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: selectedPeripheral) { _, newValue in
                    guard let id = newValue?.identifier else { return }
                    withAnimation { proxy.scrollTo(id, anchor: .center) }
                }
                .onChange(of: editting) { _, focused in
                    guard focused else { return }
                    withAnimation { proxy.scrollTo("deviceNameField", anchor: .center) }
                }
            }

            if let selectedPeripheral {
                ComponentButton(title: connect) {
                    bluetoothManager.stopScan()
                    bluetoothManager.connect(to: selectedPeripheral)
                }
                .fillWidth()
                .state(Binding(
                    get: { bluetoothManager.connectingPeripherals.contains(selectedPeripheral) ? .performing : .normal },
                    set: { _ in }
                ))
                .padding(.top, 12)
            }
        }
        .onChange(of: bluetoothManager.connectedPeripherals) { _, connected in
            guard let selected = selectedPeripheral else { return }
            if connected.contains(selected) {
                let deviceName = titleValue.isEmpty ? (selected.name ?? Language.BleConnected.deviceUnnamed) : titleValue
                let device = ConnectedDevice(
                    id: UUID(),
                    deviceName: deviceName,
                    inputName: selected.identifier.uuidString,
                    deviceDescription: "",
                    category: DeviceKind.other.rawValue,
                    connectionType: .bluetooth,
                    connectedDate: .now,
                    lastUpdate: .now,
                    parentFolderID: nil,
                    parentAquariumID: selectedAquariumID
                )
                Task {
                    try? await repository.save(device)
                    triggerHomeRefresh()
                }
                var newPath = NavigationPath()
                newPath.append(DeviceCreationResult(deviceName: deviceName, connectionType: .bluetooth))
                navigationPath = newPath
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    ConnectViaBleView(repository: CoreDataDeviceRepository(), navigationPath: $path)
}


extension CBPeripheral: ConnectSuccessConfiguration {
    var title: String {
        "Kết nối thiết bị \(name ?? "????") thành công"
    }
}
