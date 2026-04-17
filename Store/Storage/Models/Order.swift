//
//  Order.swift
//  Store
//

import Foundation

// MARK: - Cart

struct CartItem: Identifiable, Hashable {
    let id = UUID()
    let product: ReefProduct
    var quantity: Int
}

// MARK: - Shipping

struct ShippingAddress: Hashable {
    var fullName: String = ""
    var phone: String = ""
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var country: String = "Vietnam"

    var isValid: Bool {
        !fullName.isEmpty && !phone.isEmpty && !street.isEmpty && !city.isEmpty
    }

    var formatted: String {
        [street, city, state, zipCode, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Payment

enum PaymentMethod: String, CaseIterable, Identifiable {
    case cod
    case bankTransfer
    case creditCard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cod: return "Cash on Delivery"
        case .bankTransfer: return "Bank Transfer"
        case .creditCard: return "Credit Card"
        }
    }

    var iconName: String {
        switch self {
        case .cod: return "banknote"
        case .bankTransfer: return "building.columns"
        case .creditCard: return "creditcard"
        }
    }
}

// MARK: - Order

enum OrderStatus: String, CaseIterable {
    case pending
    case confirmed
    case shipping
    case delivered

    var title: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .shipping: return "Shipping"
        case .delivered: return "Delivered"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .shipping: return "shippingbox"
        case .delivered: return "checkmark.seal.fill"
        }
    }

    var stepIndex: Int {
        switch self {
        case .pending: return 0
        case .confirmed: return 1
        case .shipping: return 2
        case .delivered: return 3
        }
    }
}

struct TrackingEvent: Identifiable, Hashable {
    static func == (lhs: TrackingEvent, rhs: TrackingEvent) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id = UUID()
    let status: OrderStatus
    let title: String
    let detail: String
    let date: Date
}

struct Order: Identifiable, Hashable {
    static func == (lhs: Order, rhs: Order) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id = UUID()
    let orderNumber: String
    let items: [CartItem]
    let shippingAddress: ShippingAddress
    let paymentMethod: PaymentMethod
    let subtotal: Double
    let shippingFee: Double
    let status: OrderStatus
    let createdDate: Date
    let trackingEvents: [TrackingEvent]

    var total: Double { subtotal + shippingFee }

    var formattedTotal: String { String(format: "$%.2f", total) }
    var formattedSubtotal: String { String(format: "$%.2f", subtotal) }
    var formattedShipping: String { shippingFee == 0 ? "Free" : String(format: "$%.2f", shippingFee) }

    var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
}
