//
//  CoreRouter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 23/05/2026.
//
import SwiftUI
import RoutingPro

typealias RouterView = RoutingPro.RouterView
typealias AlertType = RoutingPro.AlertType
typealias Router = RoutingPro.Router

@MainActor
struct CoreRouter {
    let router: Router
    let builder: CoreBuilder
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            builder.categoryListView(router: router, delegate: delegate)
        }
    }
    
    func showSettingsView() {
        router.showScreen(.push) { router in
            builder.settingsView(router: router)
        }
    }
    
    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        router.showScreen(.push) { router in
            builder.createAvatarView(router: router)
                .onDisappear(perform: onDisappear)
        }
    }
    func showChatView(delegate: ChatViewDelegate) {
        router.showScreen(.push) { router in
            builder.chatView(router: router, delegate: delegate)
        }
    }
    
    func showDevSettings() {
        router.showScreen(.sheet) { router in
            builder.devSettingsView(router: router)
        }
    }
    
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)? = nil) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(router: router, delegate: delegate)
                .onDisappear {
                    onDisappear?()
                }
        }
    }
    
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingIntroView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingColorView(delegate: OnboardingColorDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingColorView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router, delegate: delegate)
        }
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    // MARK: Modals
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        router.showModal(
            backgroundColor: Color.black.opacity(0.6),
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Enable push notifications?",
                    subtitle: "We'll send you reminders and updates!",
                    primaryButtonTitle: "Enable",
                    primaryButtonAction: {
                        onEnablePressed()
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: {
                        onCancelPressed()
                    }
                )
            }
        )
    }
    
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void) {
        router.showModal(backgroundColor: Color.black.opacity(0.6), transition: .slide) {
            ProfileModalView(
                imageName: avatar.profileImageName,
                title: avatar.name,
                subtitle: avatar.characterOption?.rawValue.capitalized,
                headline: avatar.characterDescription,
                onXMarkPressed: {
                    onXMarkPressed()
                }
            )
            .padding(40)
            .transition(.slide)
        }
    }
    
    func showRatingsModal(onYesPressed: @escaping () -> Void, onNoPressed: @escaping () -> Void) {
        router.showModal(backgroundColor: Color.black.opacity(0.6), transition: .fade) {
            CustomModalView(
                title: "Are you enjoying AIChat?",
                subtitle: "We'd love to hear your feedback!",
                primaryButtonTitle: "Yes",
                primaryButtonAction: {
                    onYesPressed()
                },
                secondaryButtonTitle: "No",
                secondaryButtonAction: {
                    onNoPressed()
                }
            )
        }
    }
    
    // MARK: Alerts
    
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: buttons)
    }
    
    func showAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
    
    func dismissAlert() {
        
    }
}
