//
//  CreateAvatarInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import UIKit

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func getAuthId() throws -> String
    func generateImage(input: String) async throws -> UIImage
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

extension CoreInteractor: CreateAvatarInteractor {}
