//
//  Repository.swift
//  Machinery
//
//  Created by Salim Braksa on 2/21/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct StateMachineParams<T: State> {
    
    var currentNode: Node<T>!
    var initialNode: Node<T>!
    var nodes: [String: Node<T>]!
    
}

struct Repository {
    
    static private let domain = "SMRepository"
    private let queue = DispatchQueue(label: "\(domain).dispatchQueue.\(UUID())")
    
    // MARK: - API -
    
    func save<T: State>(machine: StateMachine<T>) {
        queue.async {
            Save.save(machine: machine)
        }
    }
    
    static func load(machineWithRestorationIdentifier identifier: String) -> Dictionary? {
        return Load.load(machineWithRestorationIdentifier: identifier)
    }
    
    static func load<T: State>(machineWithDictionary dictionary: Dictionary) -> StateMachineParams<T>? {
        return Load.load(machineWithDictionary: dictionary)
    }
    
    func isExist<T: State>(machine: StateMachine<T>) -> Bool {
        guard let identifier = machine.identifier else { return false }
        return isExist(identifier: identifier)
    }
    
    func isExist(identifier: String) -> Bool {
        let url = Constants.stateMachineUrl(identifier)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
}
