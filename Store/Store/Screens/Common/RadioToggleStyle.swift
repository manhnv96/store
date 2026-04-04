//
//  Untitled.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 24/3/26.
//

import SwiftUI

struct RadioToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(configuration.isOn ? .blue : .secondary)
                configuration.label.lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
