//
//  WaterDashboardView.swift
//  Store
//

import SwiftUI
import Charts

/// Navigation value used to push WaterDashboardView. When `focusedParameter` is set,
/// the dashboard opens with that parameter selected.
struct WaterDashboardDestination: Hashable {
    var focusedParameter: WaterParameterType?
}

struct WaterDashboardView: View {

    @State var viewModel: WaterDashboardViewModel
    @State private var showingSetup = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(viewModel.aquarium.name)
                    .font(.title3.weight(.medium))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSetup = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingSetup) {
            DosingSetupView(setup: viewModel.dosingSetup) { newSetup in
                viewModel.dosingSetup = newSetup
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                chartSection
                parameterGrid
                logsSection
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Chart (pinned on top, single parameter)

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let selected = viewModel.selectedSummary {
                HStack(alignment: .firstTextBaseline) {
                    Text(selected.type.title)
                        .font(.title2.weight(.semibold))
                    if !selected.type.unit.isEmpty {
                        Text("(\(selected.type.unit))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(selected.formattedValue)
                        .font(.title.weight(.bold))
                        .foregroundStyle(colorFor(selected.type))
                    if !selected.type.unit.isEmpty {
                        Text(selected.type.unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                SingleParameterChartView(
                    summary: selected,
                    color: colorFor(selected.type)
                )
                .id(selected.type)
                .frame(height: 220)
                .padding(12)
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .animation(.smooth(duration: 0.3), value: viewModel.selectedParameter)

                // Ideal range label
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.green.opacity(0.3))
                        .frame(width: 14, height: 8)
                    Text("Ideal: \(selected.type.idealRange.lowerBound, specifier: "%.1f") – \(selected.type.idealRange.upperBound, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Parameter Cards

    private var parameterGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(viewModel.parameters) { param in
                ParameterCardView(
                    summary: param,
                    isSelected: viewModel.selectedParameter == param.type,
                    accentColor: colorFor(param.type)
                )
                .onTapGesture {
                    withAnimation(.smooth(duration: 0.25)) {
                        viewModel.selectedParameter = param.type
                    }
                }
            }
        }
    }

    // MARK: - Logs

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let selected = viewModel.selectedSummary {
                HStack {
                    Text("Logs")
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Text("\(selected.readings.count) readings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                let logs = viewModel.pagedLogs
                LazyVStack(spacing: 0) {
                    ForEach(Array(logs.enumerated()), id: \.element.id) { index, reading in
                        logRow(reading: reading)
                        if index < logs.count - 1 {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

                if viewModel.totalLogPages > 1 {
                    logPaginationControls
                }
            }
        }
    }

    private var logPaginationControls: some View {
        HStack {
            Button {
                withAnimation { viewModel.logPage -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))
            }
            .disabled(viewModel.logPage == 0)

            Spacer()

            Text("Page \(viewModel.logPage + 1) of \(viewModel.totalLogPages)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                withAnimation { viewModel.logPage += 1 }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
            }
            .disabled(viewModel.logPage >= viewModel.totalLogPages - 1)
        }
        .padding(.horizontal, 8)
    }

    private func logRow(reading: WaterReading) -> some View {
        let isInRange = reading.type.idealRange.contains(reading.value)
        return HStack(spacing: 12) {
            Circle()
                .fill(isInRange ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(reading.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(isInRange ? "In range" : "Out of range")
                    .font(.caption2)
                    .foregroundStyle(isInRange ? .green : .orange)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(formattedValue(reading.value, type: reading.type))
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                if !reading.type.unit.isEmpty {
                    Text(reading.type.unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func formattedValue(_ value: Double, type: WaterParameterType) -> String {
        switch type {
        case .po4: return String(format: "%.2f", value)
        case .ph, .temperature: return String(format: "%.1f", value)
        default: return String(format: "%.0f", value)
        }
    }

    private func colorFor(_ type: WaterParameterType) -> Color {
        switch type.chartColor {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "pink": return .pink
        case "red": return .red
        case "cyan": return .cyan
        case "teal": return .teal
        case "indigo": return .indigo
        case "yellow": return .yellow
        default: return .gray
        }
    }
}

// MARK: - Single Parameter Chart

struct SingleParameterChartView: View {
    let summary: WaterParameterSummary
    let color: Color

    private var last12hReadings: [WaterReading] {
        let cutoff = Date().addingTimeInterval(-12 * 3600)
        return summary.readings.filter { $0.timestamp >= cutoff }
    }

    var body: some View {
        let readings = last12hReadings
        Chart {
            idealBand(readings: readings)
            ForEach(readings) { reading in
                lineMark(reading)
            }
            ForEach(readings) { reading in
                areaMark(reading)
            }
            if let last = readings.last {
                PointMark(
                    x: .value("Time", last.timestamp),
                    y: .value(summary.type.title, last.value)
                )
                .foregroundStyle(color)
                .symbolSize(50)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 2)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
            }
        }
    }

    private func lineMark(_ reading: WaterReading) -> some ChartContent {
        LineMark(
            x: .value("Time", reading.timestamp),
            y: .value(summary.type.title, reading.value)
        )
        .foregroundStyle(color)
        .interpolationMethod(.catmullRom)
        .lineStyle(StrokeStyle(lineWidth: 2))
    }

    private func areaMark(_ reading: WaterReading) -> some ChartContent {
        AreaMark(
            x: .value("Time", reading.timestamp),
            y: .value(summary.type.title, reading.value)
        )
        .foregroundStyle(
            .linearGradient(
                colors: [color.opacity(0.2), color.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .interpolationMethod(.catmullRom)
    }

    @ChartContentBuilder
    private func idealBand(readings: [WaterReading]) -> some ChartContent {
        if let first = readings.first?.timestamp,
           let last = readings.last?.timestamp {
            RectangleMark(
                xStart: .value("Start", first),
                xEnd: .value("End", last),
                yStart: .value("Low", summary.type.idealRange.lowerBound),
                yEnd: .value("High", summary.type.idealRange.upperBound)
            )
            .foregroundStyle(.green.opacity(0.1))
        }
    }
}

// MARK: - Parameter Card

struct ParameterCardView: View {
    let summary: WaterParameterSummary
    let isSelected: Bool
    var accentColor: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: summary.type.iconSystemName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : accentColor)
                Spacer()
                statusIndicator
            }

            Text(summary.type.title)
                .font(.caption)
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(summary.formattedValue)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(isSelected ? .white : .primary)
                if !summary.type.unit.isEmpty {
                    Text(summary.type.unit)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
                }
            }
        }
        .padding(14)
        .background(
            isSelected
                ? AnyShapeStyle(accentColor.gradient)
                : AnyShapeStyle(Color.gray.opacity(0.08)),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }

    private var statusColor: Color {
        summary.isInRange ? .green : .orange
    }

    private var statusIndicator: some View {
        Circle()
            .fill(isSelected ? .white : statusColor)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NavigationStack {
        WaterDashboardView(
            viewModel: WaterDashboardViewModel(aquarium: Aquarium.mocks[0])
        )
    }
}
#endif
