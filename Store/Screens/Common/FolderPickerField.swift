//
//  FolderPickerField.swift
//  Store
//

import SwiftUI

struct FolderPickerField: View {
    let folders: [DeviceFolder]
    @Binding var selectedFolder: DeviceFolder?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.Device.folderTitle)
                .font(.headline)
                .foregroundStyle(Color.primary)

            Menu {
                Button {
                    selectedFolder = nil
                } label: {
                    HStack {
                        Text(Language.Device.folderNone)
                        if selectedFolder == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach(folders) { folder in
                    Button {
                        selectedFolder = folder
                    } label: {
                        HStack {
                            Text(folder.name)
                            if selectedFolder?.id == folder.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedFolder?.name ?? Language.Device.folderNone)
                        .font(.body).fontWeight(.medium)
                        .foregroundStyle(selectedFolder == nil ? Color.gray : Color.primary)
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
    }
}

#Preview {
    FolderPickerField(
        folders: DeviceFolder.mocks,
        selectedFolder: .constant(nil)
    )
    .padding()
}
