//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/12/2025.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var path: [NavigationPathOption] = []
    @State private var recentAvatars: [AvatarModel] = AvatarModel.mocks
    
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
            .onAppear {
                loadRecentAvatars()
            }
        }
    }
    
    private func loadRecentAvatars() {
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Failed to load recents.")
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
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
            if chats.isEmpty {
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
                        currentUserId: nil, // Add cuid
                        chat: chat,
                        getAvatar: {
                            try? await Task.sleep(for: .seconds(5))
                            return AvatarModel.mocks.randomElement()!
                        },
                        getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(5))
                            return ChatMessageModel.mocks.randomElement()!
                        }
                    )
                    .anyButton(.highlight) {
                        onChatPressed(chat: chat)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("Chats")
        }
    }
}

#Preview {
    ChatsView()
        .environment(AvatarManager(service: MockAvatarService()))
}
