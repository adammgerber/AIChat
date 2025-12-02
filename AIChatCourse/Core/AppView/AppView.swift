//
//  AppView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 02/12/2025.
//

import SwiftUI

struct AppView: View {
    
    @AppStorage("showTabbarView") var showTabBar: Bool = false
    
    var body: some View {
        ZStack {
            AppViewBuilder(
                showTabBar: showTabBar,
                tabbarView: {
                    ZStack {
                        Color.red.ignoresSafeArea()
                        Text("tabBar")
                    }
                },
                onboardingView: {
                    ZStack {
                        Color.blue.ignoresSafeArea()
                        Text("ONboarding")
                    }
                }
            )
        }
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}
