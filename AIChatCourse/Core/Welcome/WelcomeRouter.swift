//
//  WelcomeRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//


@MainActor
protocol WelcomeRouter {
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
    func dismissScreen()
}

extension CoreRouter: WelcomeRouter {
}