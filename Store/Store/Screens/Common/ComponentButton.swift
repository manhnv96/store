//
//  ComponentButton.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 24/3/26.
//

import SwiftUI

enum ComponentButtonState {
    case normal, disabled, performing
    
    var enableUserInteraction: Bool {
        self == .normal
    }
}

struct ComponentButton: View {
    
    let normal: String
    var disabled: String?
    var performing: String?
    var activeColor = Color.blue
    var inactiveColor = Color(.systemGray2)
    
    var title: String {
        switch state {
        case .normal:
            normal
        case .disabled:
            disabled ?? normal
        case .performing:
            performing ?? normal
        }
    }
    
    var foregroundColor: Color {
        state.enableUserInteraction ? activeColor : inactiveColor
    }
    
    @Binding var state: ComponentButtonState
    var action: () -> Void
    
    @State private var phase: CGFloat = 0
    
    init(
        title normal: String,
        disabled: String? = nil,
        performing: String? = nil,
        activeColor: Color = Color.blue,
        inactiveColor: Color = Color(.systemGray2),
        state: Binding<ComponentButtonState>,
        action: @escaping () -> Void
    ) {
        self.normal = normal
        self.disabled = disabled
        self.performing = performing
        self.activeColor = activeColor
        self.inactiveColor = activeColor
        _state = state
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: 8) {
                Text(title).font(.title3.weight(.semibold))
                    .foregroundStyle(foregroundColor)
                
                if state == .performing {
                    ProgressView()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .overlay(
                Capsule().stroke(foregroundColor, lineWidth: 2)
            )
            .background(Capsule().fill(Color.clear))
            .opacity(state.enableUserInteraction ? 1 : 0.8)
        }
        .disabled(!state.enableUserInteraction)
    }
}

#Preview {
    @Previewable @State var state: ComponentButtonState = .performing
    ComponentButton(title: "Connect", state: $state, action: {})
}
