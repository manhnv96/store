//
//  WaterParametersCompactView.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import SwiftUI

/// Compact widget showing water parameters as small tappable rows in a 2-column grid.
/// Each row shows icon, title, value+unit, trend arrow, and an in/out-of-range status dot.
/// Tapping a row pushes a `WaterDashboardDestination` focused on that parameter — the
/// destination must be registered on an enclosing `NavigationStack`.
struct WaterParametersCompactView: View {

    let summaries: [WaterParameterSummary]

    private let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        Group {
            if summaries.isEmpty {
                placeholderGrid
            } else {
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(summaries) { summary in
                        NavigationLink(
                            value: WaterDashboardDestination(focusedParameter: summary.type)
                        ) {
                            compactRow(summary: summary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func compactRow(summary: WaterParameterSummary) -> some View {
        let accent = color(for: summary.type)
        return HStack(spacing: 10) {
            Image(systemName: summary.type.iconSystemName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(summary.type.title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(summary.formattedValue)
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if !summary.type.unit.isEmpty {
                        Text(summary.type.unit)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 4)

            VStack(spacing: 4) {
                Image(systemName: summary.trend.iconSystemName)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(trendColor(summary.trend))
                Circle()
                    .fill(summary.isInRange ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }

    private var placeholderGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.08))
                    .frame(height: 52)
            }
        }
    }

    private func trendColor(_ trend: WaterParameterTrend) -> Color {
        switch trend {
        case .up: return .orange
        case .down: return .blue
        case .stable: return .secondary
        }
    }

    private func color(for type: WaterParameterType) -> Color {
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

#if DEBUG
#Preview {
    let summaries = WaterParameterType.allCases.map { type in
        let readings = WaterParameterSummary.mockReadings(for: type)
        return WaterParameterSummary(
            id: type,
            type: type,
            currentValue: readings.last?.value ?? 0,
            readings: readings
        )
    }
    return NavigationStack {
        ScrollView {
            WaterParametersCompactView(summaries: summaries)
                .padding(16)
        }
    }
}
#endif
