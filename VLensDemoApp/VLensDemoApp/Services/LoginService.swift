import Foundation

struct LoginService {

    static let apiKey = "W70qYFzumZYn9nPqZXdZ39eRjpW5qRPrZ4jlxlG6c"
    static let tenancyName = "silverkey2"

    static func login() async throws -> String {
        let url = URL(string: "https://api.vlenseg.com/api/DigitalIdentity/Login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(tenancyName, forHTTPHeaderField: "TenancyName")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "geoLocation": [
                "latitude": 30.193033,
                "longitude": 31.463339
            ],
            "imsi": NSNull(),
            "imei": "123456789",
            "phoneNumber": "+201556005675",
            "password": "P@ssword123"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print the raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print(">>> Login API Response: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LoginError.requestFailed
        }
        
        print(">>> HTTP Status Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            throw LoginError.requestFailed
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any],
              let accessToken = dataObj["accessToken"] as? String else {
            throw LoginError.tokenNotFound
        }

        return accessToken
    }

    enum LoginError: LocalizedError {
        case requestFailed
        case tokenNotFound

        var errorDescription: String? {
            switch self {
            case .requestFailed: return "Login request failed."
            case .tokenNotFound: return "Access token not found in response."
            }
        }
    }
}
