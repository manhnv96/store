//
//  ConnectViaWifiView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 26/3/26.
//

import SwiftUI

struct ConnectViaWifiView: View {

    @State private var deviceName: String = ""
    @State private var ipAddress: String = ""
    @State private var isSaving = false

    @FocusState private var focusedField: Field?

    var selectedAquariumID: UUID?
    var repository: any DeviceRepository
    @Binding var navigationPath: NavigationPath
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh

    private enum Field: Hashable {
        case ipAddress, deviceName
    }

    private var canConnect: Bool {
        !ipAddress.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SimpleTextField(
                        axis: .vertical,
                        title: Language.Wifi.ipAddressTitle,
                        placeholder: Language.Wifi.ipAddressPlaceholder,
                        value: $ipAddress
                    )
                    .focused($focusedField, equals: .ipAddress)
                    .keyboardType(.decimalPad)

                    SimpleTextField(
                        axis: .vertical,
                        title: Language.Device.nameTitle,
                        placeholder: Language.Device.namePlaceholder,
                        value: $deviceName
                    )
                    .focused($focusedField, equals: .deviceName)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { focusedField = nil }

            ComponentButton(title: Language.Action.connect) {
                saveDevice()
            }
            .fillWidth()
            .state(buttonState)
            .padding(.top, 12)
        }
    }

    // MARK: - Helpers

    private var savedDeviceName: String {
        deviceName.trimmingCharacters(in: .whitespaces).isEmpty
            ? ipAddress.trimmingCharacters(in: .whitespaces)
            : deviceName.trimmingCharacters(in: .whitespaces)
    }

    private var buttonState: Binding<ComponentButtonState> {
        Binding(
            get: {
                if isSaving { return .performing }
                return canConnect ? .normal : .disabled
            },
            set: { _ in }
        )
    }

    private func saveDevice() {
        guard canConnect else { return }
        let trimmedIP = ipAddress.trimmingCharacters(in: .whitespaces)
        let name = savedDeviceName

        let device = ConnectedDevice(
            id: UUID(),
            deviceName: name,
            inputName: trimmedIP,
            deviceDescription: "",
            category: DeviceKind.other.rawValue,
            connectionType: .wifi,
            connectedDate: .now,
            lastUpdate: .now,
            parentFolderID: nil,
            parentAquariumID: selectedAquariumID
        )

        isSaving = true
        Task {
            try? await repository.save(device)
            isSaving = false
            triggerHomeRefresh()
            var newPath = NavigationPath()
            newPath.append(DeviceCreationResult(deviceName: name, connectionType: .wifi))
            navigationPath = newPath
        }
    }
}

// MARK: - WiFi Success Configuration

struct WifiConnectSuccessConfiguration: ConnectSuccessConfiguration {
    let deviceName: String

    var title: String {
        "Kết nối thiết bị \"\(deviceName)\" thành công"
    }

    var description: String {
        "Giờ bạn hãy kiểm tra kết nối WiFi với thiết bị."
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        ConnectViaWifiView(repository: CoreDataDeviceRepository(), navigationPath: $path)
    }
}
