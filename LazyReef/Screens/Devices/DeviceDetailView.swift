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
    @State private var showingShareSheet = false
    @State private var showingDuplicateSheet = false
    @State private var isFavorite = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh

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
                            showingDuplicateSheet = true
                        } label: {
                            Label("Duplicate Device", systemImage: "plus.square.on.square")
                        }
                    }
                    
                    // Organization Section
                    Section {
                        Button {
                            showingMoveSheet = true
                        } label: {
                            Label("Move to Folder", systemImage: "folder.badge.gearshape")
                        }
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Details", systemImage: "pencil")
                        }
                    }
                    
                    // Sharing Section
                    Section {
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Share Device Info", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            exportDeviceConfiguration()
                        } label: {
                            Label("Export Configuration", systemImage: "arrow.down.doc")
                        }
                    }
                    
                    // Danger Zone
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Device", systemImage: "trash")
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
        .sheet(isPresented: $showingShareSheet) {
            ShareDeviceView(device: device)
        }
        .sheet(isPresented: $showingDuplicateSheet) {
            DuplicateDeviceView(device: device, repository: repository)
        }
        .task { await loadData() }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                dashboardBanner
                infoSection
                connectionSection
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationDestination(for: String.self) { destination in
            if destination == "waterDashboard" {
                WaterDashboardView(
                    viewModel: WaterDashboardViewModel(device: device)
                )
            }
        }
    }

    // MARK: - Dashboard Banner

    private var dashboardBanner: some View {
        NavigationLink(value: "waterDashboard") {
            HStack(spacing: 14) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Water Dashboard")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("View parameters & charts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
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
                    triggerHomeRefresh()
                    dismiss()
                }
            } catch {
                print("Error deleting device: \(error)")
            }
        }
    }
    
    private func exportDeviceConfiguration() {
        // Create a JSON representation of the device
        let deviceInfo: [String: Any] = [
            "name": device.deviceName,
            "inputName": device.inputName,
            "description": device.deviceDescription,
            "category": device.category,
            "connectionType": device.connectionType.title,
            "connectedDate": device.connectedDate.ISO8601Format(),
            "lastUpdate": device.lastUpdate.ISO8601Format()
        ]
        
        // In a real app, you would save this to a file or share it
        if let jsonData = try? JSONSerialization.data(withJSONObject: deviceInfo, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Device Configuration:\n\(jsonString)")
            // TODO: Present share sheet with the configuration file
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
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh
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
                    triggerHomeRefresh()
                    dismiss()
                }
            } catch {
                print("Error updating device: \(error)")
            }
        }
    }
}

struct ShareDeviceView: View {
    let device: ConnectedDevice
    
    @Environment(\.dismiss) private var dismiss
    
    var shareText: String {
        """
        Device: \(device.deviceName)
        Type: \(device.connectionType.title)
        Input: \(device.inputName)
        \(device.deviceDescription.isEmpty ? "" : "Description: \(device.deviceDescription)")
        Connected: \(device.connectedDate.formatted(date: .abbreviated, time: .shortened))
        """
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: device.connectionType.iconSystemName)
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding()
                
                VStack(spacing: 8) {
                    Text(device.deviceName)
                        .font(.title2.weight(.semibold))
                    Text(device.connectionType.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share Options")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ShareOptionButton(
                            icon: "doc.on.doc",
                            title: "Copy Details",
                            action: {
                                UIPasteboard.general.string = shareText
                                dismiss()
                            }
                        )
                        
                        Divider().padding(.leading, 56)
                        
                        ShareOptionButton(
                            icon: "qrcode",
                            title: "Generate QR Code",
                            action: {
                                // TODO: Generate QR code
                                dismiss()
                            }
                        )
                        
                        Divider().padding(.leading, 56)
                        
                        ShareOptionButton(
                            icon: "square.and.arrow.up",
                            title: "Share via System",
                            action: {
                                // TODO: Present system share sheet
                                dismiss()
                            }
                        )
                    }
                    .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Share Device")
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

struct ShareOptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32)
                Text(title)
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
}

struct DuplicateDeviceView: View {
    let device: ConnectedDevice
    let repository: any DeviceRepository
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh
    @State private var deviceName: String
    @State private var includeDescription = true
    @State private var includeCategory = true
    
    init(device: ConnectedDevice, repository: any DeviceRepository) {
        self.device = device
        self.repository = repository
        _deviceName = State(initialValue: "\(device.deviceName) Copy")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("New Device Name") {
                    TextField("Device Name", text: $deviceName)
                }
                
                Section("Copy Settings") {
                    Toggle("Include Description", isOn: $includeDescription)
                    Toggle("Include Category", isOn: $includeCategory)
                }
                
                Section("Original Device") {
                    HStack {
                        Image(systemName: device.connectionType.iconSystemName)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(device.deviceName)
                                .font(.body.weight(.medium))
                            Text(device.connectionType.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Duplicate Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Duplicate") {
                        duplicateDevice()
                    }
                    .disabled(deviceName.isEmpty)
                }
            }
        }
    }
    
    private func duplicateDevice() {
        Task {
            do {
                var newDevice = device
                newDevice.id = UUID()
                newDevice.deviceName = deviceName
                newDevice.connectedDate = Date()
                newDevice.lastUpdate = Date()
                
                if !includeDescription {
                    newDevice.deviceDescription = ""
                }
                if !includeCategory {
                    newDevice.category = ""
                }
                
                try await repository.save(newDevice)
                await MainActor.run {
                    triggerHomeRefresh()
                    dismiss()
                }
            } catch {
                print("Error duplicating device: \(error)")
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

