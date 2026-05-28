//
//  TabbarItem.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 11/5/25.
//

enum TabbarItemType: String, CaseIterable {
    case home, cart, user
}

struct TabbarItem: Identifiable, Equatable, Hashable {
    var id: String { type.rawValue }
    
    let type: TabbarItemType
    let title, image, selectedImage: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        debug(hasher.finalize())
    }
    
    static func == (lhs: TabbarItem, rhs: TabbarItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension TabbarItem {
    static let home: TabbarItem = {
        TabbarItem(
            type: .home,
            title: Language.Tabbar.home,
            image: "house",
            selectedImage: "house.fill"
        )
    }()
    
    static let cart: TabbarItem = {
        TabbarItem(
            type: .cart,
            title: Language.Tabbar.cart,
            image: "cart",
            selectedImage: "cart.fill"
        )
    }()
    
    static let user: TabbarItem = {
        TabbarItem(
            type: .user,
            title: Language.Tabbar.user,
            image: "person.circle",
            selectedImage: "person.circle.fill"
        )
    }()
}
