//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 21/12/2025.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

protocol AvatarService: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

struct MockAvatarService: AvatarService {
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        // uplaod image
        
        // upload avatar
    }
}

struct FirebaseAvatarService: AvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        // uplaod image
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadimage(image: image, path: path)
        
        // upload avatar
        var avatar = avatar
        avatar.updateProfileImage(imageName: url.absoluteString)
        
        // upload the avatar
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
}

@MainActor
@Observable
class AvatarManager {
    
    private let service: AvatarService
    
    init(service: AvatarService) {
        self.service = service 
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
}
