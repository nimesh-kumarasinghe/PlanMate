//
//  GroupDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct GroupDetailView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Navigation Header
                HStack {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Office")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Edit")
                        .foregroundColor(.blue)
                }
                .padding()
                
                // Month Navigation
                HStack {
                    Text(monthYearString(from: currentMonth))
                        .font(.headline)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { moveMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { moveMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Week Headers
                HStack {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 10)
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            let day = calendar.component(.day, from: date)
                            let isToday = calendar.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: { selectedDate = date }) {
                                Text("\(day)")
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(isToday ? Color.blue : Color.clear)
                                    .foregroundColor(isToday ? .white : .primary)
                                    .clipShape(Circle())
                            }
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {}) {
                        HStack {
                            Text("Propose an Activity")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Get Join Code or QR")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                // Proposed Activities List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Proposed Activities")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(activities, id: \.title) { activity in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(activity.title)
                                    .font(.subheadline)
                                Text("from \(activity.from)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // Helper functions
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func daysInMonth() -> [Date?] {
        var days: [Date?] = []
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Add empty days for first week
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days of the month
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}

// Model
struct ActivityInfo {
    let title: String
    let from: String
}

let activities = [
    ActivityInfo(title: "October day out", from: "Cousins"),
    ActivityInfo(title: "Next hiking trip", from: "Trip Friends"),
    ActivityInfo(title: "November party", from: "Office")
]

// Preview
struct GroupCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetailView()
    }
}
