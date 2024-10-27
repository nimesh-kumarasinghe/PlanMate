//
//  SplashScreenView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI

struct SplashScreenView: View {
    // check splash screen active
    @State private var isActive: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isActive {
                    // afters plash screen navigate to onboarding
                   OnboardingView()
                    
                } else {
                    VStack {
                        Spacer()
                        Image("PlanMate")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                        
                        Spacer()
                    }
                    .onAppear {
                        // timmer for splashscreen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true) // Hide navigation bar during splash screen
    }
}

// Temporary next page
struct Next: View {
    var body: some View {
        Text("Welcome to PlanMate!")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    SplashScreenView()
}

