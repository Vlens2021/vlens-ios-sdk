import Foundation

struct LoginService {

    static let tenancyName = "Default"

    static let envs: [(name: String, baseUrl: String, apiKey: String)] = [
        (name: "Staging",    baseUrl: "https://api.vlens.co",    apiKey: "546RfMoxpE2cUJK1UioM4ajjwJ3s4DMXjLxy2tsOyM"),
        (name: "Production", baseUrl: "https://api.vlenseg.com", apiKey: "8iMtUwpr6TrvcXZtrJNC0XDiocB9KJ1T0QXkdWsS1o"),
    ]

    static func login(baseUrl: String, apiKey: String) async throws -> String {
        let url = URL(string: "\(baseUrl)/api/DigitalIdentity/Login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(tenancyName, forHTTPHeaderField: "TenancyName")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "geoLocation": ["latitude": "30", "longitude": 30],
            "imei": "test",
            "phoneNumber": "+201118997269",
            "password": "Moaz101@",
            "smsProviders": 0,
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            if let responseString = String(data: data, encoding: .utf8) {
                print(">>> Login API Error: \(responseString)")
            }
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
