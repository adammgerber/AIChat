//
//  AIService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 21/12/2025.
//
import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel 
}
