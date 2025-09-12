//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    
    @State private var isCompletingProfileSetup: Bool = false
    var selectedColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            ctaButton
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var ctaButton: some View {
        Button {
           onFinishedButtonPressed()
        } label: {
            ZStack {
                if isCompletingProfileSetup {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Finish")
                        
                }
            }
            .callToActionButton()
        }
        .disabled(isCompletingProfileSetup)
    }
    
    func onFinishedButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            try await Task.sleep(for: .seconds(3))
            isCompletingProfileSetup = false
            // try await saveUserProfile(color: selectedColor)
            
            // other logic to complete onboarding
            root.updateViewState(showTabbarView: true)
        }
        
    }
}
#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
}
