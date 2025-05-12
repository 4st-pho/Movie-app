//
//  LoginView.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Login")
                .font(.system(size: 32))
            
            SizeView(height: 40)
            
            AppTextFiledView(label: "Username", text: $viewModel.username)
                .submitLabel(.continue)
            
            AppTextFiledView(label: "Password", type: .security, text: $viewModel.password)
                .submitLabel(.done)
            
            SizeView(height: 20)
            HStack{
                Text("Don't have an account? ")
                Text("Register")
                    .foregroundColor(Color(.tintColor))
                    .onTapGesture {
                        UIApplication.topViewController()?.navigationController?.pushView(RegisterView(), animated: true)
                    }
            }
            
            Spacer()
            
            Button("Login") {
                viewModel.login()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            SizeView(height: 40)
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.keyboard)
//        .modifier(LoadingViewModifier(isLoading: $viewModel.isLoading))
        .handleLoading($viewModel.isLoading)
        .handleAlert(error: $viewModel.errorMessage)
    }
}

#Preview {
    LoginView()
}
