//
//  DeviceView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import SwiftUI

struct DeviceView: View {
    let device: ConnectedDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: device.connectionType.iconSystemName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if !device.category.isEmpty {
                    Text(device.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5), in: Capsule())
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text(device.deviceName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(device.inputName)
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
    DeviceView(device: ConnectedDevice.mocks[0])
        .frame(width: 180)
        .padding()
}
#endif
