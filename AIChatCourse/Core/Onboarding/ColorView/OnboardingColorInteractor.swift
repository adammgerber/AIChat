//
//  OnboardingColorInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: LoggableEvent)
    
}

extension CoreInteractor: OnboardingColorInteractor {}
