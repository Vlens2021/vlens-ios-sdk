import Foundation
import CoreNFC
import NFCPassportReader

/// Wraps AndyQ/NFCPassportReader.
/// readPassport() MUST be called on the main thread — NFCTagReaderSession requires it.
final class NfcPassportReader {

    // Retained for the full duration of the scan — mirrors the RN SDK pattern.
    private var passportReader: PassportReader?

    // MARK: - Public

    var isNfcAvailable: Bool {
        NFCTagReaderSession.readingAvailable
    }

    /// Reads the passport chip and returns a populated NfcPassportResult.
    /// Throws on authentication failure or unrecoverable NFC error.
    @MainActor
    func readPassport(
        documentNumber: String,
        dateOfBirth: String,
        expiryDate: String
    ) async throws -> NfcPassportResult {

        NfcLogStore.shared.clear()

        guard NFCTagReaderSession.readingAvailable else {
            NfcLogStore.shared.add("E", "NFC", "NFCTagReaderSession.readingAvailable = false")
            throw NfcReaderError.notAvailable
        }

        let mrzKey = buildMrzKey(documentNumber: documentNumber,
                                  dateOfBirth: dateOfBirth,
                                  expiryDate: expiryDate)
        NfcLogStore.shared.add("D", "MRZ", "mrzKey='\(mrzKey)' (\(mrzKey.count) chars)")
        NfcLogStore.shared.add("D", "NFC", "NFCTagReaderSession.readingAvailable=true")

        let reader = PassportReader()
        passportReader = reader  // Strong reference held for the entire scan — matches RN SDK

        NfcLogStore.shared.add("D", "SESSION", "Starting — PACE first, BAC fallback")

        do {
            let passport = try await reader.readPassport(
                mrzKey: mrzKey,
                tags: [.DG1, .DG2, .SOD],
                skipCA: true,
                customDisplayMessage: { msg in
                    switch msg {
                    case .requestPresentPassport:
                        NfcLogStore.shared.add("D", "SESSION", "ACTIVE — hold top of iPhone against passport chip")
                        return "Hold the top of your phone flat against the passport chip"
                    case .authenticatingWithPassport(let p):
                        NfcLogStore.shared.add("D", "AUTH", "Authenticating \(p)%")
                        return nil
                    case .readingDataGroupProgress(let dg, let p):
                        NfcLogStore.shared.add("D", "READ", "\(dg.getName()) \(p)%")
                        return nil
                    case .successfulRead:
                        NfcLogStore.shared.add("D", "NFC", "Read complete")
                        return nil
                    @unknown default:
                        return nil
                    }
                }
            )

            let method = passport.PACEStatus == .success ? "PACE" : "BAC"
            NfcLogStore.shared.add("D", "AUTH", "method:\(method)  PACE:\(passport.PACEStatus)  BAC:\(passport.BACStatus)")
            passportReader = nil
            return mapToResult(passport, authMethod: method)

        } catch {
            NfcLogStore.shared.add("E", "NFC", "Failed: \(error.localizedDescription)")
            passportReader = nil
            throw error
        }
    }

    func cancel() {
        NfcLogStore.shared.add("D", "SESSION", "Cancelled")
        passportReader = nil
    }

    // MARK: - Private — result mapping

    private func mapToResult(_ passport: NFCPassportModel, authMethod: String) -> NfcPassportResult {
        var result = NfcPassportResult()
        result.authMethod = authMethod

        // DG1 — MRZ data
        if let dg1 = passport.dataGroupsRead[.DG1] {
            result.dg1Base64 = Data(dg1.data).base64EncodedString()
            result.dg1 = NfcPassportResult.DG1Data(
                documentNumber: passport.documentNumber ?? "",
                firstName:      passport.firstName ?? "",
                lastName:       passport.lastName ?? "",
                nationality:    passport.nationality ?? "",
                gender:         passport.gender ?? "",
                dateOfBirth:    passport.dateOfBirth ?? "",
                dateOfExpiry:   passport.documentExpiryDate ?? "",
                documentType:   passport.documentType ?? "",
                issuingState:   passport.issuingAuthority ?? ""
            )
            NfcLogStore.shared.add("D", "DG1", "\(dg1.data.count) bytes — \(passport.documentNumber ?? "?")")
        } else {
            result.error = "DG1 not available"
            NfcLogStore.shared.add("W", "DG1", "not read")
        }

        // DG2 — face photo
        if let dg2 = passport.dataGroupsRead[.DG2] {
            result.dg2Base64 = Data(dg2.data).base64EncodedString()
            if let img = passport.passportImage, let jpeg = img.jpegData(compressionQuality: 0.9) {
                result.dg2 = NfcPassportResult.DG2Data(
                    imageBase64: jpeg.base64EncodedString(),
                    mimeType:    "image/jpeg",
                    width:       Int(img.size.width),
                    height:      Int(img.size.height)
                )
                NfcLogStore.shared.add("D", "DG2", "\(dg2.data.count) bytes  \(Int(img.size.width))x\(Int(img.size.height))")
            } else {
                NfcLogStore.shared.add("W", "DG2", "read but face image extraction failed")
            }
        } else {
            NfcLogStore.shared.add("W", "DG2", "not read")
        }

        // SOD — security object
        if let sod = passport.dataGroupsRead[.SOD] {
            result.sodBase64 = Data(sod.data).base64EncodedString()
            NfcLogStore.shared.add("D", "SOD", "\(sod.data.count) bytes")
        } else {
            NfcLogStore.shared.add("W", "SOD", "not read")
        }

        return result
    }

    // MARK: - Private — MRZ key (ICAO 9303)

    private func buildMrzKey(documentNumber: String, dateOfBirth: String, expiryDate: String) -> String {
        let doc = documentNumber.padding(toLength: 9, withPad: "<", startingAt: 0)
        return doc        + checkDigit(doc)
             + dateOfBirth + checkDigit(dateOfBirth)
             + expiryDate  + checkDigit(expiryDate)
    }

    private func checkDigit(_ s: String) -> String {
        let w = [7, 3, 1]
        var total = 0
        for (i, c) in s.uppercased().enumerated() {
            guard let ascii = c.asciiValue else { continue }
            let v: Int
            switch ascii {
            case 48...57: v = Int(ascii - 48)      // 0–9
            case 65...90: v = Int(ascii - 55)      // A–Z → 10–35
            default:      v = 0                    // '<' → 0
            }
            total += v * w[i % 3]
        }
        return String(total % 10)
    }
}

enum NfcReaderError: LocalizedError {
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "NFC is not available on this device. NFC requires an iPhone 7 or later with iOS 13+."
        }
    }
}
