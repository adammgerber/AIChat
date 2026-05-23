//
//  ChatInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol ChatInteractor {
    var currentUser: UserModel? { get }
    var auth: UserAuthInfo? { get }
//    var isPremium: Bool { get }
    
    func trackEvent(event: LoggableEvent)
    func getAuthId() throws -> String
    func getAvatar(id: String) async throws -> AvatarModel
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
    
    func createNewChat(chat: ChatModel) async throws
    func reportChat(chatId: String, userId: String) async throws
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws
    func deleteChat(chatId: String) async throws
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws
   
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}

extension CoreInteractor: ChatInteractor {}
