//
//  DevicePreviewView.swift
//  Store
//

import SwiftUI

struct DevicePreviewView: View {

    let deviceInfo: QRDeviceInfo
    let folders: [DeviceFolder]
    let repository: any DeviceRepository
    @Binding var navigationPath: NavigationPath

    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh
    @State private var selectedFolder: DeviceFolder?
    @State private var customName: String = ""
    @State private var isSaving = false
    @State private var animateCheckmark = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    deviceHero
                    deviceDetails
                    folderPicker
                    nameField
                }
                .padding(20)
                .padding(.bottom, 80)
            }
            .scrollBounceBehavior(.basedOnSize)

            confirmBar
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Add Device")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            customName = deviceInfo.name
        }
    }

    // MARK: - Hero

    private var deviceHero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: deviceInfo.deviceTypeIcon)
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 4) {
                Text(deviceInfo.name)
                    .font(.title2.weight(.bold))
                Text(deviceInfo.manufacturer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Connection badge
            HStack(spacing: 6) {
                Image(systemName: deviceInfo.parsedConnectionType.iconSystemName)
                    .font(.caption)
                Text(deviceInfo.parsedConnectionType.title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1), in: Capsule())
            .foregroundStyle(.blue)
        }
    }

    // MARK: - Details

    private var deviceDetails: some View {
        VStack(spacing: 0) {
            detailRow(icon: "qrcode", title: "Identifier", value: deviceInfo.identifier)
            Divider().padding(.leading, 48)
            detailRow(icon: "shippingbox", title: "Type", value: deviceInfo.deviceType.capitalized)
            Divider().padding(.leading, 48)
            detailRow(icon: "tag", title: "Model", value: deviceInfo.model)
            Divider().padding(.leading, 48)
            detailRow(icon: "memorychip", title: "Firmware", value: "v\(deviceInfo.firmwareVersion)")
            Divider().padding(.leading, 48)
            detailRow(icon: "calendar", title: "Published", value: deviceInfo.datePublish)
        }
        .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
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
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    // MARK: - Folder Picker

    private var folderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Language.Device.folderTitle)
                .font(.subheadline.weight(.semibold))

            if folders.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "folder")
                        .foregroundStyle(.secondary)
                    Text(Language.Device.folderNone)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            } else {
                FolderPickerField(folders: folders, selectedFolder: $selectedFolder)
            }
        }
    }

    // MARK: - Name

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Language.Device.nameTitle)
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 10) {
                Image(systemName: "pencil")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                TextField(Language.Device.namePlaceholder, text: $customName)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Confirm Bar

    private var confirmBar: some View {
        HStack(spacing: 12) {
            Button {
                navigationPath.removeLast()
            } label: {
                Text("Cancel")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }

            Button {
                addDevice()
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView().tint(.white)
                    }
                    Text("Add Device")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isSaving)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Save

    private func addDevice() {
        let name = customName.trimmingCharacters(in: .whitespaces)
        let finalName = name.isEmpty ? deviceInfo.name : name

        var device = deviceInfo.toConnectedDevice(folderID: selectedFolder?.id)
        device.deviceName = finalName

        isSaving = true
        Task {
            try? await repository.save(device)
            isSaving = false
            triggerHomeRefresh()

            // Navigate to success
            var newPath = NavigationPath()
            newPath.append(
                DeviceCreationResult(
                    deviceName: finalName,
                    connectionType: deviceInfo.parsedConnectionType
                )
            )
            navigationPath = newPath
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        DevicePreviewView(
            deviceInfo: .mock,
            folders: [],
            repository: CoreDataDeviceRepository(),
            navigationPath: $path
        )
    }
}
#endif
