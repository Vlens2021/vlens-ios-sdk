import Foundation

struct VerifyPassportOcrPost {

    struct Request: Codable {
        let transactionId: String
        let image: String
        let getExtractedData: Bool

        enum CodingKeys: String, CodingKey {
            case transactionId   = "transaction_id"
            case image
            case getExtractedData
        }
    }

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

    // Field names match /api/DigitalIdentity/verify/passport/scan response exactly.
    // Note: Date_of_Birth and Date_of_Expiry use mixed case as returned by the API.
    struct DataClass: Codable {
        let passportNumber: String?
        let name: String?
        let dateOfBirth: String?
        let expiryDate: String?
        let nationality: String?
        let countryCode: String?
        let gender: String?
        let documentType: String?
        /// False when the passport's country of issue doesn't support NFC chip reading.
        /// The NFC step must be skipped when this is false.
        let ePassportSupported: Bool?

        enum CodingKeys: String, CodingKey {
            case passportNumber    = "passport_no"
            case name
            case dateOfBirth       = "Date_of_Birth"
            case expiryDate        = "Date_of_Expiry"
            case nationality
            case countryCode       = "country_code"
            case gender
            case documentType      = "doc_Type"
            case ePassportSupported = "ePassport_supported"
        }
    }
}
