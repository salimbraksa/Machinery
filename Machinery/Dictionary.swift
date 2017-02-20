//
//  Dictionary.swift
//  Machinery
//
//  Created by Salim Braksa on 2/20/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import Foundation

func += <K, V> ( left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}
