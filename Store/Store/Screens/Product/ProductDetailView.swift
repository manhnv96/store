//
//  ProductDetailView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 11/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    var product: Product
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            WebImage(url: )
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .onTapGesture {
                    dismiss()
                }
        }
    }
}

#Preview {
    let product = Product.mocks[0]
    ProductDetailView(product: product)
}
