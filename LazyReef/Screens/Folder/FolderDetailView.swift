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
    @State private var aquariums: [Aquarium] = []
    @State private var allFolders: [DeviceFolder] = []
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    @State private var showingMoveSheet = false
    @State private var showingEditSheet = false
    @State private var showingShareSheet = false
    @State private var showingCreateSubFolderSheet = false
    @State private var isFavorite = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh

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
                    // Quick Actions Section
                    Section {
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Label(
                                isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: isFavorite ? "star.fill" : "star"
                            )
                        }
                        
                        Button {
                            showingCreateSubFolderSheet = true
                        } label: {
                            Label("Create Subfolder", systemImage: "folder.badge.plus")
                        }
                    }
                    
                    // Organization Section
                    Section {
                        Button {
                            showingMoveSheet = true
                        } label: {
                            Label("Move Folder", systemImage: "folder.badge.gearshape")
                        }
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Details", systemImage: "pencil")
                        }
                    }
                    
                    // Information Section
                    Section {
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Share Folder Info", systemImage: "square.and.arrow.up")
                        }
                        
                        Menu {
                            Button {
                                printFolderSummary()
                            } label: {
                                Label("Summary", systemImage: "doc.text")
                            }
                            
                            Button {
                                exportFolderStructure()
                            } label: {
                                Label("Structure", systemImage: "list.bullet.rectangle")
                            }
                        } label: {
                            Label("Export", systemImage: "arrow.down.doc")
                        }
                    }
                    
                    // Danger Zone
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }
                .menuOrder(.fixed)
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
        .sheet(isPresented: $showingShareSheet) {
            ShareFolderView(folder: folder, deviceCount: aquariums.count, subFolderCount: subFolders.count)
        }
        .sheet(isPresented: $showingCreateSubFolderSheet) {
            CreateSubFolderView(parentFolder: folder, repository: repository)
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
                aquariumsSection
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

    private var aquariumsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Language.Aquarium.title)
                    .font(.title2.weight(.semibold))
                Text("(\(aquariums.count))")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(.secondary)
                Spacer()
                NavigationLink(value: ConnectDestination(folderID: folder.id, importType: .aquarium)) {
                    Image(systemName: "plus").font(.title2)
                }
            }

            if aquariums.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(Language.Aquarium.listEmpty)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    NavigationLink(value: ConnectDestination(folderID: folder.id, importType: .aquarium)) {
                        Text(Language.Aquarium.addAction)
                            .font(.subheadline.weight(.medium))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                LazyVGrid(columns: gridColumns, spacing: itemSpacing) {
                    ForEach(aquariums) { aquarium in
                        NavigationLink(value: aquarium) {
                            AquariumCardView(aquarium: aquarium, deviceCount: 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
        .navigationDestination(for: Aquarium.self) { aquarium in
            AquariumDetailView(
                viewModel: AquariumDetailViewModel(aquarium: aquarium, repository: repository)
            )
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
            let (folders, aqs) = try await Task.detached(priority: .userInitiated) {
                async let f = try await repo.fetchAllFolders()
                async let a = try await repo.fetchAquariums(inFolder: folderID)
                return try await (f, a)
            }.value

            allFolders = folders
            subFolders = folders.filter { $0.parentFolderID == folderID }
            aquariums = aqs
        } catch {}

        isLoading = false
    }
    
    // MARK: - Actions
    
    private func deleteFolder(option: FolderDeletionOption) {
        Task {
            do {
                switch option {
                case .removeAllChildren:
                    // Delete all subfolders (their aquariums are not recursively deleted here)
                    for subFolder in subFolders {
                        try await repository.delete(folderID: subFolder.id)
                    }
                    // Delete the aquariums in this folder; their devices become ungrouped
                    for aquarium in aquariums {
                        let aquariumDevices = try await repository.fetchDevices(inAquarium: aquarium.id)
                        for var device in aquariumDevices {
                            device.parentAquariumID = nil
                            try await repository.update(device)
                        }
                        try await repository.delete(aquariumID: aquarium.id)
                    }
                    try await repository.delete(folderID: folder.id)

                case .moveChildrenToParent:
                    // Move all child folders to parent
                    for var subFolder in subFolders {
                        subFolder.parentFolderID = folder.parentFolderID
                        try await repository.update(subFolder)
                    }
                    // Move all aquariums to parent
                    for var aquarium in aquariums {
                        aquarium.parentFolderID = folder.parentFolderID
                        try await repository.update(aquarium)
                    }
                    try await repository.delete(folderID: folder.id)
                }

                // Navigate back after deletion
                await MainActor.run {
                    triggerHomeRefresh()
                    dismiss()
                }
            } catch {
                print("Error deleting folder: \(error)")
            }
        }
    }

    private func printFolderSummary() {
        print("Folder: \(folder.name)")
        print("Contains: \(aquariums.count) aquariums, \(subFolders.count) subfolders")
    }

    private func exportFolderStructure() {
        let structure: [String: Any] = [
            "name": folder.name,
            "icon": folder.iconName,
            "aquariumCount": aquariums.count,
            "subFolderCount": subFolders.count,
            "aquariums": aquariums.map { $0.name },
            "subFolders": subFolders.map { $0.name }
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: structure, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Folder Structure:\n\(jsonString)")
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
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh
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
                    triggerHomeRefresh()
                    dismiss()
                }
            } catch {
                print("Error updating folder: \(error)")
            }
        }
    }
}

struct ShareFolderView: View {
    let folder: DeviceFolder
    let deviceCount: Int
    let subFolderCount: Int
    
    @Environment(\.dismiss) private var dismiss
    
    var shareText: String {
        """
        Folder: \(folder.name)
        Devices: \(deviceCount)
        Subfolders: \(subFolderCount)
        Created: \(folder.createdDate.formatted(date: .abbreviated, time: .shortened))
        """
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: folder.iconName)
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding()
                
                VStack(spacing: 8) {
                    Text(folder.name)
                        .font(.title2.weight(.semibold))
                    HStack(spacing: 16) {
                        Label("\(deviceCount)", systemImage: "externaldrive.connected.to.line.below")
                            .font(.subheadline)
                        Label("\(subFolderCount)", systemImage: "folder")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share Options")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        Button {
                            UIPasteboard.general.string = shareText
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "doc.on.doc")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                    .frame(width: 32)
                                Text("Copy Folder Info")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        
                        Divider().padding(.leading, 56)
                        
                        Button {
                            // TODO: Generate folder structure as PDF
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "doc.richtext")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                    .frame(width: 32)
                                Text("Export as Document")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Share Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreateSubFolderView: View {
    let parentFolder: DeviceFolder
    let repository: any DeviceRepository
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh
    @State private var folderName = ""
    @State private var selectedIcon = "folder"
    
    private let commonIcons = [
        "folder", "folder.fill", "house", "building.2", "lightbulb", "lightbulb.fill",
        "lamp.desk", "lamp.floor", "tv", "hifispeaker.fill", "computermouse",
        "keyboard", "camera", "video", "lock", "fan", "thermometer"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Parent Folder") {
                    HStack {
                        Image(systemName: parentFolder.iconName)
                            .foregroundStyle(.blue)
                        Text(parentFolder.name)
                            .font(.body.weight(.medium))
                    }
                }
                
                Section("New Subfolder Name") {
                    TextField("Subfolder Name", text: $folderName)
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
            .navigationTitle("Create Subfolder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSubFolder()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }
    
    private func createSubFolder() {
        Task {
            do {
                let newFolder = DeviceFolder(
                    id: UUID(),
                    parentFolderID: parentFolder.id,
                    name: folderName,
                    iconName: selectedIcon,
                    createdDate: Date(),
                    updatedDate: Date()
                )
                try await repository.save(newFolder)
                await MainActor.run {
                    triggerHomeRefresh()
                    dismiss()
                }
            } catch {
                print("Error creating subfolder: \(error)")
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

