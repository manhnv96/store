//
//  AquariumSetupChipRow.swift
//  LazyReef
//
//  Shared chip-style picker for optional aquarium setup enums
//  (sump type, livestock type). Allows clearing to nil.
//

import SwiftUI

protocol AquariumSetupOption: Hashable, Identifiable {
    var displayName: String { get }
    var iconSystemName: String { get }
}

extension AquariumSumpType: AquariumSetupOption {}
extension AquariumLivestockType: AquariumSetupOption {}

struct AquariumSetupChipRow<Option: AquariumSetupOption>: View {
    let options: [Option]
    @Binding var selection: Option?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options) { option in
                    chip(for: option)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(for option: Option) -> some View {
        let isSelected = selection == option
        return Button {
            selection = isSelected ? nil : option
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.iconSystemName)
                    .font(.caption.weight(.semibold))
                Text(option.displayName)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? AnyShapeStyle(Color.blue) : AnyShapeStyle(Color.gray.opacity(0.12)),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
