//
//  LoginView.swift
//  Store
//

import SwiftUI

struct LoginView: View {

    @State var viewModel = LoginViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                formView
                    .padding(.horizontal, 24)

                loginButton
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    // MARK: - Sub-views

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Store")
                .font(.system(size: 36, weight: .bold, design: .default))

            Text("Đăng nhập để tiếp tục")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var formView: some View {
        VStack(alignment: .leading, spacing: 20) {
            fieldView(title: "Tên đăng nhập") {
                TextField("Nhập tên đăng nhập", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .fieldStyle()
            }

            fieldView(title: "Mật khẩu") {
                SecureField("Nhập mật khẩu", text: $viewModel.password)
                    .fieldStyle()
            }

            Text(viewModel.errorMessage ?? " ")
                .font(.caption)
                .foregroundStyle(.red)
                .opacity(viewModel.errorMessage != nil ? 1 : 0)
        }
    }

    private func fieldView(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private var loginButton: some View {
        let vm = viewModel
        return ComponentButton(title: "Đăng nhập") {
            Task { await vm.login() }
        }
        .state($viewModel.buttonState)
        .fillWidth()
    }
}

// MARK: - TextField style helper
private extension View {
    func fieldStyle() -> some View {
        self
            .font(.body).fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    LoginView()
}
