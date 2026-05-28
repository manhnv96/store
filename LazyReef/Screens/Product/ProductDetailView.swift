//
//  ProductDetailView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 11/5/25.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI

struct ProductDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Namespace var nameSpace
    
    var product: Product
    
    var body: some View {
        VStack(alignment: .center) {
            Text(product.name)
                .font(.title)
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .padding(.all, 8)
                .matchedTransitionSource(id: product.name, in: nameSpace)
            
            WebImage(url: try? product.thumb.asURL()) { image in
                image.resizable()
                    .scaledToFit()
                    .matchedTransitionSource(id: product.id, in: nameSpace)
            } placeholder: {
                Rectangle().foregroundColor(.gray)
            }
            .indicator(.progress)
            Spacer()
        }
    }
}

#Preview {
    if let product = Product.mocks.first {
        ProductDetailView(product: product)
    }
}
