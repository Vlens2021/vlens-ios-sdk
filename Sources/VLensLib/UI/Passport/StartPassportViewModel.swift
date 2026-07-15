import Foundation

class StartPassportViewModel: ValidationItemViewModel {
    private let stepIndex: Int
    init(stepIndex: Int) { self.stepIndex = stepIndex }
    func getStepIndex() -> Int { stepIndex }
    func getStepName() -> String { "start_passport" }
}
