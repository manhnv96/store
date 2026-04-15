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
    @State private var isDropdownExpanded = false
    @State private var expandedFolderIDs: Set<UUID> = []
    @State private var dropdownHeight: CGFloat = 0
    @State private var triggerFrame: CGRect = .zero

    @FocusState private var nameFieldFocused: Bool
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh

    let folders: [DeviceFolder]
    var repository: any DeviceRepository
    @Binding var navigationPath: NavigationPath
    var onCreated: (() -> Void)?

    private var canCreate: Bool {
        !folderName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let coordinateSpace = NamedCoordinateSpace.named("createFolder")

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
            .onTapGesture {
                nameFieldFocused = false
                if isDropdownExpanded { isDropdownExpanded = false }
            }

            createButton
                .padding(.top, 12)
        }
        .coordinateSpace(coordinateSpace)
        .overlay(alignment: .topLeading) {
            if isDropdownExpanded {
                parentDropdownList
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        dropdownHeight = newValue
                    }
                    .frame(width: triggerFrame.width)
                    .offset(x: triggerFrame.minX, y: triggerFrame.maxY + 4)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isDropdownExpanded)
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
        parentTriggerButton
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: coordinateSpace)
            } action: { newValue in
                triggerFrame = newValue
            }
    }

    private var parentTriggerButton: some View {
        Button {
            isDropdownExpanded.toggle()
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
                Image(systemName: isDropdownExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var parentDropdownList: some View {
        VStack(spacing: 0) {
            // "None" option
            Button {
                selectedParent = nil
                isDropdownExpanded = false
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary)
                    Text(Language.CreateFolder.parentFolderNone)
                        .font(.body)
                    Spacer()
                    if selectedParent == nil {
                        Image(systemName: "checkmark")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            ForEach(rootFolders) { folder in
                parentFolderRow(folder, depth: 0)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.top, 4)
    }

    // MARK: - Folder Tree Helpers

    private var rootFolders: [DeviceFolder] {
        folders.filter { $0.parentFolderID == nil }
    }

    private func childFolders(of folder: DeviceFolder) -> [DeviceFolder] {
        folders.filter { $0.parentFolderID == folder.id }
    }

    private func parentFolderRow(_ folder: DeviceFolder, depth: Int) -> AnyView {
        let children = childFolders(of: folder)
        let hasChildren = !children.isEmpty
        let isFolderExpanded = expandedFolderIDs.contains(folder.id)

        return AnyView(VStack(spacing: 0) {
            Button {
                selectedParent = folder
                isDropdownExpanded = false
            } label: {
                HStack {
                    if hasChildren {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if isFolderExpanded {
                                    expandedFolderIDs.remove(folder.id)
                                } else {
                                    expandedFolderIDs.insert(folder.id)
                                }
                            }
                        } label: {
                            Image(systemName: isFolderExpanded ? "chevron.down" : "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Spacer().frame(width: 16)
                    }

                    Image(systemName: folder.iconName)
                        .foregroundStyle(.blue)

                    Text(folder.name)
                        .font(.body)

                    Spacer()

                    if selectedParent?.id == folder.id {
                        Image(systemName: "checkmark")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.leading, CGFloat(depth) * 16 + 12)
                .padding(.trailing, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if hasChildren && isFolderExpanded {
                ForEach(children) { child in
                    parentFolderRow(child, depth: depth + 1)
                }
            }
        })
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
            onCreated?()
            // Safely call refresh if available (won't crash if not in HomeView context)
            triggerHomeRefresh()
            var newPath = NavigationPath()
            newPath.append(folder)
            navigationPath = newPath
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        CreateFolderView(
            folders: DeviceFolder.mocks,
            repository: CoreDataDeviceRepository(),
            navigationPath: $path
        )
        .padding(.horizontal, 16)
    }
}
