//
//  RegisterView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

struct RegisterAccountView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var navigateToSignIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 20)
                        TextField("Your Name", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 2)
                            )
                            .padding(.horizontal, 10)
                        
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 2)
                            )
                            .padding(.horizontal, 10)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 2)
                            )
                            .padding(.horizontal, 10)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 2)
                            )
                            .padding(.horizontal, 10)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Password must be at least 8 characters long")
                        Text("• Two or more types used out of letters, numbers, and symbols")
                            .fixedSize(horizontal: false, vertical: true)
                        Text("• Matching password")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        registerAccount()
                    }) {
                        Text("Create an Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("CustomBlue"))
                            .cornerRadius(50)
                            .padding(.horizontal, 30)
                    }
                    .disabled(isLoading)
                    
                    Text("or")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    
                    Button(action: {
                        // Handle sign up with Apple
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Sign up with Apple")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(50)
                        .padding(.horizontal, 30)
                    }
                    
                    Button(action: {
                        // Handle sign up with Google
                    }) {
                        HStack {
                            Image("google")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign up with Google")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("If you already have an account,")
                            .foregroundColor(.black)
                        NavigationLink(destination: SignInView()) {
                            Text("sign in")
                                .foregroundColor(Color("CustomBlue"))
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                .navigationTitle("Register Account")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            if isSuccess {
                                navigateToSignIn = true
                            }
                        }
                    )
                }
                .navigationDestination(isPresented: $navigateToSignIn){
                    SignInView()
                }

                // show loading
                if isLoading {
                    LoadingScreen()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func showError(_ title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isSuccess = false
        showAlert = true
    }
    
    func showSuccess(message: String) {
        alertTitle = "Success"
        alertMessage = message
        isSuccess = true
        showAlert = true
    }
    
    func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func isPasswordComplex(_ password: String) -> Bool {
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbol = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        // Check if at least two of the three conditions are true
        let complexityCount = [hasLetter, hasNumber, hasSymbol].filter { $0 }.count
        return complexityCount >= 2
    }

    
    func registerAccount() {
        // Input validation
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showError("Error", message: "Please fill in all the fields.")
            return
        }
        
        guard password == confirmPassword else {
            showError("Error", message: "Passwords do not match.")
            return
        }
        
        guard password.count >= 8 else {
            showError("Error", message: "Password must be at least 8 characters long.")
            return
        }
        
        guard isPasswordComplex(password) else {
            showError("Error", message: "Password must contain at least two of the following: letters, numbers, and symbols.")
            return
        }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                showError("Registration Error", message: error.localizedDescription)
                isLoading = false
                return
            }
            
            guard let uid = result?.user.uid else {
                showError("Error", message: "Failed to get user ID.")
                isLoading = false
                return
            }
            
            let hashedPassword = hashPassword(password)
            
            let data: [String: Any] = [
                "name": name,
                "email": email,
                "password": hashedPassword
            ]
            
            Firestore.firestore().collection("users").document(uid).setData(data) { error in
                isLoading = false
                
                if let error = error {
                    showError("Database Error", message: error.localizedDescription)
                } else {
                    showSuccess(message: "Account created successfully! Please sign in to continue.")
                }
            }
        }
    }
    
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 10)
                )
        }
    }
}

struct RegisterAccountView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterAccountView()
    }
}
