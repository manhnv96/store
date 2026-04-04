//
//  SimpleTextField.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 24/3/26.
//

import SwiftUI

struct SimpleTextField: View {
    let axis: Axis
    let title: String?
    let placeholder: String
    @Binding var value: String
    
    init(
        axis: Axis = .horizontal,
        title: String? = nil,
        placeholder: String = "",
        value: Binding<String>
    ) {
        self.axis = axis
        self.title = title
        self.placeholder = placeholder
        self._value = value
    }
    
    var body: some View {
        switch axis {
        case .horizontal:
            HStack(alignment: .center, spacing: 12) {
                content
            }
        case .vertical:
            VStack(alignment: .leading, spacing: 12) {
                content
            }
        }
        
    }
    
    var content: some View {
        Group {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
            
            TextField(text: $value) {
                Text(placeholder)
                    .font(.body).fontWeight(.regular)
                    .foregroundStyle(Color.gray)
            }
            .textInputAutocapitalization(.words)
            .font(.body).fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Color.gray.opacity(0.1).cornerRadius(8)
            }
        }
    }
}
private struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> AnyView

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> some View) {
        _value = State(initialValue: initialValue)
        self.content = { AnyView(content($0)) }
    }

    var body: some View {
        content($value)
    }
}

#Preview {
    StatefulPreviewWrapper("") { binding in
        SimpleTextField(title: "Title", placeholder: "Placeholder", value: binding)
            .padding()
    }
}

