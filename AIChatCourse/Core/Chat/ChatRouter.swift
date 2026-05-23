//
//  ChatRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol ChatRouter {
    func showAlert(error: Error)
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showAlert(title: String, subtitle: String?)
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void)
    func dismissModal()
    func dismissScreen()
}

extension CoreRouter: ChatRouter {}
