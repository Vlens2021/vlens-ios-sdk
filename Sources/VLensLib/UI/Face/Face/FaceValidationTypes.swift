//
//  FaceValidationTypes.swift
//  VLensSdkSample
//
//  Created by Mohamed Taher on 10/11/2024.
//

enum FaceValidationTypes: Int {
    case smile          = 0
    case blink          = 1
    case turnHeadRight  = 2
    case turnHeadLeft   = 3
    case headStraight   = 4
    
    @MainActor
    var title: String {
        switch self {
        case .smile:
            return "Smile".localized
        case .blink:
            return "Blinking".localized
        case .turnHeadRight:
            return "Turned Right".localized
        case .turnHeadLeft:
            return "Turned Left".localized
        case .headStraight:
            return "Looking Straight".localized
        }
    }
    
    static var validFlows: [[FaceValidationTypes]] {
        let flow1: [FaceValidationTypes] = [.blink, .turnHeadRight, .smile]
        let flow2: [FaceValidationTypes] = [.blink, .turnHeadLeft, .smile]
        let flow3: [FaceValidationTypes] = [.smile, .turnHeadRight, .blink]
        let flow4: [FaceValidationTypes] = [.smile, .turnHeadLeft, .headStraight]
        let flow5: [FaceValidationTypes] = [.blink, .turnHeadRight, .headStraight]
        let flow6: [FaceValidationTypes] = [.blink, .turnHeadLeft, .headStraight]
        let flow7: [FaceValidationTypes] = [.smile, .turnHeadRight, .headStraight]
        let flow8: [FaceValidationTypes] = [.smile, .turnHeadLeft, .headStraight]
        let flow9: [FaceValidationTypes] = [.blink, .smile, .headStraight]
        let flow10: [FaceValidationTypes] = [.smile, .blink, .headStraight]

        let flows = [flow1, flow2, flow3, flow4, flow5, flow6, flow7, flow8, flow9, flow10];
        
        return flows
    }
}
