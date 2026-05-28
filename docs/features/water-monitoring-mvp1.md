# Feature Spec — Water Parameter Monitoring (MVP1)

> Trạng thái: **Draft v2** (cập nhật BE + multi-tank)
> Owner: ManhNV
> Module: `Store/Store/Screens/WaterDashboard/`
> Last updated: 2026-05-27

---

## 1. Mục tiêu (Goal)

Cho phép người chơi bể cá cảnh biển **ghi lại các thông số nước** (Mg, Ca, KH, NO3, PO4, pH, Temp...) một cách nhanh chóng bằng **giọng nói** hoặc **nhập tay**, lưu **offline-first** trên thiết bị, đồng bộ qua **Firebase**, hỗ trợ **nhiều bể** (multi-tank) và sẵn sàng mở rộng cho **IoT ingestion + analytics + notification** ở các phase sau.

**MVP1 trả lời câu hỏi:**
> "Làm sao để hobbyist log thông số mỗi ngày cho **một hoặc nhiều bể**, mà không cần mở app, gõ phím, hay phụ thuộc thiết bị đo tự động?"

---

## 2. Quyết định kiến trúc chốt

| # | Quyết định | Lý do |
|---|------------|-------|
| D-1 | **Backend = Firebase** (Firestore + Auth) cho MVP1 | Generous free tier, realtime listener, offline cache built-in, không cần code conflict resolution; chỉ migrate sang BE riêng khi cost vượt ngưỡng |
| D-2 | **Local DB = Firestore offline persistence + Core Data cho domain cũ** | Firestore tự cache offline trong SQLite, KHÔNG cần Core Data riêng cho water readings (xem §8 phân tích) |
| D-3 | **Multi-tank**: 1 user → N **Tank** → mỗi Tank → N **WaterReading**. Tank có thể gom vào **TankGroup** (reuse `DeviceFolder` đã có) | Người chơi serious thường có 2-3 bể (display + sump + frag); group giúp tổ chức |
| D-4 | **MVP1 không làm analytics / notification** nhưng schema phải hỗ trợ | Tránh phải migrate dữ liệu khi v2 launch |
| D-5 | Conflict policy: **last-write-wins theo `updatedAt` server timestamp** | Firestore native, đơn giản |

---

## 3. User stories

| # | As a... | I want to... | So that... |
|---|---------|--------------|------------|
| US-1 | reefer | nói "Magie 450" và app tự tạo log cho bể đang chọn | log nhanh khi tay đang ướt / đang test |
| US-2 | reefer | nhập tay thông số khi voice không nhận đúng | luôn có fallback chính xác |
| US-3 | reefer | sửa / xóa log đã ghi | sửa khi gõ nhầm / đọc test kit sai |
| US-4 | reefer | xem log offline kể cả khi mất mạng | log không phụ thuộc kết nối |
| US-5 | reefer | đồng bộ log lên cloud tự động | không mất dữ liệu khi đổi máy |
| US-6 | reefer multi-tank | quản lý log riêng cho từng bể | mỗi bể có ngưỡng / thông số khác nhau |
| US-7 | reefer multi-tank | gom các bể vào nhóm (Display / Frag / Quarantine) | dễ chuyển ngữ cảnh khi xem |
| US-8 | dev | dễ cắm nguồn log mới (IoT/server) | mở rộng v2 không phải refactor |
| US-9 | (v2 preview) reefer | nhận cảnh báo khi pH vượt range | xử lý sớm trước khi hại san hô |

---

## 4. Scope

### ✅ In-scope (MVP1)

- Ghi log thông số **bằng voice** (tiếng Việt + tiếng Anh)
- Ghi log **bằng tay**
- **Sửa / xóa** log
- **Multi-tank**: tạo / xóa / chọn bể, gán vào group
- **Offline-first** qua Firestore persistence
- **Sync 2 chiều** tự động qua Firestore listener
- **Firebase Auth** (anonymous trước, link account sau) — hoặc dùng tài khoản hiện tại nếu BE đã tích hợp
- Abstraction `WaterReadingSource` (manual/voice/device/server) — dù MVP1 chỉ implement manual + voice

### ❌ Out-of-scope (đẩy sang v2+)

| Item | Phase | Ghi chú |
|------|-------|---------|
| Push notification cảnh báo out-of-range | v2 | Cần Cloud Functions + FCM |
| Analytics dashboard (xu hướng, dự đoán) | v2 | Cần aggregate query |
| IoT ingestion realtime | v2 | Provider sẽ implement `WaterReadingSourceProvider` |
| Export CSV / chia sẻ | v2 | |
| Tự động gợi ý dosing theo trend | v3 | |
| Conflict resolution UI 3-way merge | v3 | MVP1 last-write-wins là đủ |
| Migrate sang BE riêng (Vapor/Node/Go) | khi Firebase cost > $X/tháng | Lý do quyết định ở §11 |

---

## 5. Voice logging — chi tiết

### 5.1 Cú pháp người dùng có thể nói

| Người nói | Parse ra |
|-----------|----------|
| "Magie 450" / "Mg 450" / "Magnesium 450" | `mg = 450` |
| "Mg một ngàn ba trăm" | `mg = 1300` |
| "pH tám chấm hai" / "pH 8.2" | `ph = 8.2` |
| "KH bảy chấm năm" | `kh = 7.5` |
| "Calcium 420" / "Canxi 420" / "Ca 420" | `ca = 420` |
| "Nitrate 5" / "Nitrat 5" / "NO3 5" | `no3 = 5` |
| "Phosphate 0.05" / "Photphat 0.05" / "PO4 0.05" | `po4 = 0.05` |
| "Nhiệt độ 25.5" / "Temperature 25.5" / "Temp 25.5" | `temperature = 25.5` |

**Quy tắc parser:**
1. Map keyword case-insensitive: `magie/mg/magnesium`, `canxi/calcium/ca`, ...
2. Sau keyword phải có **số** (hỗ trợ "chấm" = "."; số tiếng Việt qua bảng tra hoặc `NSNumberFormatter` locale `vi-VN`)
3. Validate **plausible range** trước save (ví dụ Mg 100 → confirm "Có phải bạn nói 1000?")
4. Áp dụng cho bể **đang được chọn** (currentTankID); nếu chưa có tank → bắt user tạo trước

### 5.2 UX flow voice

```
[Floating mic button trong WaterDashboardView]
        ↓ tap
[VoiceLogSheet]
  - Waveform / animation đang nghe
  - Live transcription text
  - Indicator "Bể: {tank name}"
  - Nút "Stop"
        ↓ stop
[Parse result preview]
  - "Magie = 450 ppm cho bể Display"
  - Confirm → save
  - Reject → quay lại nghe
```

### 5.3 Tech

- `Speech.SFSpeechRecognizer` + `AVAudioEngine`
- Locale: mặc định `vi-VN`, fallback `en-US`
- `requiresOnDeviceRecognition = true` khi available (offline)
- Permission Info.plist:
  - `NSSpeechRecognitionUsageDescription`
  - `NSMicrophoneUsageDescription`

---

## 6. Manual input

```
[Nút "+ Add log" trong WaterDashboardView]
        ↓
[LogEntryFormView]
  - Picker: Tank (mặc định = tank đang chọn)
  - Picker: Parameter (Mg, Ca, KH, ...)
  - TextField số: value (.decimalPad)
  - DatePicker: timestamp (default = now)
  - Note (optional, multi-line)
  - Save
```

- **Edit:** tap log row → form pre-fill
- **Delete:** swipe → confirm

---

## 7. Data model

### 7.1 Domain models (Swift)

```swift
struct Tank: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String                    // "Display 200L", "Frag tank"
    var iconSystemName: String          // "drop.fill", "leaf.fill", ...
    var groupID: UUID?                  // optional → DeviceFolder.id (reuse folder hierarchy)
    var deviceIDs: [UUID]               // liên kết với ConnectedDevice (optional)
    var customRanges: [WaterParameterType: ClosedRange<Double>]?  // override range mặc định
    let createdAt: Date
    var updatedAt: Date
}

struct WaterReading: Identifiable, Codable, Hashable {
    let id: UUID
    let tankID: UUID                    // ← bắt buộc, mỗi reading thuộc 1 bể
    let parameter: WaterParameterType
    let value: Double
    let timestamp: Date                 // thời điểm test
    let source: WaterReadingSource
    let note: String?

    // Sync metadata (Firestore quản lý phần lớn, nhưng cache cho UI)
    let createdAt: Date
    var updatedAt: Date                 // serverTimestamp() từ Firestore
    var ownerUID: String                // Firebase Auth uid
}

enum WaterReadingSource: String, Codable {
    case manual
    case voice
    case device   // reserved cho IoT (v2)
    case server   // imported từ external API (v2)
}
```

### 7.2 Firestore schema

```
users/{uid}
  ├── tanks/{tankID}
  │     ├── name: string
  │     ├── iconSystemName: string
  │     ├── groupID: string?
  │     ├── customRanges: map
  │     ├── createdAt: timestamp
  │     └── updatedAt: serverTimestamp
  │
  ├── tankGroups/{groupID}          ← optional, có thể reuse folder structure hiện có
  │
  └── readings/{readingID}          ← root-level cho query cross-tank dễ
        ├── tankID: string          ← index field
        ├── parameter: string       ← "mg", "ph", ...
        ├── value: number
        ├── timestamp: timestamp    ← index field
        ├── source: string
        ├── note: string?
        ├── createdAt: timestamp
        └── updatedAt: serverTimestamp
```

**Lý do `readings/` flat thay vì nested dưới `tanks/{tankID}/readings/`:**
- Cross-tank query dễ ("show me all pH readings of mine in last week")
- Đủ với composite index `(tankID, timestamp DESC)`
- Tránh limit độ sâu khi v2 thêm subcollection (alerts, photos, ...)

### 7.3 Composite indexes

| Collection | Fields | Mục đích |
|------------|--------|----------|
| `readings` | `tankID ASC, timestamp DESC` | List log theo bể, mới nhất trước |
| `readings` | `tankID ASC, parameter ASC, timestamp DESC` | Chart cho 1 parameter cụ thể |

---

## 8. Phân tích & đề xuất Database (đáp ứng yêu cầu §4)

### 8.1 So sánh các phương án

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **A. Core Data (programmatic)** giống `DeviceEntity` hiện tại + sync tay sang Firestore | Đồng nhất với code base | Phải code 2 lớp: persistence + sync + conflict; programmatic schema migration đau khổ khi schema phức tạp; duplicate work với Firestore offline cache | ❌ |
| **B. SwiftData** | Cú pháp gọn, observation tốt | iOS 17+ only, project min iOS 16 → loại | ❌ |
| **C. GRDB (SQLite)** | Query mạnh (FTS, aggregate), thích hợp cho analytics time-series | Vẫn cần code sync; thêm dependency mới | ⚠️ chỉ cân nhắc khi v2 cần analytics nặng |
| **D. Realm** | API gọn | Cộng đồng giảm sau khi MongoDB Atlas Device Sync giảm focus | ❌ |
| **E. Firestore offline persistence (làm primary)** | Built-in offline cache (LevelDB), realtime listener tự đồng bộ, không cần code sync/conflict, free tier rộng | Phụ thuộc Firebase; cost tăng theo số lượt read; query analytics phức tạp yếu hơn SQL | ✅ **chọn cho MVP1** |

### 8.2 Đề xuất

**MVP1 → dùng Firestore làm primary store, bật offline persistence.**

```swift
// AppDelegate / StoreApp init
let settings = FirestoreSettings()
settings.isPersistenceEnabled = true
settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
Firestore.firestore().settings = settings
```

**Không tạo Core Data entity cho `WaterReading` và `Tank`.** Lý do:
- Firestore tự cache offline + emit lại từ cache khi mất mạng
- Listener tự reactive → UI tự update không cần observation tay
- Tiết kiệm 1 layer + 1 protocol + risk schema drift

**Core Data hiện tại (DeviceEntity, FolderEntity) giữ nguyên** — không trộn 2 cách lưu trong cùng module.

### 8.3 Ngưỡng buộc xem lại quyết định

Khi **bất kỳ** điều sau xảy ra → reassess (tách BE riêng hoặc thêm GRDB local):

- Firestore read cost > **$30/tháng** với DAU < 1000
- Cần query analytics phức tạp: percentile, moving average, correlation giữa parameters → SQL/timeseries DB tốt hơn
- Listener attached trên >5000 documents/user → cost spike

Tracking metric: bật Firebase BigQuery export sớm để theo dõi cost per user.

---

## 9. Architecture

```
            ┌────────────────────────────────┐
            │  WaterDashboardViewModel       │
            │  (@Observable @MainActor)      │
            └──────────────┬─────────────────┘
                           │ async / AsyncStream
            ┌──────────────▼─────────────────┐
            │  WaterReadingRepository  (proto)│
            └──────────────┬─────────────────┘
                           │
            ┌──────────────▼─────────────────┐
            │ FirestoreWaterReadingRepository │  ✅ MVP1
            └─────────────────────────────────┘

  TankRepository (proto) ──▶ FirestoreTankRepository  ✅ MVP1

  WaterReadingSourceProvider (proto)  ← v2 IoT cắm vào đây
```

### 9.1 Repository protocols

```swift
protocol TankRepository {
    func observeTanks() -> AsyncStream<[Tank]>
    func saveTank(_ tank: Tank) async throws
    func deleteTank(id: UUID) async throws
}

protocol WaterReadingRepository {
    func observeReadings(tankID: UUID,
                         parameter: WaterParameterType?,
                         limit: Int) -> AsyncStream<[WaterReading]>

    func saveReading(_ reading: WaterReading) async throws
    func updateReading(_ reading: WaterReading) async throws
    func deleteReading(id: UUID) async throws
}

// Reserved for v2 IoT
protocol WaterReadingSourceProvider {
    var source: WaterReadingSource { get }
    func stream(tankID: UUID) -> AsyncStream<WaterReading>
}
```

### 9.2 Auth

- Bật **Firebase Auth Anonymous** trước, sau đó link với email/password đang dùng ở `LoginView` (nếu BE app đã có account riêng → cần migrate)
- `ownerUID` trong reading = `Auth.auth().currentUser?.uid`
- Firestore Security Rules:
  ```
  match /users/{uid}/{document=**} {
    allow read, write: if request.auth.uid == uid;
  }
  match /readings/{readingID} {
    allow read, write: if request.auth.uid == resource.data.ownerUID;
    allow create: if request.auth.uid == request.resource.data.ownerUID;
  }
  ```

---

## 10. UI / UX

### 10.1 Tank selector

- Header `WaterDashboardView`: dropdown chọn tank → list các tank của user
- Nút "Manage tanks" → mở `TankListView` (CRUD)
- Persist tank đang chọn vào `@AppStorage("selectedTankID")`

### 10.2 Touchpoints

- Header: icon **sync state** (cloud / offline / syncing)
- FAB:
  - 🎙 **Voice log** (primary)
  - ✏️ **Manual log** (secondary)
- Log list: parameter + value + thời gian + source icon + tank chip

### 10.3 States

| State | UI |
|-------|-----|
| Chưa có tank | Empty state → "Tạo bể đầu tiên" |
| Tank rỗng log | Illustration + CTA "Tap mic to add your first reading" |
| Loading | Skeleton list |
| Offline | Banner mềm "Đang offline — log sẽ tự đồng bộ" |
| Voice no permission | Sheet hướng dẫn Settings |
| Voice không match | "Không nhận diện được. Thử lại?" + fallback manual |
| Value out of plausible range | Confirm "Mg = 100, có chắc không?" |
| Sync error | Toast + retry |

---

## 11. Roadmap (chuẩn bị từ MVP1)

| Phase | Tính năng | Yêu cầu thay đổi schema/code |
|-------|-----------|------------------------------|
| **MVP1** | Voice + manual + multi-tank + Firebase sync | Như spec này |
| **v1.1** | Chart nâng cao (7d/30d/90d, ideal-range overlay) | Không đổi schema, chỉ query mới |
| **v2.0** | IoT ingestion (BLE/WiFi device push) | Implement `WaterReadingSourceProvider` BLE; thêm `source = .device` |
| **v2.0** | Notification cảnh báo out-of-range | Cloud Functions trigger trên Firestore write → FCM push |
| **v2.5** | Analytics (trend, MA, correlation) | Cân nhắc thêm GRDB local cache hoặc BigQuery sync |
| **v3.0** | Dosing recommendation từ trend | ML / rule engine; cần training data từ MVP1 |
| **v3.x** | Migrate sang BE riêng (nếu cost vượt ngưỡng) | Wrap qua repository protocol → chỉ đổi impl |

### 11.1 Chuẩn bị từ MVP1

- ✅ Tách `WaterReadingRepository` protocol → đổi BE không phải refactor ViewModel
- ✅ Schema có `source` enum → v2 IoT thêm value không break
- ✅ Schema có `ownerUID` → multi-user ready
- ✅ Tank có `customRanges` → notification v2 dùng được luôn
- ✅ Bật BigQuery export từ ngày 1 → cost monitoring + sẵn dữ liệu analytics

---

## 12. Acceptance criteria (checklist)

### Multi-tank
- [ ] Tạo tank mới với tên + icon → xuất hiện trong selector
- [ ] Chuyển tank ở header → log list filter theo tank
- [ ] Xóa tank → confirm + xóa tất cả readings thuộc tank đó
- [ ] Tank có thể gắn vào TankGroup

### Voice
- [ ] Tap mic → permission flow → vào UI nghe
- [ ] "Magie 450" → parse, confirm, save với `source = .voice` và `tankID` = tank đang chọn
- [ ] "pH tám chấm hai" → `ph = 8.2`
- [ ] Offline vẫn dùng được voice (on-device)
- [ ] Không match → error gracefully

### Manual
- [ ] Form đủ field: tank, parameter, value, timestamp, note
- [ ] Edit → `version`/`updatedAt` cập nhật (server timestamp)
- [ ] Swipe delete → confirm → biến mất

### Firestore sync
- [ ] Save khi offline → ghi cache, UI cập nhật ngay
- [ ] Bật mạng → tự sync, không cần thao tác
- [ ] Đổi máy + đăng nhập lại → kéo về toàn bộ readings
- [ ] Listener attached cho readings của tank đang xem (KHÔNG attach all-user-readings)

### Security
- [ ] Firestore rules block đọc readings của user khác (test thủ công bằng tài khoản B)
- [ ] Anonymous auth hoạt động + có thể link sau

### Architecture
- [ ] `WaterReadingRepository` là protocol, `FirestoreWaterReadingRepository` implement riêng
- [ ] `WaterReadingSourceProvider` protocol tồn tại với comment "for v2 IoT"
- [ ] Không có Core Data entity cho `WaterReading` / `Tank`

---

## 13. Implementation plan

| Phase | Task | File / Component | Est. |
|-------|------|------------------|------|
| P1 | Add Firebase SDK (Firestore + Auth) | SPM, `StoreApp.swift` init | 0.5d |
| P2 | Firebase Auth integration (anonymous + link với login hiện tại) | `Services/Auth/FirebaseAuthService.swift` | 1d |
| P3 | Domain models: `Tank`, mở rộng `WaterReading` | `Storage/Models/Tank.swift`, `WaterParameter.swift` | 0.5d |
| P4 | Firestore repository protocols + impl | `Storage/Repositories/TankRepository.swift`, `WaterReadingRepository.swift`, `Storage/Firestore/*` | 2d |
| P5 | Tank CRUD UI | `Screens/WaterDashboard/TankListView.swift`, `TankEditView.swift` | 1.5d |
| P6 | `LogEntryFormView` (manual) | `Screens/WaterDashboard/LogEntryFormView.swift` | 1d |
| P7 | Voice service + parser (VN+EN) | `Services/Voice/VoiceLogService.swift`, `VoiceLogParser.swift` | 2d |
| P8 | `VoiceLogSheet` UI | `Screens/WaterDashboard/VoiceLogSheet.swift` | 1d |
| P9 | Integrate vào `WaterDashboardView` + ViewModel | `WaterDashboardView`, `WaterDashboardViewModel` | 1.5d |
| P10 | Firestore Security Rules + composite indexes | `firestore.rules`, console setup | 0.5d |
| P11 | Info.plist permissions | `Info.plist` | 0.1d |
| P12 | Unit test parser + repository | `StoreTests/` | 1d |
| P13 | Bật BigQuery export + cost dashboard | Firebase console | 0.2d |

**Tổng MVP1: ~13 ngày dev**

---

## 14. Risks & mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Firestore cost spike khi nhiều log + listener rộng | $$$ | Paginate; chỉ attach listener cho tank active; monitor BigQuery từ ngày 1 |
| Voice recognition tiếng Việt số ("một ngàn ba trăm") không chính xác | UX | Có manual fallback rõ ràng; preview trước khi save |
| Firebase Auth conflict với hệ thống login hiện tại | Block | Decide ở P2: dùng Firebase làm auth chính, hoặc dùng custom token từ BE app |
| Multi-tank UI làm nặng UX cho user 1 bể | Adoption | Hide tank selector khi chỉ có 1 tank; auto-create "My tank" lần đầu |
| Lock-in Firebase | Tech debt | Repository protocol cho phép migrate; export định kỳ qua BigQuery |

---

## 15. Open questions (đã đóng phần lớn ở v2)

- [x] ~~Backend nào?~~ → **Firebase** (D-1)
- [x] ~~Multi-tank hay single?~~ → **Multi-tank** (D-3)
- [x] ~~DB local nào?~~ → **Firestore offline persistence, không thêm Core Data** (D-2, §8)
- [ ] **Auth strategy**: dùng Firebase Auth làm chính, hay BE app hiện tại issue custom token cho Firebase? → cần confirm P2
- [ ] Voice có cần hỗ trợ **thông số custom** (user tự đặt) không?
- [ ] Khi **logout** → xóa cache Firestore local hay giữ?
- [ ] **Migration plan** khi sang BE riêng (v3.x): chỉ đổi repository impl, hay cần data dump?

---

## 16. References

- Apple Speech: https://developer.apple.com/documentation/speech
- Firestore offline persistence: https://firebase.google.com/docs/firestore/manage-data/enable-offline
- Firestore data model: https://firebase.google.com/docs/firestore/data-model
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security/get-started
- Project steering: `CLAUDE.md`
- Current model: `Store/Store/Storage/Models/WaterParameter.swift`
