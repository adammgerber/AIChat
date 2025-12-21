//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 21/12/2025.
//

import OpenAI
import SwiftUI

struct OpenAIService: AIService {
    
    var openAI: OpenAI {
        OpenAI(apiToken: Keys.openAI)
    }
    
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            n: 1,
            responseFormat: .b64_json,
            size: ._512,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
    
}
