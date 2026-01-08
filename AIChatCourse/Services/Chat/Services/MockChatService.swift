//
//  MockChatService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 04/01/2026.
//

import SwiftUI

@MainActor
class MockChatService: ChatService {
    
    let chats: [ChatModel]
    @Published var messages: [ChatMessageModel]
    let delay: Double
    let showError: Bool
    
    init(
        chats: [ChatModel] = ChatModel.mocks,
        messages: [ChatMessageModel] = ChatMessageModel.mocks,
        delay: Double = 0.0,
        showError: Bool = false
    ) {
        self.chats = chats
        self.messages = messages
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createNewChat(chat: ChatModel) async throws {
    
    }
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws {
        messages.append(message)
    }
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return chats.first { chat in
            return chat.userId == userId && chat.avatarId == avatarId
        }
    }
    
    nonisolated
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream { continuation in
               Task { @MainActor in
                   continuation.yield(messages)

                   for await _ in $messages.values {
                       continuation.yield(messages)
                   }
               }
           }
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return chats
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ChatMessageModel.mocks.randomElement()
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        
    }
    
    func deleteChat(chatId: String) async throws {
        //
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        //
    }
    
    func reportChat(report: ChatReportModel) async throws {
        
    }
}
