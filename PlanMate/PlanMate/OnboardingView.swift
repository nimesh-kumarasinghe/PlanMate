//
//  OnboardingView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 1 // check current page
    
    var body: some View {
        VStack {
            // condition for switch pages
            if currentPage == 1 {
                OnboardingScreen(
                    imageName: "group-create",
                    title: "Create Groups and Plan Activities Together",
                    description: "Effortlessly create or join groups to start planning with your friends. Propose activities, share ideas, and let everyone vote on their favorite options, ensuring every event is something the whole group enjoys.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    showBackButton: false
                )
            } else if currentPage == 2 {
                OnboardingScreen(
                    imageName: "auto-schedule",
                    title: "Auto-Schedule Around Everyone’s Availability",
                    description: "No more back-and-forth! Our smart auto-scheduling feature finds the perfect time for your group, based on everyone’s availability, so you can focus on the fun.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    showBackButton: true
                )
            } else if currentPage == 3 {
                OnboardingScreen(
                    imageName: "chats",
                    title: "Real-Time Chat for Every Event",
                    description: "Stay connected with your group using real-time chat for each event. Share details, updates, and excitement, all in one place.",
                    currentPage: $currentPage,
                    totalPages: 3,
                    showBackButton: true
                )
            }
        }
    }
}

// onboardingScreen ui component
struct OnboardingScreen: View {
    var imageName: String
    var title: String
    var description: String
    @Binding var currentPage: Int
    let totalPages: Int
    let showBackButton: Bool
    
    var body: some View {
        VStack {
            // Top Navigation for Skip
            HStack {
                Spacer()
                Button("Skip") {
                    navigateToMainApp()
                }
                .padding()
                .foregroundColor(.blue)
            }
            Spacer().frame(height: 30)
            
            // Main content
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 230)
            
            Spacer().frame(height: 20)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
            
            // Page Indicator Dots
            HStack(spacing: 8) {
                ForEach(1...totalPages, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 20)
            
                        HStack {
                            if showBackButton {
                                Button("Back") {
                                    if currentPage > 1 {
                                        currentPage -= 1
                                    }
                                }
                                .padding(.leading, 30)
                                .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if currentPage < totalPages {
                                    currentPage += 1
                                } else {
                                    navigateToMainApp()
                                }
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 30)
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                // temp page for final next page
                func navigateToMainApp() {
                    print("Navigate to main app")
                }
            }

            // Preview
            struct OnboardingView_Previews: PreviewProvider {
                static var previews: some View {
                    OnboardingView()
                }
            }

