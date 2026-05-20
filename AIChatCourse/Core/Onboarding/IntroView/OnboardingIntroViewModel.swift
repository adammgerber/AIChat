//
//  OnboardingIntroViewModel.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 18/04/2026.
//

import SwiftUI

@MainActor
protocol OnboardingIntroInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingIntroInteractor { }

@MainActor
protocol OnboardingIntroRouter {
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

extension CoreRouter: OnboardingIntroRouter { }

@Observable
@MainActor
class OnboardingIntroViewModel {
    
    private let interactor: OnboardingIntroInteractor
    private let router: OnboardingIntroRouter

    
    init(interactor: OnboardingIntroInteractor, router: OnboardingIntroRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinueButtonPressed() {
        router.showOnboardingColorView(delegate: OnboardingColorDelegate())
    }
}
