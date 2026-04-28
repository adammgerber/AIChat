//
//  CoreBuilder.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 15/04/2026.
//

import SwiftUI
import RoutingPro

typealias RouterView = RoutingPro.RouterView

@MainActor
struct CoreRouter {
    let router: Router
    let builder: CoreBuilder
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            builder.categoryListView(delegate: delegate)
        }
    }
    
    func showChatView(delegate: ChatViewDelegate) {
        router.showScreen(.push) { router in
            builder.chatView(delegate: delegate)
        }
    }
    
    func showDevSettings() {
        router.showScreen(.sheet) { router in
            builder.devSettingsView()
        }
    }
    
    func showCreateAccountView(delegate: CreateAccountDelegate) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(delegate: delegate)
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
    
    // MARK: Alerts
}

@MainActor
struct CoreBuilder {
    let interactor: CoreInteractor
    
    func appView() -> AnyView {
        AppView(
            viewModel: AppViewModel(interactor: interactor),
            tabbarView: {
                tabBarView()
            },
            onBoardingView: {
                welcomeView()
            }
        )
        .any()
    }
    
    func tabBarView() -> AnyView {
        TabBarView(
            tabs: [
                TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
                    RouterView { router in
                        exploreView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
                    chatsView()
                }),
                TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                    profileView()
                })
            ]
        )
        .any()
    }
    
    func welcomeView() -> AnyView {
        WelcomeView(
            viewModel: WelcomeViewModel(
                interactor: interactor
            ),
            createAccountView: { delegate in
                createAccountView(delegate: delegate)
            },
            onboardingColorView: { delegate in
                onboardingColorView(delegate: delegate)
            },
            onboardingIntroView: { delegate in
                onboardingIntroView(delegate: delegate)
            },
            onboardingCompletedView: { delegate in
                onboardingCompletedView(delegate: delegate)
            }
        )
        .any()
    }
    
    func onboardingColorView(delegate: OnboardingColorDelegate) -> AnyView {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingCompletedView(delegate: OnboardingCompletedDelegate) -> AnyView {
        OnboardingCompletedView(
            viewModel: OnboardingCompleteViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingIntroView(delegate: OnboardingIntroDelegate) -> AnyView {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func createAccountView(delegate: CreateAccountDelegate = CreateAccountDelegate()) -> AnyView {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    func chatsView() -> AnyView {
        ChatsView(
            viewModel: ChatsViewModel(
                interactor: interactor
            ),
            chatRowCell: { delegate in
                chatRowCell(delegate: delegate)
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    func chatView(delegate: ChatViewDelegate = ChatViewDelegate()) -> AnyView {
        ChatView(
            viewModel: ChatViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func categoryListView(delegate: CategoryListDelegate) -> AnyView {
        CategoryListView(
            viewModel: CategoryListViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    func createAvatarView() -> AnyView {
        CreateAvatarView(
            viewModel: CreateAvatarViewModel(
                interactor: interactor
            )
        )
        .any()
    }
    
    func exploreView(router: Router) -> AnyView {
        ExploreView(
            viewModel: ExploreViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
            
        )
        .any()
    }
    
    func devSettingsView() -> AnyView {
        DevSettingsView(
            viewModel: DevSettingsViewModel(
                interactor: interactor
            )
        )
        .any()
    }
    
    func settingsView() -> AnyView {
        SettingsView(
            viewModel: SettingsViewModel(
                interactor: interactor
            ),
            createAccountView: {
                createAccountView()
            }
        )
        .any()
    }
    
    func profileView() -> AnyView {
        ProfileView(
            viewModel: ProfileViewModel(interactor: interactor),
            settingsView: {
                settingsView()
            },
            createAvatarView: {
                createAvatarView()
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    // MARK: CELLS
    
    func chatRowCell(delegate: ChatRowCellDelegate = ChatRowCellDelegate()) -> AnyView {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
}
