//
//  SplashScreenView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI
import FirebaseAuth

struct SplashScreenView: View {
    
    @State private var isActive: Bool = false
    @StateObject private var appStateManager = AppStateManager()
    @AppStorage("log_status") private var logStatus: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                if isActive {
                    if appStateManager.hasCompletedOnboarding{
                        if logStatus {
                            MainHomeView()
                        } else {
                            SignInView()
                        }
                    }
                    else{
                        OnboardingView(appStateManager: AppStateManager())
                    }
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SplashScreenView()
}

