//
//  TaskBarView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

//struct TaskBar: View {
//    @State private var selectedTab = 0
//
//    var body: some View {
//        HStack {
//            Spacer()
//
//            // Home Tab
//            Button(action: {
//                selectedTab = 0
//                
//            }) {
//                VStack {
//                    Image(selectedTab == 0 ? "homefill" : "home")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                    Text("Home")
//                        .font(.system(size: 12))
//                }
//                .foregroundColor(selectedTab == 0 ? Color("CustomBlue") : .black)
//            }
//
//            Spacer()
//
//            // Calendar Tab
//            Button(action: {
//                selectedTab = 1
//            }) {
//                VStack {
//                    Image(selectedTab == 1 ? "calendarfill" : "calendar")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                    Text("Calendar")
//                        .font(.system(size: 12))
//                }
//                .foregroundColor(selectedTab == 1 ? Color("CustomBlue") : .black)
//            }
//
//            Spacer()
//
//            // Create Tab
//            Button(action: {
//                selectedTab = 2
//            }) {
//                VStack {
//                    Image(selectedTab == 2 ? "addfill" : "add")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                    Text("Create")
//                        .font(.system(size: 12))
//                }
//                .foregroundColor(selectedTab == 2 ? Color("CustomBlue") : .black)
//            }
//
//            Spacer()
//
//            // Activities Tab
//            Button(action: {
//                selectedTab = 3
//            }) {
//                VStack {
//                    Image(selectedTab == 3 ? "activitiesfill" : "activities")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                    Text("Activities")
//                        .font(.system(size: 12))
//                }
//                .foregroundColor(selectedTab == 3 ? Color("CustomBlue") : .black)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(Color.white.shadow(radius: 2))
//    }
//}
//
//struct BottomNavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskBar()
//            .previewLayout(.sizeThatFits)
//    }
//}


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

            //CreateActivityView()
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
