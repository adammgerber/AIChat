//
//  ExploreInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol ExploreInteractor {
    func schedulePushNotificationsForTheNextWeek()
    func canRequestAuthorization() async -> Bool
    func trackEvent(event: LoggableEvent)
    func requestAuthorization() async throws -> Bool
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
}

extension CoreInteractor: ExploreInteractor {}
