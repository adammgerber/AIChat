//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/5/24.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var presenter: WelcomePresenter
  
    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(urlString: presenter.imageName)
                .ignoresSafeArea()
            
            titleSection
                .padding(.top, 24)
            
            ctaButtons
                .padding(16)
            
            policyLinks
        }
        .screenAppearAnalytics(name: "WelcomeView")
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("AI Chat 🤙")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("YouTube @ SwiftfulThinking")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            Text("Get Started")
                .callToActionButton()
                .anyButton(.press, action: {
                    presenter.onGetStartedPressed()
                })
            
            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    presenter.onSignInPressed()
                }
        }
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceUrl)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    return builder.welcomeView()
        .previewEnvironment()
}
