//
//  OnboardingPathOption.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 18/04/2026.
//

import SwiftUI
import Foundation

enum OnboardingPathOption: Hashable {
    case colorView
//    case communityView
    case introView
    case completedView(selectedColor: Color)
}

struct NavDestForOnboardingModuleViewModifier: ViewModifier {
    
    let path: Binding<[OnboardingPathOption]>
    @ViewBuilder var onboardingColorView: (OnboardingColorDelegate) -> AnyView
    @ViewBuilder var onboardingIntroView: (OnboardingIntroDelegate) -> AnyView
    @ViewBuilder var onboardingCompletedView: (OnboardingCompletedDelegate) -> AnyView
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    onboardingColorView(OnboardingColorDelegate(path: path))
                case .introView:
                    onboardingIntroView(OnboardingIntroDelegate(path: path))
                case .completedView(selectedColor: let selectedColor):
                    onboardingCompletedView(OnboardingCompletedDelegate(selectedColor: selectedColor))
                }
            }
    }
}

extension View {
    
    func navigationDestinationForOnboardingModule(
        path: Binding<[OnboardingPathOption]>,
        @ViewBuilder onboardingColorView: @escaping (OnboardingColorDelegate) -> AnyView,
        @ViewBuilder onboardingIntroView: @escaping (OnboardingIntroDelegate) -> AnyView,
        @ViewBuilder onboardingCompletedView: @escaping (OnboardingCompletedDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavDestForOnboardingModuleViewModifier(
                path: path,
                onboardingColorView: onboardingColorView,
                onboardingIntroView: onboardingIntroView,
                onboardingCompletedView: onboardingCompletedView
            )
        )
    }
}
