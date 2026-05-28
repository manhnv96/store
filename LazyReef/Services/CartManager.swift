//
//  CartManager.swift
//  Store
//

import SwiftUI

@MainActor
@Observable
final class CartManager {
    static let shared = CartManager()

    private(set) var items: [CartItem] = []
    private(set) var orders: [Order] = []

    private init() {}

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }

    var shippingFee: Double {
        subtotal >= 100 ? 0 : 9.99
    }

    var total: Double {
        subtotal + shippingFee
    }

    var formattedSubtotal: String { String(format: "$%.2f", subtotal) }
    var formattedShipping: String { shippingFee == 0 ? "Free" : String(format: "$%.2f", shippingFee) }
    var formattedTotal: String { String(format: "$%.2f", total) }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - Cart Actions

    func add(_ product: ReefProduct, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }

    func updateQuantity(for itemID: UUID, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
    }

    func remove(_ itemID: UUID) {
        items.removeAll { $0.id == itemID }
    }

    func clearCart() {
        items.removeAll()
    }

    // MARK: - Order Actions

    func placeOrder(address: ShippingAddress, payment: PaymentMethod) -> Order {
        let now = Date()
        let orderNumber = "ORD-\(Int(now.timeIntervalSince1970) % 1_000_000)"

        let trackingEvents = [
            TrackingEvent(
                status: .pending,
                title: "Order Placed",
                detail: "Your order has been received and is being processed.",
                date: now
            )
        ]

        let order = Order(
            orderNumber: orderNumber,
            items: items,
            shippingAddress: address,
            paymentMethod: payment,
            subtotal: subtotal,
            shippingFee: shippingFee,
            status: .pending,
            createdDate: now,
            trackingEvents: trackingEvents
        )

        orders.insert(order, at: 0)
        clearCart()
        return order
    }
}
