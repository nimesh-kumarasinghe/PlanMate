//
//  JoinGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct JoinGroupView: View {
    @State private var groupCode: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter group code or scan a\nQR code to join")
                    .font(.system(size: 17))
                    .padding(.top, 40)
                
                TextField("Enter group code", text: $groupCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 24)
                
                Button(action: {
                    // Action for Join button
                }) {
                    Text("Join")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                
                HStack {
                    Divider().frame(height: 1).background(Color.gray)
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                    Divider().frame(height: 1).background(Color.gray)
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    // Action for Scan QR Code button
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Join a Group")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct JoinGroupView_Previews: PreviewProvider {
    static var previews: some View {
        JoinGroupView()
    }
}
