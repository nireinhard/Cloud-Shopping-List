//
//  ClassUtility.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 21.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation

// taken from
// https://stackoverflow.com/questions/376090/nsdictionary-with-ordered-keys
class MutableOrderedDictionary: NSDictionary {
    let _values: NSMutableArray = []
    let _keys: NSMutableOrderedSet = []
    
    override var count: Int {
        return _keys.count
    }
    override func keyEnumerator() -> NSEnumerator {
        return _keys.objectEnumerator()
    }
    override func object(forKey aKey: Any) -> Any? {
        let index = _keys.index(of: aKey)
        if index != NSNotFound {
            return _values[index]
        }
        return nil
    }
    func setObject(_ anObject: Any, forKey aKey: String) {
        let index = _keys.index(of: aKey)
        if index != NSNotFound {
            _values[index] = anObject
        } else {
            _keys.add(aKey)
            _values.add(anObject)
        }
    }
}
