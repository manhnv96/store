# Store iOS — Project Steering

File này cung cấp ngữ cảnh dự án cho Claude Code khi làm việc trong repository này.

## 1. Tổng quan dự án

- **Tên app:** Store
- **Lĩnh vực:** Smart Device Management + E-Commerce cho reef tank (bể cá san hô)
- **Mục đích:** Kết nối & quản lý thiết bị IoT (bơm liều, cảm biến nước, đèn LED) kèm cửa hàng bán sản phẩm reef tank
- **Ngôn ngữ chính của UI/Copy:** Tiếng Việt (base language trong `Localizable.xcstrings`)
- **Min iOS:** iOS 16+ (sử dụng `NavigationStack`, `@Observable`, `AppStorage`, ...)

## 2. Tech stack

- **UI:** SwiftUI thuần. Không dùng UIKit trừ khi bắt buộc (e.g. `LaunchScreen.storyboard`)
- **Concurrency:** **async/await + `Task`**. **Không dùng Combine cho code mới** — chỉ `APIService` hiện tại còn dùng `dataTaskPublisher`, các phần khác phải async/await
- **State:** `@Observable` (Swift Observation), `@State`, `@Binding`, `@AppStorage`, `@Environment`
- **Navigation:** `NavigationStack` + `NavigationPath`, destination-based `NavigationLink`
- **Persistence:** Core Data **programmatic model** (không có file `.xcdatamodeld`) — schema được build trong `PersistenceController`
- **Secure storage:** `KeychainManager` (lưu username/password đăng nhập)
- **Bluetooth:** CoreBluetooth qua `BluetoothManager` (`CBCentralManagerDelegate`)
- **Networking:** `APIService` + `SafeCodable` wrapper cho decoding an toàn
- **Localization:** `Localizable.xcstrings` + `Language.swift` (hand-written enum hierarchy như `Language.Home.*`, `Language.Shop.*`)
- **Assets:** SwiftGen sinh `Assets.swift` qua `swiftgen.yml`
- **Dependencies:** IQKeyboardManagerSwift, SwiftGen

## 3. Kiến trúc

**MVVM** với Observation framework:

- **View** (SwiftUI): chỉ render, không chứa business logic
- **ViewModel** (`@Observable @MainActor`): chứa state + actions, ví dụ `HomeViewModel`, `LoginViewModel`, `WaterDashboardViewModel`
- **Repository** (protocol + impl): `DeviceRepository` ↔ `CoreDataDeviceRepository`. View/ViewModel phụ thuộc protocol, không phụ thuộc Core Data trực tiếp
- **Service** (singleton hoặc DI): `BluetoothManager`, `CartManager`, `KeychainManager`, `APIService`
- **Model:** struct thuần trong `Storage/Models/` (`ConnectedDevice`, `DeviceFolder`, `ReefProduct`, `Order`, `WaterParameter`, ...)

## 4. Cấu trúc thư mục

```
Store/Store/
├── Application/         # StoreApp.swift (entry point)
├── Screens/             # Các màn hình UI + ViewModel đi kèm
│   ├── Common/          # View tái sử dụng (ComponentButton, SimpleTextField, ...)
│   ├── Dashboard/       # TabBar root (Home / Shop / Profile)
│   ├── Home/            # Home + Subviews + ViewModel
│   ├── Login/, Profile/, Connect/, Devices/, Folder/, Product/
│   ├── Shop/            # Shop, Cart, Checkout, Order flows
│   └── WaterDashboard/  # Theo dõi thông số nước
├── Services/            # BluetoothManager, CartManager, KeychainManager
├── Storage/
│   ├── CoreData/        # PersistenceController, *Entity, CoreData*Repository
│   ├── Models/          # Struct domain models
│   ├── Network/         # APIService + SafeCodable/
│   └── Repositories/    # Protocol abstractions
├── Generated/           # SwiftGen output (Assets.swift, Language.swift)
├── Resource/            # Lottie JSONs, fonts, ...
└── Assets.xcassets, Info.plist, Localizable.xcstrings
```

Tests: `StoreTests/` (Swift Testing framework), `StoreUITests/` (XCUIAutomation).

## 5. Các flow chính

1. **Login** → set `@AppStorage("isLoggedIn")` → `DashboardView`
2. **Dashboard** = TabBar 3 tab: Home, Shop/Cart, Profile
3. **Connect device:** `ConnectView` → QR scan (`QRScannerView` → `QRDeviceInfo`) → BLE discovery → WiFi config → tạo/chọn folder → `ConnectSuccessView`
4. **Home:** hiển thị folders + devices dạng grid; filter theo `parentFolderID`; mở `FolderDetailView` hoặc `DeviceDetailView`
5. **WaterDashboard:** 5 thông số (temperature, pH, KH, Ca, ORP), paging logs
6. **Shop:** 6 category → `ReefProductDetailView` → add cart → `CheckoutView` → `OrderConfirmationView` → `OrderHistoryView`
7. **CartManager:** singleton `@Observable`, shipping = $9.99 hoặc free nếu total ≥ $100

## 6. Conventions code

- **Naming:** PascalCase cho type, camelCase cho property/method
- **Indent:** 4 spaces
- **Property:** `@State private var` cho state cục bộ, `let` cho hằng
- **Tổ chức file:** mỗi View ở 1 file, ViewModel cùng tên kèm hậu tố `ViewModel`
- **Reusable components:** đặt trong `Screens/Common/`; component button tuân theo pattern `ComponentButton` với states `.normal/.disabled/.performing`
- **Builder pattern:** `Buildable` protocol cho fluent customization view
- **Debug:** dùng hàm `debug()` conditional `#if DEBUG`, mock data đặt trong extension `#if DEBUG`
- **Comments:** chỉ viết khi WHY không hiển nhiên. KHÔNG viết comment mô tả WHAT
- **MARK:** dùng `// MARK: -` để tổ chức section trong file dài

## 7. Quy tắc bắt buộc khi viết code mới

- ✅ Dùng `async/await`, **KHÔNG** thêm Combine mới (kể cả khi sửa code cũ có Combine, ưu tiên migrate sang async nếu trong scope)
- ✅ Localization: mọi string hiển thị user phải đi qua `Language.*` enum + `Localizable.xcstrings`, không hardcode
- ✅ Asset: dùng `Asset.*` sinh từ SwiftGen, không gọi `Image("name")` bằng string literal
- ✅ Repository: view/viewmodel phụ thuộc protocol (`DeviceRepository`), không gọi `NSManagedObjectContext` trực tiếp
- ✅ Force unwrap (`!`) bị cấm — dùng `guard let` / `if let` / nil-coalescing
- ✅ Không tự sinh URL/endpoint — phải đi qua `APIService`
- ✅ Tuân thủ scope: chỉ sửa đúng phần được yêu cầu, không refactor ngoài lề

## 8. Localization

- File nguồn: `Store/Store/Localizable.xcstrings` (base = Vietnamese)
- Truy cập qua enum `Language` (hierarchy: `Language.Home.title`, `Language.Shop.checkout`, ...)
- Khi thêm string mới: thêm key vào `Localizable.xcstrings` rồi cập nhật enum tương ứng trong `Language.swift`

## 9. Build & validate

- **Build:** dùng MCP `BuildProject` (Xcode build system)
- **Quick check:** `XcodeRefreshCodeIssuesInFile` cho diagnostic nhanh trên 1 file
- **Tests:** Swift Testing framework cho unit, XCUITest cho UI
- Khi xong task UI: build + chạy preview / simulator để xác nhận, không chỉ dựa vào compile success

## 10. Branching & commits

- Branch hiện tại: `feature/product_detail`
- Main branch: `main`
- Commit style (theo `git log`): câu ngắn dạng `"Add ..."`, `"Update ..."`, `"Fix ..."` — không có prefix conventional commit

## 11. Lưu ý đặc biệt

- Core Data là **programmatic** — khi thêm entity/attribute mới phải sửa `PersistenceController` chứ không phải GUI `.xcdatamodeld`
- `BluetoothManager` cần Info.plist permission đã có sẵn
- App có 2 thư mục `Generated/` (tại `Store/Generated/` và `Store/Store/Generated/`) — file thực dùng là `Store/Store/Generated/`; nếu thấy duplicate, đừng tự xóa, hỏi user trước
- File `UserInterfaceState.xcuserstate` thường xuyên dirty trong git status — bỏ qua, không commit
