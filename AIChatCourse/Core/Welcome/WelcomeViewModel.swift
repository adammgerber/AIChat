//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 13/04/2026.
//

import SwiftUI

@MainActor
protocol WelcomeViewInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBarView: Bool)
    
}

extension CoreInteractor: WelcomeViewInteractor {}


@MainActor
protocol WelcomeRouter {
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate)
    func showCreateAccountView(delegate: CreateAccountDelegate)
}

extension CoreRouter: WelcomeRouter {}

@Observable
@MainActor
class WelcomeViewModel {
    
    private(set) var imageName: String = Constants.randomImage
    
    private let interactor: WelcomeViewInteractor
    private let router: WelcomeRouter
    
    init(interactor: WelcomeViewInteractor, router: WelcomeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    private func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            // Do nothing, user goes through onboarding
        } else {
            // Push into tabbar view
            interactor.updateAppState(showTabBarView: true)
        }
    }
    
    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)
        
        let delegate = CreateAccountDelegate(
            title: "Sign in",
            subtitle: "Connect to an existing account",
            onDidSignIn: { isNewUser in
                self.handleDidSignIn(isNewUser: isNewUser)
            }
        )
        
        router .showCreateAccountView(delegate: delegate)
    }
    
    func onGetStartedPressed() {
        router.showOnboardingIntroView(delegate: OnboardingIntroDelegate())
    }
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:          return "WelcomeView_DidSignIn"
            case .signInPressed:      return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
