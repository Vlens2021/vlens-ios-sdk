import Foundation

class NfcScanViewModel: ValidationItemViewModel {

    private let stepIndex: Int

    init(stepIndex: Int) {
        self.stepIndex = stepIndex
    }

    func getStepIndex() -> Int { stepIndex }
    func getStepName() -> String { "nfc_scan" }
}
