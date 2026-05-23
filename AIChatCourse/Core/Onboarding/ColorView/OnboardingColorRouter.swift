//
//  OnboardingColorRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//


@MainActor
protocol OnboardingColorRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension CoreRouter: OnboardingColorRouter {}