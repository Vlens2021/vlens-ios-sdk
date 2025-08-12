//
//  ApiConfig.swift
//  VLens
//
//  Created by Mohamed Taher on 27/07/2023.
//

import Foundation

struct ApiConfig {
        
    // MARK: - HEADER
    let webApiHeaders = [
        "Content-Type"                  : "application/json",
        "Accept"                        : "*/*",
        "Accept_Language"               : "en"
    ]
    
    // MARK: - API
    let VERIFY_ID_FRONT_POST            = "/api/DigitalIdentity/verify/id/front"
    let VERIFY_ID_BACK_POST             = "/api/DigitalIdentity/verify/id/back"
    let VERIFY_LIVENESS_MULTI_POST      = "/api/DigitalIdentity/verify/liveness/multi"
}
    
