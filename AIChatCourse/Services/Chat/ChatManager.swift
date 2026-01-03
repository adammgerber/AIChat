//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/01/2026.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws
    //uploadchats
    // deletechats
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
    
    }
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws  {
        
    }
}

struct FirebaseChatService: ChatService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws {
        try messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
    }
}

@MainActor
@Observable
class ChatManager {
    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws  {
        try await service.addChatMessages(chatId: chatId, message: message)
    }
}
