//
//  AquariumPickerField.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import SwiftUI

struct AquariumPickerField: View {
    let aquariums: [Aquarium]
    let folders: [DeviceFolder]
    @Binding var selectedAquarium: Aquarium?

    @State private var isExpanded = false
    @State private var triggerFrame: CGRect = .zero

    private let coordinateSpace = NamedCoordinateSpace.named("aquariumPicker")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.Aquarium.pickerTitle)
                .font(.headline)
                .foregroundStyle(Color.primary)

            if aquariums.isEmpty {
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
            Text(Language.Aquarium.pickerEmpty)
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
                if let aquarium = selectedAquarium {
                    Image(systemName: aquarium.iconName)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(aquarium.name)
                            .font(.body).fontWeight(.medium)
                            .foregroundStyle(Color.primary)
                        if let folderName = parentFolderName(for: aquarium) {
                            Text(folderName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text(Language.Aquarium.pickerNone)
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
            ForEach(aquariums) { aquarium in
                aquariumRow(aquarium)
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
            selectedAquarium = nil
            isExpanded = false
        } label: {
            HStack {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
                Text(Language.Aquarium.pickerNone)
                    .font(.body)
                Spacer()
                if selectedAquarium == nil {
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

    private func aquariumRow(_ aquarium: Aquarium) -> some View {
        Button {
            selectedAquarium = aquarium
            isExpanded = false
        } label: {
            HStack {
                Image(systemName: aquarium.iconName)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 1) {
                    Text(aquarium.name)
                        .font(.body)
                    if let folderName = parentFolderName(for: aquarium) {
                        Text(folderName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if selectedAquarium?.id == aquarium.id {
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

    // MARK: - Helpers

    private func parentFolderName(for aquarium: Aquarium) -> String? {
        guard let folderID = aquarium.parentFolderID else { return nil }
        return folders.first { $0.id == folderID }?.name
    }
}

#Preview {
    AquariumPickerField(
        aquariums: Aquarium.mocks,
        folders: DeviceFolder.mocks,
        selectedAquarium: .constant(nil)
    )
    .padding()
}
