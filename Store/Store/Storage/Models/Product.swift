//
//  Product.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 17/4/25.
//
import Foundation

struct Product: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let categories: [String]
    let name, intro, thumb: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        _ = hasher.finalize()
    }
}

extension Product {
    static let mocks: [Product] = [
        Product(
            categories: ["01"],
            name: "Photo book",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            categories: ["01"],
            name: "Photo book",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            categories: ["01"],
            name: "Photo book",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            categories: ["01"],
            name: "Photo book",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            categories: ["01"],
            name: "Photo book",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            categories: ["01"],
            name: "Photo book",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        )
    ]
}
