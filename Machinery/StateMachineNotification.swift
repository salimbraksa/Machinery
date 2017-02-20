//
//  StateMachineNotification.swift
//  StateMachine
//
//  Created by Salim Braksa on 2/19/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

struct StateMachineNotification<T: StateValue> {
    
    let sourceState: StateNode<T>
    let destinationState: StateNode<T>
    
    init?(notification: Notification) {
        
        guard
            let sourceState = notification.userInfo?["source-state"] as? StateNode<T>,
            let destinationState = notification.userInfo?["dest-state"] as? StateNode<T>
            else { return nil }
        
        self.sourceState = sourceState
        self.destinationState = destinationState
        
    }
    
}
