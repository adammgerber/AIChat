//
//  ChatsPresenter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 28/01/2026.
//

import SwiftUI

@Observable
@MainActor
class ChatsPresenter {
    
    private let interactor: ChatsInteractor
    private let router: ChatsRouter

    init(interactor: ChatsInteractor, router: ChatsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    private(set) var chats: [ChatModel] = []
    private(set) var isLoadingChats: Bool = true
    private(set) var recentAvatars: [AvatarModel] = []
        
    func loadChats() async {
        interactor.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try interactor.getAuthId()
            chats = try await interactor.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            interactor.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            interactor.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
    
    func loadRecentAvatars() {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: Event.loadAvatarsSuccess(avatarsCount: recentAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(chat: nil, avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
    }
    
    func onChatPressed(chat: ChatModel) {
        interactor.trackEvent(event: Event.chatPressed(chat: chat))
        let delegate = ChatViewDelegate(chat: chat, avatarId: chat.avatarId)
        router.showChatView(delegate: delegate)
    }

    enum Event: LoggableEvent {
        
        case loadChatsStart
        case loadChatsSuccess(chatsCount: Int)
        case loadChatsFail(error: Error)
        case loadAvatarsStart
        case loadAvatarsSuccess(avatarsCount: Int)
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel?)
        case chatPressed(chat: ChatModel?)
        
        var eventName: String {
            switch self {
            case .loadChatsStart:             return "ChatsView_LoadChats_Start"
            case .loadChatsSuccess:           return "ChatsView_LoadChats_Success"
            case .loadChatsFail:              return "ChatsView_LoadChats_Fail"
            case .loadAvatarsStart:           return "ChatsView_LoadAvatars_Start"
            case .loadAvatarsSuccess:         return "ChatsView_LoadAvatars_Success"
            case .loadAvatarsFail:            return "ChatsView_LoadAvatars_Fail"
            case .avatarPressed:              return "ChatsView_Avatar_Pressed"
            case .chatPressed:                return "ChatsView_Chat_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadChatsFail(error: let error), .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .loadChatsSuccess(chatsCount: let chatsCount):
                return [
                    "chats_count": chatsCount
                ]
            case .loadAvatarsSuccess(avatarsCount: let avatarsCount):
                return [
                    "avatars_count": avatarsCount
                ]
            case .avatarPressed(avatar: let avatar):
                return avatar?.eventParameters
            case .chatPressed(chat: let chat):
                return chat?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .loadChatsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
