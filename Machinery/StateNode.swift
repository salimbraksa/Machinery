//
//  StateNode.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

precedencegroup TransitionPrecedence {
    associativity: left
}

infix operator <=>: TransitionPrecedence
infix operator =>: TransitionPrecedence

final public class StateNode<T: StateValue>: NSObject, Node {
    
    // MARK: - Properties -
    
    // MARK: Public Properties
    
    var id: String = UUID().uuidString
    var state: T
    open var value: T {
        return state
    }
    
    // MARK: Private Properties
    
    var destinationStates = [String: DictionaryValue]()
    
    // MARK: - Initializer -
    
    public init(value: T) {
        self.state = value
    }
    
    // MARK: - Managing Destination StateNode Nodes -
    
    @discardableResult
    open func to(_ node: StateNode) -> StateNode {
        let transition = Transition<T>(source: self, destination: node)
        transition.identified(by: "\(id)-\(node.id)")
        return node
    }
    
    func state(withIdentifier identifier: String) -> StateNode? {
        return destinationStates[identifier]?.value
    }
    
    // MARK: - Node Protocol Methods -
    
    func has(node: StateNode<T>) -> Bool {
        return destinationStates.values.contains { $0.value == node }
    }
    
    func destinationNodes() -> [StateNode<T>] {
        return destinationStates.values.flatMap { $0.value }
    }
    
    // MARK: - Transition Operators -
    
    @discardableResult
    open static func => (left: StateNode, right: StateNode) -> StateNode {
        return left.to(right)
    }
    
    @discardableResult
    open static func <=> (left: StateNode, right: StateNode) -> StateNode {
        left.to(right)
        right.to(left)
        return right
    }


    // MARK: - Converting Node
    
    func toDictionary() -> Dictionary {
        
        // Initialize dictionary
        var dictionary = Dictionary()
        
        // Populate dictionary with transitions
        var transitions = [Dictionary]()
        for (key, container) in destinationStates {
            
            var transition = Dictionary()
            transition["transitionId"] = key
            transition["nodeId"] = container.value.id
            transitions.append(transition)
            
        }
        dictionary["transitions"] = transitions
        
        // Set value as an encoded object
        dictionary["value"] = NSKeyedArchiver.archivedData(withRootObject: value)
        
        // Set node id
        dictionary[id] = dictionary
        
        return dictionary
        
    }
    
    // MARK: - Supporting Types -

    typealias DictionaryValue = Container<StateNode>
    typealias Dictionary = [String: Any]
    
}

public func ==<T: StateValue> (left: Transition<T>, right: String?) {
    left.identified(by: right)
}
