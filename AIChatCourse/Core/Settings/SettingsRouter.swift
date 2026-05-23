//
//  SettingsRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol SettingsRouter {
    func showRatingsModal(onYesPressed: @escaping () -> Void, onNoPressed: @escaping () -> Void)
    func showAlert(error: Error)
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
    func dismissModal()
    func dismissScreen()
}

extension CoreRouter: SettingsRouter {}
