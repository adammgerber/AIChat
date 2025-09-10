//
//  AppView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import SwiftUI

struct AppView: View {
    
    @AppStorage("showTabbarView") var showTabBar: Bool = true
    
    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar")
                }
                .transition(.move(edge: .trailing))
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding")
                }
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
