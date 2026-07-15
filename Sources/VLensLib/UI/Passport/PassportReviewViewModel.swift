import Foundation

class PassportReviewViewModel: ValidationItemViewModel {
    private let stepIndex: Int
    init(stepIndex: Int) { self.stepIndex = stepIndex }
    func getStepIndex() -> Int { stepIndex }
    func getStepName() -> String { "passport_review" }
}
