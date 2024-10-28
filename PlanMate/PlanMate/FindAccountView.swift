//
//  FindAccountView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct FindAccountView: View {
    @State private var email = ""
    
    var body: some View {
        VStack {
            // Title
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
            
            Text("Enter your email address to find & get the verification code")
                .font(.title3)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 60)
            
            // Verification Code Input
            TextField("Verification Code", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            // Verify Button
            Button(action: {
                // Handle verify button action here
            }) {
                Text("Verify")
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
        .navigationBarHidden(true)
    }
}

struct FindAccountView_Previews: PreviewProvider {
    static var previews: some View {
        FindAccountView()
    }
}
