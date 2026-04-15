//
//  FolderPickerField.swift
//  Store
//

import SwiftUI

struct FolderPickerField: View {
    let folders: [DeviceFolder]
    @Binding var selectedFolder: DeviceFolder?

    @State private var isExpanded = false
    @State private var expandedFolderIDs: Set<UUID> = []
    @State private var dropdownHeight: CGFloat = 0
    @State private var triggerFrame: CGRect = .zero

    private let coordinateSpace = NamedCoordinateSpace.named("folderPicker")

    private var rootFolders: [DeviceFolder] {
        folders.filter { $0.parentFolderID == nil }
    }

    private func children(of folder: DeviceFolder) -> [DeviceFolder] {
        folders.filter { $0.parentFolderID == folder.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.Device.folderTitle)
                .font(.headline)
                .foregroundStyle(Color.primary)

            if folders.isEmpty {
                disabledField
            } else {
                triggerButton
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: coordinateSpace)
                    } action: { newValue in
                        triggerFrame = newValue
                    }
            }
        }
        .coordinateSpace(coordinateSpace)
        .overlay(alignment: .topLeading) {
            if isExpanded {
                dropdownList
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        dropdownHeight = newValue
                    }
                    .frame(width: triggerFrame.width)
                    .offset(x: triggerFrame.minX, y: triggerFrame.maxY + 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.3), value: isExpanded)
        .zIndex(isExpanded ? 1 : 0)
    }

    // MARK: - Trigger

    private var disabledField: some View {
        HStack {
            Text(Language.Device.folderNone)
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

    private var triggerButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            HStack {
                if let folder = selectedFolder {
                    Image(systemName: folder.iconName)
                        .foregroundStyle(.secondary)
                    Text(folder.name)
                        .font(.body).fontWeight(.medium)
                        .foregroundStyle(Color.primary)
                } else {
                    Text(Language.Device.folderNone)
                        .font(.body).fontWeight(.medium)
                        .foregroundStyle(Color.gray)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dropdown

    private var dropdownList: some View {
        VStack(spacing: 0) {
            noneRow
            ForEach(rootFolders) { folder in
                folderRow(folder, depth: 0)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.top, 4)
    }

    private var noneRow: some View {
        Button {
            selectedFolder = nil
            isExpanded = false
        } label: {
            HStack {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
                Text(Language.Device.folderNone)
                    .font(.body)
                Spacer()
                if selectedFolder == nil {
                    Image(systemName: "checkmark")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func folderRow(_ folder: DeviceFolder, depth: Int) -> AnyView {
        let childFolders = children(of: folder)
        let hasChildren = !childFolders.isEmpty
        let isFolderExpanded = expandedFolderIDs.contains(folder.id)

        return AnyView(VStack(spacing: 0) {
            Button {
                selectedFolder = folder
                isExpanded = false
            } label: {
                HStack {
                    if hasChildren {
                        Button {
                            withAnimation(.smooth(duration: 0.25)) {
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

                    if selectedFolder?.id == folder.id {
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
                ForEach(childFolders) { child in
                    folderRow(child, depth: depth + 1)
                }
            }
        })
    }
}

#Preview {
    FolderPickerField(
        folders: DeviceFolder.mocks,
        selectedFolder: .constant(nil)
    )
    .padding()
}
