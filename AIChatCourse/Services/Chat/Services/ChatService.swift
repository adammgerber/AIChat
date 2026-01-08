//
//  ChatService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 04/01/2026.
//

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws 
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReportModel) async throws
}
