# Store – Project Coding Rules

> **Applies to every file committed to this repository.**
> Keep this document up-to-date as the project evolves.

---

## 1. Team Profile

- iOS developers with deep knowledge of Swift, SwiftUI, Clean Architecture, and unit/UI testing.
- Every reviewer must understand and enforce these rules during PR review.

---

## 2. Language & Platform

| Rule | Value |
|------|-------|
| Swift version | **Swift 6** (strict concurrency) |
| UI framework | **SwiftUI only** – no UIKit unless wrapping a system API that has no SwiftUI equivalent |
| Async model | **async/await** – do NOT introduce new Combine chains. Existing Combine code in the network layer may stay until refactored |
| Minimum deployment target | as defined in the project settings |
| External libraries | Only add a dependency when there is no reasonable native alternative; document the reason in the PR |

---

## 3. Architecture – Clean Architecture

Every user-facing feature consists of **four files** placed inside `Store/Screens/{FeatureName}/`:

```
Store/Screens/FeatureName/
  FeatureNameView.swift         ← SwiftUI view, presentation only
  FeatureNameViewModel.swift    ← @Observable final class, state + intent
  FeatureNameUseCase.swift      ← business / data logic, protocol-based
  FeatureNameNavigator.swift    ← navigation / routing, protocol-based
```

### Layer responsibilities

| Layer | Knows about | Must NOT know about |
|-------|-------------|---------------------|
| **View** | ViewModel | UseCase, Navigator, network |
| **ViewModel** | UseCase, Navigator | View internals, URLSession |
| **UseCase** | Models, repositories/services | View, ViewModel, Navigator |
| **Navigator** | View types for routing | UseCase, business logic |

### Dependency injection

- Pass dependencies through `init` parameters; never use singletons in ViewModels or UseCases (except App-level singletons like `BluetoothManager`).
- Define UseCase and Navigator as **protocols**; inject concrete types at the call site or via a factory/`DashboardView`.

---

## 4. File & Folder Structure

```
Store/
  Application/          ← App entry point (StoreApp.swift)
  Screens/
    Common/             ← Reusable, feature-agnostic SwiftUI components
    {FeatureName}/      ← One folder per screen/feature
  Services/             ← System services (Bluetooth, Camera, etc.)
  Storage/
    Models/             ← Plain Swift model types (struct / enum)
    Network/            ← APIService protocol, request types, SafeCodable
  Assets.xcassets
  Info.plist
StoreTests/
  Screens/
    {FeatureName}/      ← Unit tests mirroring the Screens structure
StoreUITests/           ← XCUITest suites
```

- **One type per file.** File name must match the primary type name.
- New UI files must live inside a sub-folder of `Store/Screens/`.
- Common reusable components (buttons, text fields, pickers) go in `Store/Screens/Common/`.
- Model files go in `Store/Storage/Models/`.

---

## 5. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Types (struct, class, enum, protocol) | `PascalCase` | `ProductDetailView` |
| Properties, methods, variables | `camelCase` | `selectedCategory` |
| Constants (file-scope `let`) | `camelCase` | `itemSpacing` |
| Enum cases | `camelCase` | `.performing` |
| Protocol for UseCase | `{Name}UseCase` | `HomeUseCase` |
| Protocol for Navigator | `{Name}Navigator` | `HomeNavigator` |
| Test file | `{TypeName}Tests.swift` | `HomeViewModelTests.swift` |
| Mock / stub type | `Mock{TypeName}` | `MockHomeUseCase` |

- Names must be **clear and intent-revealing**; avoid abbreviations except for universally understood ones (`URL`, `ID`, `API`).
- Do NOT use type suffixes like `Manager` or `Helper` unless the existing codebase already uses them (e.g., `BluetoothManager`).

---

## 6. Swift Style

### 6.1 General

- Use `let` wherever possible; only use `var` when mutation is required.
- Prefer **value types** (`struct`, `enum`) over reference types. Use `final class` when a reference type is necessary (e.g., `@Observable` ViewModels, services).
- Avoid force unwrapping (`!`). Use `guard let`, `if let`, or provide a safe default.
- Never use `try!` or `as!`; propagate or handle errors explicitly.
- Use Swift's type inference; do not annotate types that are obvious from context.
- Mark every `class` member as `private`, `fileprivate`, `internal`, or `public` explicitly — no implicit `internal` on shared APIs.

### 6.2 SwiftUI Views

- The `body` property should be **short and readable**. Extract complex sub-trees into `private var` computed view properties or private helper `func … -> some View`.
- Layout constants (`cornerRadius`, `itemSpacing`, etc.) must be `private let` properties at the top of the view struct.
- Colors and fonts: prefer semantic colors from the asset catalog over hardcoded values.
- Use `foregroundStyle` (not deprecated `foregroundColor`) for text/icon coloring.
- Every new screen must include a `#Preview` macro using mock data.

### 6.3 ViewModel

```swift
// ✅ Correct pattern
@Observable
final class FeatureNameViewModel {
    // MARK: - State
    private(set) var items: [Item] = []
    var isLoading = false

    // MARK: - Dependencies
    private let useCase: FeatureNameUseCase
    private let navigator: FeatureNameNavigator

    init(useCase: FeatureNameUseCase, navigator: FeatureNameNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    // MARK: - Intents
    func onAppear() async { … }
}
```

- Use `@Observable` (**not** `ObservableObject` / `@Published`).
- All async work is done with `async/await`; never block the main actor with `DispatchQueue.main.async`.
- Expose state as `private(set)` where external writes are not needed.
- Group members with `// MARK: -` sections: *State*, *Dependencies*, *Intents*.

### 6.4 async/await & Concurrency

- Annotate ViewModels `@MainActor` when they mutate UI-bound state.
- Use structured concurrency (`async let`, `TaskGroup`) for parallel work.
- Do NOT use `Task { @MainActor in … }` to escape an actor boundary without a clear reason.
- Cancel tasks in `onDisappear` when long-running work should stop.

### 6.5 Error Handling

- Define domain-specific `Error` enums (e.g., `APIError`).
- Propagate errors to the ViewModel; the ViewModel sets an `errorMessage: String?` state that the View displays.
- Do NOT silently swallow errors with empty `catch {}` blocks.

---

## 7. Models

- Models are **plain structs** conforming to `Identifiable`, `Hashable`, and `Codable` as needed.
- Use `SafeCodable` / `@CodableProperty` for network responses where resilient decoding is required.
- Mock data must be in a `#if DEBUG` extension:

```swift
#if DEBUG
extension Product {
    static let mocks: [Product] = [ … ]
}
#endif
```

---

## 8. Network Layer

- All requests go through a type conforming to `APIService`.
- Use `async/await` for new request implementations; the existing Combine-based `data(from:)` is legacy.
- Validate HTTP status codes; surface errors as typed `APIError` cases.
- Never put `URLRequest` construction inside a ViewModel or View.

---

## 9. Common Components (`Screens/Common/`)

- A component is reusable across at least **two** different screens; otherwise keep it local.
- Components must not import screen-specific modules or depend on any ViewModel.
- Every component must have a `#Preview`.
- Use `@Binding` for two-way data; `let` + a closure for one-way actions.

---

## 10. Testing

### Unit Tests

- Every new ViewModel **requires** a corresponding test file in `StoreTests/Screens/{FeatureName}/`.
- Inject **mock** implementations of UseCase and Navigator protocols.
- Test all public intent functions; assert resulting state changes.
- Use the **Swift Testing** framework (`import Testing`, `@Test`, `@Suite`).

```swift
// ✅ Example
@Suite("HomeViewModel")
struct HomeViewModelTests {
    @Test("Loads products on appear")
    func loadsProductsOnAppear() async {
        let vm = HomeViewModel(useCase: MockHomeUseCase(), navigator: MockHomeNavigator())
        await vm.onAppear()
        #expect(!vm.items.isEmpty)
    }
}
```

### UI Tests

- Use **XCUIAutomation** framework (`import XCTest`).
- Place UI tests in `StoreUITests/`.
- Test critical user journeys (launch, navigate to product detail, etc.).

---

## 11. Code Review Checklist

Before merging a PR, confirm:

- [ ] Follows the 4-file Clean Architecture per feature.
- [ ] No business logic in View; no UI code in UseCase.
- [ ] `@Observable` used for ViewModels (not `ObservableObject`).
- [ ] No force unwraps or `try!`.
- [ ] All public state is `private(set)` unless the View needs write access.
- [ ] Unit tests cover the new ViewModel.
- [ ] `#Preview` added for new Views and components.
- [ ] No new Combine chains introduced.
- [ ] No broken build; no new warnings.
- [ ] PR reviewed and approved by at least one other team member.

---

## 12. Commits & Branches

- Branch naming: `feature/{short-description}`, `fix/{short-description}`, `refactor/{short-description}`.
- Commit messages: imperative mood, concise — e.g., `Add ProductDetailViewModel unit tests`.
- Do not commit broken or warning-producing code to any shared branch.

---

*Last updated: 2026-04-04. Update this document as the project grows.*
