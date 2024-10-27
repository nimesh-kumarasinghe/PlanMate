//
//  GetstartedView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI

struct GetstartedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("PlanMate") // logo
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .foregroundColor(.blue)
        
            Spacer().frame(height: 0)
            
            Text("Welcome to PlanMate!")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Spacer().frame(height: 6)
            
            Text("PlanMate is a ultimate app to bring people together. Sign in to effortlessly join groups, propose activities, schedule events, and keep the conversation going all in one place!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            
            Spacer().frame(height: 6)
            
            // SignIn and SignUp buttons
            VStack(spacing: 15) {
                Button(action: {
                    // add action
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("CustomBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 70)
                
                Spacer().frame(height: 0)
                
                Button(action: {
                    // add action
                }) {
                    Text("Create an Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("CustomBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 70)
            }
            
            Spacer().frame(height: 0)
            
            VStack(){
                Text("By continuing, you agree to our")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                HStack(spacing: 5) {
                    Text("Terms of Services")
                        .font(.footnote)
                        .foregroundColor(.blue)
                    
                    Text("and")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text("Privacy Policy")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        GetstartedView()
    }
}

