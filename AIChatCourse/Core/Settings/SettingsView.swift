//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    onSignOutPressed()
                } label: {
                    Text("Sign Out")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    func onSignOutPressed() {
        // add logic to sign user out
        dismiss()
        Task {
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabbarView: false)
        }
        
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
