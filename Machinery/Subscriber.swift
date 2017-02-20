//
//  Subscriber.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

public protocol StateMachineSubscriber {
    
    associatedtype S: StateValue
    
    func stateMachine(_ stateMachine: StateMachine<S>, willPerformTransitionFrom sourceState: StateNode<S>, to destinationState: StateNode<S>)
    func stateMachine(_ stateMachine: StateMachine<S>, didPerformTransitionFrom sourceState: StateNode<S>, to destinationState: StateNode<S>)
    
}

public extension StateMachineSubscriber {
    
    func stateMachine(_ stateMachine: StateMachine<S>, willPerformTransitionFrom sourceState: StateNode<S>, to destinationState: StateNode<S>) { }
    func stateMachine(_ stateMachine: StateMachine<S>, didPerformTransitionFrom sourceState: StateNode<S>, to destinationState: StateNode<S>) { }

}
