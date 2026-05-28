//
//  Product.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 17/4/25.
//
import Foundation

struct Product: Identifiable, Hashable {
    let id: String
    let categories: [String]
    let name, intro, thumb: String
}

extension Product {
    static let mocks: [Product] = [
        Product(
            id: "01",
            categories: ["01"],
            name: "Photo 01",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            id: "02",
            categories: ["01"],
            name: "Photo 02",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            id: "03",
            categories: ["01"],
            name: "Photo 03",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            id: "04",
            categories: ["01"],
            name: "Photo 04",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            id: "05",
            categories: ["01"],
            name: "Photo 05",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        ),
        Product(
            id: "06",
            categories: ["01"],
            name: "Photo 06",
            intro: "",
            thumb: "https://images.pexels.com/photos/159850/book-glasses-read-professional-reading-159850.jpeg"
        )
    ]
}
