//
//  AquariumCardView.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import SwiftUI

struct AquariumCardView: View {
    let aquarium: Aquarium
    let deviceCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: aquarium.iconName)
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
                Text("\(deviceCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5), in: Capsule())
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(aquarium.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(Language.AquariumDetail.deviceCount)
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
    AquariumCardView(aquarium: Aquarium.mocks[0], deviceCount: 3)
        .frame(width: 180)
        .padding()
}
#endif
