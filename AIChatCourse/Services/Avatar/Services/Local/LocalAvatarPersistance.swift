//
//  LocalAvatarPersistance.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 22/12/2025.
//
import SwiftUI

@MainActor
protocol LocalAvatarPersistance {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
