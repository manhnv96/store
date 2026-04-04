//
//  BluetoothManager.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 25/3/26.
//

import CoreBluetooth
import SwiftUI
import Observation

@Observable
class BluetoothManager: NSObject {
    private var centralManager: CBCentralManager?
    
    // Discovered devices available for connection
    var discoveredPeripherals = Set<CBPeripheral>()
    
    var connectingPeripherals = Set<CBPeripheral>()
    
    // Multiple active connections stored by their unique identifier
    var connectedPeripherals = Set<CBPeripheral>()
    
    var failedPeripheral: CBPeripheral?
    
    var disconnectedPeripherals: [CBPeripheral] {
        Array(discoveredPeripherals.subtracting(connectingPeripherals))
    }
    
    var isPoweredOn: Bool = false
    
    var isScanning: Bool {
        centralManager?.isScanning ?? false
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    func startScanning() {
        guard centralManager?.state == .poweredOn else {
            return
        }
        // Scan for all devices; in production, specify Service UUIDs for efficiency
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral) {
        safeInsert(peripheral: peripheral, to: &connectingPeripherals)
        centralManager?.connect(peripheral, options: nil)
    }
    
    func cancelConnection(_ peripheral: CBPeripheral) {
        guard connectingPeripherals.contains(peripheral) else {
            return
        }
        
        centralManager?.cancelPeripheralConnection(peripheral)
        connectingPeripherals.remove(peripheral)
    }
}

// Separate extension for delegate methods to keep code clean
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(
        _ central: CBCentralManager
    ) {
        debug("central.state: ", String(describing: central.state))
        isPoweredOn = (central.state == .poweredOn)
        if isPoweredOn, !central.isScanning {
            startScanning()
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        guard peripheral.name != nil else {
            return
        }
        
        debug("centralManager didDiscover \(peripheral.name) - rssi \(RSSI)")
        safeInsert(peripheral: peripheral, to: &discoveredPeripherals)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        debug("centralManager didConnect \(peripheral.name)")
        safeRemove(peripheral: peripheral, from: &connectingPeripherals)
        safeInsert(peripheral: peripheral, to: &connectedPeripherals)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        debug("centralManager didFailToConnect \(peripheral.name) error: \(error?.localizedDescription)")
        safeRemove(peripheral: peripheral, from: &connectingPeripherals)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        debug("centralManager didDisconnectPeripheral \(peripheral.name) error: \(error?.localizedDescription)")
        safeRemove(peripheral: peripheral, from: &connectedPeripherals)
    }
}

extension BluetoothManager {
    func safeRemove(peripheral: CBPeripheral, from set: inout Set<CBPeripheral>) {
        guard set.contains(peripheral) else { return }
        
        set.remove(peripheral)
    }
    
    func safeInsert(peripheral: CBPeripheral, to set: inout Set<CBPeripheral>) {
        guard !set.contains(peripheral) else { return }
        
        set.insert(peripheral)
    }
}
