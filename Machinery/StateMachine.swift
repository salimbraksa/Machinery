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


open class StateMachine<T: State>: NSObject, Storable {
    
    // MARK: - Public Properties
    
    public var identifier: String?
    
    open override var debugDescription: String {
        var result = ""
        for (_, node) in nodes {
            
            let currentNodeSymbol = node.state.description == currentNode.state.description ? "+ " : ""
            let initialNodeSymbol = node.state.description == initialNode.state.description ? "- " : ""
            
            result += "\(initialNodeSymbol)\(currentNodeSymbol)\(node.state.description) => "
            result += String(describing: node.destinationNodes().map({ $0.state })) + "\n"
            
        }
        return result
    }
    
    // MARK: - Private Properties
    
    fileprivate var initialNode: Node<T>!
    fileprivate var currentNode: Node<T>!
    fileprivate let notificationCenter = NotificationCenter.default
    
    private var nodes = [String: Node<T>]()
    
    // MARK: - Initializer
    
    public init(initial: T) {
        super.init()
        self.initial(state: initial)
    }
    
    private init(nodes: [String: Node<T>]) {
        self.nodes = nodes
    }
    
    public convenience init?(identifier: String, block: @escaping (String) -> T) {
        var dictionary = Persistence.load(machineWithRestorationIdentifier: identifier) ?? [:]
        dictionary["block"] = block
        self.init(dictionary: dictionary)
        self.identifier = identifier
    }
    
    required public convenience init?(dictionary: [String : Any]) {
        guard let params: StateMachineParams<T> = Persistence.load(machineWithDictionary: dictionary) else { return nil }
        self.init(nodes: params.nodes)
        self.initial(state: params.initialNode.state)
        self.currentNode = params.currentNode
    }
    
    // MARK: - Performing Transitions
    
    @discardableResult
    open func next(_ state: T) -> StateMachine<T> {
        
        guard let destinationNode = currentNode.state(withIdentifier: "to \(state.description)")
        else { print("Couldn't perform transition from \(currentNode.state) to \(state) "); return self }
        let userInfo = ["source-state": currentNode.state, "dest-state": destinationNode.state]
        
        notificationCenter.post(name: NotificationName.willPerformTransition, object: nil, userInfo: userInfo)
        currentNode = destinationNode
        notificationCenter.post(name: NotificationName.didPerformTransition, object: nil, userInfo: userInfo)
        
        return self

    }
    
    // MARK: - Machine construction
    
    @discardableResult
    func initial(state: T) -> StateMachine<T> {
        
        let node = self.node(from: state)
        initialNode = node
        currentNode = node
        return self
        
    }
    
    @discardableResult
    open func from(_ sourceState: T, to destinationState: T) -> StateMachine<T> {
        
        let sourceNode = self.node(from: sourceState)
        let destinationNode = self.node(from: destinationState)
        sourceNode.to(destinationNode)
        return self
        
    }
    
    @discardableResult
    open func to(_ destinationState: T) -> StateMachine<T> {
        return from(initialNode.state, to: destinationState)
    }
    
    func node(from state: T) -> Node<T> {
        if nodes[state.description] == nil {
            nodes[state.description] = Node(state)
        }
        return nodes[state.description]!
    }

    // MARK: - Machine persistence
    
    open func dictionaryRepresention() -> [String: Any] {
        
        // Transform the entire graph into dictionary
        var dictionary = Dictionary()
        for (_, node) in nodes { 
            dictionary += node.dictionaryRepresention()
        }
        
        return [Persistence.Keys.currentNodeId: currentNode.id,
                Persistence.Keys.initialNodeId: initialNode.id,
                Persistence.Keys.graph: dictionary]
        
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

public func => <T: State>(left: T, right: T) -> (source: T, destination: T) {
    return (left, right)
}

// MARK: - Notifications -

public extension StateMachine {
    
    // MARK: - Notifications Subscription
    
    func subscribe<S: Subscriber>(_ subscriber: S) where S.S == T {
        
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
