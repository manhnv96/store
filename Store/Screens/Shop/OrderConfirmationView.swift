//
//  OrderConfirmationView.swift
//  Store
//

import SwiftUI

struct OrderConfirmationView: View {

    let order: Order
    @Environment(\.popToCart) private var popToCart

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                successHeader
                orderInfoCard
                trackingTimeline
                itemsList
                shippingCard
            }
            .padding(16)
            .padding(.bottom, 80)
        }
        .scrollBounceBehavior(.basedOnSize)
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Order \(order.orderNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    popToCart()
                }
                .font(.subheadline.weight(.semibold))
            }
        }
    }

    // MARK: - Success Header

    private var successHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            Text("Order Placed!")
                .font(.title2.weight(.bold))

            Text("Thank you for your purchase. Your order is being processed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Order Info

    private var orderInfoCard: some View {
        VStack(spacing: 10) {
            infoRow("Order Number", value: order.orderNumber)
            Divider()
            infoRow("Date", value: order.createdDate.formatted(date: .abbreviated, time: .shortened))
            Divider()
            infoRow("Payment", value: order.paymentMethod.title)
            Divider()
            infoRow("Items", value: "\(order.itemCount) items")
            Divider()
            HStack {
                Text("Total")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(order.formattedTotal)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.blue)
            }
        }
        .padding(14)
        .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }

    // MARK: - Tracking Timeline

    private var trackingTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tracking")
                .font(.title3.weight(.semibold))

            VStack(alignment: .leading, spacing: 0) {
                ForEach(OrderStatus.allCases, id: \.self) { status in
                    let isCompleted = status.stepIndex <= order.status.stepIndex
                    let isCurrent = status == order.status
                    let event = order.trackingEvents.first { $0.status == status }

                    HStack(alignment: .top, spacing: 14) {
                        // Timeline dot + line
                        VStack(spacing: 0) {
                            Circle()
                                .fill(isCompleted ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .overlay {
                                    if isCurrent {
                                        Circle()
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                                            .frame(width: 20, height: 20)
                                    }
                                }

                            if status != OrderStatus.allCases.last {
                                Rectangle()
                                    .fill(isCompleted && status.stepIndex < order.status.stepIndex ? Color.blue : Color.gray.opacity(0.2))
                                    .frame(width: 2, height: 40)
                            }
                        }
                        .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(status.title)
                                .font(.subheadline.weight(isCurrent ? .bold : .medium))
                                .foregroundStyle(isCompleted ? .primary : .secondary)

                            if let event {
                                Text(event.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.top, -2)
                    }
                }
            }
            .padding(14)
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Items

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Items")
                .font(.title3.weight(.semibold))

            VStack(spacing: 0) {
                ForEach(Array(order.items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: item.product.imageName)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            Text("Qty: \(item.quantity)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "$%.2f", item.product.price * Double(item.quantity)))
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    if index < order.items.count - 1 {
                        Divider().padding(.leading, 66)
                    }
                }
            }
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Shipping

    private var shippingCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shipping Address")
                .font(.title3.weight(.semibold))

            VStack(alignment: .leading, spacing: 4) {
                Text(order.shippingAddress.fullName)
                    .font(.subheadline.weight(.medium))
                Text(order.shippingAddress.phone)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(order.shippingAddress.formatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
