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
  internal enum Home {
    /// Thiết bị gần đây
    internal static let recentDevices = Language.tr("Localizable", "home.recentDevices", fallback: "Thiết bị gần đây")
    /// Thiết bị khác
    internal static let otherDevices = Language.tr("Localizable", "home.otherDevices", fallback: "Thiết bị khác")
    /// Thư mục trống
    internal static let emptyFolderTitle = Language.tr("Localizable", "home.emptyFolderTitle", fallback: "Thư mục trống")
    /// Thêm thiết bị vào thư mục này
    internal static let emptyFolderAction = Language.tr("Localizable", "home.emptyFolderAction", fallback: "Thêm thiết bị")
    /// Chưa có thiết bị nào
    internal static let emptyTitle = Language.tr("Localizable", "home.emptyTitle", fallback: "Chưa có thiết bị nào")
    /// Bắt đầu bằng cách kết nối thiết bị hoặc tạo thư mục
    internal static let emptyDescription = Language.tr("Localizable", "home.emptyDescription", fallback: "Bắt đầu bằng cách kết nối thiết bị hoặc tạo thư mục")
    /// Bắt đầu
    internal static let getStarted = Language.tr("Localizable", "home.getStarted", fallback: "Bắt đầu")
    /// Kết nối thiết bị BLE
    internal static let connectBle = Language.tr("Localizable", "home.connectBle", fallback: "Kết nối thiết bị BLE")
    /// Kết nối thiết bị WiFi
    internal static let connectWifi = Language.tr("Localizable", "home.connectWifi", fallback: "Kết nối thiết bị WiFi")
    /// Tạo thư mục
    internal static let createFolder = Language.tr("Localizable", "home.createFolder", fallback: "Tạo thư mục")
  }
  internal enum FolderDetail {
    /// Thông tin
    internal static let infoTitle = Language.tr("Localizable", "folderDetail.infoTitle", fallback: "Thông tin")
    /// Tên
    internal static let nameLabel = Language.tr("Localizable", "folderDetail.nameLabel", fallback: "Tên")
    /// Biểu tượng
    internal static let iconLabel = Language.tr("Localizable", "folderDetail.iconLabel", fallback: "Biểu tượng")
    /// Thư mục cha
    internal static let parentLabel = Language.tr("Localizable", "folderDetail.parentLabel", fallback: "Thư mục cha")
    /// Ngày tạo
    internal static let createdDateLabel = Language.tr("Localizable", "folderDetail.createdDateLabel", fallback: "Ngày tạo")
    /// Thư mục con
    internal static let subFoldersTitle = Language.tr("Localizable", "folderDetail.subFoldersTitle", fallback: "Thư mục con")
    /// thư mục con
    internal static let subFolderCount = Language.tr("Localizable", "folderDetail.subFolderCount", fallback: "thư mục con")
    /// Thiết bị
    internal static let devicesTitle = Language.tr("Localizable", "folderDetail.devicesTitle", fallback: "Thiết bị")
    /// Chưa có thiết bị nào trong thư mục
    internal static let devicesEmpty = Language.tr("Localizable", "folderDetail.devicesEmpty", fallback: "Chưa có thiết bị nào trong thư mục")
    /// Tạo thư mục thành công
    internal static let createSuccess = Language.tr("Localizable", "folderDetail.createSuccess", fallback: "Tạo thư mục thành công")
  }
  internal enum CreateFolder {
    /// Thư mục cha
    internal static let parentFolderTitle = Language.tr("Localizable", "createFolder.parentFolderTitle", fallback: "Thư mục cha")
    /// Không có
    internal static let parentFolderNone = Language.tr("Localizable", "createFolder.parentFolderNone", fallback: "Không có")
    /// Không có thư mục
    internal static let parentFolderEmpty = Language.tr("Localizable", "createFolder.parentFolderEmpty", fallback: "Không có thư mục")
    /// Tên thư mục
    internal static let nameTitle = Language.tr("Localizable", "createFolder.nameTitle", fallback: "Tên thư mục")
    /// Nhập tên thư mục
    internal static let namePlaceholder = Language.tr("Localizable", "createFolder.namePlaceholder", fallback: "Nhập tên thư mục")
    /// Biểu tượng
    internal static let iconTitle = Language.tr("Localizable", "createFolder.iconTitle", fallback: "Biểu tượng")
    /// Tạo thư mục
    internal static let createAction = Language.tr("Localizable", "createFolder.createAction", fallback: "Tạo thư mục")
  }
  internal enum DeviceDetail {
    /// Thông tin thiết bị
    internal static let infoTitle = Language.tr("Localizable", "deviceDetail.infoTitle", fallback: "Thông tin thiết bị")
    /// Tên thiết bị
    internal static let nameLabel = Language.tr("Localizable", "deviceDetail.nameLabel", fallback: "Tên thiết bị")
    /// Tên kết nối
    internal static let inputNameLabel = Language.tr("Localizable", "deviceDetail.inputNameLabel", fallback: "Tên kết nối")
    /// Mô tả
    internal static let descriptionLabel = Language.tr("Localizable", "deviceDetail.descriptionLabel", fallback: "Mô tả")
    /// Danh mục
    internal static let categoryLabel = Language.tr("Localizable", "deviceDetail.categoryLabel", fallback: "Danh mục")
    /// Thư mục
    internal static let folderLabel = Language.tr("Localizable", "deviceDetail.folderLabel", fallback: "Thư mục")
    /// Kết nối
    internal static let connectionTitle = Language.tr("Localizable", "deviceDetail.connectionTitle", fallback: "Kết nối")
    /// Loại kết nối
    internal static let connectionTypeLabel = Language.tr("Localizable", "deviceDetail.connectionTypeLabel", fallback: "Loại kết nối")
    /// Ngày kết nối
    internal static let connectedDateLabel = Language.tr("Localizable", "deviceDetail.connectedDateLabel", fallback: "Ngày kết nối")
    /// Cập nhật lần cuối
    internal static let lastUpdateLabel = Language.tr("Localizable", "deviceDetail.lastUpdateLabel", fallback: "Cập nhật lần cuối")
  }
  internal enum Device {
    /// Nhập tên gợi nhớ
    internal static let namePlaceholder = Language.tr("Localizable", "device.namePlaceholder", fallback: "Nhập tên gợi nhớ")
    /// Tên thiết bị
    internal static let nameTitle = Language.tr("Localizable", "device.nameTitle", fallback: "Tên thiết bị")
    /// Thư mục
    internal static let folderTitle = Language.tr("Localizable", "device.folderTitle", fallback: "Thư mục")
    /// Không có
    internal static let folderNone = Language.tr("Localizable", "device.folderNone", fallback: "Không có")
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
  internal enum Wifi {
    /// Địa chỉ IP
    internal static let ipAddressTitle = Language.tr("Localizable", "wifi.ipAddressTitle", fallback: "Địa chỉ IP")
    /// Nhập địa chỉ IP thiết bị (VD: 192.168.1.100)
    internal static let ipAddressPlaceholder = Language.tr("Localizable", "wifi.ipAddressPlaceholder", fallback: "Nhập địa chỉ IP thiết bị (VD: 192.168.1.100)")
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
