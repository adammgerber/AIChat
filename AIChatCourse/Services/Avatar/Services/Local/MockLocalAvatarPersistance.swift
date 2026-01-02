//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 22/12/2025.
//

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    func addRecentAvatar(avatar: AvatarModel) throws {
   
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
