//
//  DictonaryConvertible.swift
//  Machinery
//
//  Created by Salim Braksa on 2/20/17.
//  Copyright © 2017 Salim Braksa. All rights reserved.
//

import UIKit

protocol DictionaryConvertible: ExpressibleByDictionaryLiteral {
    
    func toDictionary() -> [String: Any]
    
}
