//
//  DevSettingsRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//

@MainActor
protocol DevSettingsRouter{
   func dismissScreen()
}

extension CoreRouter: DevSettingsRouter { }
