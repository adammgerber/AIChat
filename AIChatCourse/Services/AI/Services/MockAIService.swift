//
//  MockAIService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 21/12/2025.
//
import SwiftUI

struct MockAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "star.fill")!
    }
}
