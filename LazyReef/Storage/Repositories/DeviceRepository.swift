//
//  DeviceRepository.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import Foundation

protocol DeviceRepository: Sendable {
    // MARK: - Devices
    func fetchAllDevices() async throws -> [ConnectedDevice]
    func fetchDevices(inFolder folderID: UUID?) async throws -> [ConnectedDevice]
    func save(_ device: ConnectedDevice) async throws
    func update(_ device: ConnectedDevice) async throws
    func delete(deviceID: UUID) async throws

    // MARK: - Folders
    func fetchAllFolders() async throws -> [DeviceFolder]
    func save(_ folder: DeviceFolder) async throws
    func update(_ folder: DeviceFolder) async throws
    func delete(folderID: UUID) async throws
}
