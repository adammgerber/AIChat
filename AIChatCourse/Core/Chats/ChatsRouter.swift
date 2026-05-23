//
//  ChatsRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol ChatsRouter {
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: ChatsRouter {}
