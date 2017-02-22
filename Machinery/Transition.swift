//
//  Transition.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

open class Transition<T: StateValue> {
    
    let source: StateNode<T>
    let destination: StateNode<T>
    
    init(source: StateNode<T>, destination: StateNode<T>) {
        self.source = source
        self.destination = destination
    }
    
    @discardableResult
    open func identified(by identifier: String) -> StateNode<T> {
        
        let isWeak = destination.has(node: source)
        source.destinationStates[identifier] = Container(value: destination, isWeak: isWeak)
        return destination
        
    }
    
}
