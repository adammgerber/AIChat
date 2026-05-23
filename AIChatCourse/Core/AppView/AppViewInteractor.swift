//
//  AppViewInteractor.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol AppViewInteractor {
    func trackEvent(event: LoggableEvent)
    var auth: UserAuthInfo? { get }
    var showTabBar: Bool { get }
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
}

extension CoreInteractor: AppViewInteractor {}
