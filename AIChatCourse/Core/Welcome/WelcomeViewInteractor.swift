//
//  WelcomeViewInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol WelcomeViewInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBarView: Bool)
    
}

extension CoreInteractor: WelcomeViewInteractor {}
