//
//  SignInView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI
import AuthenticationServices
import Firebase
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @State private var navigateToHome: Bool = false
    @AppStorage("log_status") private var logStatus: Bool = false
    @State private var showResetPassword: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 30)
                
                Image("PlanMate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                Spacer().frame(height: 30)
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                Spacer().frame(height: 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                // Forgot Password
                HStack {
                    Spacer()
                    Button(action: {
                        showResetPassword = true
                    }) {
                        Text("Forgot password?")
                            .foregroundColor(.blue)
                            .font(.footnote)
                            .padding(.horizontal, 5)
                            .padding(.top, 1)
                    }
                    .padding(.trailing)
                }
                .padding(.bottom, 20)
                
                // Sign In Button
                Button(action: {
                    handleEmailPasswordSignIn()
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.headline)
                        .background(Color("CustomBlue"))
                        .cornerRadius(50)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 10)
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding(.vertical, 5)
                
                // Sign In with Apple
                SignInWithAppleButton(.continue) { request in
                    let nonce = randomNonceString()
                    self.nonce = nonce
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        loginWithFirebase(authorization)
                    case .failure(let error):
                        showError(error.localizedDescription)
                    }
                }
                .frame(height: 55)
                .cornerRadius(50)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                // Google Sign-In Button
                Button(action: {
                    handleGoogleSignIn()
                }) {
                    HStack {
                        Image("google")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Continue with Google")
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
                
                // Sign Up
                HStack {
                    Text("If you don't have an account,")
                        .foregroundColor(.black)
                    
                    NavigationLink(destination: RegisterAccountView()) {
                        Text("sign up")
                            .foregroundColor(Color("CustomBlue"))
                            .fontWeight(.bold)
                    }
                    .navigationBarBackButtonHidden(true)
                }
                .padding(.bottom, 20)
            }
            .alert(errorMessage, isPresented: $showAlert) { }
//            .alert("Reset Password", isPresented: $showResetPassword) {
//                TextField("Enter your email", text: $email)
//                Button("Cancel", role: .cancel) { }
//                Button("Reset") {
//                    handlePasswordReset()
//                }
//            } message: {
//                Text("Enter your email to receive a password reset link")
//            }
            .overlay {
                if isLoading {
                    LoadingScreen()
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MainHomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $showResetPassword) {
                FindAccountView()
                    .navigationBarBackButtonHidden(false)
                    .navigationBarHidden(false)
            }
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    // Firebase Authentication with Email/Password
    private func handleEmailPasswordSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            showError("Please fill in all fields")
            return
        }
        
        isLoading = true
        
        // Firebase Auth sign-in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                // Display error message
                showError("Invalid email or password. Please try again.")
                print("Sign-in error: \(error.localizedDescription)")
                return
            }
            
            // If sign-in successful, update login status and navigate to home
            logStatus = true
            navigateToHome = true
        }
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
            
            showError("Password reset email sent successfully")
        }
    }
    
    // Google Sign In
    func handleGoogleSignIn() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showError("Google Sign In configuration error")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showError("Cannot find root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                showError("Cannot get user data from Google")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else {
                    self.showError("Could not retrieve user data.")
                    return
                }
                
                logStatus = true
                isLoading = false
                navigateToHome = true
                
                // Store user data in Firestore
                let data: [String: Any] = [
                    "name": user.displayName ?? "",
                    "email": user.email ?? "",
                    "uid": user.uid
                ]
                Firestore.firestore().collection("users").document(user.uid).setData(data) { error in
                    if let error = error {
                        self.showError("Database Error")
                    }
                }
            }
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
    
    func loginWithFirebase(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            isLoading = true
            guard let nonce else {
                showError("Cannot process your request.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                showError("Cannot process your request.")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError("Cannot process your request.")
                return
            }
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                         rawNonce: nonce,
                                                         fullName: appleIDCredential.fullName)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    showError(error.localizedDescription)
                    print("Failed Sign-in: \(error.localizedDescription)")
                    return
                }
                logStatus = true
                isLoading = false
                navigateToHome = true
                print("Success Sign-in")
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
