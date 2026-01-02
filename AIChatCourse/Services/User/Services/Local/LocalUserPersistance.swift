//
//  LocalUserPersistence.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 20/12/2025.
//

protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
