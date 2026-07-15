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
        checkIfErrorExists()
    }
    
    @MainActor
    private func checkIfErrorExists() {
        // check if error exists in response
        guard let response = CachedData.shared.verifyBackResponse else {
            self.errorMessage = "error".localized
            return
        }
        if response.errorCode != nil || response.errorMessage != nil {
            self.errorMessage = resolveApiError(
                code: response.errorCode,
                fallback: response.errorMessage ?? "error".localized
            )
            return
        }

        let validationErrors = response.services?.validations?.validationErrors ?? []
        if !validationErrors.isEmpty {
            let firstError = validationErrors.first?.errors?.first
            self.errorMessage = resolveApiError(
                code: firstError?.code,
                fallback: firstError?.message ?? "error".localized
            )
            return
        }
        
        // Validate required ID fields are present
        // If idNumber is missing or empty, don't proceed to review screen
        let idNumber = response.data?.idFrontData?.idNumber ?? response.data?.idBackData?.idNumber
        if idNumber == nil || idNumber?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            self.errorMessage = "id_number_not_found".localized
            return
        }
        
        // Check that at least name is present from front data
        let name = response.data?.idFrontData?.name
        if name == nil || name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            self.errorMessage = "id_data_incomplete".localized
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
