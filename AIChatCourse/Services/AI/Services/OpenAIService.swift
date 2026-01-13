//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 21/12/2025.
//

import SwiftUI
import FirebaseFunctions

struct OpenAIService: AIService {
    
    func generateImage(input: String) async throws -> UIImage {
        let response = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])
        
        guard
            let b64json = response.data as? String,
            let data = Data(base64Encoded: b64json),
            let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
//        let query = ImagesQuery(
//            prompt: input,
//            n: 1,
//            responseFormat: .b64_json,
//            size: ._512,
//            user: nil
//        )
//        
//        let result = try await openAI.images(query: query)
//        
//        guard let b64Json = result.data.first?.b64Json,
//              let data = Data(base64Encoded: b64Json),
//              let image = UIImage(data: data) else {
//            throw OpenAIError.invalidResponse
//        }
//        
//        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap { chat in
            let role = chat.role.rawValue
            let content = chat.message
            return [
                "role": role,
                "content": content
            ]
        }
        
        let response = try await Functions.functions().httpsCallable("generateOpenAIText").call([
            "messages": messages
        ])

        guard
            let dict = response.data as? [String: Any],
            let roleString = dict["role"] as? String,
            let role = AIChatRole(rawValue: roleString),
            let content = dict["content"] as? String else {
            throw OpenAIError.invalidResponse
        }

        return AIChatModel(role: role, content: content)
        
//        let messages = chats.compactMap({ $0.toOpenAIModel() })
//        let query = ChatQuery(messages: messages, model: .gpt3_5Turbo)
//        let result = try await openAI.chats(query: query)
//        
//        guard
//            let chat = result.choices.first?.message,
//            let model = AIChatModel(chat: chat)
//        else {
//            throw OpenAIError.invalidResponse
//        }
//        
//        return model
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
    
}

struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, content: String) {
        self.role = role
        self.message = content
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case message
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "aichat_\(CodingKeys.role.rawValue)" : role,
            "aichat_\(CodingKeys.message.rawValue)": message,
        ]
        
        return dict.compactMapValues({ $0 })
    }
}

enum AIChatRole: String, Codable {
    case system, user, assistant, tool
}
