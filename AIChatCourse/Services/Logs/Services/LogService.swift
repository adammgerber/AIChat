//
//  LogService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 08/01/2026.
//
import SwiftUI

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
