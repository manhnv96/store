import SwiftUI

@Observable
final class HomeViewModel {
    // Inputs / Data
    var categories: [CategoryItem]
    var products: [Product]

    var selectedCategory: CategoryItem?
    var selectedProduct: Product?

    init(
        categories: [CategoryItem],
        products: [Product]
    ) {
        self.categories = categories
        self.products = products
    }

    func requestProduct(by category: CategoryItem) async -> [Product] {
        let task = Task<[Product], Never>(
            name: "Filter products of category \(category.title)",
            priority: .userInitiated
        ) {
            products.filter { $0.categories.contains(category.id) }
        }
        
        return await task.value
    }
    
}

#if DEBUG
extension HomeViewModel {
    static var mock: HomeViewModel {
        HomeViewModel(categories: CategoryItem.mocks, products: Product.mocks)
    }
}
#endif
