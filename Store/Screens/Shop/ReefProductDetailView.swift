//
//  ReefProductDetailView.swift
//  Store
//

import SwiftUI

struct ReefProductDetailView: View {

    let product: ReefProduct
    @State private var cart = CartManager.shared
    @State private var quantity = 1
    @State private var showingAddedAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroSection
                priceSection
                descriptionSection
                featuresSection
                ratingsSection
            }
            .padding(.bottom, 100)
        }
        .scrollBounceBehavior(.basedOnSize)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(product.category.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .alert("Added to Cart", isPresented: $showingAddedAlert) {
            Button("OK") {}
        } message: {
            Text("\(quantity)x \(product.name) added to your cart.")
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.08))
                    .frame(height: 220)
                Image(systemName: product.imageName)
                    .font(.system(size: 72))
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 6) {
                Text(product.name)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(product.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Price

    private var priceSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(product.formattedPrice)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.blue)

                if let original = product.formattedOriginalPrice {
                    Text(original)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .strikethrough()
                }

                if let discount = product.discountPercent {
                    Text("Save \(discount)%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red, in: Capsule())
                }

                Spacer()
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(product.inStock ? .green : .red)
                    .frame(width: 8, height: 8)
                Text(product.inStock ? "In Stock" : "Out of Stock")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(product.inStock ? .green : .red)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About this product")
                .font(.title3.weight(.semibold))
            Text(product.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Features")
                .font(.title3.weight(.semibold))

            VStack(spacing: 0) {
                ForEach(Array(product.features.enumerated()), id: \.offset) { index, feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        Text(feature)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    if index < product.features.count - 1 {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Ratings

    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customer Reviews")
                .font(.title3.weight(.semibold))

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 40, weight: .bold))
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: Double(star) <= product.rating ? "star.fill" : (Double(star) - 0.5 <= product.rating ? "star.leadinghalf.filled" : "star"))
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    Text("\(product.reviewCount) reviews")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    ratingBar(stars: 5, percentage: 0.68)
                    ratingBar(stars: 4, percentage: 0.22)
                    ratingBar(stars: 3, percentage: 0.06)
                    ratingBar(stars: 2, percentage: 0.03)
                    ratingBar(stars: 1, percentage: 0.01)
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }

    private func ratingBar(stars: Int, percentage: Double) -> some View {
        HStack(spacing: 6) {
            Text("\(stars)")
                .font(.caption2.weight(.medium))
                .frame(width: 10, alignment: .trailing)
            Image(systemName: "star.fill")
                .font(.system(size: 8))
                .foregroundStyle(.orange)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                    Capsule()
                        .fill(Color.orange)
                        .frame(width: proxy.size.width * percentage)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 14) {
            // Quantity stepper
            HStack(spacing: 0) {
                Button {
                    if quantity > 1 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.subheadline.weight(.medium))
                        .frame(width: 36, height: 36)
                }
                .disabled(quantity <= 1)

                Text("\(quantity)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .frame(width: 32)

                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.medium))
                        .frame(width: 36, height: 36)
                }
            }
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

            // Add to cart button
            Button {
                cart.add(product, quantity: quantity)
                showingAddedAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "cart.badge.plus")
                        .font(.subheadline.weight(.semibold))
                    Text("Add to Cart — \(totalFormatted)")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    product.inStock ? Color.blue : Color.gray,
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            .disabled(!product.inStock)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var totalFormatted: String {
        String(format: "$%.2f", product.price * Double(quantity))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReefProductDetailView(product: ReefProduct.mocks[0])
    }
}
#endif
