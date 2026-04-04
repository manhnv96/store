//
//  ConnectSuccessView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import SwiftUI
import CoreBluetooth
import Lottie

/// Displays the list of currently connected BLE peripherals
/// and lets the user disconnect any of them.
struct ConnectSuccessView: View {

    @Binding var bluetooth: BluetoothManager

    // MARK: - Layout constants
    private let rowSpacing: CGFloat = 12
    private let cornerRadius: CGFloat = 12
    private let iconSize: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            contentView
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Sub-views

    private var headerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "bluetooth")
                .foregroundStyle(Color(.systemBlue))
                .font(.title3.weight(.semibold))
            Text(Language.BleConnected.headerTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primary)
            Spacer()
            // Live connection count badge
            if !bluetooth.connectedPeripherals.isEmpty {
                Text("\(bluetooth.connectedPeripherals.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(.systemBlue)))
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if bluetooth.connectedPeripherals.isEmpty {
            emptyStateView
        } else {
            connectedListView
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(Language.BleConnected.emptyTitle, systemImage: "bluetooth.slash")
        } description: {
            Text(Language.BleConnected.emptyDescription)
        }
    }

    private var connectedListView: some View {
        ScrollView {
            VStack(spacing: rowSpacing) {
                ForEach(
                    Array(bluetooth.connectedPeripherals),
                    id: \.identifier
                ) { peripheral in
                    peripheralRow(peripheral)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func peripheralRow(_ peripheral: CBPeripheral) -> some View {
        HStack(spacing: 12) {
            // Device icon
            ZStack {
                Circle()
                    .fill(Color(.systemBlue).opacity(0.15))
                    .frame(width: iconSize, height: iconSize)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(Color(.systemBlue))
                    .font(.system(size: 18, weight: .medium))
            }

            // Device info
            VStack(alignment: .leading, spacing: 4) {
                Text(peripheral.name ?? Language.BleConnected.deviceUnnamed)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.primary)
                Text(peripheral.identifier.uuidString)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            // Connected indicator + disconnect button
            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text(Language.BleConnected.statusConnected)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.green)
                }

                Button {
                    bluetooth.cancelConnection(peripheral)
                } label: {
                    Text(Language.BleConnected.actionDisconnect)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.systemRed))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .overlay(
                            Capsule().stroke(Color(.systemRed), lineWidth: 1)
                        )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    @Previewable @State var bluetooth = BluetoothManager()
    ConnectSuccessView(bluetooth: $bluetooth)
}
