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
    
    @MainActor
    class MockProfileRouter: ProfileRouter {
        
        var didShowSettingsView: Bool = false
        var didShowCreateAvatarView: Bool = false
        var didShowChatViewWithAvatarId: String? = nil
        
        func showSettingsView() {
            didShowSettingsView = true
        }
        
        func showCreateAvatarView(onDisappear: @escaping () -> Void) {
            didShowCreateAvatarView = true
        }
        
        func showAlert(title: String, subtitle: String?) {
            
        }
        
        func showChatView(delegate: AIChatCourse.ChatViewDelegate) {
            didShowChatViewWithAvatarId = delegate.avatarId
        }
    }
    
    @MainActor
    struct MockProfileInteractor: ProfileInteractor {
        var logger = MockLogService()
        var user: UserModel = UserModel.mock
        var avatars: [AvatarModel] = AvatarModel.mocks
        
        var currentUser: AIChatCourse.UserModel? {
            user
        }
        
        func getAuthId() throws -> String {
            user.userId
        }
        
        func getAvatarsForAuthor(userId: String) async throws -> [AIChatCourse.AvatarModel] {
            avatars
        }
        
        func trackEvent(event: any AIChatCourse.LoggableEvent) {
            logger.trackEvent(event: event)
        }
        
        func removeAuthorIdFromAvatar(avatarId: String) async throws {
            
        }
    }
    
    @MainActor
    struct AnyProfileInteractor: ProfileInteractor {
        let anyCurrentUser: UserModel?
        let anyGetAuthId: () throws -> String
        let anyGetAvatarsForAuthor: (String) async throws -> [AvatarModel]
        let anyRemoveAuthorIdFromAvatar: (String) async throws -> Void
        let anyTrackEvent: (LoggableEvent) -> Void
        
        init(
            currentUser: UserModel?,
            getAuthId: @escaping () throws -> String,
            getAvatarsForAuthor: @escaping (String) async throws -> [AvatarModel],
            removeAuthorIdFromAvatar: @escaping (String) async throws -> Void,
            trackEvent: @escaping (LoggableEvent) -> Void
        ) {
            self.anyCurrentUser = currentUser
            self.anyGetAuthId = getAuthId
            self.anyGetAvatarsForAuthor = getAvatarsForAuthor
            self.anyRemoveAuthorIdFromAvatar = removeAuthorIdFromAvatar
            self.anyTrackEvent = trackEvent
        }
        
        init(interactor: ProfileInteractor) {
            self.anyCurrentUser = interactor.currentUser
            self.anyGetAuthId = interactor.getAuthId
            self.anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
            self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
            self.anyTrackEvent = interactor.trackEvent
        }
        
        init(interactor: MockProfileInteractor) {
            self.anyCurrentUser = interactor.currentUser
            self.anyGetAuthId = interactor.getAuthId
            self.anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
            self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
            self.anyTrackEvent = interactor.trackEvent
        }
        
        init(interactor: ProdProfileInteractor) {
            self.anyCurrentUser = interactor.currentUser
            self.anyGetAuthId = interactor.getAuthId
            self.anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
            self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
            self.anyTrackEvent = interactor.trackEvent
        }
        
        var currentUser: AIChatCourse.UserModel? {
            anyCurrentUser
        }
        
        func getAuthId() throws -> String {
            try anyGetAuthId()
        }
        
        func getAvatarsForAuthor(userId: String) async throws -> [AIChatCourse.AvatarModel] {
            try await anyGetAvatarsForAuthor(userId)
        }
        
        func removeAuthorIdFromAvatar(avatarId: String) async throws {
            try await anyRemoveAuthorIdFromAvatar(avatarId)
        }
        
        func trackEvent(event: any AIChatCourse.LoggableEvent) {
            anyTrackEvent(event)
        }
    }

    @Test("loadData does set current user")
    func testLoadDataDoesSetCurrentUser() async throws {
        
        // Given
        let interactor = MockProfileInteractor()
        let presenter = ProfilePresenter(interactor: interactor, router: MockProfileRouter())
        
        // When
        await presenter.loadData()
        
        // Then
        #expect(presenter.currentUser?.userId == interactor.user.userId)
        #expect(interactor.logger.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.loadAvatarsStart.eventName })
    }
    
    @Test("loadData does succeed and user avatars are set")
    func testLoadDataDoesSucceedAndAvatarsAreSet() async throws {
        // Given
        var events: [LoggableEvent] = []
        let avatars = AvatarModel.mocks
        let user = UserModel.mock
        
        let interactor = AnyProfileInteractor(
            currentUser: user,
            getAuthId: {
                user.userId
            },
            getAvatarsForAuthor: { _ in
                avatars
            },
            removeAuthorIdFromAvatar: { _ in },
            trackEvent: { event in
                events.append(event)
            }
        )
        let presenter = ProfilePresenter(interactor: interactor, router: MockProfileRouter())

        // When
        await presenter.loadData()
        
        // Then
        #expect(presenter.myAvatars.count == avatars.count)
        #expect(presenter.isLoading == false)
        #expect(events.contains { $0.eventName == ProfilePresenter.Event.loadAvatarsSuccess(count: 0).eventName })
    }
    
    @Test("loadData does fail")
    func testLoadDataDoesFail() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService(user: nil))
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)

        // Given
        let presenter = ProfilePresenter(interactor: ProdProfileInteractor(container: container), router: MockProfileRouter())

        // When
        await presenter.loadData()
        
        // Then
        #expect(presenter.isLoading == false)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.loadAvatarsFail(error: URLError(.badURL)).eventName })
    }
    
    @Test("onSettingsButtonPressed")
    func testOnSettingsButtonPressed() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let router = MockProfileRouter()
        let presenter = ProfilePresenter(interactor: ProdProfileInteractor(container: container), router: router)
        // When
        presenter.onSettingsButtonPressed()
        
        // Then
        #expect(router.didShowSettingsView == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.settingsPressed.eventName })
    }
    
    @Test("onNewAvatarButtonPressed")
    func testOnNewAvatarButtonPressed() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let router = MockProfileRouter()
        let presenter = ProfilePresenter(interactor: ProdProfileInteractor(container: container), router: router)
        // When
        presenter.onNewAvatarButtonPressed()
        
        // Then
        #expect(router.didShowCreateAvatarView == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.newAvatarPressed.eventName })
    }
    
    @Test("onAvatarPressed")
    func testOnAvatarPressed() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let router = MockProfileRouter()
        let presenter = ProfilePresenter(interactor: ProdProfileInteractor(container: container), router: router)
        // When
        let avatar = AvatarModel.mock
        presenter.onAvatarPressed(avatar: avatar)
        
        // Then
        #expect(router.didShowChatViewWithAvatarId == avatar.id)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.avatarPressed(avatar: avatar).eventName })
    }
    
    @Test("onDeleteAvatar does succeed")
    func testOnDeleteAvatarSuccess() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)

        // Given
        let presenter = ProfilePresenter(interactor: ProdProfileInteractor(container: container), router: MockProfileRouter())

        // When
        await presenter.loadData()
        presenter.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        try await Task.sleep(for: .seconds(1))

        // Then
        #expect(presenter.myAvatars.count == (avatars.count - 1))
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.deleteAvatarSuccess(avatar: avatars[0]).eventName })
    }
    
    @Test("onDeleteAvatar does fail")
    func testOnDeleteAvatarFailure() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars, showErrorForRemoveAuthorIdFromAvatar: true))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)

        // Given
        let presenter = ProfilePresenter(interactor: ProdProfileInteractor(container: container), router: MockProfileRouter())

        // When
        await presenter.loadData()
        presenter.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        
        try await Task.sleep(for: .seconds(1))
        // Then
        #expect(presenter.myAvatars.count == avatars.count)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfilePresenter.Event.deleteAvatarFail(error: URLError(.badURL)).eventName })
    }
}
