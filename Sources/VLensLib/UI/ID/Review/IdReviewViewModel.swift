//
//  IdReviewViewModel.swift
//  VLensLib
//
//  Created by VLens on 08/03/2026.
//

import Foundation

@MainActor
class IdReviewViewModel {
    
    var frontData: VerifyIdBackPost.IDFrontData? {
        return CachedData.shared.verifyBackResponse?.data?.idFrontData
    }
    
    var backData: VerifyIdBackPost.IDBackData? {
        return CachedData.shared.verifyBackResponse?.data?.idBackData
    }
    
    var isDigitalIdentityVerified: Bool {
        return CachedData.shared.verifyBackResponse?.data?.isDigitalIdentityVerified ?? false
    }
    
    // MARK: - Formatted Front Data
    
    var name: String {
        return frontData?.name ?? "-"
    }
    
    var nameEnglish: String {
        return frontData?.nameEnglish ?? "-"
    }
    
    var address: String {
        return frontData?.address ?? "-"
    }
    
    var dateOfBirth: String {
        guard let dateString = frontData?.dateOfBirth else { return "-" }
        return formatDate(dateString)
    }
    
    var idNumber: String {
        return frontData?.idNumber ?? "-"
    }
    
    var gender: String {
        return frontData?.gender ?? backData?.gender ?? "-"
    }
    
    // MARK: - Formatted Back Data
    
    var maritalStatus: String {
        return backData?.maritalStatus ?? "-"
    }
    
    var job: String {
        return backData?.job ?? backData?.jobTitle ?? "-"
    }
    
    var religion: String {
        return backData?.religion ?? "-"
    }
    
    var releaseDate: String {
        guard let dateString = backData?.releaseDate else { return "-" }
        return formatDate(dateString)
    }
    
    var expiryDate: String {
        guard let dateString = backData?.idExpiry else { return "-" }
        return formatDate(dateString)
    }
    
    var husbandName: String {
        return backData?.husbandName ?? "-"
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"
            return outputFormatter.string(from: date)
        }
        
        // Try alternative format
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
}

extension IdReviewViewModel: ValidationItemViewModel {
    func getStepIndex() -> Int {
        return 3  // After NationalIdBack (index 2)
    }
    
    func getStepName() -> String {
        return "ID Review"
    }
}
