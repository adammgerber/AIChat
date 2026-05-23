//
//  ProfileInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//


@MainActor
protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    func getAuthId() throws -> String
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func trackEvent(event: LoggableEvent)
    func removeAuthorIdFromAvatar(avatarId: String) async throws
}

extension CoreInteractor: ProfileInteractor {}

@MainActor
struct ProdProfileInteractor: ProfileInteractor {
    
    let authManager: AuthManager
    let userManager: UserManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuthor(userId: userId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
}
