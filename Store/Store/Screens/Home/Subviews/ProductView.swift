//
//  ProductView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 17/4/25.
//

import SwiftUI

struct ProductView: View {
    let product: Product
    var body: some View {
        AsyncImage(url: URL(string: product.thumb))
        .overlay(alignment: .topLeading) {
            Text(product.name)
                .foregroundStyle(Color.white)
                .font(.headline)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.all, 8)
                .background {
                    Color.black.opacity(0.2)
                }
        }
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductView(product: Product.mocks[0])
        .frame(width: 414, height: 9/16 * 414)
}
