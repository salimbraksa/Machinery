//
//  StateNode.swift
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

final public class StateNode<T: StateValue>: NSObject, Node {
    
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
    
    // MARK: - Managing Destination StateNode Nodes -
    
    open func to(_ state: T) -> StateNode<T> {
        machine.from(state, to: state)
        return machine.nodeState(from: state)
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
//    open static func => (left: StateNode, right: StateNode) -> StateNode<T> {
//        left.to(right).identified(by: nil)
//        return right
//    }

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
        if !(value is Storable) { fatalError() }
        dictionary["value"] = (value as! Storable).dictionaryRepresention()
    
        return [id: dictionary]
        
    }
    
    // MARK: - Supporting Types -

    typealias DictionaryValue = Container<StateNode>
    
}

public func ==<T: StateValue> (left: Transition<T>, right: String) {
    left.identified(by: right)
}
