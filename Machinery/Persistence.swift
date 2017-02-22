//
//  Persistence.swift
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

struct Persistence {
    
    static private let domain = "SMPersistence"
    private let queue = DispatchQueue(label: "\(domain).dispatchQueue.\(UUID())")
    
    init() {
        
    }
    
    // MARK: - API -
    
    func save<T: State>(machine: StateMachine<T>) {
        
        queue.async {
            self._save(machine: machine)
        }
        
    }
    
    static func load(machineWithRestorationIdentifier identifier: String) -> Dictionary? {
        
        // Load graph from UserDefaults
        guard
        let graphData = UserDefaults.standard.data(forKey: Keys.userDefaultsGraphKey(identifier)),
        let graph = NSKeyedUnarchiver.unarchiveObject(with: graphData) as? Dictionary
        else { return nil }
        
        // Load current node id & initial node id
        guard
        let currentNodeId = UserDefaults.standard.string(forKey: Keys.userDefaultsCurrentNodeIdKey(identifier)),
        let initialNodeId = UserDefaults.standard.string(forKey: Keys.userDefaultsInitialNodeKey(identifier))
        else { return nil }
        
        return [Persistence.Keys.currentNodeId: currentNodeId,
                Keys.graph: graph,
                Keys.initialNodeId: initialNodeId]
        
    }
    
    static func load<T: State>(machineWithDictionary dictionary: Dictionary) -> StateMachineParams<T>? {
        
        // Prepare variables to use for output construction
        guard
        let currentNodeId = dictionary[Persistence.Keys.currentNodeId] as? String,
        let initialNodeId = dictionary[Persistence.Keys.initialNodeId] as? String,
        let graphDictionary = dictionary[Persistence.Keys.graph] as? [String: Any]
        else { return nil }
        let block = dictionary["block"] as! ((String) -> T)
        var nodes = [String: Node<T>]()
        
        // Helper functions
        func getNode(from state: T) -> Node<T> {
            if nodes[state.description] == nil {
                nodes[state.description] = Node(state)
            }
            return nodes[state.description]!
        }
        func stateValue(fromNodeId id: String) -> String {
            let nodeDictionary = graphDictionary[id] as! Dictionary
            return nodeDictionary["value"] as! String
        }
        
        // The parsing goes here
        for (id, nodeDictionary) in graphDictionary {
            let nodeDictionary = nodeDictionary as! Dictionary
            
            // Get state description for node id
            let state = block(stateValue(fromNodeId: id))
            
            // Get node from state
            let node = getNode(from: state)
            node.id = id
            
            // Access node transitions
            let transitions = nodeDictionary["transitions"] as! [Dictionary]
            for transition in transitions {
                let id = transition["nodeId"] as! String
                let destinationNode = getNode(from: block(stateValue(fromNodeId: id)))
                destinationNode.id = id
                node.to(destinationNode)
            }
            
        }
        
        // Set stateMachineParams
        var stateMachineParams: StateMachineParams<T> = StateMachineParams()
        stateMachineParams.currentNode = getNode(from: block(stateValue(fromNodeId: currentNodeId)))
        stateMachineParams.initialNode = getNode(from: block(stateValue(fromNodeId: initialNodeId)))
        stateMachineParams.nodes = nodes
        return stateMachineParams
        
    }
    
    // MARK: - Helpers
    
    private func _save<T: State>(machine: StateMachine<T>) {
        
        // Get the data that should be persisted
        guard let identifier = machine.identifier else {
            print("Saving machine failed")
            return
        }
        let dictionary = machine.dictionaryRepresention()
        
        guard
        let graphDictionary = dictionary[Keys.graph] as? Dictionary,
        let currentNodeId = dictionary[Keys.currentNodeId] as? String,
        let initialNodeId = dictionary[Keys.initialNodeId] as? String
        else {
            print("Saving machine failed")
            return
        }
        
        // Archive graph
        let graphData = NSKeyedArchiver.archivedData(withRootObject: graphDictionary)
        
        // Store data into UserDefaults
        UserDefaults.standard.set(graphData, forKey: Keys.userDefaultsGraphKey(identifier))
        UserDefaults.standard.set(currentNodeId, forKey: Keys.userDefaultsCurrentNodeIdKey(identifier))
        UserDefaults.standard.set(initialNodeId, forKey: Keys.userDefaultsInitialNodeKey(identifier))
        
    }
    
    // MARK: - Supporting Types -
    
    struct Keys {
        
        // MARK: - Dictionary Keys
        
        static let initialNodeId = "initialNodeId"
        static let graph = "graph"
        static let currentNodeId = "currentNodeId"
        
        // MARK: - UserDefaults Keys
        
        static func userDefaultsInitialNodeKey(_ identifier: String) -> String {
            return "\(domain).\(identifier).initialNodeId"
        }
        
        static func userDefaultsGraphKey(_ identifier: String) -> String {
            return "\(domain).\(identifier).graph"
        }
        
        static func userDefaultsCurrentNodeIdKey(_ identifier: String) -> String {
            return "\(domain).\(identifier).currentNodeId"
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
