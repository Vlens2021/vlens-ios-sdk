import Foundation

struct NfcVerifyPost {

    // MARK: - Request (snake_case per backend spec)
    struct Request: Codable {
        let transactionId: String
        let dg1Base64: String
        let dg2Base64: String
        let sodBase64: String
        let authType: String

        enum CodingKeys: String, CodingKey {
            case transactionId = "transaction_id"
            case dg1Base64     = "dg1_base64"
            case dg2Base64     = "dg2_base64"
            case sodBase64     = "sod_base64"
            case authType      = "auth_type"
        }
    }

    // MARK: - Envelope
    struct Response: Codable {
        let errorCode: Int?
        let errorMessage: String?
        let data: DataClass?

        enum CodingKeys: String, CodingKey {
            case errorCode    = "error_code"
            case errorMessage = "error_message"
            case data
        }
    }

    // MARK: - Payload
    struct DataClass: Codable {
        let isValid: Bool?
        let signatureValid: Bool?
        let contentAuthenticityValid: Bool?
        let dg1HashValid: Bool?
        let dg2HashValid: Bool?
        let faceMatchPassed: Bool?
        let faceMatchScore: Double?
        let failedStep: String?
        let failureReason: String?
        let fullName: String?
        let dateOfBirth: String?
        let expiryDate: String?
        let nationality: String?
        let issuingCountry: String?
        let dscSubject: String?
        let dscExpiry: String?
        let dscCountryCode: String?
        let countrySigner: CountrySigner?
    }

    struct CountrySigner: Codable {
        let dscValid: Bool?
        let cscaFoundInSod: Bool?
        let cscaChainValid: Bool?
        let cscaSignatureValid: Bool?
    }
}
