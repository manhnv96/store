//
//  DeviceDetailView.swift
//  Store
//

import SwiftUI

struct DeviceDetailView: View {

    let device: ConnectedDevice

    @State private var allFolders: [DeviceFolder] = []
    @State private var isLoading = true

    private let repository: any DeviceRepository
    private let cornerRadius: CGFloat = 8

    init(
        device: ConnectedDevice,
        repository: any DeviceRepository = CoreDataDeviceRepository()
    ) {
        self.device = device
        self.repository = repository
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(device.deviceName).font(.title3.weight(.medium))
            }
        }
        .task { await loadData() }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                infoSection
                connectionSection
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Language.DeviceDetail.infoTitle)
                .font(.title2.weight(.semibold))

            VStack(spacing: 0) {
                infoRow(
                    title: Language.DeviceDetail.inputNameLabel,
                    value: device.inputName
                )
                if !device.deviceDescription.isEmpty {
                    Divider().padding(.leading)
                    infoRow(
                        title: Language.DeviceDetail.descriptionLabel,
                        value: device.deviceDescription
                    )
                }
                if !device.category.isEmpty {
                    Divider().padding(.leading)
                    infoRow(
                        title: Language.DeviceDetail.categoryLabel,
                        value: device.category
                    )
                }
                Divider().padding(.leading)
                infoRow(
                    title: Language.DeviceDetail.folderLabel,
                    value: folderName
                )
            }
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    // MARK: - Connection

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Language.DeviceDetail.connectionTitle)
                .font(.title2.weight(.semibold))

            VStack(spacing: 0) {
                infoRow(
                    title: Language.DeviceDetail.connectionTypeLabel,
                    systemImage: device.connectionType.iconSystemName
                )
                Divider().padding(.leading)
                infoRow(
                    title: Language.DeviceDetail.connectedDateLabel,
                    value: device.connectedDate.formatted(date: .abbreviated, time: .shortened)
                )
                Divider().padding(.leading)
                infoRow(
                    title: Language.DeviceDetail.lastUpdateLabel,
                    value: device.lastUpdate.formatted(date: .abbreviated, time: .shortened)
                )
            }
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    // MARK: - Helpers

    private var folderName: String {
        if let parentID = device.parentFolderID,
           let folder = allFolders.first(where: { $0.id == parentID }) {
            return folder.name
        }
        return Language.CreateFolder.parentFolderNone
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func infoRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Data

    private func loadData() async {
        let repo = repository
        do {
            allFolders = try await Task.detached(priority: .userInitiated) {
                try await repo.fetchAllFolders()
            }.value
        } catch {}
        isLoading = false
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DeviceDetailView(device: ConnectedDevice.mocks[0])
    }
}
#endif
