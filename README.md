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

Add via Swift Package Manager:
1. In Xcode, open File > Add Package Dependencies.
2. Use this URL: https://github.com/Vlens2021/vlens-ios-sdk
3. Select version 1.4.4 (or latest).

Add camera permission in Info.plist:

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

Common optional inputs:
- language (en or ar)
- withLivenessOnly
- allowAutoCapture
- allowNonTrueDepthFallback
- showIdReviewPage
- enableSounds
- showCloseButton
- clientLogoImage
- colors

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

Tag 1.4.4 includes:
- Decorative background circle (gif_background) now shown behind the ID and face icons on all start and loading screens, tinted with the configured `accent` color using `srcATop` blend mode
- All title labels now respect the `primary` color configuration instead of hardcoded XIB colors
- Full color customization applied consistently across: Start National ID, Start Face Validation, Scanning your ID (loading), and Verifying your identity (loading) screens

## Support

For issues or inquiries: mhamed@vlenseg.com
