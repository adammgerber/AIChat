//
//  DevSettingsInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol DevSettingsInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DevSettingsInteractor { }
