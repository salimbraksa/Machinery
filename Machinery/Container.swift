//
//  Container.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Container<T: AnyObject> {
    
    let isWeak: Bool
    private weak var weakValue: T!
    private var strongValue: T!
    
    var value: T! {
        if isWeak { return weakValue }
        return strongValue
    }
    
    init(value: T, isWeak: Bool = true) {
        self.isWeak = isWeak
        if isWeak { weakValue = value }
        else { strongValue = value }
    }
    
}
