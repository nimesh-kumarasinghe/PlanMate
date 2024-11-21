//
//  FindAccountView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseAuth

struct FindAccountView: View {
    @State private var email = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Find Account")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer().frame(height: 30)
            
            Image("email")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(.bottom, 24)
            
            Text("Enter your email address to find & get the resert password link")
                .font(.title3)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 60)
            
            // Verification Code Input
            TextField("Email address", text: $email)
                .padding()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray3), lineWidth: 2)
                )
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            // Verify Button
            Button(action: {
                handlePasswordReset()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("CustomBlue"))
                    .cornerRadius(50)
                    .padding(.horizontal, 50)
            }
            .padding(.bottom, 40)
            
            Spacer()
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        alertTitle = "Reset Password"
        alertMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    // Password Reset
    private func handlePasswordReset() {
        guard !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            showError("If the email is registered, you will receive a password reset link shortly.")
        }
    }
    
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemBackground))
                )
        }
    }
}

struct FindAccountView_Previews: PreviewProvider {
    static var previews: some View {
        FindAccountView()
    }
}
