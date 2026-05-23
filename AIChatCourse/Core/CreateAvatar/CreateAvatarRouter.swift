//
//  CreateAvatarRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol CreateAvatarRouter {
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: CreateAvatarRouter {}
