//
//  OrderHistoryView.swift
//  Store
//

import SwiftUI

struct OrderHistoryView: View {

    @State private var cart = CartManager.shared

    var body: some View {
        Group {
            if cart.orders.isEmpty {
                emptyView
            } else {
                orderList
            }
        }
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.large)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No orders yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var orderList: some View {
        List(cart.orders) { order in
            NavigationLink(value: order) {
                orderRow(order)
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Order.self) { order in
            OrderConfirmationView(order: order)
        }
    }

    private func orderRow(_ order: Order) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(statusColor(order.status).opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: order.status.iconName)
                    .font(.title3)
                    .foregroundStyle(statusColor(order.status))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(order.orderNumber)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    Text(order.status.title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(statusColor(order.status))
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text("\(order.itemCount) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(order.createdDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(order.formattedTotal)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }

    private func statusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipping: return .purple
        case .delivered: return .green
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        OrderHistoryView()
    }
}
#endif
