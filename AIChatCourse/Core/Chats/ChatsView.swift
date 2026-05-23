//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/12/2025.
//

import SwiftUI

struct ChatsView<ChatRowCell: View>: View {
    @State var presenter: ChatsPresenter
    @ViewBuilder var chatRowCell: (ChatRowCellDelegate) -> ChatRowCell
  
    var body: some View {
        List {
            if !presenter.recentAvatars.isEmpty {
                recentsSection
            }
            
            chatsSection
        }
        .navigationTitle("chats")
        .screenAppearAnalytics(name: "ChatsView")
        .onAppear {
            presenter.loadRecentAvatars()
        }
        .task {
            await presenter.loadChats()
        }
        
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(presenter.recentAvatars, id: \.self) { avatar in
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
                                presenter.onAvatarPressed(avatar: avatar)
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
            
            if presenter.isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                
            } else if presenter.chats.isEmpty {
                Text("Your chats will appear here!")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(presenter.chats) { chat in
                    chatRowCell(ChatRowCellDelegate(chat: chat))
                        .anyButton(.highlight) {
                            presenter.onChatPressed(chat: chat)
                        }
                        .removeListRowFormatting()
                }
            }
        } header: {
            Text(presenter.chats.isEmpty ? "" : "Chats")
        }
    }
}

#Preview("Has data") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.chatsView(router: router)
    }
    .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self) {
        AvatarManager(
            service: MockAvatarService(avatars: []),
            local: MockLocalAvatarPersistence(avatars: [])
        )
    }
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(chats: [])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.chatsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Slow loading chats") {
    let container = DevPreview.shared.container
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(delay: 5)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return RouterView { router in
        builder.chatsView(router: router)
    }
    .previewEnvironment()
}
