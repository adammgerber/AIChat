//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 17/09/2025.
//

import Foundation

struct ChatMessageModel {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreted: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
        seenByIds: [String]? = nil,
        dateCreted: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreted = dateCreted
    }
    
    static var mock: ChatMessageModel {
        mocks[0]
    }
    
    static var mocks: [ChatMessageModel] {
        let now = Date()
        return [
            ChatMessageModel(
                id: "msg1",
                chatId: "1",
                authorId: "user1",
                content: "Hey how r u",
                seenByIds: [
                    "user2",
                    "user3"
                ],
                dateCreted: now
            ),
            ChatMessageModel(
                id: "msg2",
                chatId: "2",
                authorId: "user2",
                content: "good hbu",
                seenByIds: ["user1"],
                dateCreted: now.addingTimeInterval(
                    minutes: -5
                )
            ),
            ChatMessageModel(
                id: "msg3",
                chatId: "3",
                authorId: "user3",
                content: "Anyone up for some fun?",
                seenByIds: [
                    "user1",
                    "user3",
                    "user4"
                ],
                dateCreted: now.addingTimeInterval(
                    hours: -1
                )
            ),
            ChatMessageModel(
                id: "msg4",
                chatId: "1",
                authorId: "user1",
                content: "Sure, count me in!",
                seenByIds: nil,
                dateCreted: now.addingTimeInterval(
                    hours: -2, minutes: -15
                )
            )
        ]
    }
}
