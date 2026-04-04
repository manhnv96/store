//
//  ConnectViaWifiView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 26/3/26.
//

import SwiftUI
import NetworkExtension
import CoreBluetooth

struct ConnectViaWifiView: View {
    
    let titleOfItem = Language.Device.nameTitle
    let titlePlaceholder = Language.Device.namePlaceholder
    @State var titleValue: String = ""

    let connect = Language.Action.connect
    @State var enableConnect: Bool = false
    
    @State var selectedConnection: String = "BLE"
    
    @State var bluetoothManager = BluetoothManager()
    @State var selectedPeripheral: CBPeripheral?
    @FocusState var editting
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 24) {
                    if selectedPeripheral != nil {
                        SimpleTextField(
                            axis: .vertical,
                            title: titleOfItem,
                            placeholder: titlePlaceholder,
                            value: $titleValue
                        )
                        .focused($editting)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.immediately)
            
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
                        ), action: {
                            bluetoothManager.stopScan()
                            bluetoothManager.connect(to: selectedPeripheral)
                        }
                    )
                    Spacer()
                }
            }
        }
        .onTapGesture {
            editting = false
        }
    }
}

#Preview {
    ConnectViaWifiView()
}
