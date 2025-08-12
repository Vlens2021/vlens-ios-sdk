//
//  NationalIdBackViewModel.swift
//  VLensLib
//
//  Created by Mohamed Taher on 05/08/2025.
//

internal import Alamofire
import Foundation

class NationalIdBackViewModel {
    
    var errorMessage: String? = nil
    
    @MainActor
    func postData(imageBase64: String) async throws {
        let accessToken = CachedData.shared.accessToken
        var url = "\(CachedData.shared.apiBaseUrl)/api/DigitalIdentity/verify/id/back"
        if accessToken.isEmpty {
            url = "\(CachedData.shared.apiBaseUrl)/v1/ocr/id/back"
        }
        
        let headers = [
            "Content-Type"                  : "application/json",
            "Accept"                        : "*/*",
            "Accept_Language"               : "en",
            "ApiKey"                        : CachedData.shared.apiKey,
            "TenancyName"                   : CachedData.shared.tenancyName,
            "X-Request-Id"                  : UUID().uuidString,
            "Authorization"                 : "Bearer \(CachedData.shared.accessToken)"
        ]
        
        let request = VerifyIdBackPost.Request(transactionID: CachedData.shared.transactionId, image: imageBase64, getExtractedData: true)
        let httpHeaders = HTTPHeaders(headers)
        let response = try await AF.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: httpHeaders
        )
        .serializingDecodable(VerifyIdBackPost.Data.self)
        .value
        
        CachedData.shared.verifyBackResponse = response
        if let errorMessage = response.errorMessage {
            self.errorMessage = errorMessage
        }
        
        let validationErrors = response.services?.validations?.validationErrors ?? []
        if !validationErrors.isEmpty {
            self.errorMessage = validationErrors.first?.errors?.first?.message  ?? "error".localized
        }
    }
    
}

extension NationalIdBackViewModel: ValidationItemViewModel {
    func getStepIndex() -> Int {
        return 0
    }
    
    func getStepName() -> String {
        return "Back National ID Validation"
    }
}
