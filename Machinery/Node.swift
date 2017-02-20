//
//  Node.swift
//  Machinery
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

protocol Node {
    
    associatedtype ValueType
    
    var value: ValueType { get }
    
    func destinationNodes() -> [Self]
    func has(node: Self) -> Bool
    
}
