//
//  CreateFolderView.swift
//  Store
//

import SwiftUI

struct CreateFolderView: View {

    @State private var folderName: String = ""
    @State private var selectedIconName: String = "folder"
    @State var selectedParent: DeviceFolder?
    @State private var isSaving = false
    @State private var createdFolder: DeviceFolder?
    @State private var navigateToDetail = false

    @FocusState private var nameFieldFocused: Bool

    let folders: [DeviceFolder]
    var repository: any DeviceRepository
    var onCreated: (() -> Void)?

    private var canCreate: Bool {
        !folderName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    parentFolderField
                    nameField
                    iconPickerSection
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { nameFieldFocused = false }

            createButton
                .padding(.top, 12)
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let createdFolder {
                FolderDetailView(folder: createdFolder, repository: repository)
            }
        }
    }
    
    // MARK: - Parent Folder

    private var parentFolderField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.CreateFolder.parentFolderTitle)
                .font(.headline)
                .foregroundStyle(Color.primary)

            if folders.isEmpty {
                disabledParentField
            } else {
                activeParentField
            }
        }
    }

    private var disabledParentField: some View {
        HStack {
            Text(Language.CreateFolder.parentFolderEmpty)
                .font(.body).fontWeight(.medium)
                .foregroundStyle(Color.gray)
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Color.gray.opacity(0.05).cornerRadius(8)
        }
    }

    private var activeParentField: some View {
        Menu {
            Button {
                selectedParent = nil
            } label: {
                HStack {
                    Text(Language.CreateFolder.parentFolderNone)
                    if selectedParent == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            ForEach(flattenedFolderTree) { node in
                Button {
                    selectedParent = node.folder
                } label: {
                    HStack {
                        Image(systemName: node.folder.iconName)
                        Text(node.indentedName)
                        if selectedParent?.id == node.folder.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                if let parent = selectedParent {
                    Image(systemName: parent.iconName)
                        .foregroundStyle(.secondary)
                    Text(parent.name)
                        .font(.body).fontWeight(.medium)
                        .foregroundStyle(Color.primary)
                } else {
                    Text(Language.CreateFolder.parentFolderNone)
                        .font(.body).fontWeight(.medium)
                        .foregroundStyle(Color.gray)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Color.gray.opacity(0.1).cornerRadius(8)
            }
        }
    }

    // MARK: - Folder Tree Helpers

    private struct FolderNode: Identifiable {
        let folder: DeviceFolder
        let depth: Int
        var id: UUID { folder.id }
        var indentedName: String {
            String(repeating: "    ", count: depth) + folder.name
        }
    }

    private var flattenedFolderTree: [FolderNode] {
        var result = [FolderNode]()
        let roots = folders.filter { $0.parentFolderID == nil }
        for root in roots {
            appendChildren(of: root, depth: 0, into: &result)
        }
        return result
    }

    private func appendChildren(of folder: DeviceFolder, depth: Int, into result: inout [FolderNode]) {
        result.append(FolderNode(folder: folder, depth: depth))
        let children = folders.filter { $0.parentFolderID == folder.id }
        for child in children {
            appendChildren(of: child, depth: depth + 1, into: &result)
        }
    }

    // MARK: - Name

    private var nameField: some View {
        SimpleTextField(
            axis: .vertical,
            title: Language.CreateFolder.nameTitle,
            placeholder: Language.CreateFolder.namePlaceholder,
            value: $folderName
        )
        .focused($nameFieldFocused)
    }

    // MARK: - Icon Picker

    private static let availableIcons: [String] = [
        "folder", "folder.fill",
        "house", "house.fill",
        "lightbulb", "lightbulb.fill",
        "desktopcomputer", "tv",
        "wifi", "personalhotspot",
        "camera", "camera.fill",
        "speaker.wave.2", "speaker.wave.2.fill",
        "fan", "fan.fill",
        "drop", "drop.fill",
        "thermometer.medium", "bolt",
        "leaf", "leaf.fill",
        "star", "star.fill",
    ]

    private let iconColumns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 5
    )

    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.CreateFolder.iconTitle)
                .font(.headline)
                .foregroundStyle(Color.primary)

            LazyVGrid(columns: iconColumns, spacing: 12) {
                ForEach(Self.availableIcons, id: \.self) { icon in
                    let isSelected = selectedIconName == icon
                    Button {
                        selectedIconName = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.title2)
                            .frame(width: 48, height: 48)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                            )
                    }
                }
            }
        }
    }

    // MARK: - Create Button

    private var createButton: some View {
        ComponentButton(title: Language.CreateFolder.createAction) {
            saveFolder()
        }
        .fillWidth()
        .state(Binding(
            get: {
                if isSaving { return .performing }
                return canCreate ? .normal : .disabled
            },
            set: { _ in }
        ))
    }

    private func saveFolder() {
        guard canCreate else { return }
        let folder = DeviceFolder(
            id: UUID(),
            name: folderName.trimmingCharacters(in: .whitespaces),
            iconName: selectedIconName,
            createdDate: .now,
            updatedDate: .now,
            parentFolderID: selectedParent?.id
        )
        isSaving = true
        Task {
            try? await repository.save(folder)
            isSaving = false
            createdFolder = folder
            onCreated?()
            navigateToDetail = true
        }
    }
}

#Preview {
    NavigationStack {
        CreateFolderView(
            folders: DeviceFolder.mocks,
            repository: CoreDataDeviceRepository()
        )
        .padding(.horizontal, 16)
    }
}
