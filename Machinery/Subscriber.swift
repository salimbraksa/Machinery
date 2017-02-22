//
//  Subscriber.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

public protocol Subscriber {
    
    associatedtype S: State
    
    func stateMachine(_ stateMachine: StateMachine<S>, willPerformTransitionFrom source: S, to destination: S)
    func stateMachine(_ stateMachine: StateMachine<S>, didPerformTransitionFrom source: S, to destination: S)
    
}

public extension Subscriber {
    
    func stateMachine(_ stateMachine: StateMachine<S>, willPerformTransitionFrom source: S, to destination: S) { }
    func stateMachine(_ stateMachine: StateMachine<S>, didPerformTransitionFrom source: S, to destination: S) { }

}
