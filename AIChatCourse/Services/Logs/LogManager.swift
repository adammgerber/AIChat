//
//  LogManager.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 08/01/2026.
//

import SwiftUI

@MainActor
@Observable
class LogManager {
    
    private let services: [LogService]
    
    init(services: [LogService]) {
        self.services = services
    }
    
    
    func identifyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }
    
    func addUserProperties(dict: [String: Any]) {
        for service in services {
            service.addUserProperties(dict: dict)
        }
    }
    
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }
    
    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
    
}
