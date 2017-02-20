//
//  StateMachine.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

precedencegroup AssignementPrecendence {
    associativity: left
}
infix operator <-: AssignementPrecendence

open class StateMachine<T: StateValue>: NSObject {
    
    // MARK: - Properties
    
    private let graph: Graph<StateNode<T>>
    fileprivate var currentState: StateNode<T>
    fileprivate let notificationCenter = NotificationCenter.default
    
    // MARK: - Initializer
    
    public init(initial: StateNode<T>) {
        graph = Graph(root: initial)
        currentState = graph.root
    }
    
    // MARK: - Performing Transitions
    
    open func next(node: StateNode<T>) {
        
        guard let destinationState = currentState.state(withIdentifier: "\(currentState.id)-\(node.id)")
        else {
            print("Unknown transition from \(currentState) to \(node)")
            return
        }
        let userInfo = ["source-state": currentState, "dest-state": destinationState]
        
        notificationCenter.post(name: NotificationName.willPerformTransition, object: nil, userInfo: userInfo)
        currentState = destinationState
        notificationCenter.post(name: NotificationName.didPerformTransition, object: nil, userInfo: userInfo)

    }

    // MARK: - Persistence
    
    open func toDictionary() -> [String: Any] {
        
        // Transform graph into dictionary
        var dictionary = [String: Any]()
        graph.enumerate { node in
            dictionary += node.toDictionary()
        }
        
        // Set metadata
        dictionary["currentNodeId"] = currentState.id
        return dictionary
        
    }
    
    // MARK: - NSCoding Protocol Methods
    
//    public required init?(coder aDecoder: NSCoder) {
//        
//    }
//    
//    public func encode(with aCoder: NSCoder) {
//        
//    }
    
    // MARK: <- Operator
    
    @discardableResult
    open static func <- (left: StateMachine, right: StateNode<T>) -> StateMachine {
        left.next(node: right)
        return left
    }
    
}

// MARK: - Notifications -

public extension StateMachine {
    
    // MARK: - Notifications Subscription
    
    func subscribe<S: StateMachineSubscriber>(subscriber: S) where S.S == T {
        
        notificationCenter.addObserver(forName: NotificationName.didPerformTransition, object: nil, queue: nil) { notification in
            guard let notification = StateMachineNotification<T>(notification: notification) else { return }
            subscriber.stateMachine(self, didPerformTransitionFrom: notification.sourceState, to: notification.destinationState)
        }
        
        notificationCenter.addObserver(forName: NotificationName.willPerformTransition, object: nil, queue: nil) { notification in
            guard let notification = StateMachineNotification<T>(notification: notification) else { return }
            subscriber.stateMachine(self, willPerformTransitionFrom: notification.sourceState, to: notification.destinationState)
        }
        
    }
    
}

// MARK: - Notification Names -

fileprivate struct NotificationName {
    
    static let didPerformTransition = Notification.Name("didPerformTransition")
    static let willPerformTransition = Notification.Name("willPerformTransition")
    
}
