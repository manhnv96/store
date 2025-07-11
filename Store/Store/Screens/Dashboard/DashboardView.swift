//
//  DashboardView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI

struct DashboardView: View {
    private let tabbarItems: [TabbarItem] = [
        .home, .cart, .user, .setting
    ]
    
    @State private var selectedTab: TabbarItem = .home
    
    private var homeView: some View = {
        HomeView(
            categories: CategoryItem.mocks,
            products: Product.mocks
        )
        
    }()
    
    private var cartView: some View = {
        Spacer()
        .tag(TabbarItem.cart)
    }()
    
    private var personView: some View = {
        HomeView(
            categories: CategoryItem.mocks,
            products: Product.mocks
        )
    }()
    
    private var settingView: some View = {
        HomeView(
            categories: CategoryItem.mocks,
            products: Product.mocks
        )
    }()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            homeView
                .tabItem {
                    TabbarItemView(
                        item: .home,
                        selectedItem: $selectedTab
                    )
                }
            
            cartView
                .tabItem {
                    TabbarItemView(
                        item: .cart,
                        selectedItem: $selectedTab
                    )
                }
            
            personView
                .tabItem {
                    TabbarItemView(
                        item: .user,
                        selectedItem: $selectedTab
                    )
                }
            
            settingView
                .tabItem {
                    TabbarItemView(
                        item: .setting,
                        selectedItem: $selectedTab
                    )
                }
        }
        .tint(Color.primary)
    }
}

#Preview {
    DashboardView()
}
