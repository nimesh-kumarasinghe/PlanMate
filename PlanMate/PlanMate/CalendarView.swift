//
//  CalendarView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showingMonthPicker = false
    @State private var showingDetailView = false
    
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button(action: { showingMonthPicker.toggle() }) {
                            HStack {
                                Text(monthFormatter.string(from: currentMonth))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Profile icon with navigation to AccountView
                        NavigationLink(destination: MyAccountView()) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("All calendars")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                
                // Calendar Grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Days header
                        HStack(spacing: 0) {
                            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 10)
                        .background(Color(UIColor.systemBackground))
                        
                        // Calendar days
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                            ForEach(getDaysInMonth(), id: \.self) { date in
                                if let date = date {
                                    DayCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate)) {
                                        selectedDate = date
                                        showingDetailView = true
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 100)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingMonthPicker) {
                MonthPickerView(currentMonth: $currentMonth, showingMonthPicker: $showingMonthPicker)
            }
            .sheet(isPresented: $showingDetailView) {
                DetailView(date: selectedDate)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add remaining days to complete 6 weeks
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
}

// Day cell view
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.black : Color.clear)
                    )
                    .padding(.top, 8)
                    .padding(.leading, 8)
                
                Spacer()
            }
        }
        .frame(height: 100)
        .background(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// Other Views for Month Picker and Detail
struct MonthPickerView: View {
    @Binding var currentMonth: Date
    @Binding var showingMonthPicker: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Month",
                    selection: $currentMonth,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Month")
            .navigationBarItems(
                trailing: Button("Done") {
                    showingMonthPicker = false
                }
            )
        }
    }
}

struct DetailView: View {
    let date: Date
    @Environment(\.presentationMode) var presentationMode
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .padding()
                
                if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day) {
                    Text("Movie Time")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .navigationTitle("Date Details")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
