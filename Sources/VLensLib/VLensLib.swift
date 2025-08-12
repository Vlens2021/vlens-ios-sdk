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
    
    public init(transactionId: String, apiKey: String, secretKey: String, tenancyName: String, language: String = "en", noOfRetries: Int = 5) {
        CachedData.shared.transactionId = transactionId
        CachedData.shared.apiKey        = apiKey
        CachedData.shared.secretKey     = secretKey
        CachedData.shared.tenancyName   = tenancyName
        CachedData.shared.language      = language
        CachedData.shared.noOfRetries   = noOfRetries
    }
    
    public weak var delegate: VLensDelegate? = nil
    
    
    public func setAccessToken(_ accessToken: String) {
        CachedData.shared.accessToken = accessToken
    }
    
    public func present(on viewController: UIViewController, withLivenessOnly: Bool = false) {
        debugPrint("Vlens presented :D")
        
        let validationViewController = ValidationMainViewController.instance(withLivenessOnly: withLivenessOnly)
        validationViewController.delegate = delegate
        validationViewController.modalPresentationStyle = .fullScreen
        viewController.present(validationViewController, animated: true)
    }
}
