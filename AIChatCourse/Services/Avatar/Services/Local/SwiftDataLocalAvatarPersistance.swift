//
//  SwiftDataLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 22/12/2025.
//
import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalAvatarPersistence: LocalAvatarPersistence {
    
    private let container: ModelContainer
    private var mainContenxt: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AvatarEntity.self )
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        let entity = AvatarEntity(from: avatar)
        mainContenxt.insert(entity)
        try mainContenxt.save()
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        let descriptor = FetchDescriptor<AvatarEntity>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        let entities = try mainContenxt.fetch(descriptor)
        return entities.map({ $0.toModel() })
    }
}
