//
//  Load.swift
//  Machinery
//
//  Created by Salim Braksa on 2/23/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Load {
    
    static func load(machineWithRestorationIdentifier identifier: String) -> Dictionary? {
        
        // Load graph from /Library/Application Support/Machinery/<identifier>/graph
        let graphFileUrl = Constants.graphFileUrl(identifier)
        guard
            let graphData = try? Data(contentsOf: graphFileUrl),
            let graph = NSKeyedUnarchiver.unarchiveObject(with: graphData) as? Dictionary
            else {
                print("Cannot load graph data at \(graphFileUrl)")
                return nil
        }
        
        // Load metadata from /Library/Application Support/Machinery/<identifier>/metadata
        let metadataFileUrl = Constants.metadataFileUrl(identifier)
        guard
            let metadata = try? Data(contentsOf: Constants.metadataFileUrl(identifier)),
            let metadataDictionary = NSKeyedUnarchiver.unarchiveObject(with: metadata) as? Dictionary,
            let currentNodeId = metadataDictionary[Constants.currentNodeId] as? String,
            let initialNodeId = metadataDictionary[Constants.initialNodeId] as? String
            else {
                print("Cannot load matadata at \(metadataFileUrl)")
                return nil
        }
        
        return [Constants.currentNodeId: currentNodeId,
                Constants.graph: graph,
                Constants.initialNodeId: initialNodeId]
        
    }
    
    static func load<T: State>(machineWithDictionary dictionary: Dictionary) -> StateMachineParams<T>? {
        
        // Prepare variables to use for output construction
        guard
            let currentNodeId = dictionary[Constants.currentNodeId] as? String,
            let initialNodeId = dictionary[Constants.initialNodeId] as? String,
            let graphDictionary = dictionary[Constants.graph] as? [String: Any]
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
    
}
