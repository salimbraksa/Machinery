//
//  Graph.swift
//  Machinery
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Graph<T: Node> where T: Hashable {
    
    // MARK: - Properties
    
    let root: T
    
    // MARK: - Initializer
    
    init(root: T) {
        self.root = root
    }
    
    // MARK: - Search
    
    func enumerate(from startNode: T, iterationHandler: (_ node: T) -> ()) {
        
        var visited: [T: Bool] = [:]
        var stack = [T]()
        stack.append(startNode)
        
        while !stack.isEmpty {
            
            guard let node = stack.popLast() else { break }
            visited[node] = true
            iterationHandler(node)
            
            let destinationNodes: [T] = node.destinationNodes()
            for destinationNode in destinationNodes where !(visited[destinationNode] ?? false) {
                stack.append(destinationNode)
            }
            
        }
        
    }
    
}
