//
//  StateNode.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

infix operator =>

final public class StateNode<T: State>: NSObject, Node {
    
    // MARK: - Properties -
    
    // MARK: Public Properties
    
    var id: String = UUID().uuidString
    let state: T
    var value: T {
        return state
    }
    
    // MARK: Private Properties
    
    var destinationStateNodes = [String: DictionaryValue]()
    
    // MARK: - Initializer -
    
    public init(state: T) {
        self.state = state
    }
    
    // MARK: - Managing Destination State Nodes -
    
    open func to(_ node: StateNode) -> Transition<T> {
        let transition = Transition<T>(source: self, destination: node)
        return transition
    }
    
    func stateNode(withIdentifier identifier: String) -> StateNode? {
        return destinationStateNodes[identifier]?.value
    }
    
    // MARK: - Node Protocol Methods -
    
    func has(node: StateNode<T>) -> Bool {
        return destinationStateNodes.values.contains { $0.value == node }
    }
    
    func destinationNodes() -> [StateNode<T>] {
        return destinationStateNodes.values.flatMap { $0.value }
    }
    
    // MARK: - Transition Operators -
    
    open static func => (left: StateNode, right: StateNode) -> Transition<T> {
        let transition = Transition<T>(source: left, destination: right)
        return transition
    }

    // MARK: - Converting Node
    
    func toDictionary() -> Dictionary {
        
        // Initialize dictionary
        var dictionary = Dictionary()
        
        // Populate dictionary with transitions
        var transitions = [Dictionary]()
        for (key, container) in destinationStateNodes {
            
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

public func ==<T: State> (left: Transition<T>, right: String?) {
    left.identified(by: right)
}
