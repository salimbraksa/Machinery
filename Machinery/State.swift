//
//  StateNode.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

public typealias StateValue = LosslessStringConvertible

public extension StateValue where Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {

    public var description: String {
        return self.rawValue.description
    }
    
    public init?(_ description: String) {
        guard let value = Self.RawValue.init(description) else { return nil }
        self.init(rawValue: value)
    }
    
}

extension String: Storable {
    
    public init?(dictionary: [String : Any]) {
        guard let value = dictionary["value"] as? String else { return nil }
        self.init(value)
    }
    
    public func dictionaryRepresention() -> [String : Any] {
        return ["value": self]
    }
    
}
