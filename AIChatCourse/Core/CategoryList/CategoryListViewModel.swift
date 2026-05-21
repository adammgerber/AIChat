//
//  CategoryListViewModel.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 12/04/2026.
//

import SwiftUI

@MainActor
protocol CategoryListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListInteractor {}

@MainActor
protocol CategoryListRouter {
    func showAlert(error: Error)
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: CategoryListRouter {}


@Observable
@MainActor
class CategoryListViewModel {
    
    private let interactor: CategoryListInteractor
    private let router: CategoryListRouter
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    init(interactor: CategoryListInteractor, router: CategoryListRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadAvatars(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            router.showAlert(error: error)
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(chat: nil, avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
        
    }
    
    enum Event: LoggableEvent {
        
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:  return "CategoryList_LoadAvatars_Start"
            case .loadAvatarsSuccess:  return "CategoryList_LoadAvatars_Success"
            case .loadAvatarsFail:  return "CategoryList_LoadAvatars_Fail"
            case .avatarPressed:  return "CategoryList_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
