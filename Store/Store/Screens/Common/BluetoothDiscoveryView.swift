//
//  BluetoothDiscoveryView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 25/3/26.
//

import SwiftUI
import CoreBluetooth

enum BluetoothDiscoverState {
    case discovering
    case foundDevices([CBPeripheral])
    case error(Error)
}

struct BluetoothDiscoveryView: View {
    // @State is now used for both simple types and Observable classes
    @Binding var bluetooth: BluetoothManager
    @Binding var selectedPeripheral: CBPeripheral?
    @State private var isPreparingBluetooth = false
    @State private var verifyBluetoothTimer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                if isPreparingBluetooth {
                    Text("Kiểm tra Bluetooth")
                        .foregroundStyle(Color(.systemBlue))
                    ProgressView()
                        .tint(Color(.systemBlue))
                } else {
                    if !bluetooth.isPoweredOn {
                        Text("Hãy bật Bluetooth để bắt đầu")
                            .foregroundStyle(Color(.red))
                    } else {
                        Text("Chọn thiết bị")
                            .foregroundStyle(Color(.systemBlue))
                        ProgressView()
                            .tint(Color(.systemBlue))
                    }
                }
                
                Spacer()
            }
            
            if !isPreparingBluetooth, !bluetooth.isPoweredOn {
                bluetoothUnavailableView
            } else if bluetooth.isPoweredOn {
                discoveredPerpheralsView
            }
            
            Spacer()
        }
        .onAppear {
            if bluetooth.isPoweredOn {
                stopCheckingBluetooth()
            } else {
                startCheckingBluetooth()
            }
        }
        .onChange(of: bluetooth.isPoweredOn) { _, newValue in
            if newValue {
                stopCheckingBluetooth()
            } else {
                startCheckingBluetooth()
            }
        }
    }
    
    var bluetoothUnavailableView: some View {
        ContentUnavailableView(
            "Chưa bật Bluetooth",
            systemImage: "bolt.slash.fill",
            description: Text("Hãy kiểm tra lại cài đặt bluetooth của bạn và thử lại")
        )
    }
    
    var discoveredPerpheralsView: some View {
        ForEach(Array(bluetooth.disconnectedPeripherals), id: \.identifier) { device in
            Toggle(isOn: Binding(
                get: { selectedPeripheral == device },
                set: { value in selectedPeripheral = device }
            )) {
                Text(device.name ?? "")
            }
            .toggleStyle(RadioToggleStyle())
        }
    }
    
    private func startCheckingBluetooth() {
        isPreparingBluetooth = true
        let startDate = Date()
        verifyBluetoothTimer?.invalidate()
        verifyBluetoothTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startDate)
            if elapsed >= 2.0 {
                timer.invalidate()
                verifyBluetoothTimer = nil
                isPreparingBluetooth = false
            }
        }
        RunLoop.main.add(verifyBluetoothTimer!, forMode: .common)
    }
    
    private func stopCheckingBluetooth() {
        verifyBluetoothTimer?.invalidate()
        verifyBluetoothTimer = nil
        isPreparingBluetooth = false
    }
}

#Preview {
    @Previewable @State var bluetooth = BluetoothManager()
    @Previewable @State var selectedPeripheral: CBPeripheral?
    
    BluetoothDiscoveryView(
        bluetooth: $bluetooth,
        selectedPeripheral: $selectedPeripheral
    )
}
