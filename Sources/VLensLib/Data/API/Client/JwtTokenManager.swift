//
//  JwtTokenManager.swift
//  bdc
//
//  Created by Mohamed Taher on 08/09/2024.
//

import Foundation

class JwtTokenManager {
    func getExpiration(from token: String) -> Date? {
        // Decode the JWT
        guard let payload = decodeJWT(token: token) else {
            return nil
        }
        
        // Extract the "exp" field, which is typically a Unix timestamp
        if let expTimestamp = payload["exp"] as? TimeInterval {
            return Date(timeIntervalSince1970: expTimestamp)
        }
        
        return nil
    }

    // Helper function to decode the JWT payload (from previous example)
    func decodeJWT(token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else {
            print("Invalid JWT format")
            return nil
        }
        
        let payloadSegment = segments[1]
        guard let payloadData = base64UrlDecode(payloadSegment) else {
            print("Failed to decode Base64URL payload")
            return nil
        }
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: payloadData, options: []),
           let payload = jsonObject as? [String: Any] {
            return payload
        }
        
        print("Failed to convert payload to JSON")
        return nil
    }

    // Helper function to decode Base64URL (JWT uses Base64URL, not Base64)
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let paddingLength = 4 - (base64.count % 4)
        if paddingLength < 4 {
            base64.append(String(repeating: "=", count: paddingLength))
        }
        
        return Data(base64Encoded: base64)
    }
}

//// Example usage
//let jwtToken = "your.jwt.token.here"
//if let expDate = getExpiration(from: jwtToken) {
//    print("Expiration Date: \(expDate)")
//} else {
//    print("Failed to extract expiration date")
//}
