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
//        if let errorMessage = response.errorMessage {
//            self.errorMessage = errorMessage
//        }
//        
//        let validationErrors = response.services?.validations?.validationErrors ?? []
//        if !validationErrors.isEmpty {
//            self.errorMessage = validationErrors.first?.errors?.first?.message  ?? "error".localized
//        }
        
        checkIfErrorExists()
    }
    
    @MainActor
    private func checkIfErrorExists() {
        // check if error exists in front response
        guard let frontResponse = CachedData.shared.verifyBackResponse else {
            self.errorMessage = "error".localized
            return
        }
        if let errorMessage = frontResponse.errorMessage {
            self.errorMessage = errorMessage
            return
        }
        
        let fValidationErrors = frontResponse.services?.validations?.validationErrors ?? []
        if !fValidationErrors.isEmpty {
            self.errorMessage = fValidationErrors.first?.errors?.first?.message  ?? "error".localized
            return
        }
        
        // check if error exists in back response
        guard let backResponse = CachedData.shared.verifyBackResponse else {
            self.errorMessage = "error".localized
            return
        }
        if let errorMessage = backResponse.errorMessage {
            self.errorMessage = errorMessage
            return
        }
        
        let bValidationErrors = backResponse.services?.validations?.validationErrors ?? []
        if !bValidationErrors.isEmpty {
            self.errorMessage = bValidationErrors.first?.errors?.first?.message  ?? "error".localized
            return
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
