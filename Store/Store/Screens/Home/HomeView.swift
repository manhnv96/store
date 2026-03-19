//
//  HomeView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI

struct HomeView: View {
    @State var selectedItem: CategoryItem?
    @State var categories: [CategoryItem]
    @State var products: [Product]
    @State var selectedProduct: Product?
    
    @Environment(\.refresh) var refresh
    @Namespace var nameSpace
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                GeometryReader { geometry in
                    List {
                        ForEach(products, id: \.id) { product in
                            NavigationLink(value: product) {
                                ProductView(product: product)
                                    .frame(maxWidth: geometry.size.width)
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .matchedTransitionSource(id: product.id, in: nameSpace)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .safeAreaPadding(.horizontal, 8)
                    }
                    .listStyle(.plain)
                    .frame(maxWidth: geometry.size.width)
                    .safeAreaPadding(.top, 40)
                    .refreshable {
                        debugPrint("Refresh")
                    }
                }
                
                CategoryView(
                    selectedItem: $selectedItem,
                    categories: categories
                )
                .safeAreaPadding(.horizontal, 16)
                .padding(.bottom, 8)
                .background {
                    Color.white.opacity(0.95)
                        .ignoresSafeArea()
                        .blur(radius: 3)
                }
            }
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
                .navigationTransition(.zoom(sourceID: product.id, in: nameSpace))
        }
    }
}

#Preview {
    HomeView(
        categories: CategoryItem.mocks,
        products: Product.mocks
    )
}
