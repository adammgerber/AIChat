//
//  MockUserPersistance.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 20/12/2025.
//


struct MockUserPersistance: LocalUserPersistance {
    var currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
      
    }
}