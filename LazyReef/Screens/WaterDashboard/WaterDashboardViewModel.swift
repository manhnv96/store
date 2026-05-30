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
    var dosingSetup = DosingSetup()
    var selectedParameter: WaterParameterType = .temperature {
        didSet { if oldValue != selectedParameter { logPage = 0 } }
    }
    var logPage = 0
    let logsPerPage = 12

    let aquarium: Aquarium

    init(aquarium: Aquarium, initialSelection: WaterParameterType? = nil) {
        self.aquarium = aquarium
        if let initialSelection {
            self.selectedParameter = initialSelection
        }
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

    var totalLogPages: Int {
        guard let count = selectedSummary?.readings.count, count > 0 else { return 0 }
        return (count + logsPerPage - 1) / logsPerPage
    }

    var pagedLogs: [WaterReading] {
        guard let readings = selectedSummary?.readings else { return [] }
        let reversed = Array(readings.reversed())
        let start = logPage * logsPerPage
        let end = min(start + logsPerPage, reversed.count)
        guard start < reversed.count else { return [] }
        return Array(reversed[start..<end])
    }
}
