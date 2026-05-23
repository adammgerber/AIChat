//
//  CategoryListInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol CategoryListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListInteractor {}
