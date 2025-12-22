//
//  MockLocalAvatarPersistance.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 22/12/2025.
//


@MainActor
struct MockLocalAvatarPersistance: LocalAvatarPersistance {
    
    func addRecentAvatar(avatar: AvatarModel) throws {
   
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}