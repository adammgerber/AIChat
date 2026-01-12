//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/12/2025.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    @State private var chats: [ChatModel] = []
    @State private var isLoadingChats: Bool = true
    @State private var path: [NavigationPathOption] = []
    @State private var recentAvatars: [AvatarModel] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                
                chatsSection
            }
            .navigationTitle("chats")
            .navigationDestinationForCoreModule(path: $path)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
    
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
    
    private func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarsSuccess(avatarsCount: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
        logManager.trackEvent(event: Event.chatPressed(chat: chat))
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
    
    private var chatsSection: some View {
        Section {
            
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                
            } else if chats.isEmpty {
                Text("Your chats will appear here!")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.auth?.uid,
                        chat: chat,
                        getAvatar: {
                            try? await avatarManager.getAvatar(id: chat.avatarId)
                        },
                        getLastChatMessage: {
                            try? await chatManager.getLastChatMessage(chatId: chat.id)
                        }
                    )
                    .anyButton(.highlight) {
                        onChatPressed(chat: chat)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }
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

#Preview("Has data") {
    ChatsView()
        .previewEnvironment()
}

#Preview("No data") {
    ChatsView()
        .environment(
            AvatarManager (
                service: MockAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])
            )
        )
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewEnvironment()
}
