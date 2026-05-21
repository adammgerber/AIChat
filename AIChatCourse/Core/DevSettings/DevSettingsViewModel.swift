//
//  DevSettingsViewModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI
import SwiftfulUtilities

@MainActor
protocol DevSettingsInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DevSettingsInteractor { }

@MainActor
protocol DevSettingsRouter{
   func dismissScreen()
}

extension CoreRouter: DevSettingsRouter { }

@Observable
@MainActor
class DevSettingsViewModel {
    
    private let interactor: DevSettingsInteractor
    private let router: DevSettingsRouter
  
    
    var authData: [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var userData: [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var utilitiesData: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalArray
    }

    init(interactor: DevSettingsInteractor, router: DevSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onBackButtonPressed() {
        router.dismissScreen()
    }

}
