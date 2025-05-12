//
//  SwiftUIView.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding()
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(UIColor.tintColor))
            )
            .opacity(configuration.isPressed ? 0.6 : 1)
            .shadow(radius: configuration.isPressed ? 4 : 0)
    }
}
