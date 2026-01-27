//
//  RemoteUserService.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 20/12/2025.
//
@MainActor
protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
}
