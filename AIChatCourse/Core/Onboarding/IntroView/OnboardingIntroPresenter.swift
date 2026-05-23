//
//  OnboardingIntroPresenter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 18/04/2026.
//

import SwiftUI

@Observable
@MainActor
class OnboardingIntroPresenter {
    
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
