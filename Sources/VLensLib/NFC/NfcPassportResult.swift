import Foundation

struct NfcPassportResult {
    var authMethod: String = "NONE"
    var dg1Base64: String?
    var dg2Base64: String?
    var sodBase64: String?
    var dg1: DG1Data?
    var dg2: DG2Data?
    var error: String?

    struct DG1Data {
        let documentNumber: String
        let firstName: String
        let lastName: String
        let nationality: String
        let gender: String
        let dateOfBirth: String
        let dateOfExpiry: String
        let documentType: String
        let issuingState: String
    }

    struct DG2Data {
        let imageBase64: String
        let mimeType: String
        let width: Int
        let height: Int
    }
}
