//
//  ApiResponse.swift
//  VLens
//
//  Created by Mohamed Taher on 27/07/2023.
//

import Foundation

// MARK: - Request
class ApiResponse<T: Codable & Sendable>: Codable, @unchecked Sendable {
    let data: T?
    let services: Services?
    let errorCode: Int?
    let errorMessage: String?

    init(data: T?, services: Services?, errorCode: Int?, errorMessage: String?) {
        self.data = data
        self.services = services
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
    
    // MARK: - Services
    struct Services: Codable {
        let classification: Classification?
        let liveness, aml, src: String?
        let validations: Validations?
        let spoofing: String?

        enum CodingKeys: String, CodingKey {
            case classification, liveness
            case aml = "AML"
            case src = "SRC"
            case validations = "Validations"
            case spoofing
        }
    }

    // MARK: - Classification
    struct Classification: Codable {
        let docType: String?

        enum CodingKeys: String, CodingKey {
            case docType = "doc_type"
        }
    }

    // MARK: - Validations
    struct Validations: Codable {
        let validationErrors: [ValidationError]?

        enum CodingKeys: String, CodingKey {
            case validationErrors = "validation_errors"
        }
    }
    
    // MARK: - ValidationError
    struct ValidationError: Codable {
        let field, value: String?
        let errors: [Error]?
    }

    // MARK: - Error
    struct Error: Codable {
        let message: String?
        let code: Int?
    }
    
    enum CodingKeys: String, CodingKey {
        case data
        case services
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
    
    func toApiErrorResponse() -> ApiResponse<String> {
        let userErrorMessage = errorMessage ?? "Something went wrong" // TODO: - Handle Vlens error messages
        return ApiResponse<String>(data: userErrorMessage, services: nil, errorCode: errorCode, errorMessage: errorMessage)
    }
    
    static func from(description: String? = nil) -> ApiResponse {
        return ApiResponse(data: nil, services: nil, errorCode: nil, errorMessage: description)
    }
}
