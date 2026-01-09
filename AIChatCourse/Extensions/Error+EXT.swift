//
//  Error+EXT.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 09/01/2026.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
