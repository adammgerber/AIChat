//
//  LogService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 08/01/2026.
//
import SwiftUI

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any])
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
