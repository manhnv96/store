//
//  CheckoutView.swift
//  Store
//

import SwiftUI

struct CheckoutView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.onOrderPlaced) private var onOrderPlaced
    @State private var cart = CartManager.shared

    @State private var address = ShippingAddress()
    @State private var selectedPayment: PaymentMethod = .cod
    @State private var currentStep: CheckoutStep = .address
    @State private var isPlacing = false

    // Credit card fields
    @State private var cardNumber = ""
    @State private var cardExpiry = ""
    @State private var cardCVV = ""
    @State private var cardHolder = ""

    // Bank transfer confirmation
    @State private var bankTransferConfirmed = false

    enum CheckoutStep: Int, CaseIterable {
        case address, payment, review
        var title: String {
            switch self {
            case .address: return "Address"
            case .payment: return "Payment"
            case .review: return "Review"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            stepIndicator

            TabView(selection: $currentStep) {
                addressStep.tag(CheckoutStep.address)
                paymentStep.tag(CheckoutStep.payment)
                reviewStep.tag(CheckoutStep.review)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth(duration: 0.3), value: currentStep)

            bottomBar
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CheckoutStep.allCases, id: \.self) { step in
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.2))
                            .frame(width: 28, height: 28)
                        Text("\(step.rawValue + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(step.rawValue <= currentStep.rawValue ? .white : .secondary)
                    }
                    Text(step.title)
                        .font(.caption2)
                        .foregroundStyle(step == currentStep ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)

                if step != CheckoutStep.allCases.last {
                    Rectangle()
                        .fill(step.rawValue < currentStep.rawValue ? Color.blue : Color.gray.opacity(0.2))
                        .frame(height: 2)
                        .padding(.bottom, 18)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    // MARK: - Address Step

    private var addressStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Shipping Address")
                    .font(.title2.weight(.bold))

                VStack(spacing: 14) {
                    formField("Full Name", text: $address.fullName, icon: "person")
                    formField("Phone Number", text: $address.phone, icon: "phone", keyboard: .phonePad)
                    formField("Street Address", text: $address.street, icon: "mappin")
                    HStack(spacing: 12) {
                        formField("City", text: $address.city, icon: "building.2")
                        formField("State", text: $address.state, icon: "map")
                    }
                    HStack(spacing: 12) {
                        formField("Zip Code", text: $address.zipCode, icon: "number", keyboard: .numberPad)
                        formField("Country", text: $address.country, icon: "globe")
                    }
                }
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func formField(
        _ placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.subheadline)
                .keyboardType(keyboard)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Payment Step

    private var paymentStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Payment Method")
                    .font(.title2.weight(.bold))

                VStack(spacing: 10) {
                    ForEach(PaymentMethod.allCases) { method in
                        paymentOption(method)
                    }
                }

                // Method-specific details
                switch selectedPayment {
                case .cod:
                    codInfoView
                case .bankTransfer:
                    bankTransferView
                case .creditCard:
                    creditCardForm
                }
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func paymentOption(_ method: PaymentMethod) -> some View {
        let isSelected = selectedPayment == method
        return Button {
            withAnimation(.smooth(duration: 0.25)) {
                selectedPayment = method
                bankTransferConfirmed = false
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: method.iconName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : .blue)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(method.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : .primary)
                    Text(paymentDescription(method))
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .padding(14)
            .background(
                isSelected ? AnyShapeStyle(Color.blue.gradient) : AnyShapeStyle(Color.gray.opacity(0.08)),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
    }

    private func paymentDescription(_ method: PaymentMethod) -> String {
        switch method {
        case .cod: return "Pay when you receive"
        case .bankTransfer: return "Transfer to our bank account"
        case .creditCard: return "Visa, Mastercard, JCB"
        }
    }

    // MARK: - COD Info

    private var codInfoView: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Pay on Delivery")
                    .font(.subheadline.weight(.semibold))
                Text("Payment will be collected when your order arrives. Please prepare the exact amount.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Bank Transfer

    private var bankTransferView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bank Account Details")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 0) {
                bankInfoRow("Bank", value: "Vietcombank")
                Divider().padding(.leading, 14)
                bankInfoRow("Account", value: "1234 5678 9012")
                Divider().padding(.leading, 14)
                bankInfoRow("Name", value: "REEF STORE CO., LTD")
                Divider().padding(.leading, 14)
                bankInfoRow("Amount", value: cart.formattedTotal)
                Divider().padding(.leading, 14)
                bankInfoRow("Content", value: "ORDER \(address.phone.suffix(4))")
            }
            .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))

            Button {
                bankTransferConfirmed.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: bankTransferConfirmed ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(bankTransferConfirmed ? .blue : .secondary)
                    Text("I have completed the bank transfer")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    private func bankInfoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(.subheadline.weight(.medium))
                .textSelection(.enabled)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Credit Card Form

    private var creditCardForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Card Details")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 12) {
                formField("Cardholder Name", text: $cardHolder, icon: "person")
                formField("Card Number", text: $cardNumber, icon: "creditcard", keyboard: .numberPad)
                HStack(spacing: 12) {
                    formField("MM/YY", text: $cardExpiry, icon: "calendar", keyboard: .numberPad)
                    formField("CVV", text: $cardCVV, icon: "lock", keyboard: .numberPad)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("Your card info is encrypted and secure")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Review Step

    private var reviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Order Review")
                    .font(.title2.weight(.bold))

                // Items
                VStack(alignment: .leading, spacing: 8) {
                    let items = cart.selectedItems
                    Text("Items (\(items.reduce(0) { $0 + $1.quantity }))")
                        .font(.subheadline.weight(.semibold))
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            HStack {
                                Text("\(item.quantity)x")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28, alignment: .leading)
                                Text(item.product.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                Text(String(format: "$%.2f", item.product.price * Double(item.quantity)))
                                    .font(.subheadline.weight(.medium))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            if index < items.count - 1 {
                                Divider().padding(.leading, 42)
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                }

                // Shipping
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shipping To")
                        .font(.subheadline.weight(.semibold))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(address.fullName)
                            .font(.subheadline.weight(.medium))
                        Text(address.phone)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(address.formatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                }

                // Payment
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment")
                        .font(.subheadline.weight(.semibold))
                    HStack(spacing: 10) {
                        Image(systemName: selectedPayment.iconName)
                            .foregroundStyle(.blue)
                        Text(selectedPayment.title)
                            .font(.subheadline)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                }

                // Totals
                VStack(spacing: 8) {
                    totalRow("Subtotal", value: cart.formattedSubtotal)
                    totalRow("Shipping", value: cart.formattedShipping)
                    Divider()
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(cart.formattedTotal)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.blue)
                    }
                }
                .padding(14)
                .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func totalRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if currentStep != .address {
                Button {
                    withAnimation {
                        if let prev = CheckoutStep(rawValue: currentStep.rawValue - 1) {
                            currentStep = prev
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 48, height: 48)
                        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
            }

            Button {
                handleNext()
            } label: {
                HStack(spacing: 8) {
                    if isPlacing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(nextButtonTitle)
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    canProceed ? Color.blue : Color.gray,
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            .disabled(!canProceed || isPlacing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var nextButtonTitle: String {
        switch currentStep {
        case .address: return "Continue to Payment"
        case .payment: return "Review Order"
        case .review: return "Place Order — \(cart.formattedTotal)"
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case .address:
            return address.isValid
        case .payment:
            return isPaymentValid
        case .review:
            return true
        }
    }

    private var isPaymentValid: Bool {
        switch selectedPayment {
        case .cod:
            return true
        case .bankTransfer:
            return bankTransferConfirmed
        case .creditCard:
            return !cardHolder.isEmpty
                && cardNumber.count >= 13
                && cardExpiry.count >= 4
                && cardCVV.count >= 3
        }
    }

    private func handleNext() {
        switch currentStep {
        case .address:
            withAnimation { currentStep = .payment }
        case .payment:
            withAnimation { currentStep = .review }
        case .review:
            placeOrder()
        }
    }

    private func placeOrder() {
        isPlacing = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            let order = cart.placeOrder(address: address, payment: selectedPayment)
            isPlacing = false
            onOrderPlaced(order)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CheckoutView()
    }
}
#endif
