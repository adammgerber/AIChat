//
//  AIManager.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 20/12/2025.
//

import SwiftUI
import OpenAI

@MainActor
@Observable
class AIManager {
    
    private let service: AIService
    
    init(service: AIService) {
        self.service = service
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws  -> AIChatModel {
        try await service.generateText(chats: chats)
    }
}
