//
//  Persistence.swift
//  Machinery
//
//  Created by Salim Braksa on 2/21/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Persistence {
    
    private static let domain = "SMPersistence"
    private static let queue = DispatchQueue(label: "\(domain).dispatchQueue")
    
    private init() {
        
    }
    
    // MARK: - API -
    
    static func save<T: State>(machine: StateMachine<T>, queue: DispatchQueue? = nil) {
        
        let queue = queue ?? Persistence.queue
        queue.async {
            Persistence.save(machine: machine)
        }
        
    }
    
    static func load<T: State>(machineWithRestorationIdentifier restorationIdentifier: String) -> StateMachine<T>? {
        
        // Load graph from UserDefaults
        guard let graphData = UserDefaults.standard.data(forKey: Keys.userDefaultsGraphKey(restorationIdentifier)) else { return nil }
        guard let _ = NSKeyedUnarchiver.unarchiveObject(with: graphData) as? Dictionary else { return nil }
        
        // Load current node id
        let _ = UserDefaults.standard.string(forKey: Keys.userDefaultsCurrentNodeIdKey(restorationIdentifier))
        
        return nil
        
    }
    
    // MARK: - Helpers
    
    static private func save<T: State>(machine: StateMachine<T>) {
        
        // Get the data that should be persisted
        guard let restorationIdentifier = machine.restorationIdentifier else { return }
        let dictionary = machine.dictionaryRepresention()
        
        guard
            let graphDictionary = dictionary[Keys.graph] as? Dictionary,
            let currentNodeId = dictionary[Keys.currentNodeId] as? String
            else { return }
        
        // Archive graph
        let graphData = NSKeyedArchiver.archivedData(withRootObject: graphDictionary)
        
        // Store data into UserDefaults
        UserDefaults.standard.set(graphData, forKey: Keys.userDefaultsGraphKey(restorationIdentifier))
        UserDefaults.standard.set(currentNodeId, forKey: Keys.userDefaultsCurrentNodeIdKey(restorationIdentifier))
        
    }
    
    // MARK: - Supporting Types -
    
    struct Keys {
        
        // MARK: - Dictionary Keys
        
        static let graph = "graph"
        static let currentNodeId = "currentNodeId"
        
        // MARK: - UserDefaults Keys
        
        static func userDefaultsGraphKey(_ restorationIdentifier: String) -> String {
            return "\(domain).\(restorationIdentifier).graph"
        }
        
        static func userDefaultsCurrentNodeIdKey(_ restorationIdentifier: String) -> String {
            return "\(domain).\(restorationIdentifier).currentNodeId"
        }
        
        // MARK: - Paths
        
        static let graphsArchivePath: String = {
            let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let graphsArchivePath = documentsDirectory.appendingPathComponent("machines-graphs").absoluteString
            return graphsArchivePath
        }()
        
        static let currentNodesArchivePath: String = {
            let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let currentNodesArchivePath = documentsDirectory.appendingPathComponent("machines-current-node").absoluteString
            return currentNodesArchivePath
        }()
        
    }
    
}
