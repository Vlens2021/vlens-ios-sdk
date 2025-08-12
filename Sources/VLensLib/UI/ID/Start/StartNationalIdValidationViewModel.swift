//
//  StartNationalIdValidationViewModel.swift
//  VLensLib
//
//  Created by Mohamed Taher on 05/08/2025.
//

class StartNationalIdValidationViewModel {
    
}

extension StartNationalIdValidationViewModel: ValidationItemViewModel {
    func getStepIndex() -> Int {
        return 0
    }
    
    func getStepName() -> String {
        return "Start National Id Validation"
    }
}
