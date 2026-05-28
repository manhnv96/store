//
//  CartView.swift
//  Store
//

import SwiftUI

struct CartView: View {

    @State private var cart = CartManager.shared

    var body: some View {
        Group {
            if cart.isEmpty {
                emptyView
            } else {
                cartContent
            }
        }
        .navigationTitle("Cart")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Your cart is empty")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Browse the shop to add devices and equipment")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    // MARK: - Content

    private var cartContent: some View {
        VStack(spacing: 0) {
            List {
                ForEach(cart.items) { item in
                    cartRow(item)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        cart.remove(cart.items[index].id)
                    }
                }

                Section {
                    summaryRow("Subtotal", value: cart.formattedSubtotal)
                    summaryRow("Shipping", value: cart.formattedShipping)
                    if cart.subtotal < 100 {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Text("Free shipping on orders over $100")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(cart.formattedTotal)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.blue)
                    }
                }
            }
            .listStyle(.insetGrouped)

            checkoutButton
        }
    }

    private func cartRow(_ item: CartItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: item.product.imageName)
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(item.product.formattedPrice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 0) {
                Button {
                    cart.updateQuantity(for: item.id, quantity: item.quantity - 1)
                } label: {
                    Image(systemName: "minus")
                        .font(.caption.weight(.semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)

                Text("\(item.quantity)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .frame(width: 28)

                Button {
                    cart.updateQuantity(for: item.id, quantity: item.quantity + 1)
                } label: {
                    Image(systemName: "plus")
                        .font(.caption.weight(.semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)
            }
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 4)
    }

    private func summaryRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }

    private var checkoutButton: some View {
        NavigationLink(value: ShopRoute.checkout) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.subheadline)
                Text("Checkout — \(cart.formattedTotal)")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CartView()
    }
}
#endif
