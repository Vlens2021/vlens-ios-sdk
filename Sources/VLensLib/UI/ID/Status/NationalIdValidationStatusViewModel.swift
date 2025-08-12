//
//  NationalIdValidationStatusViewModel.swift
//  VLensLib
//
//  Created by Mohamed Taher on 05/08/2025.
//

class NationalIdValidationStatusViewModel {
    
}

extension NationalIdValidationStatusViewModel: ValidationItemViewModel {
    func getStepIndex() -> Int {
        return 0
    }
    
    func getStepName() -> String {
        return "NationalId Validation Status"
    }
}
