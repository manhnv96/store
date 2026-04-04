//
//  HomeView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI
import SDWebImage

struct HomeView: View {
    @Namespace var nameSpace
    
    @State var viewModel: HomeViewModel
    @State private var path = NavigationPath()
    
    // Grid configuration
    private let itemsPerRow: CGFloat = 2
    private let cornerRadius: CGFloat = 6
    private let itemSpacing: CGFloat = 16
    private let sectionBGColor = Color(.lightGray)
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                titleView
                contentView
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
                    .navigationTransition(
                        .zoom(sourceID: product.id, in: nameSpace)
                    )
            }
            .navigationDestination(for: Bool.self) { bool in
                ConnectView()
            }
        }
    }
    
    private var titleView: some View {
        Text(Language.Tabbar.home)
            .font(.system(size: 32, design: .default))
            .bold()
            .padding(.all)
            .padding(.top)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: itemSpacing) {
                ForEach(viewModel.categories, id: \.id) { category in
                    createSectionView(
                        category: category,
                        products: viewModel.products
                    )
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .refreshable {}
    }
    
    private func createSectionView(
        category: CategoryItem,
        products: [Product]
    ) -> some View {
        Section {
            let columns: [GridItem] = Array(
                repeating: GridItem(.flexible(), spacing: itemSpacing),
                count: Int(itemsPerRow)
            )
            LazyVGrid(
                columns: columns,
                spacing: itemSpacing
            ) {
                ForEach(viewModel.products, id: \.id) { product in
                    NavigationLink(value: product) {
                        ProductView(product: product)
                        .cornerRadius(cornerRadius, antialiased: false)
                    }
                }
            }
            .padding(16)
            .background {
                Color.brown.opacity(0.1).cornerRadius(3)
            }
        } header: {
            HStack {
                Text(category.title)
                    .font(.title)
                    .foregroundColor(.primary)
                Spacer()
                
                NavigationLink(value: true) {
                    Image(systemName: "plus").font(.title)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    HomeView(viewModel: .init(categories: CategoryItem.mocks, products: Product.mocks))
}

