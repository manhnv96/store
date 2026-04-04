//
//  TabbarView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI

struct TabbarView: View {
    @Binding var selectedTab: TabbarItem
    var items: [TabbarItem]
    
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(items, id: \.type) { item in
                TabbarItemView(
                    item: item,
                    selectedItem: $selectedTab
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .onTapGesture {
                    withAnimation {
                        selectedTab = item
                    }
                }
            }
        }
        .background {
            Color.white.shadow(
                color: Color.black.opacity(0.08),
                radius: 3,
                x: 0,
                y: -4
            )
        }
    }
}

struct TabbarItemView: View {
    let item: TabbarItem
    @Binding var selectedItem: TabbarItem
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 5
        ) {
            let isSelected = selectedItem == item
            let systemName = isSelected ? item.selectedImage : item.image
            Image(systemName: systemName)
                .resizable()
                .frame(width: 22, height: 22)
            Text(item.title)
                .font(.subheadline)
                .fontWeight(isSelected ? .medium : .regular)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedTab: TabbarItem = .home
    TabbarView(
        selectedTab: $selectedTab,
        items: [
            .home, .cart, .user
        ]
    )
    .frame(width: 415)
}
