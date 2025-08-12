//
//  NationalIdFrontViewModel.swift
//  VLensLib
//
//  Created by Mohamed Taher on 05/08/2025.
//

internal import Alamofire
import Foundation

class NationalIdFrontViewModel {
    
    @MainActor
    func postData(imageBase64: String) async throws {
        let accessToken = CachedData.shared.accessToken
        var url = "\(CachedData.shared.apiBaseUrl)/api/DigitalIdentity/verify/id/front"
        if accessToken.isEmpty {
            url = "\(CachedData.shared.apiBaseUrl)/v1/ocr/id/front"
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
        
        let request = VerifyIdFrontPost.Request(transactionID: CachedData.shared.transactionId, image: imageBase64, getExtractedData: true)
        let httpHeaders = HTTPHeaders(headers)
        let response = try await AF.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: httpHeaders
        )
        .serializingDecodable(VerifyIdFrontPost.Data.self)
        .value
        
        CachedData.shared.verifyFrontResponse = response
    }
}

extension NationalIdFrontViewModel: ValidationItemViewModel {
    
    func getStepIndex() -> Int {
        return 0
    }
    
    func getStepName() -> String {
        return "Front National ID Validation"
    }
}
