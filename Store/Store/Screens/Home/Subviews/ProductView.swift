//
//  ProductView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 17/4/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductView: View {
    @Namespace var nameSpace
    
    let product: Product
    
    var body: some View {
        WebImage(url: URL(string: product.thumb)) { image in
            image.resizable()
                .scaledToFill()
                .matchedTransitionSource(id: product.id, in: nameSpace)
        } placeholder: {
            Rectangle().foregroundColor(.gray)
        }
        .indicator(.progress)
        .overlay(alignment: .topLeading) {
            Text(product.name)
                .foregroundStyle(Color.white)
                .font(.headline)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.all, 8)
                .background(Color.white.opacity(0.3))
                .matchedTransitionSource(id: product.name, in: nameSpace)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductView(product: Product.mocks[0])
        .frame(width: 414, height: 9/16 * 414)
}
