//
//  FirebaseChatService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 04/01/2026.
//
import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    
    private var chatReportsCollection: CollectionReference {
        Firestore.firestore().collection("chat_reports")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
//        let result: [ChatModel] = try await collection
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
        
//
//        return result.first
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func addChatMessages(chatId: String, message: ChatMessageModel) async throws {
        try messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messagesCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        
        return messages.first
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await messagesCollection(chatId: chatId).document(messageId).updateData([
            ChatMessageModel.CodingKeys.seenByIds.rawValue: FieldValue.arrayUnion([userId])
        ])
    }
    
    func deleteChat(chatId: String) async throws {
        
        async let deleteChat: () = collection.deleteDocument(id: chatId)
        async let deleteMessages: () = messagesCollection(chatId: chatId).deleteAllDocuments()
        
        let (_, _) = await (try deleteChat, try deleteMessages)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        let allChats = try await getAllChats(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in allChats {
                group.addTask {
                    try await deleteChat(chatId: chat.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func reportChat(report: ChatReportModel) async throws {
        try await chatReportsCollection.setDocument(document: report)
    }
}
