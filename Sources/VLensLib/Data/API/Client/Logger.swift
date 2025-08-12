//
//  Logger.swift
//  Tayary
//
//  Created by Mohamed Taher on 8/14/19.
//  Copyright © 2019 Mohamed Taher. All rights reserved.
//

import Foundation

struct Logger {
    
    let className: String
    
    func success(_ message: String) {
        let content = "✅ \(className) ➤ \(message)"
        debugPrint(content)
    }
    
    func success(_ data: Data?) {

        var content = ""
        if let JSONString = data?.prettyPrintedJSONString {
            content = "✅ \(className) ➤ \(JSONString)"
        } else {
            content = "✅ \(className) ➤ Can't parse response !!!"
        }

        debugPrint(content)
    }
    
    func success<T: Encodable>(_ obj: T) {

        let content = "✅ \(className)"
//        let data: Data? = CodableHelper.encode(obj).data
//        if let JSONString = data?.prettyPrintedJSONString {
//            content = "✅ \(className) ➤ \(JSONString)"
//        }

        debugPrint(content)
    }
    
    func info(_ message: String) {
        let content = "⚠️ \(className) ➤ \(message)"

        debugPrint(content)
    }
    
    func error(_ message: String) {
        let content = "❌ \(className) ➤ \(message)"

        debugPrint(content)
    }
    
    func debug(_ message: Any) {
        let content = "🔴 \(className) ➤ \(message)"

        debugPrint(content)
    }

}

extension Data {
    fileprivate func toJSON() -> String {
        if let JSONString = String(data: self, encoding: String.Encoding.utf8)
        {
            return JSONString
        }
        
        return "---"
    }
    
    fileprivate var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
