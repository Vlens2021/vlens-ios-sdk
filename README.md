# VLens iOS SDK

VLens iOS SDK enables digital identity verification in iOS apps:
- National ID capture (front and back)
- Face liveness checks
- Face matching

Supports both SwiftUI and UIKit.

## Quick Install

Requirements:
- iOS 15+
- Swift 5.5+
- Xcode 13+

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

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/Vlens2021/vlens-ios-sdk
   ```
3. Select version **1.5.1** (or the latest release) and click **Add Package**.

### Info.plist

Add camera permission to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera is required for identity verification</string>
```

## Minimum Setup

Required inputs:
- transactionId
- apiKey
- secretKey (or empty string if using access token flow)
- tenancyName
- accessToken

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
| `showIdReviewPage` | `Bool` | ❌ | `true` | Show ID review page after capture |
| `enableSounds` | `Bool` | ❌ | `true` | Enable/disable SDK sounds |
| `clientLogoImage` | `UIImage?` | ❌ | `nil` | Custom client logo shown in the SDK |
| `colors` | `VLensColors` | ❌ | `.default` | UI color configuration for branding |

## Color Customization

The SDK exposes a full color system that lets you match the VLens UI to your app's branding. All colors are configured via `VLensColors`, which holds separate `VLensColorConfig` objects for light and dark mode.

### Color Roles

| Property | Role in the UI | Default |
|---|---|---|
| `accent` | Buttons, gif background circle tint | `#007AFF` |
| `primary` | Title labels, close button tint | `#000000` |
| `secondary` | Supporting text and secondary labels | `#666666` |
| `background` | Screen and container backgrounds | `#FFFFFF` |
| `dark` | Dark variant used for headings (dark mode) | `#1C1C1E` |
| `light` | Light variant used for subtle backgrounds | `#F2F2F7` |

### Usage

Pass a `VLensColors` instance when building your `VLensConfig`:

```swift
let colors = VLensColors(
    light: VLensColorConfig(
        accent: "#007AFF",      // buttons, background circle tint
        primary: "#1E3A5F",     // title text, close button
        secondary: "#666666",   // body and supporting text
        background: "#FFFFFF",  // screen backgrounds
        dark: "#1C1C1E",        // dark headings
        light: "#F2F2F7"        // subtle backgrounds
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

let config = VLensConfig(
    transactionId: "YOUR_TRANSACTION_ID",
    apiKey: "YOUR_API_KEY",
    secretKey: "YOUR_SECRET_KEY",
    tenancyName: "YOUR_TENANCY",
    accessToken: "YOUR_TOKEN",
    colors: colors
)
```

### Single Theme (Light Only)

If your app doesn't support dark mode, omit the dark parameter — the SDK falls back to the light config for both modes:

```swift
let colors = VLensColors(
    light: VLensColorConfig(
        accent: "#D4AF37",
        primary: "#2C3E50",
        secondary: "#7F8C8D",
        background: "#FFFFFF",
        dark: "#1C1C1E",
        light: "#F5F5F5"
    )
)
```

### Color Format

All color strings accept:
- 6-digit hex: `"#FF5733"` or `"FF5733"`
- 3-digit hex shorthand: `"#FFF"`
- 8-digit hex with alpha (ARGB): `"#80FF5733"`

### Where Each Color Appears

**`accent`**
- Primary action buttons (Scan ID, Start Scanning, Continue, Retry)
- Decorative background circle tint behind the ID / face icons on all screens

**`primary`**
- Title labels on all screens (Scan Your ID, Let's Verify Your Face, Scanning your ID, Verifying your identity)
- Close / cancel button tint

**`secondary`**
- Descriptive body text and tip labels

**`background`**
- Screen background color across all VLens views

**`dark`**
- Available for headings that require stronger contrast (used in review screens)

**`light`**
- Subtle container backgrounds (e.g., tips box background tint)

## Latest Release

Tag 1.5.1 includes:
- Datadog RUM and Logs integration for session tracking, screen views, and feature-level success/failure reporting
- Backend error messages are now shown as-is to the user instead of being mapped to SDK-defined strings — applies to liveness and ID back responses

## Support

For issues or inquiries: mhamed@vlenseg.com
