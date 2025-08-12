//
//  FaceValidationViewModel.swift
//  VLensSdkSample
//
//  Created by Mohamed Taher on 10/11/2024.
//


class FaceValidationViewModel {
    
    let currentType: FaceValidationTypes
    let stepName: String
    let stepIndex: Int
    
    var face = ""
    
    init(currentType: FaceValidationTypes, stepName: String, stepIndex: Int) {
        self.currentType = currentType
        self.stepName = stepName
        self.stepIndex = stepIndex
    }
    
    func getImageName() -> String {
        switch currentType {
        case .smile:
            return "Smile"
        case .blink:
            return "Blinking"
        case .headStraight:
            return "Looking Straight"
        case .turnHeadRight:
            return "Turned Right"
        case .turnHeadLeft:
            return "Turned Left"
        }
    }
    
    func getSoundFileName() -> String {
        switch currentType {
        case .smile:
            return "smile"
        case .blink:
            return "blink"
        case .headStraight:
            return "look_directly"
        case .turnHeadRight:
            return "right"
        case .turnHeadLeft:
            return "left"
        }
    }
    
    func getSoundFileNameAr() -> String {
        switch currentType {
        case .smile:
            return "smile_ar"
        case .blink:
            return "blink_ar"
        case .headStraight:
            return "look_directly_ar"
        case .turnHeadRight:
            return "right_ar"
        case .turnHeadLeft:
            return "left_ar"
        }
    }
    
}


extension FaceValidationViewModel: ValidationItemViewModel {
    func getStepIndex() -> Int {
        return stepIndex
    }
    
    func getStepName() -> String {
        return stepName
    }
}
