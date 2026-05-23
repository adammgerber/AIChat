//
//  OnboardingIntroRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol OnboardingIntroRouter {
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

extension CoreRouter: OnboardingIntroRouter { }
