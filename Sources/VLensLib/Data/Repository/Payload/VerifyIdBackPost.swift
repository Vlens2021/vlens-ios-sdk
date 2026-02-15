//
//  DigitalIdentityVerifyIdBack.swift
//  VLensSdkSample
//
//  Created by Mohamed Taher on 05/11/2024.
//

public struct VerifyIdBackPost {
    
    struct Request: Codable {
        let transactionID, image: String?
        let getExtractedData: Bool
        
        enum CodingKeys: String, CodingKey {
            case transactionID = "transaction_id"
            case image
            case getExtractedData
        }
    }
    
    // MARK: - Body
    struct Data: Codable, Sendable {
        let services: Services?
        let data: DataClass?
        let errorCode: Int?
        let errorMessage: String?
        
        enum CodingKeys: String, CodingKey {
            case services, data
            case errorCode = "error_code"
            case errorMessage = "error_message"
        }
    }
    
    // MARK: - DataClass
    public struct DataClass: Codable, Sendable {
        public let isVerificationProcessCompleted, isDigitalIdentityVerified: Bool?
        public let deviceInfo: String?
        public let user: User?
        public let idFrontData: IDFrontData?
        public let idBackData: IDBackData?
    }
    
    // MARK: - IDBackData
    public struct IDBackData: Codable, Sendable {
        public let maritalStatus, job, jobTitle, religion: String?
        public let husbandName, releaseDate, idExpiry, idNumber: String?
        public let gender: String?
    }
    
    // MARK: - IDFrontData
    public struct IDFrontData: Codable, Sendable {
        public let nameEnglish, firstNameEnglish, lastNamesEnglish, name: String?
        public let address, dateOfBirth, idNumber, gender: String?
        
        enum CodingKeys: String, CodingKey {
            case nameEnglish = "name_english"
            case firstNameEnglish = "first_name_english"
            case lastNamesEnglish = "last_names_english"
            case name, address, dateOfBirth, idNumber, gender
        }
    }
    
    // MARK: - User
    public struct User: Codable, Sendable {
        public let id: Int?
        public let name, surname, fullName, userName: String?
        public let emailAddress, phoneNumber, idNumber, address: String?
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
