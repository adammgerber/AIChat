//
//  FileManagerUserPersistance.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 20/12/2025.
//
import SwiftUI

struct FileManagerUserPersistance: LocalUserPersistance {
    private let userDocumentKey = "current_user"
    
    func getCurrentUser() -> UserModel? {
        // this ones optional because we dont care if we get back or not
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        // this ones non-optional because it should save every time
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
