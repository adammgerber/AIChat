//
//  AppView.swift
//  AIChatCourse
//
//  Created by Adam Gerber
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.scenePhase) private var scenePhase
    @State var appState: AppState = AppState()

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    print("Entering foreground: resuming session if it was paused")
                    Task {
                        await checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: { _ in
                    logManager.trackEvent(event: Event.enteredBackground)
                },
                onApplicationWillTerminate: nil
            ),
            content: {
                AppViewBuilder(
                    showTabBar: appState.showTabBar,
                    tabbarView: {
                        TabBarView()
                    },
                    onboardingView: {
                        WelcomeView()
                    }
                )
                .environment(appState)
                .task {
                    await checkUserStatus()
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await showATTPromptIfNeeded()
                }
                .onChange(of: appState.showTabBar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await checkUserStatus()
                        }
                    }
                }
            }
        )
    }
    
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        case enteredBackground

        var eventName: String {
            switch self {
            case .existingAuthStart:    return "AppView_ExistingAuth_Start"
            case .existingAuthFail:     return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:        return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:      return "AppView_AnonAuth_Success"
            case .anonAuthFail:         return "AppView_AnonAuth_Fail"
            case .attStatus:            return "AppView_ATTStatus"
            case .enteredBackground:    return "AppView_EnteredBackground"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // User is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated
            logManager.trackEvent(event: Event.anonAuthStart)

            do {
                let result = try await authManager.signInAnonymously()
                
                // log in to app
                logManager.trackEvent(event: Event.anonAuthSuccess)
                
                // Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()

}
#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}
