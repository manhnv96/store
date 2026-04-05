//
//  FolderDetailView.swift
//  Store
//

import SwiftUI

struct FolderDetailView: View {

    let folder: DeviceFolder

    @State private var subFolders: [DeviceFolder] = []
    @State private var devices: [ConnectedDevice] = []
    @State private var allFolders: [DeviceFolder] = []
    @State private var isLoading = true

    private let repository: any DeviceRepository
    private let itemSpacing: CGFloat = 16
    private let cornerRadius: CGFloat = 8

    init(folder: DeviceFolder, repository: any DeviceRepository = CoreDataDeviceRepository()) {
        self.folder = folder
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
                Text(folder.name)
                    .font(.title3.weight(.medium))
            }
        }
        .task { await loadData() }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                infoSection
                if !subFolders.isEmpty {
                    subFoldersSection
                }
                devicesSection
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .refreshable { await loadData() }
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Language.FolderDetail.infoTitle)
                .font(.title2.weight(.semibold))

            VStack(spacing: 0) {
                infoRow(
                    title: Language.FolderDetail.iconLabel,
                    systemImage: folder.iconName
                )
                Divider().padding(.leading)
                
                infoRow(
                    title: Language.FolderDetail.parentLabel,
                    value: parentFolderName
                )
                Divider().padding(.leading)
                
                infoRow(
                    title: Language.FolderDetail.createdDateLabel,
                    value: folder.createdDate.formatted(date: .abbreviated, time: .shortened)
                )
            }
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    private var parentFolderName: String {
        if let parentID = folder.parentFolderID,
           let parent = allFolders.first(where: { $0.id == parentID }) {
            return parent.name
        }
        return Language.CreateFolder.parentFolderNone
    }

    private func infoRow(title: String, value: String, icon: String? = nil) -> some View {
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

    // MARK: - Sub-folders & Devices

    private let gridColumns = Array(
        repeating: GridItem(.flexible(), spacing: 16),
        count: 2
    )

    private var subFoldersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.FolderDetail.subFoldersTitle)
                .font(.title2.weight(.semibold))

            LazyVGrid(columns: gridColumns, spacing: itemSpacing) {
                ForEach(subFolders) { sub in
                    NavigationLink(value: sub) {
                        SubFolderView(folder: sub)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
        .navigationDestination(for: DeviceFolder.self) { subFolder in
            FolderDetailView(folder: subFolder, repository: repository)
        }
    }

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Language.FolderDetail.devicesTitle)
                    .font(.title2.weight(.semibold))
                Spacer()
                Text("\(devices.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if devices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(Language.FolderDetail.devicesEmpty)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                LazyVGrid(columns: gridColumns, spacing: itemSpacing) {
                    ForEach(devices) { device in
                        NavigationLink(value: device) {
                            DeviceView(device: device)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationDestination(for: ConnectedDevice.self) { device in
            DeviceDetailView(device: device, repository: repository)
        }
    }

    // MARK: - Data

    private func loadData() async {
        let repo = repository
        let folderID = folder.id

        do {
            let (folders, devs) = try await Task.detached(priority: .userInitiated) {
                async let f = try await repo.fetchAllFolders()
                async let d = try await repo.fetchDevices(inFolder: folderID)
                return try await (f, d)
            }.value

            allFolders = folders
            subFolders = folders.filter { $0.parentFolderID == folderID }
            devices = devs
        } catch {}

        isLoading = false
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        FolderDetailView(folder: DeviceFolder.mocks[0])
    }
}
#endif
