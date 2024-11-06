//
//  ResetPasswordView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack() {
            // Title
            Text("Find Account")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer().frame(height: 40)
            
            Image("reset")
                .resizable()
                .scaledToFit()
                .frame(height: 230)
                .padding(.bottom, 24)
            
            Text("Enter your new password and confirm it.")
                .font(.title3)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 40)
            
            // Password Fields
            VStack(spacing: 16) {
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 40)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 40)
            }
            Spacer().frame(height: 30)
            // Reset Button
            Button(action: {
                // Handle reset password action
            }) {
                Text("Reset Password")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("CustomBlue"))
                    .foregroundColor(.white)
                    .cornerRadius(50)
                    .padding(.horizontal, 50)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(false)
    }
}

#Preview{
    ResetPasswordView()
}
