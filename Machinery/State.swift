//
//  Node.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

public typealias State = LosslessStringConvertible

public extension State where Self: RawRepresentable, Self.RawValue: LosslessStringConvertible {

    public var description: String {
        return self.rawValue.description
    }
    
    public init?(_ description: String) {
        guard let value = Self.RawValue.init(description) else { return nil }
        self.init(rawValue: value)
    }
    
}

public func => <T: State>(left: T, right: T) -> (source: T, destination: T) {
    return (left, right)
}
