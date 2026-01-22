# Multitrack Player - Copilot Development Guidelines

This document outlines the architectural patterns, coding standards, and development practices for the Multitrack Player iOS application.

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Git Workflow](#git-workflow)
3. [Code Organization](#code-organization)
4. [SwiftUI & iOS Development](#swiftui--ios-development)
5. [Localization & Accessibility](#localization--accessibility)
6. [Testing & Validation](#testing--validation)
7. [Project Standards](#project-standards)

---

## Architecture Overview

### MVVM Pattern (Model-View-ViewModel)

The Multitrack Player uses the **Model-View-ViewModel (MVVM)** architectural pattern to separate concerns and improve testability.

#### Components:

**Models**
- Data structures representing domain entities
- Examples: `Multitrack`, `Track`, `PSUser`
- Location: `/iOS/Model/`
- Responsibility: Hold data, no business logic
- Should be `Codable` and `Identifiable` where appropriate

**Views (SwiftUI)**
- UI components displaying data to users
- Examples: `AccountScreen`, `DashboardScreen`, `Header`
- Location: `/iOS/Ui/*/View/`
- Responsibility: Display data, handle user interactions
- Should be thin, delegating logic to ViewModels

**ViewModels**
- Bridge between Views and Services
- Examples: `LoginViewModel`, `DashboardViewModel`
- Location: `/iOS/Ui/*/ViewModel/`
- Responsibility: Process user actions, manage state, call services
- Use `@Published` properties for reactive updates
- Implement `ObservableObject` protocol

#### MVVM Example:

```swift
// Model
struct PSUser: Identifiable, Codable {
    let id: String
    let email: String
    let displayName: String
}

// ViewModel
class AccountViewModel: ObservableObject {
    @Published var user: PSUser?
    @Published var isLoading = false
    
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService) {
        self.authService = authService
    }
    
    func logOut() {
        authService.logOut()
    }
}

// View
struct AccountScreen: View {
    @ObservedObject var viewModel: AccountViewModel
    @Binding var showAccountScreen: Bool
    
    var body: some View {
        VStack {
            Text(viewModel.user?.email ?? "")
            Button("Log Out") {
                viewModel.logOut()
                showAccountScreen = false
            }
        }
    }
}
```

---

### SOLID Principles

The project adheres to SOLID principles for maintainable, scalable code:

#### Single Responsibility Principle (S)
Each class/service has one reason to change.

**Example:**
```swift
// ✅ GOOD: AuthenticationService handles only authentication
class AuthenticationService {
    func logInWithGoogle() async throws -> User
    func logInWithApple() async throws -> User
    func logOut()
}

// ✅ GOOD: SessionManager handles only session state
class SessionManager {
    @Published var user: User?
    func saveUserEmail(_ email: String)
    func clearUserData()
}

// ❌ BAD: Mixing concerns
class AuthManager {
    func authenticate() // auth logic
    func saveToDatabase() // persistence logic
    func sendAnalytics() // analytics logic
}
```

**Project Examples:**
- `AuthenticationService` - handles Google/Apple sign-in only
- `AccountDeletionService` - handles account deletion only
- `SessionManager` - manages user session state
- `UserDefaultsManager` - handles local preferences

#### Open/Closed Principle (O)
Open for extension, closed for modification.

**Example:**
```swift
// ✅ GOOD: Protocol allows new providers without modifying existing code
protocol AuthenticationProvider {
    func signIn() async throws -> User
    func signOut()
}

class GoogleAuthProvider: AuthenticationProvider {
    func signIn() async throws -> User { /* Google implementation */ }
    func signOut() { /* Google sign out */ }
}

class AppleAuthProvider: AuthenticationProvider {
    func signIn() async throws -> User { /* Apple implementation */ }
    func signOut() { /* Apple sign out */ }
}

class AuthenticationService {
    let provider: AuthenticationProvider
    
    func logIn() async throws -> User {
        return try await provider.signIn()
    }
}
```

#### Liskov Substitution Principle (L)
Subtypes must be substitutable for their base types.

**Example:**
```swift
// ✅ GOOD: Both providers conform to same protocol
protocol DataRepository {
    func fetch<T: Decodable>(_ id: String) async throws -> T
    func save<T: Encodable>(_ item: T) async throws
}

class FirestoreRepository: DataRepository {
    // Implements protocol exactly as expected
}

class MockRepository: DataRepository {
    // Can be used interchangeably in tests
}
```

#### Interface Segregation Principle (I)
Don't force classes to implement interfaces they don't use.

**Example:**
```swift
// ❌ BAD: Header forced to implement player methods it doesn't need
protocol NavigationComponent {
    func play()
    func pause()
    func displayUserProfile()
    func updateColors()
}

// ✅ GOOD: Segregate into focused interfaces
protocol UserProfileComponent {
    func displayUserProfile()
}

protocol NavigationComponent {
    func updateColors()
}

class Header: UserProfileComponent, NavigationComponent {
    // Only implements what it needs
}
```

**Project Examples:**
- Services expose only necessary methods
- Views implement only required protocols
- ViewModels don't implement unnecessary protocols

#### Dependency Inversion Principle (D)
Depend on abstractions, not concrete implementations.

**Example:**
```swift
// ✅ GOOD: ViewModel depends on protocol (abstraction)
class LoginViewModel: ObservableObject {
    private let authService: AuthenticationService // abstraction
    
    init(authService: AuthenticationService = .shared) {
        self.authService = authService
    }
}

// ❌ BAD: Direct dependency on concrete class
class LoginViewModel: ObservableObject {
    private let googleAuth = GoogleAuthProvider() // concrete
}
```

---

### Clean Architecture

The project follows **Clean Architecture** principles with clear layer separation:

#### Layers:

**1. Entities** (Core Business Rules)
- Pure Swift structs and enums
- No framework dependencies
- Examples: `Multitrack`, `Track`, `PSUser`
- Location: `/iOS/Model/`

**2. Use Cases** (Business Logic)
- Services implementing business rules
- Examples: `AuthenticationService`, `AccountDeletionService`, `MultitrackRepository`
- Location: `/iOS/Model/Repository/`, `/iOS/Ui/Commons/`
- Dependencies: Only Entities

**3. Controllers** (Interface Adapters)
- ViewModels coordinating between Views and Use Cases
- Examples: `LoginViewModel`, `DashboardViewModel`
- Location: `/iOS/Ui/*/ViewModel/`
- Dependencies: Views, Use Cases, Entities

**4. External** (Frameworks & Platforms)
- SwiftUI, Firebase, CoreData
- Dependencies: Everything depends on this layer, not vice versa

#### Dependency Rule:
**All dependencies point inward toward entities. Nothing in inner layers should know about outer layers.**

```
External (Firebase, SwiftUI, CoreData)
    ↓
Controllers (ViewModels)
    ↓
Use Cases (Services, Repositories)
    ↓
Entities (Models)
```

#### Architecture Violation Prevention:

```swift
// ❌ VIOLATION: Entity imports Firebase (outer layer dependency)
struct User: Codable {
    let id: String
    // Cannot use Firebase types here
}

// ✅ CORRECT: Entity is pure Swift
struct PSUser: Codable, Identifiable {
    let id: String
    let email: String
    let displayName: String
}

// ✓ Repository (Use Case) converts Firebase types to Entity
class MultitrackRepository {
    func fetchMultitracks() async throws -> [Multitrack] {
        let firebaseData = try await firestore.collection("multitracks").getDocuments()
        return firebaseData.documents.map { doc in
            Multitrack(from: doc.data())
        }
    }
}
```

---

## Git Workflow

### Branch Naming Convention

```
feature/[feature-name]      # New features
fix/[bug-name]              # Bug fixes
refactor/[component-name]   # Code refactoring
docs/[topic]                # Documentation
```

### Pull Request Process

1. Create feature branch from `main`
   ```bash
   git checkout -b feature/account-screen
   ```

2. Implement feature with regular commits
   ```bash
   git commit -m "feat: Add account information display"
   git commit -m "feat: Add logout functionality"
   git commit -m "fix: Add accessibility label to profile button"
   ```

3. Push to origin
   ```bash
   git push origin feature/account-screen
   ```

4. Create Pull Request on GitHub
   - Clear title: "Move profile button to header for always-visible access"
   - Description with context: What changed and why
   - Link related issues if applicable

5. Address review feedback
   - Make changes with new commits
   - Push updated branch

6. Rebase and merge when approved
   ```bash
   git rebase main
   git push -f origin feature/[name]
   ```

7. Merge via GitHub UI or CLI
   ```bash
   gh pr merge [number] --rebase --delete-branch
   ```

8. Delete local branch
   ```bash
   git branch -d feature/[name]
   ```

### Commit Message Format

Use conventional commits:
```
feat: Add new feature
fix: Fix specific bug
refactor: Refactor component
docs: Update documentation
style: Format code
test: Add tests
```

---

## Code Organization

### Directory Structure

```
/iOS
├── Model/
│   ├── CoreDataManager/     # CoreData persistence
│   ├── Repository/          # Data access layer
│   └── Multitrack/          # Domain entities
├── Resources/
│   └── Localizable.xcstrings   # Bilingual translations
└── Ui/
    ├── Commons/             # Shared components
    │   ├── Authenticator/   # Auth providers
    │   ├── Extensions/      # SwiftUI extensions
    │   ├── Headers/         # Navigation header
    │   ├── Login/           # Login feature
    │   ├── Session/         # Session management
    │   ├── UserDefaults/    # Local storage
    │   └── Utils/           # Utility functions
    └── Player/              # Main player feature
        ├── View/            # UI screens
        └── ViewModel/       # Business logic
```

### File Naming Conventions

- **Views**: `[ScreenName]Screen.swift` or `[ComponentName]View.swift`
  - Example: `AccountScreen.swift`, `Header.swift`

- **ViewModels**: `[ScreenName]ViewModel.swift`
  - Example: `LoginViewModel.swift`

- **Models**: `[EntityName].swift`
  - Example: `Multitrack.swift`, `Track.swift`

- **Services**: `[ServiceName]Service.swift` or `[ServiceName]Manager.swift`
  - Example: `AuthenticationService.swift`, `SessionManager.swift`

- **Extensions**: `[Type]+[Feature].swift`
  - Example: `String+Empty.swift`, `View+Extensions.swift`

### Imports Organization

```swift
import SwiftUI
import Firebase
import FirebaseAuth

// Alphabetical by module

import Combine

// System imports at top, custom below
```

---

## SwiftUI & iOS Development

### View State Management

**Use `@State` for local view state only:**
```swift
struct AccountScreen: View {
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        // State updates stay within this view
    }
}
```

**Use `@ObservedObject` for ViewModel binding:**
```swift
struct DashboardScreen: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        // Reactive updates from viewModel.@Published properties
    }
}
```

**Use `@Binding` for child-to-parent communication:**
```swift
struct Header: View {
    @Binding var showAccountScreen: Bool
    
    var body: some View {
        Button(action: { showAccountScreen = true }) {
            Image(systemName: "person.circle")
        }
    }
}
```

**Use `@Environment` for system settings:**
```swift
struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button("Back") { dismiss() }
    }
}
```

### Optional Features with Default Values

When a component has optional features:

```swift
struct Header: View {
    var showAccountScreenBinding: Binding<Bool>?
    
    init(showAccountScreenBinding: Binding<Bool> = .constant(false)) {
        self.showAccountScreenBinding = showAccountScreenBinding
    }
    
    var body: some View {
        HStack {
            // Profile button only appears if binding provided
            if let binding = showAccountScreenBinding {
                Button(action: { binding.wrappedValue = true }) {
                    Image(systemName: "person.circle")
                }
            }
        }
    }
}
```

### Sheet vs NavigationDestination

- **Use `.sheet()` for:**
  - Modal presentations
  - Standalone flows (login, settings)
  - Reliable dismiss behavior
  
```swift
@State private var showAccountScreen = false

var body: some View {
    ZStack {
        // Main content
    }
    .sheet(isPresented: $showAccountScreen) {
        AccountScreen(showAccountScreenBinding: $showAccountScreen)
    }
}
```

- **Use `.navigationDestination()` for:**
  - Stack-based navigation
  - Breadcrumb trails
  - Back button navigation

### Button Action Patterns

**Simple actions:**
```swift
Button("Log Out") {
    viewModel.logOut()
    showAccountScreen = false
}
```

**Async operations:**
```swift
Button("Delete Account") {
    Task {
        try await viewModel.confirmAccountDeletion()
        showAccountScreen = false
    }
}
```

**Confirmation dialogs:**
```swift
.confirmationDialog("Delete Account?", isPresented: $showConfirmation) {
    Button("Delete", role: .destructive) {
        viewModel.confirmAccountDeletion()
    }
    Button("Cancel", role: .cancel) {}
}
```

---

## Localization & Accessibility

### Localization Pattern

**All user-facing text must use `String(localized:)`:**

```swift
// ✅ CORRECT
Text(String(localized: "account"))
Button(action: {}) {
    Label(String(localized: "logout"), systemImage: "arrowtriangleright.turn.down.left")
}

// ❌ INCORRECT
Text("Account")
Button("Log Out") {}
```

**Strings defined in `Localizable.xcstrings`:**
```json
{
    "account": {
        "comment": "Title of account screen",
        "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Account" } },
            "es": { "stringUnit": { "state": "translated", "value": "Cuenta" } }
        }
    }
}
```

**Current supported locales:** English (EN), Spanish (ES)

### Accessibility Requirements

**All interactive elements must have accessibility labels:**

```swift
// ✅ GOOD
Button(action: { showAccountScreen = true }) {
    Image(systemName: "person.circle")
        .accessibilityLabel(String(localized: "profile"))
}

Button(action: { viewModel.logOut() }) {
    Text(String(localized: "logout"))
        .accessibilityLabel(String(localized: "logout"))
}

// ❌ BAD (unlabeled icon buttons)
Button(action: {}) {
    Image(systemName: "person.circle")
    // Screen readers won't know what this does
}
```

**Accessibility guidelines:**
- Icon-only buttons must have `.accessibilityLabel()`
- Complex custom views need `.accessibilityElement()` and `.accessibilityLabel()`
- Use localized strings for labels
- Test with Voice Control and Voice Over enabled

---

## Testing & Validation

### Before Pushing Code

1. **Compilation Check**
   - No errors or warnings in Xcode
   - Run `Product > Build` or ⌘B

2. **Simulator Testing**
   - Test on iPhone 15 simulator (minimum)
   - Test on iPad if app supports it
   - Verify all tap targets work
   - Test navigation flows

3. **Localization Validation**
   - Verify all new UI text uses `String(localized:)`
   - Check that new strings exist in `Localizable.xcstrings`
   - Test EN and ES variants

4. **Accessibility Validation**
   - Verify all buttons have `.accessibilityLabel()`
   - Test with Voice Over enabled
   - Test with Dynamic Type (Settings > Accessibility > Display & Text Size)

5. **Git Cleanliness**
   - No uncommitted changes
   - Branch is up-to-date with `main`
   - Meaningful commit messages

### Test Checklist for Account Features

- [ ] Login works with Google Sign-In
- [ ] Login works with Apple Sign-In
- [ ] AccountScreen displays user email
- [ ] Logout button clears session
- [ ] Back button dismisses AccountScreen (no flash to login)
- [ ] Profile button appears in Dashboard header
- [ ] Profile button doesn't appear in Login screen
- [ ] Delete account shows confirmation dialog
- [ ] Cancel delete keeps user logged in
- [ ] Confirm delete clears account and returns to login
- [ ] All text displays in both EN and ES
- [ ] All buttons have accessibility labels

---

## Project Standards

### Code Style

**Naming Conventions:**
- Properties: camelCase (`userEmail`, `isLoading`)
- Types: PascalCase (`AccountScreen`, `LoginViewModel`)
- Constants: camelCase or UPPER_CASE (`maxRetries`, `API_BASE_URL`)
- Private/internal: Prefix with underscore if needed (`_internalState`)

**Formatting:**
- 4 spaces indentation (Xcode default)
- Line length: Aim for < 100 characters
- One blank line between logical sections
- Trailing commas in multi-line collections (SwiftUI style)

**Comments:**
```swift
// Single line comment for brief notes

/// Documentation comment for public APIs
/// - Parameter name: Description
/// - Returns: Description
func methodName() {
}
```

### Error Handling

**Use Result types for async operations:**
```swift
func fetchData() async throws -> [Item] {
    // Propagate errors with throws
}
```

**Handle errors appropriately:**
```swift
Task {
    do {
        let items = try await repository.fetch()
        self.items = items
    } catch {
        self.errorMessage = error.localizedDescription
        print("Fetch failed: \(error)")
    }
}
```

### Performance Considerations

1. **Avoid rebuilding entire View hierarchy**
   - Break complex views into smaller components
   - Use `@StateObject` for expensive initialization

2. **Use `.constant()` for read-only bindings**
   - `.constant(false)` for non-functional parameters

3. **Debounce search operations**
   - Use `Combine.debounce()` for text field inputs

4. **Cache images and network responses**
   - Use `URLCache` for network requests
   - Cache images in memory and disk

### Dependencies

**Approved third-party libraries:**
- Firebase (Authentication, Firestore, Analytics)
- SwiftUI (iOS 15+)
- Combine (async/await)

**Avoid:**
- Mixing SwiftUI with UIKit unnecessarily
- Using deprecated APIs
- Adding new large dependencies without team discussion

### When to Refactor

- Extract repeated code into reusable components
- Break large ViewModels into smaller, focused ones
- Simplify complex conditional logic
- Improve test coverage before major changes

---

## Quick Reference

### Common Patterns

**Create a new feature:**
```bash
git checkout -b feature/new-feature
# Implement feature
git push origin feature/new-feature
# Create PR on GitHub
```

**Add new UI text:**
1. Add string key to `Localizable.xcstrings`
2. Use `String(localized: "key_name")` in code
3. Verify both EN and ES translations

**Add new screen:**
1. Create `[ScreenName]Screen.swift` in `/iOS/Ui/[Feature]/View/`
2. Create `[ScreenName]ViewModel.swift` in `/iOS/Ui/[Feature]/ViewModel/`
3. Define models in `/iOS/Model/`
4. Import in parent View with `@ObservedObject`

**Add accessibility label:**
```swift
Image(systemName: "icon")
    .accessibilityLabel(String(localized: "localization_key"))
```

---

## Questions or Updates?

When encountering situations not covered by these guidelines:
1. Check existing patterns in codebase
2. Follow SOLID principles and Clean Architecture
3. Prioritize user experience and accessibility
4. Keep code maintainable and readable
5. Document complex logic with comments

These guidelines ensure consistency, maintainability, and scalability across the Multitrack Player codebase.
