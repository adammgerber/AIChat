//
//  ChatsInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol ChatsInteractor {
    func trackEvent(event: LoggableEvent)
    func getAuthId() throws -> String
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getRecentAvatars() throws -> [AvatarModel]
}

extension CoreInteractor: ChatsInteractor {}
