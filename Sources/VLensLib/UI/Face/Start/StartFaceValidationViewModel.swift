//
//  StartFaceValidationViewModel.swift
//  VLensLib
//
//  Created by Mohamed Taher on 10/08/2025.
//

class StartFaceValidationViewModel {
    
}

extension StartFaceValidationViewModel: ValidationItemViewModel {
    func getStepIndex() -> Int {
        return 0
    }
    
    func getStepName() -> String {
        return "Back National ID Validation"
    }
}
