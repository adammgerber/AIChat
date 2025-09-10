//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    var body: some View {
        VStack {
            Text("Onboarding Completed!")
                .frame(maxHeight: .infinity)
            
            Button {
               onFinishedButtonPressed()
            } label: {
                Text("Finish")
                    .callToActionButton()
                
            }
        }
        .padding(16)
    }
    
    func onFinishedButtonPressed() {
        // other logic to complete onboarding
        root.updateViewState(showTabbarView: true)
    }
}
#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
