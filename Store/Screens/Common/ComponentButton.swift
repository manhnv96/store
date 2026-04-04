//
//  ComponentButton.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 24/3/26.
//

import SwiftUI

enum ComponentButtonState {
    case normal, disabled, performing
}

extension ComponentButtonState {
    var interactable: Bool {
        self == .normal
    }
}

enum ComponentButtonStyle {
    case primary
    case secondary
}

struct ComponentButton: View {
    
    // MARK: - Required
    private let normal: String
    private let action: () -> Void
    
    // MARK: - Configurable via builder
    private var style: ComponentButtonStyle = .primary
    private var disabledTitle: String?
    private var performingTitle: String?
    private var activeColor: Color = .blue
    private var inactiveColor: Color = Color(.systemGray2)
    private var fillWidth: Bool = false
    private var stateBinding: Binding<ComponentButtonState> = .constant(.normal)
    
    // MARK: - Init
    
    init(title: String, action: @escaping () -> Void) {
        self.normal = title
        self.action = action
    }
    
    // MARK: - Builder
    
    func style(_ style: ComponentButtonStyle) -> Self {
        var copy = self; copy.style = style; return copy
    }
    
    func disabledTitle(_ title: String) -> Self {
        var copy = self; copy.disabledTitle = title; return copy
    }
    
    func performingTitle(_ title: String) -> Self {
        var copy = self; copy.performingTitle = title; return copy
    }
    
    func activeColor(_ color: Color) -> Self {
        var copy = self; copy.activeColor = color; return copy
    }
    
    func inactiveColor(_ color: Color) -> Self {
        var copy = self; copy.inactiveColor = color; return copy
    }
    
    func fillWidth(_ fill: Bool = true) -> Self {
        var copy = self; copy.fillWidth = fill; return copy
    }
    
    func state(_ binding: Binding<ComponentButtonState>) -> Self {
        var copy = self; copy.stateBinding = binding; return copy
    }
    
    // MARK: - Private helpers
    
    private var currentState: ComponentButtonState {
        stateBinding.wrappedValue
    }
    
    private var title: String {
        switch currentState {
        case .normal:    normal
        case .disabled:  disabledTitle ?? normal
        case .performing: performingTitle ?? normal
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
                .white
        case .secondary:
            currentState.interactable ? activeColor : inactiveColor
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            currentState.interactable ? activeColor : inactiveColor
        case .secondary:
                .clear
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: 8) {
                Text(title).font(.title3.weight(.semibold))
                    .foregroundStyle(foregroundColor)
                
                if currentState == .performing {
                    ProgressView()
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: fillWidth ? .infinity : nil, minHeight: 44)
            .overlay {
                switch style {
                case .secondary:
                    Capsule().stroke(foregroundColor, lineWidth: 2)
                case .primary:
                    EmptyView()
                }
            }
            .background(Capsule().fill(backgroundColor))
            .opacity(currentState.interactable ? 1 : 0.8)
        }
        .disabled(!currentState.interactable)
    }
}

#Preview {
    VStack(spacing: 16) {
        ComponentButton(title: "Primary", action: {})
            .style(.primary)
            .fillWidth()
        
        ComponentButton(title: "Secondary", action: {})
            .style(.secondary)
            .fillWidth()
    }
    .padding()
}
