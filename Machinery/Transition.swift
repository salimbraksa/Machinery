//
//  Transition.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

class Transition<T: State> {
    
    let source: StateNode<T>
    let desination: StateNode<T>
    
    init(source: StateNode<T>, destination: StateNode<T>) {
        self.source = source
        self.desination = destination
    }
    
    func identified(by identifier: String?) {
        let identifier = identifier ?? UUID().uuidString
        let isWeak = desination.has(StateNode: source)
        source.destinationStateNodes[identifier] = Container(value: desination, isWeak: isWeak)
    }
    
}
