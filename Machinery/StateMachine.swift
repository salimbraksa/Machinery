//
//  StateMachine.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

open class StateMachine<T: State>: NSObject {
    
    // MARK: - Properties
    
    private let graph: Graph<StateNode<T>>
    fileprivate var currentStateNode: StateNode<T>
    fileprivate let notificationCenter = NotificationCenter.default
    
    // MARK: - Initializer
    
    public init(initial: StateNode<T>) {
        graph = Graph(root: initial)
        currentStateNode = graph.root
    }
    
    // MARK: - Performing Transitions
    
    open func next(identifier: String) {
        
        guard let destinationStateNode = currentStateNode.stateNode(withIdentifier: identifier)
        else { return }
        let userInfo = ["source-state": currentStateNode.state, "dest-state": destinationStateNode.state]
        
        notificationCenter.post(name: NotificationName.willPerformTransition, object: nil, userInfo: userInfo)
        currentStateNode = destinationStateNode
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
        dictionary["currentNodeId"] = currentStateNode.id
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
    
}

// MARK: - Notifications -

public extension StateMachine {
    
    // MARK: - Notifications Subscription
    
    func subscribe<S: StateMachineSubscriber>(subscriber: S) where S.StateType == T {
        
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
