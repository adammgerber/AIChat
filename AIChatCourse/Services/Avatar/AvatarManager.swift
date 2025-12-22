//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 21/12/2025.
//

import SwiftUI

@MainActor
@Observable
class AvatarManager {
    
    private let service: AvatarService
    
    init(service: AvatarService) {
        self.service = service 
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await service.getFeaturedAvatars( )
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await service.getPopularAvatars( )
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await service.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await service.getAvatarsForAuthor(userId: userId)
    }
}
