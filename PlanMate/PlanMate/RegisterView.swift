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

struct RegisterAccountView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Register Account")
                    .font(.title3)
                    .bold()

                VStack(spacing: 16) {
                    TextField("Your Name", text: $name)
                        .padding()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 10)

                    TextField("Email", text: $email)
                        .padding()
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
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 10)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 10)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("• 8-64 characters")
                    Text("• Two or more types used out of letters, numbers, and symbols")
                        .fixedSize(horizontal: false, vertical: true)
                    Text("• Matching password")
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

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
                        Image("google") // Replace with Google icon if available
                            .resizable()
                            .frame(width: 20, height: 20) // Adjust size as needed
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
        }
        .navigationBarHidden(true)
    }

    func registerAccount() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all the fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                isLoading = false
                return
            }

            guard let uid = result?.user.uid else {
                errorMessage = "Failed to get user ID."
                isLoading = false
                return
            }

            let data: [String: Any] = [
                "name": name,
                "email": email,
                "password": password
            ]

            Firestore.firestore().collection("users").document(uid).setData(data) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    // Account creation successful
                    // You can navigate to the next screen or perform additional actions
                }
                isLoading = false
            }
        }
    }
}

struct RegisterAccountView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterAccountView()
    }
}
