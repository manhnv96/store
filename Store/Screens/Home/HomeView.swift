//
//  HomeView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI

struct ConnectDestination: Hashable {
    var folderID: UUID?
    var importType: ImportType?
    var connectionType: ConnectionType?
}

struct HomeView: View {
    @Namespace private var nameSpace

    @State var viewModel: HomeViewModel
    @State private var path = NavigationPath()

    private let itemsPerRow: CGFloat = 2
    private let cornerRadius: CGFloat = 8
    private let itemSpacing: CGFloat = 16

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                titleView
                contentView
            }
            .navigationDestination(for: ConnectDestination.self) { destination in
                ConnectView(
                    preselectedFolderID: destination.folderID,
                    preselectedImportType: destination.importType,
                    preselectedConnectionType: destination.connectionType
                )
            }
        }
        .task { await viewModel.onAppear() }
    }

    // MARK: - Sub-views

    private var titleView: some View {
        Text(Language.Tabbar.home)
            .font(.system(size: 32, design: .default))
            .bold()
            .padding(.all)
            .padding(.top)
    }

    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                folderList
            }
        }
    }

    private var folderList: some View {
        ScrollView {
            if viewModel.isEmpty {
                globalEmptyView
            } else {
                VStack(spacing: itemSpacing) {
                    if !viewModel.recentDevices.isEmpty {
                        deviceSection(
                            title: Language.Home.recentDevices,
                            devices: viewModel.recentDevices,
                            folderID: nil
                        )
                    }

                    ForEach(viewModel.folders) { folder in
                        let devices = viewModel.devices(for: folder)
                        if devices.isEmpty {
                            emptyFolderSection(folder: folder)
                        } else {
                            deviceSection(title: folder.name, devices: devices, folderID: folder.id)
                        }
                    }

                    if !viewModel.ungroupedDevices.isEmpty {
                        deviceSection(
                            title: Language.Home.otherDevices,
                            devices: viewModel.ungroupedDevices,
                            folderID: nil
                        )
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - Empty states

    private func emptyFolderSection(folder: DeviceFolder) -> some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(Language.Home.emptyFolderTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                NavigationLink(value: ConnectDestination(folderID: folder.id)) {
                    Text(Language.Home.emptyFolderAction)
                        .font(.subheadline.weight(.medium))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.brown.opacity(0.1).cornerRadius(cornerRadius))
        } header: {
            HStack {
                Text(folder.name)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Spacer()
                NavigationLink(value: ConnectDestination(folderID: folder.id)) {
                    Image(systemName: "plus").font(.title)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
        }
    }

    private var globalEmptyView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "square.stack.3d.up.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text(Language.Home.emptyTitle)
                    .font(.title2.weight(.semibold))
                Text(Language.Home.emptyDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Text(Language.Home.getStarted)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                quickStartItem(
                    icon: "personalhotspot",
                    title: Language.Home.connectBle,
                    destination: ConnectDestination(importType: .equipment, connectionType: .bluetooth)
                )
                quickStartItem(
                    icon: "wifi",
                    title: Language.Home.connectWifi,
                    destination: ConnectDestination(importType: .equipment, connectionType: .wifi)
                )
                quickStartItem(
                    icon: "folder.badge.plus",
                    title: Language.Home.createFolder,
                    destination: ConnectDestination(importType: .folder)
                )
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func quickStartItem(icon: String, title: String, destination: ConnectDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color.brown.opacity(0.1), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    // MARK: - Device section

    private func deviceSection(title: String, devices: [ConnectedDevice], folderID: UUID?) -> some View {
        let columns: [GridItem] = Array(
            repeating: GridItem(.flexible(), spacing: itemSpacing),
            count: Int(itemsPerRow)
        )
        return Section {
            LazyVGrid(columns: columns, spacing: itemSpacing) {
                ForEach(devices) { device in
                    DeviceView(device: device)
                }
            }
            .padding(16)
            .background(Color.brown.opacity(0.1).cornerRadius(cornerRadius))
        } header: {
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Spacer()
                NavigationLink(value: ConnectDestination(folderID: folderID)) {
                    Image(systemName: "plus").font(.title)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    HomeView(viewModel: .mock)
}
