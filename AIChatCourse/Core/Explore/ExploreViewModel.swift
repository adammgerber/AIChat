//
//  ExploreViewModel.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 15/04/2026.
//

import SwiftUI

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

@MainActor
protocol ExploreRouter {
    func showCategoryListView(delegate: CategoryListDelegate)
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void)
    func showDevSettings()
    func dismissModal()
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: ExploreRouter { }

@Observable
@MainActor
class ExploreViewModel {
    
    private let interactor: ExploreInteractor
    private let router: CoreRouter
    
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var showNotificationButton: Bool = false
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    
    init(interactor: ExploreInteractor, router: CoreRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func schedulePushNotifications() {
        interactor.schedulePushNotificationsForTheNextWeek()
    }
    
    func handleShowPushNotificationButton() async {
        showNotificationButton = await interactor.canRequestAuthorization()
    }
    
    func onPushNotificationButtonPressed() {
        
        func onEnablePushNotificationsPressed() {
            router.dismissModal()
            Task {
                let isAuthorized = try await interactor.requestAuthorization()
                interactor.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
                await handleShowPushNotificationButton()
            }
        }
        
        func onCancelPushNotificationsPressed() {
            router.dismissModal()
            interactor.trackEvent(event: Event.pushNotifsCancel)
        }
        
        interactor.trackEvent(event: Event.pushNotifcStart)
        router.showPushNotificationModal(
            onEnablePressed: {
                onEnablePushNotificationsPressed()
            },
            onCancelPressed: {
                onCancelPushNotificationsPressed()
            }
        )
    }
    
    func onDevSettingsPressed() {
        interactor.trackEvent(event: Event.devSettingsPressed)
        router.showDevSettings()
    }
    
    func onTryAgainPressed() {
        isLoadingFeatured = true
        isLoadingPopular = true
        interactor.trackEvent(event: Event.tryAgainPressed)

        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func loadFeaturedAvatars() async {
        // If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadFeaturedAvatarsStart)

        do {
            featuredAvatars = try await interactor.getFeaturedAvatars()
            interactor.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        
        isLoadingFeatured = false
    }
    
    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadPopularAvatarsStart)

        do {
            popularAvatars = try await interactor.getPopularAvatars()
            interactor.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        router.showChatView(delegate: ChatViewDelegate(chat: nil, avatarId: avatar.avatarId))
    }

    func onCategoryPressed(category: CharacterOption, imageName: String) {
        interactor.trackEvent(event: Event.categoryPressed(category: category))
        
    }
    
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotifcStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel

        var eventName: String {
            switch self {
            case .devSettingsPressed:           return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:              return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart:     return "ExploreView_LoadFeaturedAvatars_Start"
            case .loadFeaturedAvatarsSuccess:   return "ExploreView_LoadFeaturedAvatars_Success"
            case .loadFeaturedAvatarsFail:      return "ExploreView_LoadFeaturedAvatars_Fail"
            case .loadPopularAvatarsStart:      return "ExploreView_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess:    return "ExploreView_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail:       return "ExploreView_LoadPopularAvatars_Fail"
            case .avatarPressed:                return "ExploreView_Avatar_Pressed"
            case .categoryPressed:              return "ExploreView_Category_Pressed"
            case .pushNotifcStart:              return "ExploreView_PushNotifs_Start"
            case .pushNotifsEnable:             return "ExploreView_PushNotifs_Enable"
            case .pushNotifsCancel:             return "ExploreView_PushNotifs_Cancel"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadPopularAvatarsSuccess(count: let count), .loadFeaturedAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category):
                return [
                    "category": category.rawValue
                ]
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
