//
//  Constants.swift
//  Machinery
//
//  Created by Salim Braksa on 2/23/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: - Dictionary Constants
    
    static let initialNodeId = "initialNodeId"
    static let graph = "graph"
    static let currentNodeId = "currentNodeId"
    
    // MARK: - Paths
    
    static let archiveDirectoryUrl: URL = {
        var applicationSupportUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        applicationSupportUrl.appendPathComponent("Machinery")
        return applicationSupportUrl
    }()
    
    static func stateMachineUrl(_ identifier: String) -> URL {
        let url = Constants.archiveDirectoryUrl.appendingPathComponent(identifier)
        return url
    }
    
    static func graphFileUrl(_ identifier: String) -> URL {
        return stateMachineUrl(identifier).appendingPathComponent("graph")
    }
    
    static func metadataFileUrl(_ identifier: String) -> URL {
        return stateMachineUrl(identifier).appendingPathComponent("metadata")
    }
    
}
