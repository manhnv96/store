//
//  SegmentedPicker.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 23/3/26.
//
import SwiftUI

protocol SegmentedPickerItem: Equatable, Hashable {
    var title: String { get }
}

struct SegmentedPicker<Item: SegmentedPickerItem>: View {
    let items: [Item]
    
    var selectedColor = Color.accentColor
    var selectedTextColor: Color = .white
    var selectedFont: Font = Font.title3.weight(.semibold)
    
    var backgroundColor: Color = Color(.systemGray6)
    var textColor = Color(.systemGray2)
    var font: Font = .title3
    
    @Binding var selection: Item?
    @State var animating: Bool = false
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                let isSelected = selection == item
                Text(item.title)
                    .font(isSelected ? selectedFont : font )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .foregroundColor(isSelected ? selectedTextColor : textColor)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: "active", in: animation)
                        }
                    }
                    .onTapGesture {
                        guard !animating else { return }
                        
                        withAnimation(
                            .spring(response: 0.3, dampingFraction: 0.6)
                        ) {
                            animating = true
                            selection = item
                        } completion: {
                            animating = false
                        }
                    }
            }
        }
        .padding(6)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var selected: ImportType?
    SegmentedPicker<ImportType>(
        items: ImportType.allCases,
        selection: $selected
    )
}
