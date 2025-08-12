//
//  NSObject.swift
//  Tayary
//
//  Created by Mohamed Taher on 4/20/19.
//  Copyright © 2019 Mohamedt. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    // Name Of class
    class var stringRepresentation: String {
        let name = String(describing: self)
        return name
    }
}


protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }
    
    static var typeName: String {
        return String(describing: self)
    }
}

extension NSObject: NameDescribable {}
extension Array: NameDescribable {}
