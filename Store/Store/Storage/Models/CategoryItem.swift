//
//  CategoryItem.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 17/4/25.
//

struct CategoryItem: Equatable {
    let id: String
    let title: String
}

extension CategoryItem {
    
    static var mocks = [
        CategoryItem(id: "01", title: "Calendar"),
        CategoryItem(id: "02", title: "Wallpaper"),
        CategoryItem(id: "03", title: "Sticker"),
        CategoryItem(id: "04", title: "Calendar"),
        CategoryItem(id: "05", title: "Wallpaper"),
        CategoryItem(id: "06", title: "Sticker")
    ]
    
}
