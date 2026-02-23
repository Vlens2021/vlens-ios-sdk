# VLens iOS SDK Demo App

A SwiftUI demo application that demonstrates integration with the VLens iOS SDK.

## Prerequisites

- Xcode 15.0+
- iOS 15.0+ physical device (camera required)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed

## Setup

1. **Install XcodeGen** (if not already installed):

   ```bash
   brew install xcodegen
   ```

2. **Generate the Xcode project**:

   ```bash
   cd vlens_ios/VLensDemoApp
   xcodegen generate
   ```

3. **Open in Xcode**:

   ```bash
   open VLensDemoApp.xcodeproj
   ```

4. **Configure signing**: Select the `VLensDemoApp` target, go to *Signing & Capabilities*, and set your Development Team.

5. **Build and run** on a physical iOS device.

## Usage

1. Tap **Set Default Data** to generate a Transaction ID and fetch an Access Token from the login API.
2. Tap **Get Started** to launch the full VLens verification flow (ID scanning + liveness).
3. Tap **Get Started With Liveness Only** to launch only the liveness verification flow.

## Project Structure

```
VLensDemoApp/
├── project.yml                  # XcodeGen specification
├── README.md
└── VLensDemoApp/
    ├── App/
    │   └── VLensDemoAppApp.swift    # SwiftUI app entry point
    ├── Views/
    │   └── ContentView.swift        # Main demo screen
    ├── Services/
    │   └── LoginService.swift       # Login API client
    └── Resources/
        ├── Info.plist               # Camera & microphone permissions
        └── Assets.xcassets/         # App icons, accent color, VLens logo
```

## SDK Integration

The demo uses the `.vlensVerification()` SwiftUI view modifier from `VLensLib` for a declarative integration. The SDK is referenced as a local SPM package pointing to the parent directory (`../`).
