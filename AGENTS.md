# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build & Run Commands

```bash
# Open project in Xcode
open "MultitrackPlayer/The Multitrack Player.xcodeproj"

# Build via command line (requires xcodebuild)
xcodebuild -project "MultitrackPlayer/The Multitrack Player.xcodeproj" -scheme "The Multitrack Player (iOS)" -sdk iphonesimulator build

# Run tests
xcodebuild -project "MultitrackPlayer/The Multitrack Player.xcodeproj" -scheme "The Multitrack Player (iOS)" -sdk iphonesimulator test
```

**Primary development**: Open Xcode, select iPhone 15 simulator, press ⌘R to run or ⌘B to build.

## Architecture

**MVVM + Clean Architecture** with SOLID principles:

- **Entities** (`iOS/Model/`): Pure Swift data structures (`Multitrack`, `Track`, `PSUser`)
- **Use Cases** (`iOS/Model/Repository/`, `iOS/Ui/Commons/`): Services like `AuthenticationService`, `AccountDeletionService`, `MultitrackRepository`
- **ViewModels** (`iOS/Ui/*/ViewModel/`): Business logic with `@Published` properties implementing `ObservableObject`
- **Views** (`iOS/Ui/*/View/`): SwiftUI components - thin, delegating logic to ViewModels

**Dependency rule**: Inner layers (Entities) must not import outer layers (Firebase, SwiftUI).

## Key Services & Patterns

**Authentication** (`iOS/Ui/Commons/Authentication/`):
- `AuthenticationService` - Facade coordinating Google/Apple sign-in
- `GoogleAuthProvider`, `AppleAuthProvider` - Implement `AuthenticationProvider` protocol
- `SessionManager` - Manages user session state with `@Published` properties
- Session restoration tries Google first, then Apple

**Data Layer** (`iOS/Model/Repository/`):
- `MultitrackRepository` - Main data access
- `UserCoreDataRepository` - User-specific CoreData operations
- `UserFileRepository` - User file management

## Code Requirements

**Localization** (EN/ES required):
```swift
// Always use String(localized:) for user-facing text
Text(String(localized: "key_name"))
```
Strings defined in `iOS/Resources/Localizable.xcstrings`

**Accessibility** (WCAG compliance required):
```swift
// All icon buttons must have labels
Image(systemName: "person.circle")
    .accessibilityLabel(String(localized: "profile"))
```

**State Management**:
- `@State` - Local view state only
- `@ObservedObject` - ViewModel binding
- `@Binding` - Child-to-parent communication
- Use `.sheet()` for modal presentations, `.navigationDestination()` for stack navigation

## Git Workflow

```bash
# Branch naming
feature/[feature-name]
fix/[bug-name]
refactor/[component-name]

# Conventional commits
feat: Add new feature
fix: Fix specific bug
refactor: Refactor component

# Merge with rebase
gh pr merge <number> --rebase --delete-branch
```

## File Naming

- Views: `[ScreenName]Screen.swift` or `[ComponentName]View.swift`
- ViewModels: `[ScreenName]ViewModel.swift`
- Models: `[EntityName].swift`
- Services: `[ServiceName]Service.swift` or `[ServiceName]Manager.swift`

## Firebase Configuration

Environment-specific plist files:
- `GoogleService-Info-Dev.plist`
- `GoogleService-Info-Staging.plist`
- `GoogleService-Info-Prod.plist`

## Dependencies

- SwiftUI (iOS 15+)
- Firebase (Auth, Firestore, Analytics)
- Google Sign-In
- AuthenticationServices (Apple Sign-In)
- CoreData
- Combine
