//
//  RegisterView.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import Foundation
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        VStack {
            Text("Register")
                .font(.system(size: 32))
                .padding(.bottom, 40)
            
            AppTextFiledView(label: "Email", text: $viewModel.email)
                .submitLabel(.next)
            AppTextFiledView(label: "Username", text: $viewModel.username)
                .submitLabel(.next)
            AppTextFiledView(label: "Password",type: .security, text: $viewModel.password)
                .submitLabel(.next)
            AppTextFiledView(label: "Confirm password",type: .security, text: $viewModel.confirmPassword)
                .submitLabel(.done)
            Spacer()
            Button("Register") {
                viewModel.validateAndRegister()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
            
            
        }
        .padding(.horizontal, 20)
        .ignoresSafeArea(.keyboard)
        .handleLoading($viewModel.isLoading)
        .handleAlert(error: $viewModel.errorMessage, message: $viewModel.successMessage) { _ in
            UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
        }
    }
}

#Preview {
    RegisterView()
}
