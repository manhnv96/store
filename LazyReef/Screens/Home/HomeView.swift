//
//  HomeView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI

struct ConnectDestination: Hashable {
    var folderID: UUID?
    var aquariumID: UUID?
    var importType: ImportType?
    var connectionType: ConnectionType?
}

struct DeviceCreationResult: Hashable {
    let deviceName: String
    let connectionType: ConnectionType
}

struct ScannedDevicePreview: Hashable {
    let info: QRDeviceInfo
    let aquariumID: UUID?
}

struct HomeView: View {
    @Namespace private var nameSpace

    @State var viewModel: HomeViewModel
    @State private var path = NavigationPath()
    @State private var isTabBarHidden = false
    @State private var hasAppeared = false

    private let itemsPerRow: CGFloat = 2
    private let cornerRadius: CGFloat = 8
    private let itemSpacing: CGFloat = 16

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    private func triggerRefresh() {
        Task {
            await viewModel.refresh()
        }
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
                    preselectedAquariumID: destination.aquariumID,
                    preselectedImportType: destination.importType,
                    preselectedConnectionType: destination.connectionType,
                    navigationPath: $path
                )
            }
            .navigationDestination(for: DeviceFolder.self) { folder in
                FolderDetailView(folder: folder)
            }
            .navigationDestination(for: Aquarium.self) { aquarium in
                AquariumDetailView(
                    viewModel: AquariumDetailViewModel(aquarium: aquarium)
                )
            }
            .navigationDestination(for: ConnectedDevice.self) { device in
                DeviceDetailView(device: device)
            }
            .navigationDestination(for: DeviceCreationResult.self) { result in
                ConnectSuccessView(
                    configuration: DeviceCreationSuccessConfig(
                        deviceName: result.deviceName,
                        connectionType: result.connectionType
                    )
                )
            }
            .navigationDestination(for: ScanDestination.self) { dest in
                QRScannerView { scannedInfo in
                    path.append(ScannedDevicePreview(info: scannedInfo, aquariumID: dest.aquariumID))
                }
            }
            .navigationDestination(for: ScannedDevicePreview.self) { preview in
                DevicePreviewView(
                    deviceInfo: preview.info,
                    aquariums: viewModel.allAquariums,
                    folders: viewModel.allFolders,
                    preselectedAquariumID: preview.aquariumID,
                    repository: CoreDataDeviceRepository(),
                    navigationPath: $path
                )
            }
        }
        .environment(\.triggerHomeRefresh, triggerRefresh)
        .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .onChange(of: path.count) { oldValue, newValue in
            withAnimation(.smooth(duration: 0.35)) {
                isTabBarHidden = newValue > 0
            }
        }
        .task {
            // First time appear
            if !hasAppeared {
                await viewModel.onAppear()
                hasAppeared = true
            }
        }
    }

    // MARK: - Sub-views

    private var titleView: some View {
        HStack(alignment: .center) {
            Text(Language.Tabbar.home)
                .font(.system(size: 32, design: .default))
                .bold()
            Spacer()
            NavigationLink(value: ConnectDestination(folderID: nil)) {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.medium)
            }
        }
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
            VStack(spacing: itemSpacing) {
                if viewModel.isEmpty {
                    globalEmptyView
                } else {
                    if !viewModel.recentDevices.isEmpty {
                        deviceSection(
                            title: Language.Home.recentDevices,
                            devices: viewModel.recentDevices,
                            creatable: false
                        )
                    }

                    ForEach(viewModel.folders) { folder in
                        let subs = viewModel.subFolders(for: folder)
                        let aquariums = viewModel.aquariums(in: folder)
                        if aquariums.isEmpty && subs.isEmpty {
                            emptyFolderSection(folder: folder)
                        } else {
                            folderSection(folder: folder, subFolders: subs, aquariums: aquariums)
                        }
                    }

                    if !viewModel.rootAquariums.isEmpty {
                        aquariumSection(
                            title: Language.Aquarium.title,
                            aquariums: viewModel.rootAquariums
                        )
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
        .refreshable {
            await viewModel.refresh()
        }
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
                Image(systemName: folder.iconName)
                    .font(.title2)
                    .foregroundStyle(.blue)
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
                    icon: "drop.fill",
                    title: Language.Aquarium.createTitle,
                    destination: ConnectDestination(importType: .aquarium)
                )
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

    // MARK: - Sections

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: itemSpacing), count: Int(itemsPerRow))
    }

    private func folderSection(folder: DeviceFolder, subFolders: [DeviceFolder], aquariums: [Aquarium]) -> some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: itemSpacing) {
                ForEach(subFolders) { sub in
                    NavigationLink(value: sub) {
                        SubFolderView(folder: sub)
                    }
                    .buttonStyle(.plain)
                }
                ForEach(aquariums) { aquarium in
                    NavigationLink(value: aquarium) {
                        AquariumCardView(
                            aquarium: aquarium,
                            deviceCount: viewModel.devices(in: aquarium).count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Color.brown.opacity(0.1).cornerRadius(cornerRadius))
        } header: {
            HStack {
                Image(systemName: folder.iconName)
                    .font(.title2)
                    .foregroundStyle(.blue)
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

    private func aquariumSection(title: String, aquariums: [Aquarium]) -> some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: itemSpacing) {
                ForEach(aquariums) { aquarium in
                    NavigationLink(value: aquarium) {
                        AquariumCardView(
                            aquarium: aquarium,
                            deviceCount: viewModel.devices(in: aquarium).count
                        )
                    }
                    .buttonStyle(.plain)
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
                NavigationLink(value: ConnectDestination(importType: .aquarium)) {
                    Image(systemName: "plus").font(.title)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
        }
    }

    private func deviceSection(
        title: String,
        devices: [ConnectedDevice],
        folderID: UUID? = nil,
        creatable: Bool = true
    ) -> some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: itemSpacing) {
                ForEach(devices) { device in
                    NavigationLink(value: device) {
                        DeviceView(device: device)
                    }
                    .buttonStyle(.plain)
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
                if creatable {
                    NavigationLink(value: ConnectDestination(folderID: folderID)) {
                        Image(systemName: "plus").font(.title)
                    }
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
