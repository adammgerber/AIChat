//
//  OnboardingCompletedInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol OnboardingCompletedInteractor {
    func trackEvent(event: LoggableEvent)
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: OnboardingCompletedInteractor {}
