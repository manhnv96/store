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
    /// IDs of items currently selected for checkout. Newly added items
    /// are auto-selected. Empty set means nothing will be checked out.
    private(set) var selectedItemIDs: Set<UUID> = []

    private init() {}

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - Selection

    var selectedItems: [CartItem] {
        items.filter { selectedItemIDs.contains($0.id) }
    }

    var hasSelection: Bool { !selectedItems.isEmpty }

    var allSelected: Bool { !items.isEmpty && selectedItems.count == items.count }

    func isSelected(_ itemID: UUID) -> Bool { selectedItemIDs.contains(itemID) }

    func toggleSelection(_ itemID: UUID) {
        if selectedItemIDs.contains(itemID) {
            selectedItemIDs.remove(itemID)
        } else {
            selectedItemIDs.insert(itemID)
        }
    }

    func setAllSelected(_ selected: Bool) {
        selectedItemIDs = selected ? Set(items.map(\.id)) : []
    }

    // MARK: - Totals (based on selected items)

    var subtotal: Double {
        selectedItems.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }

    var shippingFee: Double {
        guard hasSelection else { return 0 }
        return subtotal >= 100 ? 0 : 9.99
    }

    var total: Double {
        subtotal + shippingFee
    }

    var formattedSubtotal: String { String(format: "$%.2f", subtotal) }
    var formattedShipping: String { shippingFee == 0 ? "Free" : String(format: "$%.2f", shippingFee) }
    var formattedTotal: String { String(format: "$%.2f", total) }

    // MARK: - Cart Actions

    func add(_ product: ReefProduct, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
            selectedItemIDs.insert(items[index].id)
        } else {
            let item = CartItem(product: product, quantity: quantity)
            items.append(item)
            selectedItemIDs.insert(item.id)
        }
    }

    func updateQuantity(for itemID: UUID, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
            selectedItemIDs.remove(itemID)
        } else {
            items[index].quantity = quantity
        }
    }

    func remove(_ itemID: UUID) {
        items.removeAll { $0.id == itemID }
        selectedItemIDs.remove(itemID)
    }

    func clearCart() {
        items.removeAll()
        selectedItemIDs.removeAll()
    }

    // MARK: - Order Actions

    /// Create an order from currently selected items. Selected items are
    /// removed from the cart; unselected items remain.
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

        let checkoutItems = selectedItems
        let checkoutSubtotal = subtotal
        let checkoutShipping = shippingFee

        let order = Order(
            orderNumber: orderNumber,
            items: checkoutItems,
            shippingAddress: address,
            paymentMethod: payment,
            subtotal: checkoutSubtotal,
            shippingFee: checkoutShipping,
            status: .pending,
            createdDate: now,
            trackingEvents: trackingEvents
        )

        orders.insert(order, at: 0)
        // Remove only checked-out items; keep the rest in cart.
        let orderedIDs = Set(checkoutItems.map(\.id))
        items.removeAll { orderedIDs.contains($0.id) }
        selectedItemIDs.subtract(orderedIDs)
        return order
    }
}
