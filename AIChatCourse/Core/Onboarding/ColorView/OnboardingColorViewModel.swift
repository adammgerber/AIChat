//
//  OnboardingColorInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 28/01/2026.
//
import SwiftUI

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: LoggableEvent)
    
}

extension CoreInteractor: OnboardingColorInteractor {}

@MainActor
protocol OnboardingColorRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension CoreRouter: OnboardingColorRouter {}

@Observable
@MainActor
class OnboardingColorViewModel {
    
    private let interactor: OnboardingColorInteractor
    private let router: OnboardingColorRouter

    
    init(interactor: OnboardingColorInteractor, router: OnboardingColorRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    private(set) var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    
    func onColorPressed(color: Color) {
        selectedColor = color
    }
    
    func onContinuePressed() {
        guard let selectedColor else { return }
        let delegate = OnboardingCompletedDelegate(selectedColor: selectedColor)
        router.showOnboardingCompletedView(delegate: delegate)
    }
    
}
