//
//  OnboardingView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appStateManager: AppStateManager
    @State private var currentPage = 1
    @State private var navigateToGetStarted = false
    private let totalPages = 3
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HStack {
                    Spacer()
                    Button("Skip") {
                        navigateToGetStarted = true
                    }
                    .padding()
                    .foregroundColor(.gray)
                }
                
                // Swipeable content image and text
                TabView(selection: $currentPage) {
                    ForEach(1...totalPages, id: \.self) { page in
                        OnboardingScreenContent(page: page)
                            .tag(page)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // disables default dots
                .frame(height: 500)
                
                Spacer()
                
                // Custom Indicator Dots
                HStack(spacing: 8) {
                    ForEach(1...totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                // Bottom Navigation Buttons
                HStack {
                    if currentPage > 1 {
                        Button("Back") {
                            if currentPage > 1 {
                                currentPage -= 1
                            }
                        }
                        .padding(.leading, 30)
                        .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    if currentPage == totalPages {
                        Button(action: {
                            navigateToGetStarted = true
                        }) {
                            HStack {
                                Text("Get Started")
                                    .padding(15)
                                    .background(Color("CustomBlue"))
                                    .foregroundColor(.white)
                                    .cornerRadius(50)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.trailing, 30)
                    } else {
                        Button(action: {
                            if currentPage < totalPages {
                                currentPage += 1
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color("CustomBlue"))
                                    .frame(width: 44, height: 44)
                                
                                Image("next")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 30)
                    }
                }
                .padding(.bottom, 20)
                .navigationDestination(isPresented: $navigateToGetStarted){
                    GetstartedView(appStateManager: appStateManager)
                        .navigationBarBackButtonHidden(true)
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// Onboarding content
struct OnboardingScreenContent: View {
    let page: Int
    
    var body: some View {
        VStack {
            if page == 1 {
                OnboardingPageView(
                    imageName: "group-create",
                    title: "Create Groups and Plan Activities Together",
                    description: "Effortlessly create or join groups to start planning with your friends. Propose activities, share ideas, and let everyone vote on their favorite options, ensuring every event is something the whole group enjoys."
                )
            } else if page == 2 {
                OnboardingPageView(
                    imageName: "auto-schedule",
                    title: "Auto-Schedule Around Everyone’s Availability",
                    description: "No more back-and-forth! Our smart auto-scheduling feature finds the perfect time for your group, based on everyone’s availability, so you can focus on the fun."
                )
            } else if page == 3 {
                OnboardingPageView(
                    imageName: "chats",
                    title: "Real-Time Chat for Every Event",
                    description: "Stay connected with your group using real-time chat for each event. Share details, updates, and excitement, all in one place."
                )
            }
        }
        .padding(.horizontal, 40)
    }
}

// Onboarding View Ui
struct OnboardingPageView: View {
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        VStack {
            Spacer().frame(height: 30)
            
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
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            
            Spacer()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(appStateManager: AppStateManager())
    }
}

