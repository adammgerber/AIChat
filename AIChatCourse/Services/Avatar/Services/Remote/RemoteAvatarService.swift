//
//  AvatarService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 22/12/2025.
//
import SwiftUI

protocol RemoteAvatarService: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func getAvatar(id: String) async throws -> AvatarModel
    func incrementAvatarClickCount(avatarId: String) async throws
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func removeAuthorIdFromAllAvatars(userId: String) async throws
}
