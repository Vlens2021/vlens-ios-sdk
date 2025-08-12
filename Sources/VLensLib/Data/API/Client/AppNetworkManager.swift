//
//  AppNetworkManager.swift
//  VLens
//
//  Created by Mohamed Taher on 30/08/2023.
//

import Foundation
internal import Alamofire

class AppNetworkManager {
    
    var session: Session!
    
    init() {
        session = createSession()
    }
    
    private func createSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        
        let delegate = Session.default.delegate

        let certificates = [SecCertificate]()
                
//        TODO: Add your certificate here
//        if let url = Bundle.main.url(forResource: "*.vlenseg.com", withExtension: "cer"){
//            let localCertificate = try! Data(contentsOf: url) as CFData
//            if let cert = SecCertificateCreateWithData(nil, localCertificate) {
//                certificates.append(cert)
//            }
//        }
        
        let evaluators: [String: ServerTrustEvaluating] = [
            Constants.HOST: PinnedCertificatesTrustEvaluator(
                certificates: certificates,
                acceptSelfSignedCertificates: true,
                performDefaultValidation: true,
                validateHost: true
            )
        ]
        
        let manager = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: evaluators)
        
        let session = Session.init(configuration                : configuration,
                                   delegate                     : delegate,
                                   startRequestsImmediately     : true,
                                   serverTrustManager           : manager,
                                   cachedResponseHandler        : nil
        )
        
        return session
    }
}

