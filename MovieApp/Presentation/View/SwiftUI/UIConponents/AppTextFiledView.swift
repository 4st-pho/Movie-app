//
//  AppTextFiledView.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import SwiftUI

struct AppTextFiledView: View {
    enum AppTextFiledType {
        case normal
        case security
    }
    var label: String = ""
    var placeholder: String = ""
    var type: AppTextFiledType = .normal
    @Binding var text: String
    @State private var isSecured: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.appOutlineBorder), lineWidth: 1)
                .overlay {
                    if type == .normal {
                        TextField(placeholder, text: $text)
                            .textInputAutocapitalization(.never)
                            .controlSize(.large)
                            .padding(.horizontal)
                    } else {
                        HStack {
                            if isSecured {
                                SecureField(placeholder, text: $text)
                                    .textInputAutocapitalization(.never)
                                    .controlSize(.large)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                            } else {
                                TextField(placeholder, text: $text)
                                    .textInputAutocapitalization(.never)
                                    .controlSize(.large)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button {
                                isSecured.toggle()
                            } label: {
                                if isSecured {
                                    Image(systemName: "eye.slash")
                                        .tint(Color(.appTintColor))
                                } else {
                                    Image(systemName: "eye")
                                        .tint(Color(.appTintColor))
                                }
                            }
                            
                            SizeView(width: 10)
                            
                        }
                    }
                }
                .background(Color(.appBackgroudTextField))
                .frame(height: 46)
        }
    }
}
