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
3. Select version 1.3.3 (or latest).

Add camera permission in Info.plist:

<key>NSCameraUsageDescription</key>
<string>Camera is required for identity verification</string>

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

## Latest Release

Tag 1.3.3 includes recent stability and flow fixes across:
- Face verification and retry behavior
- Face start screen flow
- National ID start screen flow
- Validation main flow and related UI resources

## Support

For issues or inquiries: mhamed@vlenseg.com

