# Multitrack Player - iOS

A professional SwiftUI-based iOS application for playing multitrack audio. Features modern authentication, session management, and comprehensive development guidelines.

## Overview

Multitrack Player is an iOS app that allows users to play and manage multitrack audio files with a clean, intuitive interface. The project is built with SwiftUI and follows MVVM architecture with SOLID principles and Clean Architecture patterns.

**Status:** Active Development  
**Latest Version:** 1.0  
**Minimum iOS Version:** 15.0

## Key Features

- 🎵 Multitrack audio playback
- 👤 Authentication (Google Sign-In & Apple Sign-In)
- 📱 Session management with credential state verification
- 🔐 Account management and deletion (GDPR compliant)
- 🌍 Bilingual support (English & Spanish)
- ♿ Full accessibility support (WCAG compliant)
- 📊 Firebase analytics integration
- 💾 Core Data persistence

## Project Structure

```
/iOS
├── Model/                  # Data entities and repositories
├── Resources/              # Localization strings
└── Ui/                     # UI components and features
    ├── Commons/            # Shared components (Auth, Session, Headers)
    └── Player/             # Main player interface

/docs                       # Privacy policy and documentation
/The Multitrack Player.xcodeproj    # Xcode project
```

## Development Guidelines

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/Esteban-Trivino-Software-House/MultitrackPlayer.git
   cd MultitrackPlayer
   ```

2. Open the project in Xcode:
   ```bash
   open "The Multitrack Player.xcodeproj"
   ```

3. Set up Firebase:
   - Download `GoogleService-Info.plist` for your Firebase project
   - Replace the existing plist files (Dev, Staging, Prod)

4. Build and run on simulator or device

### Architecture

The project follows **MVVM + Clean Architecture**:

- **Models (Entities)**: Pure Swift data structures
- **Views**: SwiftUI components with minimal logic
- **ViewModels**: Business logic and state management
- **Services**: Domain-specific use cases (Auth, Account, etc.)
- **Repositories**: Data access layer

### Code Standards

For comprehensive development guidelines, see [copilot-instructions.md](copilot-instructions.md) which includes:

- **MVVM Pattern**: How we structure Views, ViewModels, and Models
- **SOLID Principles**: Best practices with real project examples
- **Clean Architecture**: Layer separation and dependency rules
- **Git Workflow**: Branch naming, PR process, commit messages
- **SwiftUI Best Practices**: State management, bindings, navigation
- **Localization**: EN/ES bilingual support requirements
- **Accessibility**: WCAG compliance and implementation
- **Testing**: Validation checklist before pushing code
- **Project Standards**: Code style, naming conventions, error handling

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git commit -m "feat: Your feature description"

# Push and create PR
git push origin feature/your-feature-name
gh pr create --title "Your PR title"

# After review, merge with rebase
gh pr merge <number> --rebase --delete-branch
```

### Authentication

The app supports two authentication methods:

1. **Google Sign-In**: Native Google authentication with session restoration
2. **Apple Sign-In**: Native Apple authentication with credential state verification

Both providers implement the `AuthenticationProvider` protocol for unified handling.

### Localization

All user-facing text must use localization:

```swift
Text(String(localized: "key_name"))
Button(action: {}) {
    Text(String(localized: "button_label"))
}
```

Strings are defined in `iOS/Resources/Localizable.xcstrings` with EN and ES translations.

### Accessibility

All interactive elements must have accessibility labels:

```swift
Button(action: {}) {
    Image(systemName: "person.circle")
        .accessibilityLabel(String(localized: "profile"))
}
```

## Known Issues & Fixes

### Apple Sign-In Double Login (Fixed in PR #17)
- **Issue**: Users had to authenticate twice with Face ID when using Apple Sign-In
- **Solution**: Replaced `SignInWithAppleButton` with custom button and added credential state verification
- **Result**: Single authentication prompt per login

### Apple Credential Revocation (Fixed in PR #17)
- **Issue**: App attempted to use revoked Apple credentials, causing authentication failures
- **Solution**: Added `getCredentialState()` check to verify credentials before restoration
- **Result**: Proper handling of revoked credentials with clean session cleanup

## Testing Checklist

Before pushing code, verify:

- [ ] No compilation errors or warnings
- [ ] All new UI text uses `String(localized:)`
- [ ] All buttons have accessibility labels
- [ ] App works on iPhone 15 simulator
- [ ] Navigation flows work correctly
- [ ] All text displays in EN and ES
- [ ] Voice Over works with all interactive elements

## Dependencies

### Core
- **SwiftUI**: UI framework (iOS 15+)
- **Combine**: Reactive programming
- **CoreData**: Local persistence

### External
- **Firebase**: Authentication, Analytics, Firestore
- **Google Sign-In**: Google authentication provider
- **AuthenticationServices**: Apple Sign-In (native)
- **CryptoKit**: Cryptographic operations for Apple Sign-In

## Privacy & Security

- Privacy Policy: [English](docs/index.html) | [Español](docs/privacy-es.html)
- All user data handled according to GDPR requirements
- Account deletion available per App Store Guideline 5.1.1(v)
- Firebase analytics for usage tracking (non-personal)

## Contributing

1. Create a feature branch from `main`
2. Follow the guidelines in [copilot-instructions.md](copilot-instructions.md)
3. Ensure all tests pass and code is properly localized
4. Create a pull request with clear description
5. Request review from team members
6. After approval, merge with rebase

## Team

- **Lead Developer**: Esteban Triviño

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Support

For issues, bug reports, or feature requests, please open an issue on GitHub.

---

**Last Updated**: January 22, 2026  
**Current Version**: 1.0
