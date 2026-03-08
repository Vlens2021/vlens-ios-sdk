# VLens iOS SDK

VLens iOS SDK provides digital identity verification for iOS apps — including national ID capture (front & back), liveness detection, and face matching. It supports both **SwiftUI** and **UIKit** integration.

---

## Installation

### Requirements
- **iOS**: 15.0 or later
- **Swift**: 5.5 or later
- **Xcode**: 13.0 or later

### Device Compatibility

The VLens SDK uses ARKit face tracking for liveness detection, which requires a **TrueDepth camera**.

| TrueDepth Camera | Devices |
|------------------|--------|
| ✅ Supported | iPhone X and later (excluding SE models) |
| ❌ Not Supported | iPhone 8, iPhone 7, iPhone SE (all generations) |

**Behavior based on `allowNonTrueDepthFallback`:**

| `allowNonTrueDepthFallback` | TrueDepth Available | Behavior |
|-----------------------------|---------------------|----------|
| `false` (default) | ✅ Yes | ARKit face tracking (full liveness) |
| `false` (default) | ❌ No | SDK closes with `DEVICE_NOT_SUPPORTED` error |
| `true` | ✅ Yes | ARKit face tracking (full liveness) |
| `true` | ❌ No | Fallback to auto-capture every 2 seconds |

### Swift Package Manager
To add VLensLib to your project using Swift Package Manager:

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/Vlens2021/vlens-ios-sdk
   ```
3. Select version **1.1.0** (or the latest release) and click **Add Package**.

### Info.plist

Add camera permission to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera is required for identity verification</string>
```

---

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `transactionId` | `String` | ✅ | — | Unique identifier for the transaction |
| `apiKey` | `String` | ✅ | — | Your VLens API key |
| `secretKey` | `String` | ✅ | — | Secret key (pass `""` if using access-token auth) |
| `tenancyName` | `String` | ✅ | — | Your tenancy name |
| `accessToken` | `String` | ✅ | — | Bearer token from the Login API |
| `language` | `String` | ❌ | `"en"` | UI language — `"en"` or `"ar"` |
| `withLivenessOnly` | `Bool` | ❌ | `false` | Skip ID capture, run liveness only |
| `noOfRetries` | `Int` | ❌ | `5` | Number of retry attempts |
| `allowAutoCapture` | `Bool` | ❌ | `true` | Enable automatic document capture |
| `allowNonTrueDepthFallback` | `Bool` | ❌ | `false` | Allow SDK on devices without TrueDepth camera |
| `showCloseButton` | `Bool` | ❌ | `true`* | Show "X" close button in top-right corner |
| `colors` | `VLensColors` | ❌ | `.default` | UI color configuration for branding |
| `enableSounds` | `Bool` | ❌ | `true` | Enable/disable SDK sounds |
| `clientLogoImage` | `UIImage?` | ❌ | `nil` | Custom client logo image |
| `showIdReviewPage` | `Bool` | ❌ | `true` | Show ID review page after capture |
| `onDismiss` | `(() -> Void)?` | ❌ | `nil` | Called when user taps the close button |

> \* `showCloseButton` defaults to `true` when using `VLensVerificationView` directly, and `false` when using the `.vlensVerification()` modifier.

---

## Sound Control

The SDK plays audio feedback for face verification instructions (smile, blink, turn head) and success sounds. You can disable all sounds:

```swift
// UIKit
let manager = VLensManager(
    transactionId: UUID().uuidString,
    apiKey: "...",
    secretKey: "",
    tenancyName: "...",
    enableSounds: false  // Disable all SDK sounds
)

// Or set after initialization:
manager.setEnableSounds(false)
```

**Affected sounds when `enableSounds: false`:**
- Face verification instruction sounds (smile, blink, turn left/right, look straight)
- Success confirmation sounds
- All audio feedback is muted

---

## Custom Logo (Branding)

Display your company logo instead of the VLens logo throughout the SDK:

```swift
// UIKit
let manager = VLensManager(
    transactionId: UUID().uuidString,
    apiKey: "...",
    secretKey: "",
    tenancyName: "...",
    clientLogoImage: UIImage(named: "your-company-logo")
)

// Or set after initialization:
manager.setClientLogoImage(UIImage(named: "your-company-logo"))
```

The custom logo will be displayed on:
- National ID scan start screen
- Face verification start screen

---

## ID Review Page

After capturing both sides of the national ID, the SDK displays a review page showing the extracted data. Users can verify the information before proceeding to face verification.

```swift
// UIKit - Enable ID review page (default: true)
let manager = VLensManager(
    transactionId: UUID().uuidString,
    apiKey: "...",
    secretKey: "",
    tenancyName: "...",
    showIdReviewPage: true
)

// Disable ID review page to skip directly to face verification:
manager.setShowIdReviewPage(false)
```

**ID Review Page Features:**
- Displays extracted front ID data (name, address, date of birth, ID number)
- Displays extracted back ID data (gender, marital status, job, religion, issue/expiry dates)
- Shows verification status badge
- **"Retake ID"** button: Returns to ID scanning to recapture
- **"Continue"** button: Proceeds to face verification

---

## UI Customization

Customize the SDK's appearance to match your app's branding using `VLensColors`:

```swift
let customColors = VLensColors(
    light: VLensColorConfig(
        accent: "#007AFF",      // Highlights, secondary actions
        primary: "#1E3A5F",     // Main buttons, headers
        secondary: "#666666",   // Supporting text
        background: "#FFFFFF",  // Screen backgrounds
        dark: "#1C1C1E",        // Dark variant
        light: "#F2F2F7"        // Light variant
    ),
    dark: VLensColorConfig(
        accent: "#0A84FF",
        primary: "#FFFFFF",
        secondary: "#ABABAB",
        background: "#1C1C1E",
        dark: "#000000",
        light: "#2C2C2E"
    )
)

// SwiftUI
.vlensVerification(
    isPresented: $showVLens,
    transactionId: txnId,
    apiKey: "...",
    secretKey: "",
    tenancyName: "...",
    accessToken: token,
    colors: customColors,
    onSuccess: { ... },
    onFailure: { ... }
)

// UIKit
let manager = VLensManager(
    transactionId: UUID().uuidString,
    apiKey: "...",
    secretKey: "",
    tenancyName: "...",
    colors: customColors
)
```

---

## SwiftUI Integration

Use the `.vlensVerification()` view modifier to present the verification flow:

```swift
import SwiftUI
import VLensLib

struct ContentView: View {
    @State private var showVLens = false
    @State private var transactionId = ""
    @State private var accessToken = "" // obtain from Login API

    var body: some View {
        VStack(spacing: 20) {
            Button("Start Verification") {
                transactionId = UUID().uuidString
                showVLens = true
            }
        }
        .vlensVerification(
            isPresented: $showVLens,
            transactionId: transactionId,
            apiKey: "YOUR_API_KEY",
            secretKey: "",
            tenancyName: "YOUR_TENANCY_NAME",
            accessToken: accessToken,
            onSuccess: { txnId, userData in
                print("Success: \(txnId)")
                if let name = userData?.user?.fullName {
                    print("Name: \(name)")
                }
            },
            onFailure: { txnId, error in
                print("Failed: \(error)")
            }
        )
    }
}
```

### Liveness Only (SwiftUI)

Pass `withLivenessOnly: true` to skip ID capture:

```swift
.vlensVerification(
    isPresented: $showVLens,
    transactionId: transactionId,
    apiKey: "YOUR_API_KEY",
    secretKey: "",
    tenancyName: "YOUR_TENANCY_NAME",
    withLivenessOnly: true,
    accessToken: accessToken,
    onSuccess: { txnId, userData in /* ... */ },
    onFailure: { txnId, error in /* ... */ }
)
```

### Flexible Presentation with VLensVerificationView

For scenarios where you need more control over presentation (e.g., `.sheet`, `NavigationStack`, or custom modals), use `VLensVerificationView` directly:

#### Using with .sheet

```swift
import SwiftUI
import VLensLib

struct ContentView: View {
    @State private var showVLens = false
    @State private var transactionId = ""
    @State private var accessToken = ""

    var body: some View {
        VStack {
            Button("Start Verification") {
                transactionId = UUID().uuidString
                showVLens = true
            }
        }
        .sheet(isPresented: $showVLens) {
            VLensVerificationView(
                transactionId: transactionId,
                apiKey: "YOUR_API_KEY",
                secretKey: "",
                tenancyName: "YOUR_TENANCY_NAME",
                accessToken: accessToken,
                showCloseButton: true, // Shows "X" button
                onSuccess: { txnId, userData in
                    showVLens = false
                    print("Success: \(txnId)")
                },
                onFailure: { txnId, error in
                    showVLens = false
                    print("Failed: \(error)")
                },
                onDismiss: {
                    showVLens = false // Called when user taps "X"
                }
            )
        }
    }
}
```

#### Using with NavigationStack

```swift
import SwiftUI
import VLensLib

struct VerificationFlowView: View {
    @State private var path = NavigationPath()
    @State private var transactionId = ""
    @State private var accessToken = ""

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Start Verification") {
                    transactionId = UUID().uuidString
                    path.append("verification")
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "verification" {
                    VLensVerificationView(
                        transactionId: transactionId,
                        apiKey: "YOUR_API_KEY",
                        secretKey: "",
                        tenancyName: "YOUR_TENANCY_NAME",
                        accessToken: accessToken,
                        showCloseButton: false, // Use navigation bar instead
                        onSuccess: { txnId, userData in
                            path.removeLast()
                        },
                        onFailure: { txnId, error in
                            path.removeLast()
                        },
                        onDismiss: {
                            path.removeLast()
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                path.removeLast()
                            }
                        }
                    }
                }
            }
        }
    }
}
```

### showCloseButton & onDismiss

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `showCloseButton` | `Bool` | `true` (VLensVerificationView) / `false` (modifier) | Shows an "X" close button in the top-right corner |
| `onDismiss` | `(() -> Void)?` | `nil` | Called when user taps the close button |

> **Note:** When using `.vlensVerification()` modifier, `showCloseButton` defaults to `false` because the full-screen cover presentation handles dismissal automatically via the verification callbacks. When using `VLensVerificationView` directly, `showCloseButton` defaults to `true` to ensure users can always dismiss the view.

---

## UIKit Integration

Use `VLensManager` directly in UIKit apps:

```swift
import UIKit
import VLensLib

class VerificationViewController: UIViewController, VLensDelegate {

    private var vlensManager: VLensManager!

    func startVerification() {
        vlensManager = VLensManager(
            transactionId: UUID().uuidString,
            apiKey: "YOUR_API_KEY",
            secretKey: "",
            tenancyName: "YOUR_TENANCY_NAME",
            language: "en"
        )
        vlensManager.setAccessToken("YOUR_ACCESS_TOKEN")
        vlensManager.delegate = self
        vlensManager.present(on: self, withLivenessOnly: false)
    }

    // MARK: - VLensDelegate

    func didValidateSuccessfully(transactionId: String, userData: VerifyIdBackPost.DataClass?) {
        print("Success: \(transactionId)")
        print("Name: \(userData?.user?.fullName ?? "N/A")")
    }

    func didFailToValidate(transactionId: String, error: String) {
        print("Failed: \(error)")
    }
}
```

---

## Obtaining an Access Token

Before starting verification, obtain an access token from the VLens Login API:

```
POST https://api.vlenseg.com/api/DigitalIdentity/Login
```

**Headers:**

| Header | Value |
|--------|-------|
| `Content-Type` | `application/json` |
| `Accept` | `text/plain` |
| `ApiKey` | Your API key |
| `TenancyName` | Your tenancy name |

**Body:**

```json
{
  "geoLocation": { "latitude": "30", "longitude": "30" },
  "imei": "device_identifier",
  "phoneNumber": "+20XXXXXXXXXX",
  "password": "your_password",
  "smsProviders": 0
}
```

**Response:** Extract `data.accessToken` from the JSON response.

---

## Callbacks

### onSuccess / didValidateSuccessfully

Called when verification completes successfully. Provides:
- `transactionId` — The transaction identifier
- `userData` — A `VerifyIdBackPost.DataClass?` containing:
  - `user?.fullName` — Full name from the ID
  - `user?.idNumber` — National ID number
  - `idFrontData` — Front ID extracted data
  - `idBackData` — Back ID extracted data
  - `isVerificationProcessCompleted` — Whether all steps completed
  - `isDigitalIdentityVerified` — Whether identity was verified

### onFailure / didFailToValidate

Called when verification fails or is cancelled. Provides:
- `transactionId` — The transaction identifier
- `error` — Error description string

---

## Language Support

The SDK supports English and Arabic:

```swift
// English (default)
language: "en"

// Arabic
language: "ar"
```

---

## Support

For issues or inquiries, contact [mhamed@vlenseg.com](mailto:mhamed@vlenseg.com).

