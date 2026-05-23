//
//  CategoryListRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol CategoryListRouter {
    func showAlert(error: Error)
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: CategoryListRouter {}
