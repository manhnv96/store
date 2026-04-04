// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Language {
  internal enum Action {
    /// Kết nối
    internal static let connect = Language.tr("Localizable", "action.connect", fallback: "Kết nối")
  }
  internal enum BleConnected {
    /// Ngắt kết nối
    internal static let actionDisconnect = Language.tr("Localizable", "bleConnected.actionDisconnect", fallback: "Ngắt kết nối")
    /// Thiết bị không tên
    internal static let deviceUnnamed = Language.tr("Localizable", "bleConnected.deviceUnnamed", fallback: "Thiết bị không tên")
    /// Hãy kết nối một thiết bị BLE trước
    internal static let emptyDescription = Language.tr("Localizable", "bleConnected.emptyDescription", fallback: "Hãy kết nối một thiết bị BLE trước")
    /// Chưa có thiết bị nào
    internal static let emptyTitle = Language.tr("Localizable", "bleConnected.emptyTitle", fallback: "Chưa có thiết bị nào")
    /// Thiết bị đã kết nối
    internal static let headerTitle = Language.tr("Localizable", "bleConnected.headerTitle", fallback: "Thiết bị đã kết nối")
    /// Đã kết nối
    internal static let statusConnected = Language.tr("Localizable", "bleConnected.statusConnected", fallback: "Đã kết nối")
  }
  internal enum Bluetooth {
    /// Kiểm tra Bluetooth
    internal static let checking = Language.tr("Localizable", "bluetooth.checking", fallback: "Kiểm tra Bluetooth")
    /// Chọn thiết bị
    internal static let selectDevice = Language.tr("Localizable", "bluetooth.selectDevice", fallback: "Chọn thiết bị")
    /// Hãy bật Bluetooth để bắt đầu
    internal static let turnOnPrompt = Language.tr("Localizable", "bluetooth.turnOnPrompt", fallback: "Hãy bật Bluetooth để bắt đầu")
    /// Hãy kiểm tra lại cài đặt bluetooth của bạn và thử lại
    internal static let unavailableDescription = Language.tr("Localizable", "bluetooth.unavailableDescription", fallback: "Hãy kiểm tra lại cài đặt bluetooth của bạn và thử lại")
    /// Chưa bật Bluetooth
    internal static let unavailableTitle = Language.tr("Localizable", "bluetooth.unavailableTitle", fallback: "Chưa bật Bluetooth")
  }
  internal enum ConnectionType {
    /// Bluetooth
    internal static let bluetooth = Language.tr("Localizable", "connectionType.bluetooth", fallback: "Bluetooth")
    /// Wifi
    internal static let wifi = Language.tr("Localizable", "connectionType.wifi", fallback: "Wifi")
  }
  internal enum Device {
    /// Nhập tên gợi nhớ
    internal static let namePlaceholder = Language.tr("Localizable", "device.namePlaceholder", fallback: "Nhập tên gợi nhớ")
    /// Tên thiết bị
    internal static let nameTitle = Language.tr("Localizable", "device.nameTitle", fallback: "Tên thiết bị")
  }
  internal enum Import {
    /// Kết nối qua
    internal static let connectionLabel = Language.tr("Localizable", "import.connectionLabel", fallback: "Kết nối qua")
    /// Tạo mới!
    internal static let title = Language.tr("Localizable", "import.title", fallback: "Tạo mới!")
    /// Thiết bị
    internal static let typeEquipment = Language.tr("Localizable", "import.typeEquipment", fallback: "Thiết bị")
    /// Thư mục
    internal static let typeFolder = Language.tr("Localizable", "import.typeFolder", fallback: "Thư mục")
  }
  internal enum Tabbar {
    /// Giỏ hàng
    internal static let cart = Language.tr("Localizable", "tabbar.cart", fallback: "Giỏ hàng")
    /// Trang chủ
    internal static let home = Language.tr("Localizable", "tabbar.home", fallback: "Trang chủ")
    /// Cá nhân
    internal static let user = Language.tr("Localizable", "tabbar.user", fallback: "Cá nhân")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Language {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
