# Agents Guide: Cocktails 4.0

## Project Structure
The source code is located in: `/Cocktails 4.0/Cocktails 4.0/`

## Architecture
- **Framework**: SwiftUI + SwiftData.
- **Dependency Injection**: `AppDependencies` (in `Services/Dependencies/`) is the central hub. It is injected into views as an `.environmentObject`.
- **Data Flow**: ViewModel -> Service -> APIClient/SwiftData.

## Persistence (SwiftData)
- **Core Models**: `Cocktail`, `MyBar`, `PendingAction`.
- **Container**: Initialized in `Cocktails_4_0App.swift`.
- **Bootstrap**: `bootstrapData()` ensures a `MyBar` instance exists on first launch.

## Networking & Config
- **Configuration**: API keys and URLs are read from `Info.plist` via `ServiceConfig.swift`.
- **Environment**: Uses `.xcconfig` files (`AppConfig_Dev.xcconfig`, `AppConfig_Release.xcconfig`) for environment-specific settings.
- **Endpoints**: Defined in `Endpoints` struct within `ServiceConfig.swift`.

## Key Services & Coordinators
- **Services**: `CocktailService`, `MyBarService`, `UserService`, `AdminService`.
- **Coordinators**: 
  - `SyncCoordinator`: Manages data synchronization.
  - `PendingActionCoordinator`: Handles asynchronous/offline actions via `PendingActionProcessor` implementations.
  - `ContextCoordinator`: Manages shared context.
- **Globals**: `ToastManager` and `LocalizationManager` provide app-wide UI state and localization.

## Development Notes
- **Localization**: Managed via `Localizable.xcstrings` and `LocalizationManager`.
- **Assets**: Custom colors and images are stored in `Assets.xcassets`.
- **Testing**: Logic tests are in `Cocktails 4.0Tests` and UI tests in `Cocktails 4.0UITests`.
