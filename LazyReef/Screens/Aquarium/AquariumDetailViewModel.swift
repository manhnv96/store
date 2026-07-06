//
//  AquariumDetailViewModel.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import SwiftUI

@MainActor
@Observable
final class AquariumDetailViewModel {

    private(set) var aquarium: Aquarium
    private(set) var devices: [ConnectedDevice] = []
    private(set) var parameters: [WaterParameterSummary] = []
    private(set) var recentLogs: [WaterReading] = []
    private(set) var isLoading = false

    private let repository: any DeviceRepository
    private let logRepository: any WaterReadingRepository
    private let recentLogsLimit = 5

    init(
        aquarium: Aquarium,
        repository: any DeviceRepository = CoreDataDeviceRepository(),
        logRepository: any WaterReadingRepository = CoreDataWaterReadingRepository()
    ) {
        self.aquarium = aquarium
        self.repository = repository
        self.logRepository = logRepository
    }

    func onAppear() async {
        guard parameters.isEmpty && devices.isEmpty && recentLogs.isEmpty else {
            await reloadDevices()
            await loadRecentLogs()
            return
        }
        isLoading = true
        defer { isLoading = false }
        await reloadAll()
    }

    func refresh() async {
        await reloadAll()
    }

    func reloadDevices() async {
        do {
            devices = try await repository.fetchDevices(inAquarium: aquarium.id)
        } catch {
            devices = []
        }
    }

    func removeFromAquarium(_ device: ConnectedDevice) async {
        var updated = device
        updated.parentAquariumID = nil
        do {
            try await repository.update(updated)
            await reloadDevices()
        } catch {}
    }

    // MARK: - Water Logs

    func loadRecentLogs() async {
        do {
            recentLogs = try await logRepository.fetchReadings(
                aquariumID: aquarium.id,
                parameter: nil,
                limit: recentLogsLimit
            )
        } catch {
            recentLogs = []
        }
    }

    func save(_ reading: WaterReading) async {
        do {
            try await logRepository.save(reading)
            await loadRecentLogs()
        } catch {}
    }

    func update(_ reading: WaterReading) async {
        do {
            try await logRepository.update(reading)
            await loadRecentLogs()
        } catch {}
    }

    // MARK: - Settings

    func updateSettings(
        sumpType: AquariumSumpType?,
        livestockType: AquariumLivestockType?
    ) async {
        var updated = aquarium
        updated.sumpType = sumpType
        updated.livestockType = livestockType
        updated.updatedDate = .now
        do {
            try await repository.update(updated)
            aquarium = updated
        } catch {}
    }

    func deleteLog(_ id: UUID) async {
        do {
            try await logRepository.delete(readingID: id)
            await loadRecentLogs()
        } catch {}
    }

    private func reloadAll() async {
        await reloadDevices()
        await loadRecentLogs()
        parameters = WaterParameterType.allCases.map { type in
            let readings = WaterParameterSummary.mockReadings(for: type)
            return WaterParameterSummary(
                id: type,
                type: type,
                currentValue: readings.last?.value ?? 0,
                readings: readings
            )
        }
    }
}
