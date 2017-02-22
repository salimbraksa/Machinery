//
//  Node.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

precedencegroup TransitionPrecedence {
    higherThan: AdditionPrecedence
    associativity: left
}

infix operator <=>: TransitionPrecedence
infix operator =>: TransitionPrecedence

final public class Node<T: State>: NSObject, NodeType {
    
    // MARK: - Properties -
    
    // MARK: Public Properties
    
    var id: String = UUID().uuidString
    var state: T
    open var value: T {
        return state
    }
    
    // MARK: Private Properties
    
    weak var machine: StateMachine<T>!
    var destinationStates = [String: DictionaryValue]()
    
    // MARK: - Initializer -
    
    public init(_ value: T) {
        self.state = value
    }
    
    // MARK: - Managing Destination Node Nodes -
    
    open func to(_ node: Node<T>) {
        let transition = Transition(source: self, destination: node)
        transition.identified(by: "to \(node.state.description)")
    }
    
    func state(withIdentifier identifier: String) -> Node? {
        return destinationStates[identifier]?.value
    }
    
    // MARK: - Node Protocol Methods -
    
    func has(node: Node<T>) -> Bool {
        return destinationStates.values.contains { $0.value == node }
    }
    
    func destinationNodes() -> [Node<T>] {
        return destinationStates.values.flatMap { $0.value }
    }
    
    // MARK: - Converting Node
    
    func dictionaryRepresention() -> Dictionary {
        
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
        dictionary["value"] = state.description
    
        return [id: dictionary]
        
    }
    
    // MARK: - Supporting Types -

    typealias DictionaryValue = Container<Node>
    
}

public func ==<T: State> (left: Transition<T>, right: String) {
    left.identified(by: right)
}
