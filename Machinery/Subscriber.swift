//
//  Subscriber.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

protocol StateMachineSubscriber {
    
    associatedtype StateType: State
    
    func stateMachine(_ stateMachine: StateMachine<StateType>, willPerformTransitionFrom sourceState: StateType, to destinationState: StateType)
    func stateMachine(_ stateMachine: StateMachine<StateType>, didPerformTransitionFrom sourceState: StateType, to destinationState: StateType)
    
}

extension StateMachineSubscriber {
    
    func stateMachine(_ stateMachine: StateMachine<StateType>, willPerformTransitionFrom sourceState: StateType, to destinationState: StateType) { }
    func stateMachine(_ stateMachine: StateMachine<StateType>, didPerformTransitionFrom sourceState: StateType, to destinationState: StateType) { }

}
