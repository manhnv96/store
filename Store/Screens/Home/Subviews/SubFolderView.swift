//
//  SubFolderView.swift
//  Store
//

import SwiftUI

struct SubFolderView: View {
    let folder: DeviceFolder

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: folder.iconName)
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(folder.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(Language.FolderDetail.subFoldersTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(Color(.white), in: RoundedRectangle(cornerRadius: 10))
    }
}

#if DEBUG
#Preview(traits: .fixedLayout(width: 300, height: 200)) {
    SubFolderView(folder: DeviceFolder.mocks[0])
        .frame(width: 180)
        .padding()
}
#endif
