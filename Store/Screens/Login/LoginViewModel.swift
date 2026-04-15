//
//  LoginViewModel.swift
//  Store
//

import SwiftUI

@MainActor
@Observable
final class LoginViewModel {

    private static let keychainUsernameKey = "store_last_username"
    private static let keychainPasswordKey = "store_last_password"

    // MARK: - State
    var username: String = "" { didSet { syncButtonState() } }
    var password: String = "" { didSet { syncButtonState() } }
    private(set) var errorMessage: String?
    var buttonState: ComponentButtonState = .disabled

    init() {
        if let savedUsername = KeychainManager.load(for: Self.keychainUsernameKey) {
            username = savedUsername
        }
        syncButtonState()
    }

    var isLoginEnabled: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    private func syncButtonState() {
        guard buttonState != .performing else { return }
        buttonState = isLoginEnabled ? .normal : .disabled
    }

    // MARK: - Callbacks
    var onLoginSuccess: (() -> Void)?

    // MARK: - Intents
    func login() async {
        guard isLoginEnabled else { return }
        buttonState = .performing
        defer { syncButtonState() }

        // Simulate network delay — replace with real API call
        try? await Task.sleep(for: .seconds(1))

        if username == "admin" && password == "admin" {
            KeychainManager.save(username, for: Self.keychainUsernameKey)
            KeychainManager.save(password, for: Self.keychainPasswordKey)
            onLoginSuccess?()
        } else {
            buttonState = .normal
            errorMessage = "Tên đăng nhập hoặc mật khẩu không đúng"
        }
    }
}
