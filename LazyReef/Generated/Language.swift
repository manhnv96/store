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
    /// Bể cá
    internal static let typeAquarium = Language.tr("Localizable", "import.typeAquarium", fallback: "Bể cá")
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
  internal enum DeviceKind {
    /// Skimmer
    internal static let skimmer = Language.tr("Localizable", "deviceKind.skimmer", fallback: "Skimmer")
    /// Tạo sóng
    internal static let wavemaker = Language.tr("Localizable", "deviceKind.wavemaker", fallback: "Tạo sóng")
    /// Đèn
    internal static let light = Language.tr("Localizable", "deviceKind.light", fallback: "Đèn")
    /// Chiller
    internal static let chiller = Language.tr("Localizable", "deviceKind.chiller", fallback: "Chiller")
    /// Dosing
    internal static let dosing = Language.tr("Localizable", "deviceKind.dosing", fallback: "Dosing")
    /// Lọc cuộn
    internal static let rollerFilter = Language.tr("Localizable", "deviceKind.rollerFilter", fallback: "Lọc cuộn")
    /// Bơm
    internal static let pump = Language.tr("Localizable", "deviceKind.pump", fallback: "Bơm")
    /// Controller
    internal static let controller = Language.tr("Localizable", "deviceKind.controller", fallback: "Controller")
    /// Cảm biến
    internal static let sensor = Language.tr("Localizable", "deviceKind.sensor", fallback: "Cảm biến")
    /// Khác
    internal static let other = Language.tr("Localizable", "deviceKind.other", fallback: "Khác")
  }
  internal enum Aquarium {
    /// Bể cá
    internal static let title = Language.tr("Localizable", "aquarium.title", fallback: "Bể cá")
    /// Chưa có bể cá nào
    internal static let listEmpty = Language.tr("Localizable", "aquarium.listEmpty", fallback: "Chưa có bể cá nào")
    /// Thêm bể cá
    internal static let addAction = Language.tr("Localizable", "aquarium.addAction", fallback: "Thêm bể cá")
    /// Tạo bể cá
    internal static let createTitle = Language.tr("Localizable", "aquarium.createTitle", fallback: "Tạo bể cá")
    /// Tên bể cá
    internal static let nameTitle = Language.tr("Localizable", "aquarium.nameTitle", fallback: "Tên bể cá")
    /// Nhập tên bể cá
    internal static let namePlaceholder = Language.tr("Localizable", "aquarium.namePlaceholder", fallback: "Nhập tên bể cá")
    /// Biểu tượng
    internal static let iconTitle = Language.tr("Localizable", "aquarium.iconTitle", fallback: "Biểu tượng")
    /// Thư mục cha
    internal static let parentFolderTitle = Language.tr("Localizable", "aquarium.parentFolderTitle", fallback: "Thư mục cha")
    /// Tạo bể cá thành công
    internal static let createSuccess = Language.tr("Localizable", "aquarium.createSuccess", fallback: "Tạo bể cá thành công")
    /// Bể cá
    internal static let pickerTitle = Language.tr("Localizable", "aquarium.pickerTitle", fallback: "Bể cá")
    /// Không có
    internal static let pickerNone = Language.tr("Localizable", "aquarium.pickerNone", fallback: "Không có")
    /// Chưa có bể cá. Tạo mới ngay?
    internal static let pickerEmpty = Language.tr("Localizable", "aquarium.pickerEmpty", fallback: "Chưa có bể cá. Tạo mới ngay?")
    /// Tạo bể cá mới
    internal static let createNewShortcut = Language.tr("Localizable", "aquarium.createNewShortcut", fallback: "+ Tạo bể cá mới")
  }
  internal enum WaterParameter {
    /// Độ mặn
    internal static let salinity = Language.tr("Localizable", "waterParameter.salinity", fallback: "Độ mặn")
  }
  internal enum LogSource {
    /// Nhập tay
    internal static let manual = Language.tr("Localizable", "logSource.manual", fallback: "Nhập tay")
    /// Giọng nói
    internal static let voice = Language.tr("Localizable", "logSource.voice", fallback: "Giọng nói")
    /// Thiết bị
    internal static let device = Language.tr("Localizable", "logSource.device", fallback: "Thiết bị")
    /// Hệ thống
    internal static let server = Language.tr("Localizable", "logSource.server", fallback: "Hệ thống")
  }
  internal enum Log {
    /// Nhật ký
    internal static let title = Language.tr("Localizable", "log.title", fallback: "Nhật ký")
    /// Chưa có bản ghi nào
    internal static let empty = Language.tr("Localizable", "log.empty", fallback: "Chưa có bản ghi nào")
    /// Ghi log đầu tiên
    internal static let firstLogCta = Language.tr("Localizable", "log.firstLogCta", fallback: "Ghi log đầu tiên")
    /// Thêm bằng giọng nói
    internal static let addVoice = Language.tr("Localizable", "log.addVoice", fallback: "Thêm bằng giọng nói")
    /// Thêm thủ công
    internal static let addManual = Language.tr("Localizable", "log.addManual", fallback: "Thêm thủ công")
    /// Xoá
    internal static let delete = Language.tr("Localizable", "log.delete", fallback: "Xoá")
    /// Xoá bản ghi?
    internal static let deleteConfirmTitle = Language.tr("Localizable", "log.deleteConfirmTitle", fallback: "Xoá bản ghi?")
    /// Bản ghi sẽ bị xoá vĩnh viễn khỏi nhật ký.
    internal static let deleteConfirmMessage = Language.tr("Localizable", "log.deleteConfirmMessage", fallback: "Bản ghi sẽ bị xoá vĩnh viễn khỏi nhật ký.")
    /// Giá trị có vẻ bất thường
    internal static let plausibleWarning = Language.tr("Localizable", "log.plausibleWarning", fallback: "Giá trị có vẻ bất thường")
    /// Huỷ
    internal static let cancel = Language.tr("Localizable", "log.cancel", fallback: "Huỷ")
  }
  internal enum LogForm {
    /// Ghi nhật ký
    internal static let title = Language.tr("Localizable", "logForm.title", fallback: "Ghi nhật ký")
    /// Sửa bản ghi
    internal static let editTitle = Language.tr("Localizable", "logForm.editTitle", fallback: "Sửa bản ghi")
    /// Thông số
    internal static let parameter = Language.tr("Localizable", "logForm.parameter", fallback: "Thông số")
    /// Giá trị
    internal static let value = Language.tr("Localizable", "logForm.value", fallback: "Giá trị")
    /// Nhập giá trị đo
    internal static let valuePlaceholder = Language.tr("Localizable", "logForm.valuePlaceholder", fallback: "Nhập giá trị đo")
    /// Thời điểm đo
    internal static let timestamp = Language.tr("Localizable", "logForm.timestamp", fallback: "Thời điểm đo")
    /// Ghi chú
    internal static let note = Language.tr("Localizable", "logForm.note", fallback: "Ghi chú")
    /// Ghi chú thêm (tuỳ chọn)
    internal static let notePlaceholder = Language.tr("Localizable", "logForm.notePlaceholder", fallback: "Ghi chú thêm (tuỳ chọn)")
    /// Lưu
    internal static let save = Language.tr("Localizable", "logForm.save", fallback: "Lưu")
  }
  internal enum VoiceLog {
    /// Ghi log bằng giọng nói
    internal static let title = Language.tr("Localizable", "voiceLog.title", fallback: "Ghi log bằng giọng nói")
    /// Đang nghe... (tự dừng khi bạn ngừng nói)
    internal static let listening = Language.tr("Localizable", "voiceLog.listening", fallback: "Đang nghe... (tự dừng khi bạn ngừng nói)")
    /// Nhấn để bắt đầu nói
    internal static let tapToStart = Language.tr("Localizable", "voiceLog.tapToStart", fallback: "Nhấn để bắt đầu nói")
    /// Nói tiếp hoặc xem kết quả
    internal static let speakMore = Language.tr("Localizable", "voiceLog.speakMore", fallback: "Tiếp tục nói hoặc xem kết quả phía dưới")
    /// Dừng
    internal static let stop = Language.tr("Localizable", "voiceLog.stop", fallback: "Dừng")
    /// Kết quả nhận diện
    internal static let previewTitle = Language.tr("Localizable", "voiceLog.previewTitle", fallback: "Kết quả nhận diện")
    /// Lưu tất cả
    internal static let confirmAll = Language.tr("Localizable", "voiceLog.confirmAll", fallback: "Lưu tất cả")
    /// Ghi âm lại
    internal static let retry = Language.tr("Localizable", "voiceLog.retry", fallback: "Ghi âm lại")
    /// Không có quyền micro / nhận diện giọng nói
    internal static let permissionDenied = Language.tr("Localizable", "voiceLog.permissionDenied", fallback: "Không có quyền micro / nhận diện giọng nói")
    /// Vào Cài đặt → LazyReef để bật quyền micro và Speech Recognition
    internal static let permissionInstruction = Language.tr("Localizable", "voiceLog.permissionInstruction", fallback: "Vào Cài đặt → LazyReef để bật quyền micro và Speech Recognition")
    /// Không nhận diện được. Thử lại?
    internal static let noMatch = Language.tr("Localizable", "voiceLog.noMatch", fallback: "Không nhận diện được. Thử lại?")
    /// Ví dụ: "Magie 450", "pH 8.2", "Canxi 420"
    internal static let hint = Language.tr("Localizable", "voiceLog.hint", fallback: "Ví dụ: \"Magie 450\", \"pH 8.2\", \"Canxi 420\"")
  }
  internal enum WakeMode {
    /// Rảnh tay
    internal static let title = Language.tr("Localizable", "wakeMode.title", fallback: "Rảnh tay")
    /// Đang nghe "Ghi log"...
    internal static let listening = Language.tr("Localizable", "wakeMode.listening", fallback: "Đang nghe \"Ghi log\"...")
    /// Nói "Ghi log" rồi đọc thông số
    internal static let instruction = Language.tr("Localizable", "wakeMode.instruction", fallback: "Nói \"Ghi log\" rồi đọc thông số. Ví dụ: \"Ghi log Canxi 450\"")
    /// Tắt
    internal static let stop = Language.tr("Localizable", "wakeMode.stop", fallback: "Tắt")
    /// Bật rảnh tay
    internal static let start = Language.tr("Localizable", "wakeMode.start", fallback: "Bật rảnh tay")
    /// Đã lưu
    internal static let savedToast = Language.tr("Localizable", "wakeMode.savedToast", fallback: "Đã lưu")
    /// Hoàn tác
    internal static let undo = Language.tr("Localizable", "wakeMode.undo", fallback: "Hoàn tác")
    /// Không khả dụng — kiểm tra quyền micro / Speech
    internal static let unavailable = Language.tr("Localizable", "wakeMode.unavailable", fallback: "Không khả dụng — kiểm tra quyền micro / Speech")
  }
  internal enum AquariumDetail {
    /// Thông số nước
    internal static let waterSectionTitle = Language.tr("Localizable", "aquariumDetail.waterSectionTitle", fallback: "Thông số nước")
    /// Xem chi tiết
    internal static let seeDetail = Language.tr("Localizable", "aquariumDetail.seeDetail", fallback: "Xem chi tiết")
    /// Thiết bị
    internal static let devicesSection = Language.tr("Localizable", "aquariumDetail.devicesSection", fallback: "Thiết bị")
    /// Chưa có thiết bị trong bể
    internal static let devicesEmpty = Language.tr("Localizable", "aquariumDetail.devicesEmpty", fallback: "Chưa có thiết bị trong bể")
    /// Thêm thiết bị
    internal static let addDeviceAction = Language.tr("Localizable", "aquariumDetail.addDeviceAction", fallback: "Thêm thiết bị")
    /// Gỡ khỏi bể
    internal static let removeAction = Language.tr("Localizable", "aquariumDetail.removeAction", fallback: "Gỡ khỏi bể")
    /// Gỡ thiết bị?
    internal static let removeConfirmTitle = Language.tr("Localizable", "aquariumDetail.removeConfirmTitle", fallback: "Gỡ thiết bị?")
    /// Thiết bị sẽ bị gỡ khỏi bể nhưng vẫn còn trong danh sách thiết bị đã kết nối.
    internal static let removeConfirmMessage = Language.tr("Localizable", "aquariumDetail.removeConfirmMessage", fallback: "Thiết bị sẽ bị gỡ khỏi bể nhưng vẫn còn trong danh sách thiết bị đã kết nối.")
    /// Hoạt động gần nhất
    internal static let lastActivity = Language.tr("Localizable", "aquariumDetail.lastActivity", fallback: "Hoạt động gần nhất")
    /// Đang hoạt động
    internal static let statusOnline = Language.tr("Localizable", "aquariumDetail.statusOnline", fallback: "Đang hoạt động")
    /// Ngoại tuyến
    internal static let statusOffline = Language.tr("Localizable", "aquariumDetail.statusOffline", fallback: "Ngoại tuyến")
    /// Số thiết bị
    internal static let deviceCount = Language.tr("Localizable", "aquariumDetail.deviceCount", fallback: "Số thiết bị")
  }
  internal enum DeviceAction {
    /// Xoá thiết bị
    internal static let deleteAction = Language.tr("Localizable", "deviceAction.deleteAction", fallback: "Xoá thiết bị")
    /// Xoá thiết bị?
    internal static let deleteConfirmTitle = Language.tr("Localizable", "deviceAction.deleteConfirmTitle", fallback: "Xoá thiết bị?")
    /// Thiết bị sẽ bị ngắt kết nối và xoá vĩnh viễn khỏi danh sách thiết bị đã kết nối. Hành động này không thể hoàn tác.
    internal static let deleteConfirmMessage = Language.tr("Localizable", "deviceAction.deleteConfirmMessage", fallback: "Thiết bị sẽ bị ngắt kết nối và xoá vĩnh viễn khỏi danh sách thiết bị đã kết nối. Hành động này không thể hoàn tác.")
    /// Đang ngắt kết nối...
    internal static let disconnecting = Language.tr("Localizable", "deviceAction.disconnecting", fallback: "Đang ngắt kết nối...")
    /// Huỷ
    internal static let cancel = Language.tr("Localizable", "deviceAction.cancel", fallback: "Huỷ")
    /// Xoá
    internal static let confirmDelete = Language.tr("Localizable", "deviceAction.confirmDelete", fallback: "Xoá")
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
