//
//  FolderDetailView.swift
//  Store
//

import SwiftUI

enum FolderDeletionOption {
    case removeAllChildren
    case moveChildrenToParent
}

struct FolderDetailView: View {

    let folder: DeviceFolder

    @State private var subFolders: [DeviceFolder] = []
    @State private var devices: [ConnectedDevice] = []
    @State private var allFolders: [DeviceFolder] = []
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    @State private var showingMoveSheet = false
    @State private var showingEditSheet = false
    
    @Environment(\.dismiss) private var dismiss

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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingMoveSheet = true
                    } label: {
                        Label("Move Folder", systemImage: "folder.badge.gearshape")
                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
        }
        .alert("Delete Folder", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            
            Button("Remove All Contents", role: .destructive) {
                deleteFolder(option: .removeAllChildren)
            }
            
            Button("Move Contents to Parent", role: .destructive) {
                deleteFolder(option: .moveChildrenToParent)
            }
        } message: {
            Text("What would you like to do with the folders and devices inside this folder?")
        }
        .sheet(isPresented: $showingMoveSheet) {
            MoveFolderView(folder: folder, allFolders: allFolders, repository: repository)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditFolderView(folder: folder, repository: repository)
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
                Text("(\(devices.count))")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(.secondary)
                Spacer()
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
                .padding()
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
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
    
    // MARK: - Actions
    
    private func deleteFolder(option: FolderDeletionOption) {
        Task {
            do {
                switch option {
                case .removeAllChildren:
                    // Delete all child folders and devices first
                    for subFolder in subFolders {
                        try await repository.delete(folderID: subFolder.id)
                    }
                    for device in devices {
                        try await repository.delete(deviceID: device.id)
                    }
                    // Then delete the folder itself
                    try await repository.delete(folderID: folder.id)
                    
                case .moveChildrenToParent:
                    // Move all child folders to parent
                    for var subFolder in subFolders {
                        subFolder.parentFolderID = folder.parentFolderID
                        try await repository.update(subFolder)
                    }
                    // Move all devices to parent
                    for var device in devices {
                        device.parentFolderID = folder.parentFolderID
                        try await repository.update(device)
                    }
                    // Then delete the folder
                    try await repository.delete(folderID: folder.id)
                }
                
                // Navigate back after deletion
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error deleting folder: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct MoveFolderView: View {
    let folder: DeviceFolder
    let allFolders: [DeviceFolder]
    let repository: any DeviceRepository
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFolderID: UUID?
    
    private var availableFolders: [DeviceFolder] {
        // Filter out the current folder and its descendants
        allFolders.filter { $0.id != folder.id && $0.parentFolderID != folder.id }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        selectedFolderID = nil
                    } label: {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundStyle(.blue)
                            Text("Root (No Parent)")
                            Spacer()
                            if selectedFolderID == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                Section("Folders") {
                    ForEach(availableFolders) { availableFolder in
                        Button {
                            selectedFolderID = availableFolder.id
                        } label: {
                            HStack {
                                Image(systemName: availableFolder.iconName)
                                    .foregroundStyle(.blue)
                                Text(availableFolder.name)
                                Spacer()
                                if selectedFolderID == availableFolder.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Move Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Move") {
                        moveFolder()
                    }
                }
            }
        }
    }
    
    private func moveFolder() {
        Task {
            do {
                var updatedFolder = folder
                updatedFolder.parentFolderID = selectedFolderID
                try await repository.update(updatedFolder)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error moving folder: \(error)")
            }
        }
    }
}

struct EditFolderView: View {
    let folder: DeviceFolder
    let repository: any DeviceRepository
    
    @Environment(\.dismiss) private var dismiss
    @State private var folderName: String
    @State private var selectedIcon: String
    
    init(folder: DeviceFolder, repository: any DeviceRepository) {
        self.folder = folder
        self.repository = repository
        _folderName = State(initialValue: folder.name)
        _selectedIcon = State(initialValue: folder.iconName)
    }
    
    private let commonIcons = [
        "folder", "folder.fill", "house", "building.2", "lightbulb", "lightbulb.fill",
        "lamp.desk", "lamp.floor", "tv", "hifispeaker.fill", "computermouse",
        "keyboard", "camera", "video", "lock", "fan", "thermometer"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Folder Name", text: $folderName)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(commonIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                VStack {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(selectedIcon == icon ? .blue : .primary)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            selectedIcon == icon ? Color.blue.opacity(0.1) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 8)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFolder()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }
    
    private func saveFolder() {
        Task {
            do {
                var updatedFolder = folder
                updatedFolder.name = folderName
                updatedFolder.iconName = selectedIcon
                try await repository.update(updatedFolder)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error updating folder: \(error)")
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        FolderDetailView(folder: DeviceFolder.mocks[0])
    }
}
#endif
