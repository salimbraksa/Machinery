//
//  Graph.swift
//  Machinery
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Graph<T: NodeType> where T: Hashable {
    
    // MARK: - Properties
    
    let root: T
    
    // MARK: - Initializer
    
    init(root: T) {
        self.root = root
    }
    
    // MARK: - Search
    
    func enumerate(iterationHandler: (_ node: T) -> ()) {
        
        let startNode = root
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
