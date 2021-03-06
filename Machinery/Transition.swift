//
//  Transition.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

open class Transition<T: State> {
    
    let source: Node<T>
    let destination: Node<T>
    
    init(source: Node<T>, destination: Node<T>) {
        self.source = source
        self.destination = destination
    }
    
}
