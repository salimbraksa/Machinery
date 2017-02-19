//
//  StateMachineNotification.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct StateMachineNotification<T: State> {
    
    let sourceState: T
    let destinationState: T
    
    init?(notification: Notification) {
        
        guard
            let sourceState = notification.userInfo?["source-state"] as? T,
            let destinationState = notification.userInfo?["dest-state"] as? T
            else { return nil }
        
        self.sourceState = sourceState
        self.destinationState = destinationState
        
    }
    
}
