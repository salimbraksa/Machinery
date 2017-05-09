//
//  StateMachine.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

typealias Dictionary = [String: Any]

open class StateMachine<T: State>: NSObject, Storable {
    
    // MARK: - Public Properties
    
    public var currentState: T { return currentNode.state }
    public var identifier: String?
    public var saveWhen = { (state: T) -> Bool in return true }
    
    public var autosave = false {
        didSet {
            if !repository.isExist(machine: self) {
                save()
            }
        }
    }
    
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
    
    fileprivate let repository = Repository()
    fileprivate var initialNode: Node<T>!
    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var nodes = [String: Node<T>]()
    
    fileprivate var currentNode: Node<T>! {
        didSet {
            if autosave && saveWhen(currentNode.state) {
                self.save()
            }
        }
    }
    
    // MARK: - Initializer
    
    private override init() {
        super.init()
    }
    
    public init(initial: T) {
        super.init()
        self.initial(initial)
    }
    
    private init(nodes: [String: Node<T>]) {
        self.nodes = nodes
    }
    
    public convenience init?(identifier: String, state: ( (String) -> T)? = nil) {
        var dictionary = Repository.load(machineWithRestorationIdentifier: identifier) ?? [:]
        dictionary["state"] = state
        self.init(dictionary: dictionary)
        self.identifier = identifier
        
    }
    
    public convenience init(restorationIdentifier identifier: String, state: ( (String) -> T)? = nil, orNew new: @escaping (StateMachine<T>) -> ()) {
        
        var dictionary = Repository.load(machineWithRestorationIdentifier: identifier) ?? [:]
        dictionary["state"] = state
        dictionary["creation"] = new
        self.init(dictionary: dictionary)!
        self.identifier = identifier
        
    }
    
    required public convenience init?(dictionary: [String : Any]) {
        
        guard let params: StateMachineParams<T> = Repository.load(machineWithDictionary: dictionary) else {
            
            if let creation = dictionary["creation"] as? (StateMachine<T>) -> () {
                self.init()
                creation(self)
            }
            return nil
            
        }
        
        self.init(nodes: params.nodes)
        self.initial(params.initialNode.state)
        self.currentNode = params.currentNode
        self.autosave = params.autosave
        
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
    public func initial(_ state: T) -> StateMachine<T> {
        
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

    // MARK: - Machine repository
    
    open func dictionaryRepresention() -> [String: Any] {
        
        // Transform the entire graph into dictionary
        var dictionary = Dictionary()
        for (_, node) in nodes { 
            dictionary += node.dictionaryRepresention()
        }
        
        return [Constants.currentNodeId: currentNode.id,
                Constants.initialNodeId: initialNode.id,
                Constants.graph: dictionary]
        
    }
    
    /// Manually saves the machine's current configuration
    private func save() {
        repository.save(machine: self)
    }

    // MARK: Operator
    
    @discardableResult
    open static func + (left: StateMachine, right: (source: T, destination: T)) -> StateMachine {
        return left.from(right.source, to: right.destination)
    }
    
    @discardableResult
    open static func => (left: StateMachine, right: T) -> StateMachine {
        return left.next(right)
    }
    
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
        
        notificationCenter.addObserver(forName: NotificationName.stateMachineStarted, object: nil, queue: nil) { _ in
            subscriber.stateMachine(self, startedAtState: self.currentNode.state)
        }
        
        self.notificationCenter.post(name: NotificationName.stateMachineStarted, object: nil)
        
    }
    
}

// MARK: - Notification Names -

fileprivate struct NotificationName {
    
    static let didPerformTransition = Notification.Name("didPerformTransition")
    static let willPerformTransition = Notification.Name("willPerformTransition")
    static let stateMachineStarted = Notification.Name("stateMachineStarted")
    
}
