//
//  HttpService.swift
//  VLens
//
//  Created by Mohamed Taher on 27/07/2023.
//

import Foundation
internal import Alamofire

enum StatusEnum {
    case OK
    case Error(data: ApiResponse<String>?)
    
    var value: String? {
        return String(describing: self).components(separatedBy: "(").first
    }
    
    static func == (lhs: StatusEnum, rhs: StatusEnum) -> Bool {
        lhs.value == rhs.value
    }
}

@MainActor
class HttpService<T>: Sendable where T: Decodable & Sendable {
    
    private let logger = Logger(className: "HttpService")
    
    var httpSession: Session {
        return AppNetworkManager().session
    }
    
    private func getNewRequestHeaders() -> HTTPHeaders {
        
        var headers = ApiConfig().webApiHeaders
        
        headers["X-Request-Id"]         = UUID().uuidString
        headers["Accept_Language"]      = CachedData.shared.language

        if (CachedData.shared.accessToken.isEmpty == false) {
            headers["Authorization"] = "Bearer \(CachedData.shared.accessToken)"
        }
        
        var result = [String: String]()
        headers.forEach( {
            if ($0.value.isEmpty == false) {
                result[$0.key] = $0.value
            }
        })
        
        return HTTPHeaders(result)
    }
    
    private func handleResponse(response: AFDataResponse<T>, callback: @escaping (T?, StatusEnum) -> Void) {
        //-------------------------------------- Success ------------------------------------------//
        let httpStatusCode = HttpStatusCode(rawValue: response.response?.statusCode ?? 404)
        if httpStatusCode?.isSuccess ?? false {
            
            if (httpStatusCode == .Http204_NoContent) {
                callback(nil, .OK)
                return
            }
            
            
            
            guard let responseValue = response.value else  {
                let description = "Serialization Error at \(response.response?.url?.absoluteString ?? "--") API"
                let errorObject = ApiResponse<String>.from(description: description)
                callback(nil, .Error(data: errorObject))
                logger.debug("\(description) \n \(response.result)")
                return
            }
            
            callback(responseValue, .OK)
            return
        }
        
        //--------------------------------------- Error -------------------------------------------//
        guard let errorResponse = response.data else {
            let errorObject = ApiResponse<String>.from(description: "\(httpStatusCode?.rawValue ?? 404)")
            callback(nil, .Error(data: errorObject))
            return
        }
        
        do {
            let errorResponse = try JSONDecoder().decode(ApiResponse<String>.self, from: errorResponse)
            callback(response.value, .Error(data: errorResponse))
        } catch {
            let errorObject = ApiResponse<String>.from(description: "\(httpStatusCode?.rawValue ?? 404)")
            callback(nil, .Error(data: errorObject))
        }
    }
    
    func getData(_ url: String, params: [String: Sendable]?, callback: @escaping (T?, StatusEnum) -> Void) {
        httpSession.request(url, method: .get, parameters: params, headers: getNewRequestHeaders()).responseDecodable(of: T.self) { response in
            Task { @MainActor in
                self.handleResponse(response: response, callback: callback)
            }
        }
    }
    
    func postData(_ url: String, body: Codable, callback: @escaping (T?, StatusEnum) -> Void) {
        let data = body.asDictionary()
        httpSession.request(url, method: .post, parameters: data as Parameters, encoding: JSONEncoding.default, headers: getNewRequestHeaders()).responseDecodable(of: T.self) { response in
            Task { @MainActor in
                self.handleResponse(response: response, callback: callback)
            }
        }
    }
    
    func putData(_ url: String, body: Codable, callback: @escaping (T?, StatusEnum) -> Void) {
        let data = body.asDictionary()
        httpSession.request(url, method: .put, parameters: data as Parameters, encoding: JSONEncoding.default, headers: getNewRequestHeaders()).responseDecodable(of: T.self) { response in
            Task { @MainActor in
                self.handleResponse(response: response, callback: callback)
            }
        }
    }
    
    func patchData(_ url: String, body: Codable, callback: @escaping (T?, StatusEnum) -> Void) {
        let data = body.asDictionary()
        httpSession.request(url, method: .patch, parameters: data as Parameters, encoding: JSONEncoding.default, headers: getNewRequestHeaders()).responseDecodable(of: T.self) { response in
            Task { @MainActor in
                self.handleResponse(response: response, callback: callback)
            }
        }
    }
    
    func deleteData(_ url: String, params: [String: Sendable]?, callback: @escaping (T?, StatusEnum) -> Void) {
        httpSession.request(url, method: .delete, parameters: params, headers: getNewRequestHeaders()).responseDecodable(of: T.self) { response in
            Task { @MainActor in
                self.handleResponse(response: response, callback: callback)
            }
        }
    }
}

extension Encodable {
    fileprivate func asDictionary() -> [String: Sendable?] {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(self)
            //Notice(t) : that commented code is for testing the request body's form.
            /*let reqJSONStr = String(data: data, encoding: .utf8)
            var testDic: [String: Any]
            if let dataV2 = reqJSONStr?.data(using: .utf8) {
                do {
                    testDic = (try JSONSerialization.jsonObject(with: dataV2, options: []) as? [String: Any])!
                } catch {
             debugPrint(error.localizedDescription)
                }
            }*/
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Sendable?] else {
                return [:]
            }
            return dictionary
        } catch {
            return [:]
        }
    }
}
