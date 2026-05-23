//
//  OnboardingCompletedRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol OnboardingCompletedRouter {
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    
    func showAlert(error: Error)
    
}

extension CoreRouter: OnboardingCompletedRouter {}
