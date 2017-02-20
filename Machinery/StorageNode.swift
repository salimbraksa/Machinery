//
//  StorageNode.swift
//  Machinery
//
//  Created by Salim Braksa on 2/20/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct StorageNode: Node, Hashable {
    
    // MARK: - Properties
    
    var destinationStorageNodes = [String: StorageNode]()
    
    private var _value: String
    var value: String {
        return _value
    }
    
    var hashValue: Int {
        return value.hashValue
    }
    
    // MARK: - Initializer
    
    init<T: State>(stateNode: StateNode<T>, recursive: Bool = true) {
        
        self._value = stateNode.id
        guard recursive else { return }
        for (key, container) in stateNode.destinationStateNodes {
            destinationStorageNodes[key] = StorageNode(stateNode: container.value, recursive: !container.isWeak)
        }
        
    }
    
    // MARK: - Node Protocol Methods
    
    mutating func add(node: StorageNode, identifier: String) {
        destinationStorageNodes[identifier] = node
    }
    
    func has(node: StorageNode) -> Bool {
        return destinationStorageNodes.values.contains(node)
    }
    
    func destinationNodes() -> [StorageNode] {
        return destinationStorageNodes.values.flatMap { $0 }
    }
    
    // MARK: - Equatable Protocol
    
    static func ==(left: StorageNode, right: StorageNode) -> Bool {
        return left.value == right.value
    }
    
}
