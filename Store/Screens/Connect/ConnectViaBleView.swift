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
    
    @State var bluetoothManager = BluetoothManager()
    @State var selectedPeripheral: CBPeripheral?
    
    @FocusState var editting
    @State private var navigateToConnected = false

    var selectedFolderID: UUID?
    var repository: any DeviceRepository

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
        .navigationDestination(isPresented: $navigateToConnected) {
            if let selectedPeripheral {
                ConnectSuccessView(configuration: selectedPeripheral)
            }
        }
        .onChange(of: bluetoothManager.connectedPeripherals) { _, connected in
            guard let selected = selectedPeripheral else { return }
            if connected.contains(selected) {
                let device = ConnectedDevice(
                    id: UUID(),
                    deviceName: titleValue.isEmpty ? (selected.name ?? Language.BleConnected.deviceUnnamed) : titleValue,
                    inputName: selected.name ?? selected.identifier.uuidString,
                    deviceDescription: "",
                    category: "",
                    connectionType: .bluetooth,
                    connectedDate: .now,
                    lastUpdate: .now,
                    parentFolderID: selectedFolderID
                )
                Task {
                    try? await repository.save(device)
                }
                navigateToConnected = true
            }
        }
    }
}

#Preview {
    ConnectViaBleView(repository: CoreDataDeviceRepository())
}


extension CBPeripheral: ConnectSuccessConfiguration {
    var title: String {
        "Kết nối thiết bị \(name ?? "????") thành công"
    }
}
