//
//  StoreApp.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 16/4/25.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct StoreApp: App {

    private let persistenceController = PersistenceController.shared
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    init() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                DashboardView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                LoginView(viewModel: makeLoginViewModel())
            }
        }
    }

    private func makeLoginViewModel() -> LoginViewModel {
        let vm = LoginViewModel()
        vm.onLoginSuccess = { isLoggedIn = true }
        return vm
    }
}
