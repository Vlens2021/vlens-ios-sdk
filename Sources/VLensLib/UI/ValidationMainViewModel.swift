//
//  ValidationMainViewModel.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import Foundation
internal import Alamofire

class ValidationMainViewModel {
    
    var withLivenessOnly = false
    
    var isDigitalIdentityVerified = false
    var validationErrorMessage: String? = nil
    
    var face1ViewModel: FaceValidationViewModel? = nil
    var face2ViewModel: FaceValidationViewModel? = nil
    var face3ViewModel: FaceValidationViewModel? = nil
    
    var stepsViewModels: [ValidationItemViewModel] = []
    var currentStepIndex = 0
    var faceStepIndex = 0
    
    @MainActor
    func initData() {
        // generate three random numbers from 1 to 5
        let noOfFlows = FaceValidationTypes.validFlows.count
        let randomFlowIndex = Int.random(in: 0..<noOfFlows)
        let selectedFlow = FaceValidationTypes.validFlows[randomFlowIndex]

        let face1Type = selectedFlow[0]
        let face2Type = selectedFlow[1]
        let face3Type = selectedFlow[2]

        // create steps view models
        if withLivenessOnly {
            faceStepIndex = 1
            // create face view models
            self.face1ViewModel = FaceValidationViewModel(currentType: face1Type, stepName: face1Type.title, stepIndex: 1)
            self.face2ViewModel = FaceValidationViewModel(currentType: face2Type, stepName: face2Type.title, stepIndex: 2)
            self.face3ViewModel = FaceValidationViewModel(currentType: face3Type, stepName: face3Type.title, stepIndex: 3)

            stepsViewModels = [
                StartFaceValidationViewModel(),
                face1ViewModel!,
                face2ViewModel!,
                face3ViewModel!
            ]
        } else {
            // Determine steps based on whether ID review page is shown
            let showIdReview = CachedData.shared.showIdReviewPage

            if showIdReview {
                faceStepIndex = 5  // After IdReview
                // create face view models
                self.face1ViewModel = FaceValidationViewModel(currentType: face1Type, stepName: face1Type.title, stepIndex: 5)
                self.face2ViewModel = FaceValidationViewModel(currentType: face2Type, stepName: face2Type.title, stepIndex: 6)
                self.face3ViewModel = FaceValidationViewModel(currentType: face3Type, stepName: face3Type.title, stepIndex: 7)

                stepsViewModels = [
                    StartNationalIdValidationViewModel(),
                    NationalIdFrontViewModel(),
                    NationalIdBackViewModel(),
                    IdReviewViewModel(),  // New ID Review step
                    StartFaceValidationViewModel(),
                    face1ViewModel!,
                    face2ViewModel!,
                    face3ViewModel!
                ]
            } else {
                faceStepIndex = 4
                // create face view models
                self.face1ViewModel = FaceValidationViewModel(currentType: face1Type, stepName: face1Type.title, stepIndex: 4)
                self.face2ViewModel = FaceValidationViewModel(currentType: face2Type, stepName: face2Type.title, stepIndex: 5)
                self.face3ViewModel = FaceValidationViewModel(currentType: face3Type, stepName: face3Type.title, stepIndex: 6)

                stepsViewModels = [
                    StartNationalIdValidationViewModel(),
                    NationalIdFrontViewModel(),
                    NationalIdBackViewModel(),
                    StartFaceValidationViewModel(),
                    face1ViewModel!,
                    face2ViewModel!,
                    face3ViewModel!
                ]
            }
        }
    }

    /// Re-randomizes face instructions by picking a new random flow and replacing
    /// the three face view models in stepsViewModels. Called on every retry.
    @MainActor
    func rerandomizeFaceInstructions() {
        let flows = FaceValidationTypes.validFlows
        let selectedFlow = flows[Int.random(in: 0..<flows.count)]

        let i1 = faceStepIndex
        let i2 = faceStepIndex + 1
        let i3 = faceStepIndex + 2

        self.face1ViewModel = FaceValidationViewModel(currentType: selectedFlow[0], stepName: selectedFlow[0].title, stepIndex: i1)
        self.face2ViewModel = FaceValidationViewModel(currentType: selectedFlow[1], stepName: selectedFlow[1].title, stepIndex: i2)
        self.face3ViewModel = FaceValidationViewModel(currentType: selectedFlow[2], stepName: selectedFlow[2].title, stepIndex: i3)

        stepsViewModels[i1] = face1ViewModel!
        stepsViewModels[i2] = face2ViewModel!
        stepsViewModels[i3] = face3ViewModel!
    }
    
    @MainActor
    func postData() async throws {
        let face1 = face1ViewModel?.face ?? ""
        let face2 = face2ViewModel?.face ?? ""
        let face3 = face3ViewModel?.face ?? ""
        
        let compressedFace1 = Utils.compressBase64Image(face1) ?? ""
        let compressedFace2 = Utils.compressBase64Image(face2) ?? ""
        let compressedFace3 = Utils.compressBase64Image(face3) ?? ""
        
        let request = VerifyLivenessMultiPost.Request(transactionID: CachedData.shared.transactionId, face1: compressedFace1, face2: compressedFace2, face3: compressedFace3)
        
        let accessToken = CachedData.shared.accessToken
        var url = "\(CachedData.shared.apiBaseUrl)/api/DigitalIdentity/verify/liveness/multi"
        if accessToken.isEmpty {
            url = "\(CachedData.shared.apiBaseUrl)/v1/ocr/liveness/multi"
        }
        
        let headers = [
            "Content-Type"                  : "application/json",
            "Accept"                        : "*/*",
            "Accept_Language"               : "en",
            "ApiKey"                        : CachedData.shared.apiKey,
            "TenancyName"                   : CachedData.shared.tenancyName,
            "X-Request-Id"                  : UUID().uuidString,
            "Authorization"                 : "Bearer \(CachedData.shared.accessToken)"
        ]
        
        let httpHeaders = HTTPHeaders(headers)
        let response = try await AF.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: httpHeaders
        )
        .serializingDecodable(VerifyLivenessMultiPost.Response.self)
        .value
        
        CachedData.shared.livenessResponse = response
        isDigitalIdentityVerified = response.data?.isDigitalIdentityVerified ?? false

        if response.errorCode != nil || response.errorMessage != nil {
            self.validationErrorMessage = resolveApiError(
                code: response.errorCode,
                fallback: response.errorMessage ?? "error".localized
            )
        }

        let validationErrors = response.services?.validations?.validationErrors ?? []
        if let firstError = validationErrors.first?.errors?.first,
           firstError.code != nil || firstError.message != nil {
            self.validationErrorMessage = resolveApiError(
                code: firstError.code,
                fallback: firstError.message ?? "error".localized
            )
        } else if !validationErrors.isEmpty {
            self.validationErrorMessage = "error".localized
        }

        if !isDigitalIdentityVerified && validationErrorMessage == nil {
            self.validationErrorMessage = "div_failed".localized
        }
    }
    
}
