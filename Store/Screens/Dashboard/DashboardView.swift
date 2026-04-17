//
//  DashboardView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI

struct DashboardView: View {
    private let tabbarItems: [TabbarItem] = [
        .home, .cart, .user
    ]
    
    @State private var selectedTab: TabbarItem = .home
    
    private var homeView: some View = {
        HomeView(viewModel: .init())
    }()

    private var cartView: some View = {
        ShopView()
    }()

    private var personView: some View = {
        ProfileView()
    }()

    private var settingView: some View = {
        HomeView(viewModel: .init())
    }()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: TabbarItem.home) {
                homeView
            } label: {
                label(for: .home, selected: selectedTab == .home)
            }
            
            Tab(value: TabbarItem.cart) {
                cartView
            } label: {
                label(for: .cart, selected: selectedTab == .cart)
            }
            
            Tab(value: TabbarItem.user) {
                personView
            } label: {
                label(for: .user, selected: selectedTab == .user)
            }
        }
        .tint(Color.blue)
    }
    
    func label(for item: TabbarItem, selected: Bool) -> some View {
        Label(
            item.title,
            systemImage: selected ? item.selectedImage : item.image
        )
    }
}

#Preview {
    DashboardView()
}
