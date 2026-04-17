//
//  ShopView.swift
//  Store
//

import SwiftUI

// MARK: - Shop Route

enum ShopRoute: Hashable {
    case cart
    case orders
    case checkout
    case orderConfirmation(Order)
}

// MARK: - Environment keys for shop navigation

private struct PopToCartKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct OnOrderPlacedKey: EnvironmentKey {
    static let defaultValue: (Order) -> Void = { _ in }
}

extension EnvironmentValues {
    var popToCart: () -> Void {
        get { self[PopToCartKey.self] }
        set { self[PopToCartKey.self] = newValue }
    }

    var onOrderPlaced: (Order) -> Void {
        get { self[OnOrderPlacedKey.self] }
        set { self[OnOrderPlacedKey.self] = newValue }
    }
}

struct ShopView: View {

    @State private var cart = CartManager.shared
    @State private var path = NavigationPath()
    @State private var isTabBarHidden = false
    @State private var selectedCategory: ReefProductCategory?
    @State private var searchText = ""

    private var filteredProducts: [ReefProduct] {
        var products = ReefProduct.mocks
        if let cat = selectedCategory {
            products = products.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            products = products.filter {
                $0.name.lowercased().contains(query) ||
                $0.subtitle.lowercased().contains(query) ||
                $0.category.title.lowercased().contains(query)
            }
        }
        return products
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                categoryFilter
                productList
            }
            .navigationTitle("Reef Shop")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search devices & equipment")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: ShopRoute.cart) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.title3)
                            if cart.itemCount > 0 {
                                Text("\(cart.itemCount)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .background(.red, in: Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: ShopRoute.orders) {
                        Image(systemName: "shippingbox")
                            .font(.title3)
                    }
                }
            }
        }
        .environment(\.popToCart) {
            // Pop back to CartView: keep only the first entry (.cart)
            while path.count > 1 {
                path.removeLast()
            }
        }
        .environment(\.onOrderPlaced) { order in
            // Pop checkout, then push order confirmation
            while path.count > 1 {
                path.removeLast()
            }
            path.append(ShopRoute.orderConfirmation(order))
        }
        .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .onChange(of: path.count) { _, newValue in
            withAnimation(.smooth(duration: 0.35)) {
                isTabBarHidden = newValue > 0
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "All", icon: "square.grid.2x2", category: nil)
                ForEach(ReefProductCategory.allCases) { cat in
                    categoryChip(title: cat.title, icon: cat.iconName, category: cat)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func categoryChip(title: String, icon: String, category: ReefProductCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.smooth(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(
                isSelected ? AnyShapeStyle(Color.blue) : AnyShapeStyle(Color.gray.opacity(0.12)),
                in: Capsule()
            )
        }
    }

    // MARK: - Product List

    private var productList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredProducts) { product in
                    NavigationLink(value: product) {
                        ProductRowView(product: product)
                    }
                    .buttonStyle(.plain)
                }

                if filteredProducts.isEmpty {
                    emptyView
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .navigationDestination(for: ReefProduct.self) { product in
            ReefProductDetailView(product: product)
        }
        .navigationDestination(for: ShopRoute.self) { route in
            switch route {
            case .cart: CartView()
            case .orders: OrderHistoryView()
            case .checkout: CheckoutView()
            case .orderConfirmation(let order): OrderConfirmationView(order: order)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No products found")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Product Row

struct ProductRowView: View {
    let product: ReefProduct

    var body: some View {
        HStack(spacing: 14) {
            // Product icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: product.imageName)
                    .font(.title2)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(product.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    // Price
                    Text(product.formattedPrice)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.blue)

                    if let original = product.formattedOriginalPrice {
                        Text(original)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .strikethrough()
                    }

                    if let discount = product.discountPercent {
                        Text("-\(discount)%")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red, in: Capsule())
                    }
                }

                HStack(spacing: 4) {
                    // Rating
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", product.rating))
                        .font(.caption2.weight(.medium))
                    Text("(\(product.reviewCount))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if !product.inStock {
                        Text("Out of stock")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.red)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }
}

#if DEBUG
#Preview {
    ShopView()
}
#endif
