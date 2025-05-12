//
//  View+.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func handleLoading(_ isLoading: Binding<Bool>) -> some View {
        self.onChange(of: isLoading.wrappedValue) { newValue in
            newValue ? LoadingView.show() : LoadingView.hide()
        }
    }
    
    func handleAlert(error: Binding<String>? = nil, message: Binding<String>? = nil, title: String = "Notification", alertActionHanler: ((UIAlertAction) -> Void)? = nil) -> some View {
        self.onChange(of: error?.wrappedValue ?? "") { newValue in
            guard !newValue.isEmpty else { return }
            LoadingView.hide()
            AlertDialog.showAlert(title: "Error", message: newValue)
        }
        .onChange(of: message?.wrappedValue ?? "") { newValue in
            guard !newValue.isEmpty else { return }
            AlertDialog.showAlert(title: title, message: newValue, alertActionHanler: alertActionHanler)
        }
    }
}

struct LoadingViewModifier: ViewModifier {
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isLoading ? 4 : 0)
                .disabled(isLoading)
            
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                    .contentShape(Rectangle())
                    .onTapGesture { }
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Loading...")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top, 8)
                }
                .frame(width: 120, height: 120)
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .allowsHitTesting(!isLoading)
        .overlay {
            if isLoading {
                Color.clear
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
                    .onTapGesture { }
            }
        }
    }
}

