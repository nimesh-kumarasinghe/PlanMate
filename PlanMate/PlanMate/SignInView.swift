//
//  SignInView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            
            Spacer().frame(height: 30)
            
            Image("PlanMate") // logo
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
            
            Spacer().frame(height: 30)
            
            TextField("Email", text: $email)
                .padding()
                .cornerRadius(10)
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                .padding(.horizontal,20)
            
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
                    // Action
                }) {
                    Text("Forgot password?")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .padding(.horizontal, 5)
                        .padding(.top,1)
                }
                .padding(.trailing)
            }
            .padding(.bottom, 20)
            
            // Sign In Button
            Button(action: {
                // Action
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
            Button(action: {
                // Action
            }) {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Sign In with Apple")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(50)
                .padding(.horizontal, 30)
            }
            .padding(.bottom, 10)
            
            // Google signin
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
            
            // Sign Up
            HStack {
                Text("If you don’t have an account,")
                    .foregroundColor(.black)
                
                Button(action: {
                    // Action for Sign up
                }) {
                    Text("sign up")
                        .foregroundColor(Color("CustomBlue"))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

