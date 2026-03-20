//
//  TabbarItem.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 11/5/25.
//

enum TabbarItemType: String {
    case home, cart, user, setting
}

struct TabbarItem: Identifiable, Hashable {
    var id: String { type.rawValue }
    
    let type: TabbarItemType
    let title, image, selectedImage: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        _ = hasher.finalize()
    }
}

extension TabbarItem {
    static let home: TabbarItem = {
        TabbarItem(
            type: .home,
            title: "Home",
            image: "house",
            selectedImage: "house.fill"
        )
    }()
    
    static let cart: TabbarItem = {
        TabbarItem(
            type: .cart,
            title: "Cart",
            image: "cart",
            selectedImage: "cart.fill"
        )
    }()
    
    static let user: TabbarItem = {
        TabbarItem(
            type: .user,
            title: "Person",
            image: "person.circle",
            selectedImage: "person.circle.fill"
        )
    }()
    
    static let setting: TabbarItem = {
        TabbarItem(
            type: .setting,
            title: "Setting",
            image: "gear",
            selectedImage: "cart.fill"
        )
    }()
}
