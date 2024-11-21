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
import GoogleSignIn
import AuthenticationServices
import FirebaseCore

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
    @State private var navigateToHome = false
    @State private var nonce = ""
    @State private var googleSignInSuccess = false
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userid: String = ""
    
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
                        .padding(.top, 5)
                    
                    
                    
                    // Apple Sign In Button
                    SignInWithAppleButton(.continue){ request in
                        let nonce = randomNonceString()
                        self.nonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    }
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        loginWithApple(authResults)
                    case .failure(let error):
                        showError("Apple Sign In Failed", message: error.localizedDescription)
                    }
                }
                    
                .frame(height: 55)
                .cornerRadius(50)
                .padding(.horizontal, 30)
                .padding(.bottom, 5)
                    
                    // Google Sign In Button
                    Button(action: {
                        signUpWithGoogle()
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
                            handleAlertDismiss()
                            
                        }
                    )
                }
                .navigationDestination(isPresented: $navigateToSignIn) {
                    SignInView()
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    MainHomeView()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                }
                
                // Show loading indicator
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
        googleSignInSuccess = false
    }
    
    func showSuccessGoogle(message: String){
        alertTitle = "Success"
        alertMessage = message
        googleSignInSuccess = true
        showAlert = true
        isSuccess = false
    }
    
    func handleAlertDismiss() {
        if googleSignInSuccess {
            navigateToHome = true
            logStatus = true
        } else if isSuccess {
            navigateToSignIn = true
        }
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
            
            let data: [String: Any] = [
                "name": name,
                "email": email,
                "uid": uid
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
    
    func signUpWithGoogle() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.showError("Google Sign In configuration error", message:"Google Sign In configuration error")
            return
        }
        
        // Configure Google Sign-In with the client ID
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the root view controller for presenting the sign-in screen
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showError("Cannot find root view controller", message:"Cannot find root view controller")
            return
        }
        
        // Perform Google Sign-In
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            self.isLoading = false
            
            if let error = error {
                self.showError("Google Sign-In Error", message: error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showError("Google Sign-In Error", message: "Cannot get user data from Google.")
                return
            }
            
            // Create Firebase credentials with Google ID token
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // Sign in to Firebase with Google credentials
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showError("Firebase Error", message: error.localizedDescription)
                    return
                }
                
                guard let user = authResult?.user else {
                    self.showError("Error", message: "Could not retrieve user data.")
                    return
                }
                
                // Store user data in Firestore
                let data: [String: Any] = [
                    "name": user.displayName ?? "",
                    "email": user.email ?? "",
                    "uid": user.uid
                ]
                
                // Store username in @AppStorage
                userName = user.displayName ?? ""
                userid = user.uid
                
                Firestore.firestore().collection("users").document(user.uid).setData(data) { error in
                    if let error = error {
                        self.showError("Database Error", message: error.localizedDescription)
                    } else {
                        showSuccessGoogle(message: "Continue with Google successfully!")
                    }
                }
            }
        }
    }
    
    // Continue with apple
    func loginWithApple(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            isLoading = true
            
            // Retrieve the Apple ID token
            guard let appleIDToken = appleIDCredential.identityToken else {
                showError("Error", message: "Cannot process your request.")
                return
            }
            
            // Convert the token to a string format
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError("Error", message: "Cannot process your request.")
                return
            }
            
            // Use the new method to create OAuth credentials for Apple Sign-In
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenString,
                rawNonce: nonce,
                accessToken: nil // Optional accessToken parameter; set to `nil` for Apple
            )
            
            // Sign in to Firebase using the credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    showError("Authentication Error", message: error.localizedDescription)
                    isLoading = false
                    return
                }
                
                guard let user = authResult?.user else {
                    showError("Error", message: "Could not retrieve user data.")
                    isLoading = false
                    return
                }
                
                // Get the user's name from Apple ID credential
                var userName = user.displayName ?? ""
                if let fullName = appleIDCredential.fullName {
                    userName = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")"
                }
                
                // Prepare user data for Firestore
                let userData: [String: Any] = [
                    "name": userName,
                    "email": user.email ?? "",
                    "uid": user.uid,
                    "signInProvider": "apple"
                ]
                
                // Store user data in Firestore
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    isLoading = false
                    
                    if let error = error {
                        showError("Database Error", message: error.localizedDescription)
                    } else {
                        showSuccess(message: "Successfully signed in with Apple!")
                        navigateToHome = true
                        logStatus = true
                    }
                }
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
