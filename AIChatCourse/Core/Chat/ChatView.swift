//
//  ChatView.swift
//  AIChatCourse
//
import SwiftUI

struct ChatViewDelegate {
    var chat: ChatModel?
    var avatarId: String = AvatarModel.mock.avatarId
}

struct ChatView: View {
    
    @State var presenter: ChatPresenter
    let delegate: ChatViewDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(presenter.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if presenter.isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .anyButton {
                            presenter.onChatSettingsPressed()
                        }
                }
                
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .task {
            await presenter.loadAvatar(avatarId: delegate.avatarId)
        }
        .task {
            await presenter.loadChat(avatarId: delegate.avatarId)
            await presenter.listenForChatMessages()
        }
        .onFirstAppear {
            presenter.onViewFirstAppear(chat: delegate.chat)
        }
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(presenter.chatMessages) { message in
                    if presenter.messageIsDelayed(message: message) {
                        presenter.timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    let isCurrentUser = presenter.messageIsCurrentUser(message: message)
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: presenter.currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : presenter.avatar?.profileImageName,
                        onImagePressed: presenter.onAvatarImagePressed
                    )
                    .onAppear {
                        presenter.onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $presenter.scrollPosition, anchor: .center)
        .animation(.default, value: presenter.chatMessages.count)
        .animation(.default, value: presenter.scrollPosition)
    }
    
    private var textFieldSection: some View {
        TextField("Say something...", text: $presenter.textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain, action: {
                        presenter.onSendMessagePressed(avatarId: delegate.avatarId)
                    })
                
                , alignment: .trailing
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview("Working chat") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return RouterView { router in
        builder.chatView(router: router)
            .previewEnvironment()
    }
}

#Preview("Slow AI generation") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 20)))
    
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.chatView(router: router)
            .previewEnvironment()
    }
}

#Preview("Failed AI generation") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 2, showError: true)))
    
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.chatView(router: router)
            .previewEnvironment()
    }
}
