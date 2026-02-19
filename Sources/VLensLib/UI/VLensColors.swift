//
//  VLensColors.swift
//  VLensLib
//
//  UI customization colors for VLens SDK.
//  Mirrors the Android SDK's color configuration for cross-platform consistency.
//

import UIKit
import SwiftUI

// MARK: - Color Configuration

/// Configuration for a single color theme (light or dark mode).
///
/// All color properties accept hex strings (e.g., "#FF5733" or "FF5733") or
/// standard color names.
public struct VLensColorConfig: Sendable {
    /// Accent color for highlights and secondary actions
    public let accent: String
    /// Primary color for main buttons, headers, and key UI elements
    public let primary: String
    /// Secondary color for supporting elements
    public let secondary: String
    /// Background color for screens and containers
    public let background: String
    /// Dark variant color
    public let dark: String
    /// Light variant color
    public let light: String
    
    /// Creates a color configuration.
    ///
    /// - Parameters:
    ///   - accent: Accent color hex (e.g., "#007AFF")
    ///   - primary: Primary color hex (e.g., "#000000")
    ///   - secondary: Secondary color hex (e.g., "#666666")
    ///   - background: Background color hex (e.g., "#FFFFFF")
    ///   - dark: Dark variant hex (e.g., "#1C1C1E")
    ///   - light: Light variant hex (e.g., "#F2F2F7")
    public init(
        accent: String = "#007AFF",
        primary: String = "#000000",
        secondary: String = "#666666",
        background: String = "#FFFFFF",
        dark: String = "#1C1C1E",
        light: String = "#F2F2F7"
    ) {
        self.accent = accent
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.dark = dark
        self.light = light
    }
}

/// Colors configuration supporting both light and dark mode themes.
///
/// Use this to customize the VLens SDK UI to match your app's branding.
///
/// **Example:**
/// ```swift
/// let colors = VLensColors(
///     light: VLensColorConfig(
///         accent: "#007AFF",
///         primary: "#1E3A5F",
///         secondary: "#666666",
///         background: "#FFFFFF",
///         dark: "#1C1C1E",
///         light: "#F2F2F7"
///     ),
///     dark: VLensColorConfig(
///         accent: "#0A84FF",
///         primary: "#FFFFFF",
///         secondary: "#ABABAB",
///         background: "#1C1C1E",
///         dark: "#000000",
///         light: "#2C2C2E"
///     )
/// )
/// ```
public struct VLensColors: Sendable {
    /// Light mode color configuration
    public let light: VLensColorConfig
    /// Dark mode color configuration
    public let dark: VLensColorConfig
    
    /// Creates a colors configuration with light and dark themes.
    ///
    /// - Parameters:
    ///   - light: Color configuration for light mode
    ///   - dark: Color configuration for dark mode
    public init(
        light: VLensColorConfig = VLensColorConfig(),
        dark: VLensColorConfig = VLensColorConfig(
            accent: "#0A84FF",
            primary: "#FFFFFF",
            secondary: "#ABABAB",
            background: "#1C1C1E",
            dark: "#000000",
            light: "#2C2C2E"
        )
    ) {
        self.light = light
        self.dark = dark
    }
    
    /// Default VLens colors (blue accent with system defaults)
    public static let `default` = VLensColors()
}

// MARK: - UIColor Extension

extension UIColor {
    /// Creates a UIColor from a hex string.
    ///
    /// - Parameter hex: Hex color string (e.g., "#FF5733", "FF5733", "#FFF")
    /// - Returns: UIColor or nil if parsing fails
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        
        var r, g, b, a: CGFloat
        
        switch length {
        case 3: // RGB (12-bit)
            r = CGFloat((rgb & 0xF00) >> 8) / 15.0
            g = CGFloat((rgb & 0x0F0) >> 4) / 15.0
            b = CGFloat(rgb & 0x00F) / 15.0
            a = 1.0
        case 6: // RGB (24-bit)
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8: // ARGB (32-bit)
            a = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            r = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: - Color Extension

@available(iOS 13.0, *)
extension Color {
    /// Creates a Color from a hex string.
    ///
    /// - Parameter hex: Hex color string (e.g., "#FF5733", "FF5733")
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else {
            return nil
        }
        self.init(uiColor)
    }
}

// MARK: - VLensColorConfig UIColor Accessors

extension VLensColorConfig {
    /// Accent color as UIColor
    public var accentColor: UIColor {
        UIColor(hex: accent) ?? .systemBlue
    }
    
    /// Primary color as UIColor
    public var primaryColor: UIColor {
        UIColor(hex: primary) ?? .label
    }
    
    /// Secondary color as UIColor
    public var secondaryColor: UIColor {
        UIColor(hex: secondary) ?? .secondaryLabel
    }
    
    /// Background color as UIColor
    public var backgroundColor: UIColor {
        UIColor(hex: background) ?? .systemBackground
    }
    
    /// Dark variant as UIColor
    public var darkColor: UIColor {
        UIColor(hex: dark) ?? .darkGray
    }
    
    /// Light variant as UIColor
    public var lightColor: UIColor {
        UIColor(hex: light) ?? .lightGray
    }
}

// MARK: - Current Theme Helper

extension VLensColors {
    /// Returns the appropriate color config based on the current interface style.
    ///
    /// - Parameter traitCollection: The trait collection to check (defaults to current)
    /// - Returns: Light or dark color config based on the interface style
    public func current(for traitCollection: UITraitCollection = .current) -> VLensColorConfig {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return dark
        case .light, .unspecified:
            return light
        @unknown default:
            return light
        }
    }
}
