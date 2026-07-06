# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

File này cung cấp ngữ cảnh cho Claude Code khi làm việc trong repo này.

## 1. Tổng quan dự án

- **Tên app:** LazyReef (đã đổi tên từ `Store`; một số artifact / commit cũ vẫn còn tên `Store` — không sửa lung tung nếu không được yêu cầu)
- **Lĩnh vực:** Smart Device Management + E-Commerce cho reef tank (bể cá san hô)
- **Mục đích:** Kết nối / quản lý thiết bị IoT (dosing, cảm biến, đèn), theo dõi thông số nước (ghi log tay + giọng nói), kèm shop bán sản phẩm reef
- **Ngôn ngữ UI:** Tiếng Việt (base language trong `Localizable.xcstrings`)
- **Min iOS:** iOS 16+ (`NavigationStack`, `@Observable`, `AppStorage`, ...)

## 2. Tech stack

- **UI:** SwiftUI thuần. Không thêm UIKit trừ khi bắt buộc (`LaunchScreen.storyboard`)
- **Concurrency:** `async/await` + `Task`. **Không viết Combine mới** — chỉ `APIService` cũ còn `dataTaskPublisher`, migrate dần khi trong scope
- **State:** `@Observable`, `@State`, `@Binding`, `@AppStorage`, `@Environment`
- **Navigation:** `NavigationStack` + `NavigationPath`, destination-based `NavigationLink`
- **Persistence:** Core Data **programmatic model** (không có `.xcdatamodeld`) — schema build trong `PersistenceController`
- **Secure storage:** `KeychainManager`
- **Bluetooth:** CoreBluetooth qua `BluetoothManager`
- **Voice:** `SFSpeechRecognizer` + `AVAudioEngine` — `VoiceLogService` (one-shot ghi log), `WakeWordListener` (rảnh tay, phát hiện "ghi log" rồi parse), `VoiceLogParser` (pure, unit-testable)
- **Networking:** `APIService` + `SafeCodable` wrapper
- **Localization:** `Localizable.xcstrings` + `Language.swift` (enum hierarchy như `Language.Home.*`)
- **Assets/L10n codegen:** SwiftGen (`swiftgen.yml`)
- **Dependencies (SPM):** Firebase (đã link, **CHƯA** configure — không có `GoogleService-Info.plist` / gọi `FirebaseApp.configure()`), IQKeyboardManagerSwift, Lottie, SDWebImage, AlertToast, Alamofire

## 3. Kiến trúc

**MVVM** với Swift Observation:

- **View** (SwiftUI): chỉ render, không chứa business logic
- **ViewModel** (`@Observable @MainActor`): state + actions (`HomeViewModel`, `AquariumDetailViewModel`, `WaterDashboardViewModel`, ...)
- **Repository** (protocol + impl): view/VM phụ thuộc protocol, không đụng `NSManagedObjectContext` trực tiếp
  - `DeviceRepository` ← `CoreDataDeviceRepository` (devices, folders, aquariums)
  - `WaterReadingRepository` ← `CoreDataWaterReadingRepository` (water log entries)
- **Service:** singleton hoặc DI (`BluetoothManager`, `CartManager`, `KeychainManager`, `APIService`, `VoiceLogService`, `WakeWordListener`)
- **Model:** struct thuần trong `Storage/Models/`

## 4. Cấu trúc thư mục

Đường dẫn trên đĩa (không có prefix lặp):

```
LazyReef/                          # ← module chính, đường dẫn đĩa thực tế
├── Application/                   # LazyReefApp / StoreApp entry
├── Screens/
│   ├── Aquarium/                  # AquariumDetail{View,ViewModel}, AquariumSetupEditView
│   ├── Common/                    # ComponentButton, SimpleTextField, ChipRow, ...
│   ├── Connect/                   # ConnectView, QRScannerView, CreateAquariumView, ...
│   ├── Dashboard/                 # TabBar root
│   ├── Devices/, Folder/, Home/, Login/, Product/, Profile/
│   ├── Shop/                      # ShopView, CartView, CheckoutView, OrderHistory, ...
│   └── WaterDashboard/            # WaterDashboardView, LogEntryFormView, VoiceLogSheet, DosingSetup
├── Services/
│   ├── Bluetooth/                 # BluetoothManager
│   ├── Voice/                     # VoiceLogParser, VoiceLogService, WakeWordListener
│   └── CartManager, KeychainManager
├── Storage/
│   ├── CoreData/                  # PersistenceController + *Entity + CoreData*Repository
│   ├── Models/                    # Aquarium, ConnectedDevice, WaterParameter, ReefProduct, Order, ...
│   ├── Network/                   # APIService + SafeCodable/
│   └── Repositories/              # Protocol abstractions
├── Generated/                     # SwiftGen output (Assets.swift, Language.swift)
├── Resource/                      # Lottie JSONs
└── Assets.xcassets, Info.plist, Localizable.xcstrings, swiftgen.yml
```

**Xcode virtual path vs đĩa:** Trong project navigator Xcode, cùng file xuất hiện dưới `LazyReef/LazyReef/Screens/...` (thừa 1 tầng), còn trên đĩa chỉ là `LazyReef/Screens/...`. **Luôn dùng `XcodeUpdate` / `XcodeWrite` / `XcodeRead`** (từ MCP `xcode-tools`) — sẽ tự map đúng path. Dùng `Write` gốc có thể tạo file lệch tầng (`LazyReef/LazyReef/Screens/...` trên đĩa) — orphan file dù build vẫn xanh.

Tests:
- `LazyReefTest/` (thư mục **số ít**, đơn vị): `StoreTests.swift` — Swift Testing framework
- `LazyReefTests/` (số nhiều, UI): `StoreUITests.swift`, `StoreUITestsLaunchTests.swift` — XCUIAutomation
- Tên file test vẫn còn `Store...` do lịch sử rename — chỉ đổi khi task yêu cầu

## 5. Các flow chính

1. **Login** → set `@AppStorage("isLoggedIn")` → `DashboardView`
2. **Dashboard** = TabBar 3 tab: Home, Shop/Cart, Profile
3. **Connect device:** `ConnectView` → QR scan → BLE discovery → WiFi config → chọn folder/aquarium → `ConnectSuccessView`
4. **Home:** grid folders + devices; filter theo `parentFolderID`; navigate vào `FolderDetailView` / `DeviceDetailView` / `AquariumDetailView`
5. **AquariumDetail:** hiển thị water summary + devices trong bể + log gần nhất. Có 2 nút log (mic + plus) + toolbar `slider.horizontal.3` mở `AquariumSetupEditView` (sump / livestock). Wake listener auto-start khi vào view (nói "ghi log <param> <value>" → tự save)
6. **WaterDashboard:** 5 thông số chính với biểu đồ + paging log; hiển thị chip sump/livestock ở header
7. **Shop:** category filter + search (inline trong scroll, không dùng `.searchable` nữa) → `ReefProductDetailView` → add cart → `CheckoutView` → `OrderConfirmationView` → `OrderHistoryView`
8. **CartManager:** singleton `@Observable`, free ship ≥ $100

## 6. Voice logging (đặc thù)

- **`VoiceLogParser`** thuần function — dễ unit test. Hỗ trợ số ASCII, số Việt (`bốn năm không` → 450), số ghép (`một ngàn ba trăm` → 1300), decimal (`tám chấm hai` → 8.2). Chọn candidate trong `plausibleRange(for:)` để disambiguate.
- **`WakeWordListener`** giữ audio engine chạy nền, quét transcript tìm "ghi log" (kèm biến thể mis-transcription) → parse phần sau → callback `onReadingDetected`. Restart task khi partial isFinal để tránh transcript rác.
- **`VoiceLogService`** (one-shot) — dùng trong `VoiceLogSheet` khi user tap mic thủ công.
- `AquariumDetailView` auto-start `WakeWordListener` khi appear, pause khi sheet (voice/manual/setup) mở, resume khi đóng, tôn trọng flag `userDisabledWake` nếu user tắt tay bằng nút ear.
- Info.plist đã có `NSSpeechRecognitionUsageDescription` + `NSMicrophoneUsageDescription`.

## 7. Conventions

- **Naming:** PascalCase type, camelCase property/method
- **Indent:** 4 spaces
- **Reusable components:** `Screens/Common/`; button style qua `ComponentButton` với `.normal/.disabled/.performing`
- **Builder pattern:** `Buildable` protocol cho fluent view customization
- **Mock/debug:** wrap trong `#if DEBUG`, hàm `debug()` conditional
- **Comments:** chỉ viết WHY khi non-obvious. KHÔNG viết comment mô tả WHAT
- **MARK:** `// MARK: -` cho section trong file dài

## 8. Quy tắc bắt buộc khi viết code mới

- Dùng `async/await`, **không thêm Combine mới**
- Localization: đi qua `Language.*` enum + `Localizable.xcstrings`, **không hardcode string**
- Asset: dùng `Asset.*` sinh từ SwiftGen, không `Image("name")` string literal
- Repository: view/VM phụ thuộc protocol, không gọi Core Data trực tiếp
- **Cấm force unwrap** (`!`) — dùng `guard let` / `if let` / `??`
- **Core Data programmatic:** thêm entity/attribute mới → sửa `PersistenceController.makeModel()` (không có `.xcdatamodeld`); attribute mới nên optional để lightweight migration hoạt động
- Không tự sinh URL/endpoint — phải qua `APIService`
- Không refactor ngoài scope task

## 9. Build & validate

- **Build:** MCP `mcp__xcode-tools__BuildProject` (Xcode build system, không dùng `xcodebuild` CLI trừ khi cần)
- **Quick check:** `mcp__xcode-tools__XcodeRefreshCodeIssuesInFile` — diagnostic 1 file, chạy trong 1-2 giây
- **Đọc/sửa file:** `XcodeRead` / `XcodeUpdate` / `XcodeWrite` — dùng Xcode virtual path, tránh lệch tầng khi tạo file mới
- **Snippet thử nghiệm:** `mcp__xcode-tools__ExecuteSnippet`
- **Docs Apple mới:** `mcp__xcode-tools__DocumentationSearch` (Liquid Glass, FoundationModels, SwiftUI API mới cutoff sau training)
- **Tests:** Swift Testing (unit), XCUITest (UI). Chạy qua `RunAllTests` / `RunSomeTests` từ MCP xcode-tools
- **UI task:** build + verify trên simulator/preview, không chỉ dựa compile success

## 10. Branching & commits

- Branch hiện tại: `feature/product_detail`
- Main: `main`
- Commit style (theo `git log`): câu ngắn `"Add ..."`, `"Update ..."`, `"Fix ..."` — không dùng conventional commit prefix

## 11. Lưu ý đặc biệt

- **Firebase:** SDK đã link qua SPM nhưng chưa configure (`FirebaseApp.configure()` chưa gọi, không có `GoogleService-Info.plist`). Không giả định Firebase runtime — bất kỳ tính năng Firebase mới cần user thêm plist + gọi configure trước
- **`UserInterfaceState.xcuserstate`** thường dirty trong `git status` — bỏ qua, không commit
- **`.searchable`** trong SwiftUI hay gặp bug ẩn search bar sau navigation push/pop. `ShopView` đã bỏ `.searchable` chuyển sang custom search field inline trong scroll (scroll ẩn/hiện tự nhiên)
- **`.swipeActions`** chỉ hoạt động trong `List` — không dùng trong `VStack`/`LazyVStack` (SwiftUI im lặng bỏ qua). Dùng `.contextMenu` (long-press) hoặc chuyển sang `List` nếu cần
- **Language.swift** là SwiftGen output nhưng đang được sửa thủ công song song với `Localizable.xcstrings` — khi thêm string mới, cập nhật cả 2 (hoặc chạy lại SwiftGen)
