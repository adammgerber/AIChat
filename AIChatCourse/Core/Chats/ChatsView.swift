//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/12/2025.
//

import SwiftUI

struct ChatsView: View {
    @State var viewModel: ChatsViewModel
    @ViewBuilder var chatRowCell: (ChatRowCellDelegate) -> AnyView
  
    var body: some View {
        List {
            if !viewModel.recentAvatars.isEmpty {
                recentsSection
            }
            
            chatsSection
        }
        .navigationTitle("chats")
        .screenAppearAnalytics(name: "ChatsView")
        .onAppear {
            viewModel.loadRecentAvatars()
        }
        .task {
            await viewModel.loadChats()
        }
        
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.recentAvatars, id: \.self) { avatar in
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
                                viewModel.onAvatarPressed(avatar: avatar)
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
            
            if viewModel.isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                
            } else if viewModel.chats.isEmpty {
                Text("Your chats will appear here!")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.chats) { chat in
                    chatRowCell(ChatRowCellDelegate(chat: chat))
                        .anyButton(.highlight) {
                            viewModel.onChatPressed(chat: chat)
                        }
                        .removeListRowFormatting()
                }
            }
        } header: {
            Text(viewModel.chats.isEmpty ? "" : "Chats")
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
