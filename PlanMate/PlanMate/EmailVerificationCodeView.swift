//
//  EmailVerificationCodeView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct EmailVerificationCodeView: View {
    @State private var verificationCode = ""
    
    var body: some View {
        VStack {
            // Title
            Text("Verify Account")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer().frame(height: 30)
            
            VStack {
                Image("otp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 230, height: 230)
                    .padding(.bottom, 20)
                
                Text("Enter verification code which we sent to your email.")
                    .font(.title3)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer().frame(height: 60)
            
            // Verification Code Input
            TextField("Verification Code", text: $verificationCode)
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
        .frame(maxHeight: .infinity, alignment: .top) // Forces VStack content to align at the top
    }
}

struct VerifyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationCodeView()
    }
}


