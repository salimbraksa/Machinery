//
//  Node.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/18/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

final public class Node<T: State>: NSObject {
    
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
    
    // MARK: - Supporting Types -

    typealias DictionaryValue = Container<Node>
    
}
