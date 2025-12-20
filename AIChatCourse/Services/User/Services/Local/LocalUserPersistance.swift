//
//  LocalUserPersistance.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 20/12/2025.
//

protocol LocalUserPersistance {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
