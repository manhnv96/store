// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// !! Do not edit manually – run `swiftgen run` to regenerate !!

import Foundation

// MARK: - L10n

internal enum L10n {

    // MARK: Action
    internal enum Action {
        /// Vietnamese: "Kết nối"
        internal static var connect: String { L10n.tr("action.connect", fallback: "Kết nối") }
    }

    // MARK: BleConnected
    internal enum BleConnected {
        /// Vietnamese: "Ngắt kết nối"
        internal static var actionDisconnect: String { L10n.tr("bleConnected.actionDisconnect", fallback: "Ngắt kết nối") }
        /// Vietnamese: "Thiết bị không tên"
        internal static var deviceUnnamed: String { L10n.tr("bleConnected.deviceUnnamed", fallback: "Thiết bị không tên") }
        /// Vietnamese: "Hãy kết nối một thiết bị BLE trước"
        internal static var emptyDescription: String { L10n.tr("bleConnected.emptyDescription", fallback: "Hãy kết nối một thiết bị BLE trước") }
        /// Vietnamese: "Chưa có thiết bị nào"
        internal static var emptyTitle: String { L10n.tr("bleConnected.emptyTitle", fallback: "Chưa có thiết bị nào") }
        /// Vietnamese: "Thiết bị đã kết nối"
        internal static var headerTitle: String { L10n.tr("bleConnected.headerTitle", fallback: "Thiết bị đã kết nối") }
        /// Vietnamese: "Đã kết nối"
        internal static var statusConnected: String { L10n.tr("bleConnected.statusConnected", fallback: "Đã kết nối") }
    }

    // MARK: Bluetooth
    internal enum Bluetooth {
        /// Vietnamese: "Kiểm tra Bluetooth"
        internal static var checking: String { L10n.tr("bluetooth.checking", fallback: "Kiểm tra Bluetooth") }
        /// Vietnamese: "Chọn thiết bị"
        internal static var selectDevice: String { L10n.tr("bluetooth.selectDevice", fallback: "Chọn thiết bị") }
        /// Vietnamese: "Hãy bật Bluetooth để bắt đầu"
        internal static var turnOnPrompt: String { L10n.tr("bluetooth.turnOnPrompt", fallback: "Hãy bật Bluetooth để bắt đầu") }
        /// Vietnamese: "Hãy kiểm tra lại cài đặt bluetooth của bạn và thử lại"
        internal static var unavailableDescription: String { L10n.tr("bluetooth.unavailableDescription", fallback: "Hãy kiểm tra lại cài đặt bluetooth của bạn và thử lại") }
        /// Vietnamese: "Chưa bật Bluetooth"
        internal static var unavailableTitle: String { L10n.tr("bluetooth.unavailableTitle", fallback: "Chưa bật Bluetooth") }
    }

    // MARK: ConnectionType
    internal enum ConnectionType {
        /// Vietnamese: "Bluetooth"
        internal static var bluetooth: String { L10n.tr("connectionType.bluetooth", fallback: "Bluetooth") }
        /// Vietnamese: "Wifi"
        internal static var wifi: String { L10n.tr("connectionType.wifi", fallback: "Wifi") }
    }

    // MARK: Device
    internal enum Device {
        /// Vietnamese: "Nhập tên gợi nhớ"
        internal static var namePlaceholder: String { L10n.tr("device.namePlaceholder", fallback: "Nhập tên gợi nhớ") }
        /// Vietnamese: "Tên thiết bị"
        internal static var nameTitle: String { L10n.tr("device.nameTitle", fallback: "Tên thiết bị") }
    }

    // MARK: Import
    internal enum Import {
        /// Vietnamese: "Kết nối qua"
        internal static var connectionLabel: String { L10n.tr("import.connectionLabel", fallback: "Kết nối qua") }
        /// Vietnamese: "Tạo mới!"
        internal static var title: String { L10n.tr("import.title", fallback: "Tạo mới!") }
        /// Vietnamese: "Thiết bị"
        internal static var typeEquipment: String { L10n.tr("import.typeEquipment", fallback: "Thiết bị") }
        /// Vietnamese: "Thư mục"
        internal static var typeFolder: String { L10n.tr("import.typeFolder", fallback: "Thư mục") }
    }

    // MARK: Tabbar
    internal enum Tabbar {
        /// Vietnamese: "Giỏ hàng"
        internal static var cart: String { L10n.tr("tabbar.cart", fallback: "Giỏ hàng") }
        /// Vietnamese: "Trang chủ"
        internal static var home: String { L10n.tr("tabbar.home", fallback: "Trang chủ") }
        /// Vietnamese: "Cá nhân"
        internal static var user: String { L10n.tr("tabbar.user", fallback: "Cá nhân") }
    }
}

// MARK: - Implementation

extension L10n {
    /// Looks up `key` in Localizable.xcstrings (or Localizable.strings).
    /// Falls back to `fallback` when no translation is found.
    private static func tr(_ key: String, _ args: CVarArg..., fallback value: String) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: "Localizable")
        return args.isEmpty ? format : String(format: format, locale: Locale.current, arguments: args)
    }
}

// MARK: - BundleToken

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable all
