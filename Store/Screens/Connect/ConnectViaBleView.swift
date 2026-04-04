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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                BluetoothDiscoveryView(
                    bluetooth: $bluetoothManager,
                    selectedPeripheral: $selectedPeripheral
                )
                .padding(.vertical, 8)
            }
            .scrollBounceBehavior(.basedOnSize)
            
            if selectedPeripheral != nil {
                SimpleTextField(
                    axis: .vertical,
                    title: titleOfItem,
                    placeholder: titlePlaceholder,
                    value: $titleValue
                )
                .focused($editting)
            }
            
            if let selectedPeripheral {
                HStack {
                    Spacer()
                    ComponentButton(
                        title: connect,
                        state: Binding(
                            get: {
                                bluetoothManager.connectingPeripherals.contains(selectedPeripheral) ? .performing : .normal
                            },
                            set: { value in }
                        )
                    ) {
                        bluetoothManager.stopScan()
                        bluetoothManager.connect(to: selectedPeripheral)
                    }
                    Spacer()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToConnected) {
            ConnectSuccessView(bluetooth: $bluetoothManager)
        }
        .onChange(of: bluetoothManager.connectedPeripherals) { _, connected in
            guard let selected = selectedPeripheral else { return }
            if connected.contains(selected) {
                navigateToConnected = true
            }
        }
    }
}

#Preview {
    ConnectViaBleView()
}
