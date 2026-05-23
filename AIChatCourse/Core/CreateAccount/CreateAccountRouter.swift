//
//  CreateAccountRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI

@MainActor
protocol CreateAccountRouter {
    func dismissScreen()
}

extension CoreRouter: CreateAccountRouter {}
