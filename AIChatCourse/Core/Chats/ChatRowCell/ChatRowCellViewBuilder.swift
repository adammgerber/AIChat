//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 08/12/2025.
//

import SwiftUI

struct ChatRowCellDelegate {
    var chat: ChatModel = .mock
}

struct ChatRowCellViewBuilder: View {
    
    @State var presenter: ChatRowCellPresenter
    let delegate: ChatRowCellDelegate
    
    var body: some View {
        ChatRowCellView(
            imageName: presenter.avatar?.profileImageName,
            headline: presenter.isLoading ? "xxxx xxxx" : presenter.avatar?.name,
            subheadline: presenter.subheadline,
            hasNewChat: presenter.isLoading ? false : presenter.hasNewChat
        )
        .redacted(reason: presenter.isLoading ? .placeholder : [])
        .task {
            await presenter.loadAvatar(chat: delegate.chat)
        }
        .task {
            await presenter.loadLastChatMessage(chat: delegate.chat)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return VStack {
        builder.chatRowCell()
    }
}
