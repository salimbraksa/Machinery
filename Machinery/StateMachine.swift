//
//  StateMachine.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

precedencegroup TransitionPrecedence {
    associativity: left
}

infix operator <-: TransitionPrecedence
infix operator <-!: TransitionPrecedence

public protocol StateHandler {
    
    associatedtype T: State
    
    func didEnter(state: T)
    
    func willExit(state: T)
    
}

open class StateMachine<T: State>: NSObject {
    
    // MARK: - Public Properties
    
    open var currentState: T { return currentNode.state }
    
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
    
    private var stateHandlers = [String: AnyStateHandler<T>]()
    
    // MARK: - Private Properties
    
    fileprivate var initialNode: Node<T>!
    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var nodes = [String: Node<T>]()
    
    fileprivate var currentNode: Node<T>! {
        willSet {
            if let currentNode = self.currentNode {
                willSet(currentNode: currentNode)
            }
        } didSet {
            didSet(currentNode: currentNode)
        }
    }
    
    // MARK: - Initializer
    
    public override init() {
        super.init()
    }
    
    public init(initial: T) {
        super.init()
        self.initial(initial)
    }

    // MARK: - Performing Transitions
    
    @discardableResult
    open func move(to state: T) -> StateMachine<T> {
        let node = self.nodes[state.description]
        node?.state = state
        self.currentNode = node
        return self

    }
    
    @discardableResult
    open func `try`(_ state: T) -> StateMachine<T> {
        guard let destinationNode = currentNode.state(withIdentifier: "to \(state.description)") else { return self }
        currentNode = destinationNode
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
    public func add(_ transition: Transition<T>) -> StateMachine<T> {
        
        let source = transition.source
        let destination = transition.destination
        
        let identifier = "to \(destination.description)"
        
        let isWeak = destination.has(node: source)
        source.destinationStates[identifier] = Container(value: destination, isWeak: isWeak)
        
        return self
        
    }
    
    @discardableResult
    open func add(_ state: T) -> StateMachine<T> {
        if nodes[state.description] == nil {
            nodes[state.description] = Node(state)
        }
        return self
    }
    
    @discardableResult
    open func add(_ states: T...) -> StateMachine<T> {
        states.forEach { self.add($0) }
        return self
    }
    
    @discardableResult
    open func add(source: T, destination: T) -> StateMachine<T> {
        let source = self.node(from: source)
        let destination = self.node(from: destination)
        return self.add(Transition(source: source, destination: destination))
    }

    func node(from state: T) -> Node<T> {
        if nodes[state.description] == nil {
            nodes[state.description] = Node(state)
        }
        return nodes[state.description]!
    }
    
    // MARK: - State Handling
    
    open func handle<H: StateHandler>(_ state: T, with handler: H) where H.T == T {
        self.stateHandlers[state.description] = AnyStateHandler<T>(handler)
    }
    
    // MARK: - Property Observers

    private func willSet(currentNode: Node<T>) {
        let handler = self.stateHandlers[currentNode.state.description]
        handler?.willExit(state: currentNode.state)
    }
    
    private func didSet(currentNode: Node<T>) {
        let handler = self.stateHandlers[currentNode.state.description]
        handler?.didEnter(state: currentNode.state)
    }
    
    // MARK: - Operator
    
    @discardableResult
    open static func + (left: StateMachine, right: (source: T, destination: T)) -> StateMachine {
        return left.add(source: right.source, destination: right.destination)
    }
    
    @discardableResult
    open static func <- (left: StateMachine, right: T) -> StateMachine {
        return left.try(right)
    }
    
    @discardableResult
    open static func <-! (left: StateMachine, right: T) -> StateMachine {
        return left.move(to: right)
    }
    
}

class AnyStateHandler<T: State>: StateHandler {
    
    private let _willExit: (T) -> Void
    private let _didEnter: (T) -> Void
    
    init<H: StateHandler>(_ handler: H) where H.T == T {
        self._willExit = handler.willExit(state:)
        self._didEnter = handler.didEnter(state:)
    }
    
    func willExit(state: T) {
        self._willExit(state)
    }
    
    func didEnter(state: T) {
        self._didEnter(state)
    }
    
}
