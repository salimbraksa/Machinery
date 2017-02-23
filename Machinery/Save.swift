//
//  Save.swift
//  Machinery
//
//  Created by Salim Braksa on 2/23/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Save {

    static func save<T: State>(machine: StateMachine<T>) {
        
        // Get the data that should be persisted
        guard let identifier = machine.identifier else {
            fatalError("Attempt to save a machine ( \(machine) ) with a nil identifier")
        }
        let dictionary = machine.dictionaryRepresention()
        
        guard
        let graphDictionary = dictionary[Constants.graph] as? Dictionary,
        let currentNodeId = dictionary[Constants.currentNodeId] as? String,
        let initialNodeId = dictionary[Constants.initialNodeId] as? String
        else {
            print("Saving machine failed")
            return
        }
        
        do {
            
            // Create directory if it doesn't already exist
            try FileManager.default.createDirectory(at: Constants.stateMachineUrl(identifier), withIntermediateDirectories: true, attributes: nil)
            
            // Write graph data at /Library/Application Support/Machinery/<identifier>/graph
            let graphData = NSKeyedArchiver.archivedData(withRootObject: graphDictionary)
            try graphData.write(to: Constants.graphFileUrl(identifier))
            
            // Write graph metadata at /Library/Application Support/Machinery/<identifier>/metadata
            let metadataDictionary = [Constants.currentNodeId: currentNodeId, Constants.initialNodeId: initialNodeId]
            let metadata = NSKeyedArchiver.archivedData(withRootObject: metadataDictionary)
            try metadata.write(to: Constants.metadataFileUrl(identifier))
            
        } catch let error {
            print(error)
        }
        
    }

}
