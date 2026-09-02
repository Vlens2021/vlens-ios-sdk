// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

public protocol VLensDelegate: AnyObject {
    func didValidateSuccessfully(transactionId: String, userData: VerifyIdBackPost.DataClass?)
    func didFailToValidate(transactionId: String, error: String)
}

// MARK: - VLens Entry Point Class
@MainActor
public class VLensManager {
    
    public init(transactionId: String, apiKey: String, secretKey: String, tenancyName: String, language: String = "en", noOfRetries: Int = 5, allowAutoCapture: Bool = true, colors: VLensColors = .default, enableSounds: Bool = true, clientLogoImage: UIImage? = nil, showIdReviewPage: Bool = true, customErrorMessages: [ApiError] = []) {
        DatadogService.shared.initialize()
        CachedData.shared.transactionId         = transactionId
        CachedData.shared.apiKey                = apiKey
        CachedData.shared.secretKey             = secretKey
        CachedData.shared.tenancyName           = tenancyName
        CachedData.shared.language              = language
        CachedData.shared.noOfRetries           = noOfRetries
        CachedData.shared.allowAutoCapture      = allowAutoCapture
        CachedData.shared.colors                = colors
        CachedData.shared.enableSounds          = enableSounds
        CachedData.shared.clientLogoImage       = clientLogoImage
        CachedData.shared.showIdReviewPage      = showIdReviewPage
        CachedData.shared.customErrorMessages   = customErrorMessages
        DatadogService.shared.applyTenancyAttribute(tenancyName: tenancyName)
    }
    
    public weak var delegate: VLensDelegate? = nil
    
    /// Sets the UI color configuration for branding.
    ///
    /// - Parameter colors: The color configuration to use
    public func setColors(_ colors: VLensColors) {
        CachedData.shared.colors = colors
    }
    
    /// Sets whether SDK sounds are enabled.
    ///
    /// - Parameter enabled: When true, sounds are enabled. When false, all sounds are muted.
    public func setEnableSounds(_ enabled: Bool) {
        CachedData.shared.enableSounds = enabled
    }
    
    /// Sets a custom client logo image to display instead of VLens logo.
    ///
    /// - Parameter image: The logo image to display. Pass nil to use the default VLens logo.
    public func setClientLogoImage(_ image: UIImage?) {
        CachedData.shared.clientLogoImage = image
    }
    
    /// Sets whether to show the ID review page after ID capture.
    ///
    /// - Parameter show: When true, shows the ID review page. When false, proceeds directly to face validation.
    public func setShowIdReviewPage(_ show: Bool) {
        CachedData.shared.showIdReviewPage = show
    }
    
    public func setAccessToken(_ accessToken: String) {
        CachedData.shared.accessToken = accessToken
    }

    /// Overrides SDK error messages for specific error codes.
    /// Custom entries take priority over the built-in defaults.
    public func setCustomErrorMessages(_ messages: [ApiError]) {
        CachedData.shared.customErrorMessages = messages
    }

    public func present(on viewController: UIViewController, withLivenessOnly: Bool = false) {
        debugPrint("Vlens presented :D")
        
        let validationViewController = ValidationMainViewController.instance(withLivenessOnly: withLivenessOnly)
        validationViewController.delegate = delegate
        validationViewController.modalPresentationStyle = .fullScreen
        viewController.present(validationViewController, animated: true)
    }
}
