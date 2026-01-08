//
//  Dictionary+EXT.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 08/01/2026.
//
import SwiftUI

extension Dictionary where Key == String, Value == Any {
    
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self.map({ (key: $0, value: $1) }).sortedByKeyPath(keyPath: \.key)
    }
    
    
    mutating func first(upTo maxItems: Int) {
        var counter: Int = 0
        for (key, value) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
    
}
