//
//  StateNode.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

infix operator -->

open class StateNode<T: State>: NSObject {
    
    // MARK: - Properties -
    
    // MARK: Public Properties
    
    let state: T
    
    // MARK: Private Properties
    
    var destinationStateNodes = [String: DictionaryValue]()
    
    // MARK: - Initializer -
    
    public init(state: T) {
        self.state = state
    }
    
    // MARK: - Managing Destination State Containers -
    
    open func to(_ node: StateNode) -> Transition<T> {
        let transition = Transition<T>(source: self, destination: node)
        return transition
    }
    
    func stateNode(withIdentifier identifier: String) -> StateNode? {
        return destinationStateNodes[identifier]?.value
    }
    
    func has(stateNode: StateNode) -> Bool {
        return destinationStateNodes.values.contains { $0.value == stateNode }
    }
    
    // MARK: - Transition Operators -
    
    open static func --> (left: StateNode, right: StateNode) -> Transition<T> {
        let transition = Transition<T>(source: left, destination: right)
        return transition
    }

    // MARK: - Supporting Types -

    typealias DictionaryValue = Container<StateNode>
    
}

public func ==<T: State> (left: Transition<T>, right: String?) {
    left.identified(by: right)
}
