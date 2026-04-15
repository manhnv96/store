//
//  DeviceDetailView.swift
//  Store
//

import SwiftUI

struct DeviceDetailView: View {

    let device: ConnectedDevice

    @State private var allFolders: [DeviceFolder] = []
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    @State private var showingMoveSheet = false
    @State private var showingEditSheet = false
    
    @Environment(\.dismiss) private var dismiss

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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingMoveSheet = true
                    } label: {
                        Label("Move Device", systemImage: "folder.badge.gearshape")
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
        .alert("Delete Device", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            
            Button("Delete", role: .destructive) {
                deleteDevice()
            }
        } message: {
            Text("Are you sure you want to delete '\(device.deviceName)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showingMoveSheet) {
            MoveDeviceView(device: device, allFolders: allFolders, repository: repository)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDeviceView(device: device, repository: repository)
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
    
    // MARK: - Actions
    
    private func deleteDevice() {
        Task {
            do {
                try await repository.delete(deviceID: device.id)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error deleting device: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct MoveDeviceView: View {
    let device: ConnectedDevice
    let allFolders: [DeviceFolder]
    let repository: any DeviceRepository
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFolderID: UUID?
    
    init(device: ConnectedDevice, allFolders: [DeviceFolder], repository: any DeviceRepository) {
        self.device = device
        self.allFolders = allFolders
        self.repository = repository
        _selectedFolderID = State(initialValue: device.parentFolderID)
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
                            Text("Root (No Folder)")
                            Spacer()
                            if selectedFolderID == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                if !allFolders.isEmpty {
                    Section("Folders") {
                        ForEach(allFolders) { folder in
                            Button {
                                selectedFolderID = folder.id
                            } label: {
                                HStack {
                                    Image(systemName: folder.iconName)
                                        .foregroundStyle(.blue)
                                    Text(folder.name)
                                    Spacer()
                                    if selectedFolderID == folder.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Move Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Move") {
                        moveDevice()
                    }
                }
            }
        }
    }
    
    private func moveDevice() {
        Task {
            do {
                var updatedDevice = device
                updatedDevice.parentFolderID = selectedFolderID
                try await repository.update(updatedDevice)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error moving device: \(error)")
            }
        }
    }
}

struct EditDeviceView: View {
    let device: ConnectedDevice
    let repository: any DeviceRepository
    
    @Environment(\.dismiss) private var dismiss
    @State private var deviceName: String
    @State private var inputName: String
    @State private var deviceDescription: String
    @State private var category: String
    
    init(device: ConnectedDevice, repository: any DeviceRepository) {
        self.device = device
        self.repository = repository
        _deviceName = State(initialValue: device.deviceName)
        _inputName = State(initialValue: device.inputName)
        _deviceDescription = State(initialValue: device.deviceDescription)
        _category = State(initialValue: device.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Device Information") {
                    TextField("Device Name", text: $deviceName)
                    TextField("Input Name", text: $inputName)
                    TextField("Category", text: $category)
                }
                
                Section("Description") {
                    TextEditor(text: $deviceDescription)
                        .frame(minHeight: 100)
                }
                
                Section("Connection") {
                    HStack {
                        Image(systemName: device.connectionType.iconSystemName)
                        Text(device.connectionType.title)
                        Spacer()
                        Text("Connected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDevice()
                    }
                    .disabled(deviceName.isEmpty || inputName.isEmpty)
                }
            }
        }
    }
    
    private func saveDevice() {
        Task {
            do {
                var updatedDevice = device
                updatedDevice.deviceName = deviceName
                updatedDevice.inputName = inputName
                updatedDevice.deviceDescription = deviceDescription
                updatedDevice.category = category
                try await repository.update(updatedDevice)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error updating device: \(error)")
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DeviceDetailView(device: ConnectedDevice.mocks[0])
    }
}
#endif
