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
typealias Dictionary = [String: Any]


open class StateMachine<T: StateValue>: NSObject, Storable {
    
    // MARK: - Public Properties
    
    public var restorationIdentifier: String?
    
    // MARK: - Private Properties
    
    private var graph: Graph<StateNode<T>>!
    fileprivate var initialState: StateNode<T>!
    fileprivate var currentState: StateNode<T>!
    fileprivate let notificationCenter = NotificationCenter.default
    
    private var nodes = [String: StateNode<T>]()
    
    // MARK: - Initializer
    
    public init(initial: T) {
        super.init()
        self.initial(state: initial)
    }
    
    public static func retrieve(restorationIdentifier: String) -> StateMachine<T>? {
        let _: StateMachine<T>? = Persistence.load(machineWithRestorationIdentifier: restorationIdentifier)
        return nil
    }
    
    required public init(dictionary: [String : Any]) {
        fatalError("Not implemented yet")
    }
    
    // MARK: - Performing Transitions
    
    @discardableResult
    open func next(_ state: T) -> StateMachine<T> {
        
        guard let destinationState = currentState.state(withIdentifier: "to \(state.description)")
        else { print("Couldn't perform transition from \(currentState.state) to \(state) "); return self }
        let userInfo = ["source-state": currentState, "dest-state": destinationState]
        
        notificationCenter.post(name: NotificationName.willPerformTransition, object: nil, userInfo: userInfo)
        currentState = destinationState
        notificationCenter.post(name: NotificationName.didPerformTransition, object: nil, userInfo: userInfo)
        
        return self

    }
    
    // MARK: - Machine construction
    
    @discardableResult
    func initial(state: T) -> StateMachine<T> {
        
        let stateNode = StateNode<T>(state)
        graph = Graph(root: stateNode)
        initialState = stateNode
        currentState = stateNode
        nodes[state.description] = stateNode
        return self
        
    }
    
    @discardableResult
    open func from(_ sourceState: T, to destinationState: T) -> StateMachine<T> {
        
        let sourceNodeState = self.nodeState(from: sourceState)
        let destinationNodeState = self.nodeState(from: destinationState)
        
        let transition = Transition(source: sourceNodeState, destination: destinationNodeState)
        transition.identified(by: "to \(destinationState.description)")
        
        return self
        
    }
    
    @discardableResult
    open func to(_ destinationState: T) -> StateMachine<T> {
        return from(initialState.state, to: destinationState)
    }
    
    func nodeState(from state: T) -> StateNode<T> {
        if nodes[state.description] == nil {
            nodes[state.description] = StateNode(state)
        }
        return nodes[state.description]!
    }

    // MARK: - Persistence
    
    open func dictionaryRepresention() -> [String: Any] {
        
        // Transform the entire graph into dictionary
        var dictionary = Dictionary()
        graph.enumerate { node in
            dictionary += node.dictionaryRepresention()
        }
        return [Persistence.Keys.currentNodeId: currentState.id, Persistence.Keys.graph: dictionary]
        
    }
    
    /// Manually saves the machine's current configuration
    open func save() {
        Persistence.save(machine: self)
    }

    // MARK: <- Operator
    
    @discardableResult
    open static func + (left: StateMachine, right: (source: T, destination: T)) -> StateMachine {
        return left.from(right.source, to: right.destination)
    }
    
    @discardableResult
    open static func <- (left: StateMachine, right: T) -> StateMachine {
        return left.next(right)
    }
    
}

public func => <T: StateValue>(left: T, right: T) -> (source: T, destination: T) {
    return (left, right)
}

// MARK: - Notifications -

public extension StateMachine {
    
    // MARK: - Notifications Subscription
    
    func subscribe<S: Subscriber>(subscriber: S) where S.S == T {
        
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
