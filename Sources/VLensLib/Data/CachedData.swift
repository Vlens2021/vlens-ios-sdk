//
//  CachedData.swift
//  VLens
//
//  Created by Mohamed Taher on 10/11/2024.
//

@MainActor 
class CachedData {
    
    static let shared = CachedData()
    private init() {}  
    
    // MARK: - Entry Point Properties
    var apiBaseUrl  : String   = "https://api.vlenseg.com"
    var apiKey      : String   = ""
    var secretKey   : String   = ""
    var tenancyName : String   = ""
    var accessToken : String   = ""
    var language    : String   = "en"
    var noOfRetries : Int      = 5
    
    // MARK: - Transaction Properties
    var transactionId = ""
    
    // MARK: - APIs Response
    var didGetVerifyFrontResponseSuccessfully: Bool? = nil
    var verifyFrontResponse: VerifyIdFrontPost.Data? = nil
    var verifyBackResponse: VerifyIdBackPost.Data? = nil
    var livenessResponse: VerifyLivenessMultiPost.Response? = nil
}
