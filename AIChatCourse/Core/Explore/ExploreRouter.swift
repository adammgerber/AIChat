//
//  ExploreRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol ExploreRouter {
    func showCategoryListView(delegate: CategoryListDelegate)
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void)
    func showDevSettings()
    func dismissModal()
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: ExploreRouter { }
