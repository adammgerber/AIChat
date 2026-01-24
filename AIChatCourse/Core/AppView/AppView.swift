//
//  AppView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/12/2025.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @State var appState: AppState = AppState()
    
    var body: some View {
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
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            await showATTPromptIfNeeded()
        }
    }
    
    enum Event: LoggableEvent {
        
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart:    return "AppView_ExistingAuth_Start"
            case .existingAuthFail:     return "ApppView_ExistingAuth_Fail"
            case .anonAuthStart:        return "ApppView_AnonAuth_Start"
            case .anonAuthSuccess:      return "ApppView_AnonAuth_Success"
            case .anonAuthFail:         return "ApppView_AnonAuth_Fail"
            case .attStatus:            return "AppView_ATTStatus"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
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
            // user is authd
           // print("User already authenticated: \(user.uid)")
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                //print("Failed to log in to auth for existing user: \(error)")
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // user not authd
            logManager.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await authManager.signInAnonymously()
                
                // log into app
                logManager.trackEvent(event: Event.anonAuthSuccess)
               // print("Sign in ananoymous success: \(result.user.uid)")
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                //print("Failed to sign in anonymously and log in: \(error)")
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
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
}
