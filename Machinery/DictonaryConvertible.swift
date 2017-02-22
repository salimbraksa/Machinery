//
//  DictonaryConvertible.swift
//  Machinery
//
//  Created by Salim Braksa on 2/20/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import UIKit

public protocol Storable {
    
    init?(dictionary: [String: Any])
    
    func dictionaryRepresention() -> [String: Any]
    
}

public extension Storable where Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {
    
    init?(dictionary: [String : Any]) {
        guard let rawValue = dictionary["rawValue"] as? RawValue else { return nil }
        self.init(rawValue: rawValue)
    }
    
    func dictionaryRepresention() -> [String : Any] {
        return ["rawValue": rawValue.description]
    }
    
}
