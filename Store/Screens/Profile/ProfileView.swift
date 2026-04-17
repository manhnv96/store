//
//  ProfileView.swift
//  Store
//

import SwiftUI

struct ProfileView: View {

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("profile_displayName") private var displayName = ""
    @AppStorage("profile_email") private var email = ""
    @AppStorage("profile_phone") private var phone = ""

    @State private var showingEditSheet = false
    @State private var showingLogoutAlert = false

    private var username: String {
        KeychainManager.load(for: "store_last_username") ?? "admin"
    }

    var body: some View {
        NavigationStack {
            List {
                headerSection
                personalInfoSection
                appSection
                dangerSection
            }
            .navigationTitle(Language.Tabbar.user)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditSheet) {
                EditProfileView(
                    displayName: displayName,
                    email: email,
                    phone: phone
                ) { name, mail, ph in
                    displayName = name
                    email = mail
                    phone = ph
                }
            }
            .alert("Đăng xuất", isPresented: $showingLogoutAlert) {
                Button("Huỷ", role: .cancel) {}
                Button("Đăng xuất", role: .destructive) { logout() }
            } message: {
                Text("Bạn có chắc chắn muốn đăng xuất?")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 64, height: 64)
                    Text(avatarInitials)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName.isEmpty ? username : displayName)
                        .font(.title3.weight(.semibold))
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var avatarInitials: String {
        let name = displayName.isEmpty ? username : displayName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    // MARK: - Personal Info

    private var personalInfoSection: some View {
        Section("Thông tin cá nhân") {
            infoRow(icon: "person.fill", title: "Tên hiển thị", value: displayName.isEmpty ? "Chưa cập nhật" : displayName)
            infoRow(icon: "envelope.fill", title: "Email", value: email.isEmpty ? "Chưa cập nhật" : email)
            infoRow(icon: "phone.fill", title: "Số điện thoại", value: phone.isEmpty ? "Chưa cập nhật" : phone)
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(value == "Chưa cập nhật" ? .tertiary : .primary)
        }
    }

    // MARK: - App

    private var appSection: some View {
        Section("Ứng dụng") {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                Text("Phiên bản")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Logout

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showingLogoutAlert = true
            } label: {
                HStack {
                    Spacer()
                    Label("Đăng xuất", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.body.weight(.medium))
                    Spacer()
                }
            }
        }
    }

    private func logout() {
        KeychainManager.delete(for: "store_last_password")
        isLoggedIn = false
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String
    @State private var email: String
    @State private var phone: String

    private let onSave: (String, String, String) -> Void

    init(displayName: String, email: String, phone: String, onSave: @escaping (String, String, String) -> Void) {
        _displayName = State(initialValue: displayName)
        _email = State(initialValue: email)
        _phone = State(initialValue: phone)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tên hiển thị") {
                    TextField("Nhập tên hiển thị", text: $displayName)
                }
                Section("Email") {
                    TextField("Nhập email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section("Số điện thoại") {
                    TextField("Nhập số điện thoại", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Chỉnh sửa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        onSave(displayName, email, phone)
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ProfileView()
}
#endif
