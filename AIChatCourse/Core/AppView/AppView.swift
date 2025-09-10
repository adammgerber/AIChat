//
//  AppView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import SwiftUI

struct AppView: View {
    
    @AppStorage("showTabbarView") var showTabBar: Bool = false
    
    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
                .transition(.move(edge: .leading))
            }
        )
        .animation(.smooth, value: showTabBar)
        
    }
}

#Preview("AppView - Onboarding"){
    AppView(showTabBar: false)
}
#Preview("AppView - Tabbar") {
    AppView(showTabBar: true)
}
