//
//  View+EXT.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/09/2025.
//

import Foundation
import SwiftUI

extension View {
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent)
            .cornerRadius(16)
    }
}
