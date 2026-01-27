//
//  ProfileViewTests.swift
//  AIChatCourseTests2
//
//  Created by Adam Gerber on 27/01/2026.
//
import SwiftUI
import Testing
@testable import AIChatCourse

@MainActor
struct ProfileViewTests {

    @Test("loadData does set current user")
    func testLoadDataDoesSetCurrentUser() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.userId == mockUser.userId)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsStart.eventName })
    }
}
