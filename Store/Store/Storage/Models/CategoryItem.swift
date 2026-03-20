//
//  CategoryItem.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 17/4/25.
//

struct CategoryItem: Equatable, Hashable {
    let id: String
    let title: String
}

extension CategoryItem {
    
    static var mocks = [
        CategoryItem(id: "01", title: "Calendar"),
        CategoryItem(id: "02", title: "Wallpaper"),
        CategoryItem(id: "03", title: "Sticker")
    ]
    
}
