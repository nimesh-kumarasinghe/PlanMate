//
//  JoinGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct JoinGroupView: View {
    @State private var groupCode: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Navigation header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back")
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
            }
            .padding(.leading)
            
            // Main content
            VStack(spacing: 25) {
                Text("Enter group code or scan a\nQR code to join")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .medium))
                
                TextField("Enter group code", text: $groupCode)
                    .padding()
                    .cornerRadius(8)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 20)
                
                Button(action: {
                    // Join action
                }) {
                    Text("Join")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("CustomBlue"))
                        .cornerRadius(50)
                }
                .padding(.horizontal, 60)
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("or")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    // Scan QR code action
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color("CustomBlue"))
                    .cornerRadius(50)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    JoinGroupView()
}
