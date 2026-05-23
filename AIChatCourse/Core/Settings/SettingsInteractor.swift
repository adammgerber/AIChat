//
//  SettingsInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func deleteUserProfile()
    func deleteAccount() async throws
    func signOut() async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: SettingsInteractor {}
