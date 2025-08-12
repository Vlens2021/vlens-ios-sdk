//
//  VerifyLivenessMultiPost.swift
//  VLensSdkSample
//
//  Created by Mohamed Taher on 05/11/2024.
//

struct VerifyLivenessMultiPost {
    
    struct Request: Codable {
        let transactionID, face1, face2, face3: String?

        enum CodingKeys: String, CodingKey {
            case transactionID = "transaction_id"
            case face1 = "face_1"
            case face2 = "face_2"
            case face3 = "face_3"
        }
    }
    
    struct Response: Codable {
        let services: Services?
        let data: Data?
        let errorCode: Int?
        let errorMessage: String?
    }
    
    struct Data: Codable {
        let isDigitalIdentityVerified: Bool?
        let isVerificationProcessCompleted: Bool?
//        let deviceInfo, user: JSONNull?
    }
    
    // MARK: - Services
    public struct Services: Codable, Sendable {
        let validations: Validations?
        let spoofing: Spoofing?
        let classification: Classification?
        let liveness: Bool?
        let aml: Aml?
        let src: Src?
        
        enum CodingKeys: String, CodingKey {
            case validations = "Validations"
            case spoofing, classification, liveness
            case aml = "AML"
            case src = "SRC"
        }
    }
    
    // MARK: - Aml
    public struct Aml: Codable, Sendable {
        let amlMatched: Bool?
        let data: [Datum]?
        
        enum CodingKeys: String, CodingKey {
            case amlMatched = "AML_matched"
            case data
        }
    }
    
    // MARK: - Datum
    public struct Datum: Codable, Sendable {
        let caseNo: String?
        let caseYear: Int?
        let recordDate, fullName, idNumber, dateOfBirth: String?
        let score: String?
    }
    
    // MARK: - Classification
    public struct Classification: Codable, Sendable {
        let docType: String?
        
        enum CodingKeys: String, CodingKey {
            case docType = "doc_type"
        }
    }
    
    // MARK: - Spoofing
    public struct Spoofing: Codable, Sendable {
        let fake: Bool?
    }
    
    // MARK: - Src
    public struct Src: Codable, Sendable {
        let isValid: Bool?
        let errorCode: Int?
        let errorKey, errorMessage: String?
    }
    
    // MARK: - Validations
    public struct Validations: Codable, Sendable {
        let validationErrors: [ValidationError]?
        
        enum CodingKeys: String, CodingKey {
            case validationErrors = "validation_errors"
        }
    }
    
    // MARK: - ValidationError
    public struct ValidationError: Codable, Sendable {
        let field, value: String?
        let errors: [Error]?
    }
    
    // MARK: - Error
    public struct Error: Codable, Sendable {
        let code: Int?
        let message: String?
    }
}
