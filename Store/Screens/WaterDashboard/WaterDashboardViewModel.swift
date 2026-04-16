//
//  WaterDashboardViewModel.swift
//  Store
//

import SwiftUI

@MainActor
@Observable
final class WaterDashboardViewModel {

    private(set) var parameters: [WaterParameterSummary] = []
    private(set) var isLoading = false
    var selectedParameter: WaterParameterType = .temperature

    let device: ConnectedDevice

    init(device: ConnectedDevice) {
        self.device = device
    }

    func onAppear() async {
        isLoading = true
        defer { isLoading = false }
        await fetchData()
    }

    func refresh() async {
        let start = ContinuousClock.now
        await fetchData()
        let elapsed = ContinuousClock.now - start
        if elapsed < .milliseconds(600) {
            try? await Task.sleep(for: .milliseconds(600) - elapsed)
        }
    }

    private func fetchData() async {
        // TODO: Replace with real API call to the device server
        // For now, generate mock data
        try? await Task.sleep(for: .milliseconds(300))
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

    var selectedSummary: WaterParameterSummary? {
        parameters.first { $0.type == selectedParameter }
    }
}
