import Foundation

/// Step view model for the passport photo-page OCR step.
/// The camera captures the MRZ zone; on success the extracted data
/// is stored in CachedData for the subsequent NFC scan step.
class PassportOcrViewModel: ValidationItemViewModel {

    private let stepIndex: Int

    init(stepIndex: Int) {
        self.stepIndex = stepIndex
    }

    func getStepIndex() -> Int { stepIndex }
    func getStepName() -> String { "passport_ocr" }
}
