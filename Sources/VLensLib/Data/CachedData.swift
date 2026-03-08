//
//  CachedData.swift
//  VLens
//
//  Created by Mohamed Taher on 10/11/2024.
//

import UIKit

@MainActor 
class CachedData {
    
    static let shared = CachedData()
    private init() {}  
    
    // MARK: - Entry Point Properties
    var apiBaseUrl       : String   = "https://api.vlenseg.com"
    var apiKey           : String   = ""
    var secretKey        : String   = ""
    var tenancyName      : String   = ""
    var accessToken      : String   = ""
    var language         : String   = "en"
    var noOfRetries      : Int      = 5
    var allowAutoCapture : Bool     = false
    var allowNonTrueDepthFallback : Bool = false
    var colors           : VLensColors = .default
    
    // MARK: - Sound Control
    /// When true, SDK sounds are enabled. When false, all sounds are muted.
    var enableSounds     : Bool     = true
    
    // MARK: - Custom Branding
    /// Custom client logo image to be displayed instead of VLens logo
    var clientLogoImage  : UIImage? = nil
    
    // MARK: - ID Review Page
    /// When true, shows the ID review page after ID capture before proceeding to face validation
    var showIdReviewPage : Bool     = true
    
    // MARK: - Transaction Properties
    var transactionId = ""
    
    // MARK: - APIs Response
    var didGetVerifyFrontResponseSuccessfully: Bool? = nil
    var verifyFrontResponse: VerifyIdFrontPost.Data? = nil
    var verifyBackResponse: VerifyIdBackPost.Data? = nil
    var livenessResponse: VerifyLivenessMultiPost.Response? = nil
}
