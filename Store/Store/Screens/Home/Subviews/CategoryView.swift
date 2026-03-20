//
//  CategoryView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI
struct CategoryView: View {
    @Binding var selectedItem: CategoryItem?
    let categories: [CategoryItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6, content: {
                ForEach(categories, id: \.id) { category in
                    let isSelected = category.id == selectedItem?.id
                    Text(category.title)
                        .id(category.id)
                        .foregroundStyle(isSelected ? Color.white : Color.black)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule(style: .circular)
                                .fill(isSelected ? Color.black : Color.white)
                                .stroke(.black, lineWidth: 2)
                                .padding(.all, 1)
                        }
                        .onTapGesture {
                            selectedItem = category
                        }
                        .animation(.spring, value: selectedItem)
                }
            })
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedItem: CategoryItem?
    
    CategoryView(
        selectedItem: $selectedItem,
        categories: CategoryItem.mocks
    )
    .frame(width: 415)
}
