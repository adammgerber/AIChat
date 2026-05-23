//
//  CreateAccountInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol CreateAccountInteractor {
    func trackEvent(event: LoggableEvent)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: CreateAccountInteractor {}
