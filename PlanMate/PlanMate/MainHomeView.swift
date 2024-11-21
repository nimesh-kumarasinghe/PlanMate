//
//  MainHomeView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct MainHomeView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
            
            CalendarView()
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                }
            
            CreateActivityView()
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }
                }
            
            ActivityListView()
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("Activities")
                    }
                }
        }
        .accentColor(Color("CustomBlue"))
    }
}

#Preview {
    MainHomeView()
}
