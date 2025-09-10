//
//  AppViewBuilder.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import SwiftUI

struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {
    var showTabBar: Bool = true
    @ViewBuilder var tabbarView: TabbarView
    @ViewBuilder var onboardingView: OnboardingView
    var body: some View {
        ZStack {
            if showTabBar {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar")
                }
                .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding")
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {
    
    @State private var showTabBar: Bool = true
    
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
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}
#Preview {
    PreviewView()
}
