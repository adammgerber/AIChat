//
//  ProfileRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol ProfileRouter {
    func showSettingsView()
    func showCreateAvatarView(onDisappear: @escaping () -> Void)
    func showAlert(title: String, subtitle: String?)
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: ProfileRouter {}
