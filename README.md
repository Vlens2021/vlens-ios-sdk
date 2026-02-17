# VLens iOS SDK

VLens iOS SDK provides digital identity verification for iOS apps — including national ID capture (front & back), liveness detection, and face matching. It supports both **SwiftUI** and **UIKit** integration.

---

## Installation

### Requirements
- **iOS**: 15.0 or later
- **Swift**: 6.0 or later
- **Xcode**: 16.0 or later

### Swift Package Manager
To add VLensLib to your project using Swift Package Manager:

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/Vlens2021/vlens-ios-sdk
   ```
3. Select the desired version or branch and add the package.

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

