//
//  CalendarView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Models
struct GroupEvent: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var groupId: String
    var groupName: String
    var isAllDay: Bool
    var locations: [EventLocation]
    var notes: [String]
    var participants: [String]
    var reminder: String
    var startDate: Timestamp
    var endDate: Timestamp
    var tasks: [EventTask]
    var urls: [String]
    var updatedAt: Timestamp?
}

struct EventLocation: Codable {
    var address: String
    var category: String
    var latitude: Double
    var longitude: Double
    var name: String
}

struct EventTask: Codable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
}

// MARK: - View Model
class ActivitiesViewModel: ObservableObject {
    @Published var activities: [GroupEvent] = []
    @Published var userActivities: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    init() {
        fetchUserActivities()
    }
    
    func fetchUserActivities() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let data = snapshot?.data(),
               let activities = data["activities"] as? [String] {
                self.userActivities = activities
                print("Found \(activities.count) activity IDs for user")
            } else {
                self.errorMessage = "No activities found"
            }
        }
    }
    
    func fetchActivities(for date: Date) {
        guard !userActivities.isEmpty else {
            self.errorMessage = "No activities available"
            return
        }
        
        isLoading = true
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("activities")
            .whereField(FieldPath.documentID(), in: userActivities)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                let filteredActivities = snapshot?.documents.compactMap { document -> GroupEvent? in
                    do {
                        var activity = try document.data(as: GroupEvent.self)
                        activity.id = document.documentID
                        
                        let activityDate = activity.startDate.dateValue()
                        if calendar.isDate(activityDate, inSameDayAs: date) {
                            return activity
                        }
                        return nil
                    } catch {
                        print("Error decoding activity: \(error)")
                        return nil
                    }
                } ?? []
                
                DispatchQueue.main.async {
                    self.activities = filteredActivities
                }
            }
    }
    
    func hasActivities(for date: Date) -> Bool {
        let calendar = Calendar.current
        return activities.contains { activity in
            calendar.isDate(activity.startDate.dateValue(), inSameDayAs: date)
        }
    }
}

// MARK: - Views
struct CalendarView: View {
    @StateObject private var viewModel = ActivitiesViewModel()
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
                CalendarHeaderView(
                    currentMonth: currentMonth,
                    showingMonthPicker: $showingMonthPicker,
                    monthFormatter: monthFormatter
                )
                
                // Calendar Grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Days header
                        WeekdayHeaderView()
                        
                        // Calendar days
                        CalendarGridView(
                            currentMonth: currentMonth,
                            selectedDate: $selectedDate,
                            showingDetailView: $showingDetailView,
                            viewModel: viewModel
                        )
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .sheet(isPresented: $showingMonthPicker) {
                MonthPickerView(currentMonth: $currentMonth, showingMonthPicker: $showingMonthPicker)
            }
            .sheet(isPresented: $showingDetailView) {
                DetailView(date: selectedDate, viewModel: viewModel)
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchUserActivities()
            }
        }
    }
}

struct CalendarHeaderView: View {
    let currentMonth: Date
    @Binding var showingMonthPicker: Bool
    let monthFormatter: DateFormatter
    
    var body: some View {
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
                .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: MyAccountView()) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(Color("CustomBlue"))
                    
                }
            }
            .padding(.horizontal)
            
            Text("My Activities")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
    }
}

struct WeekdayHeaderView: View {
    var body: some View {
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
    }
}

struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    @Binding var showingDetailView: Bool
    @ObservedObject var viewModel: ActivitiesViewModel
    
    private let calendar = Calendar.current
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(getDaysInMonth(), id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasActivities: viewModel.hasActivities(for: date)
                    ) {
                        selectedDate = date
                        showingDetailView = true
                        viewModel.fetchActivities(for: date)
                    }
                } else {
                    Color.clear
                        .frame(height: 100)
                }
            }
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
        
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasActivities: Bool
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
                            .fill(isSelected ? Color("CustomBlue") : Color.clear)
                    )
                    .padding(.top, 8)
                    .padding(.leading, 8)
                
                if hasActivities {
                    Circle()
                        .fill(Color("CustomBlue"))
                        .frame(width: 6, height: 6)
                        .padding(.leading, 21)
                }
                
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

struct DetailView: View {
    let date: Date
    @ObservedObject var viewModel: ActivitiesViewModel
    @Environment(\.presentationMode) var presentationMode

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading activities...")
                } else if viewModel.activities.isEmpty {
                    VStack(spacing: 20) {
                        Text("No activities for this day")
                            .foregroundColor(.gray)
                    }
                } else {
                    List(viewModel.activities) { activity in
                        Section(header: Text(activity.groupName)
                                    .font(.headline)
                                    .foregroundColor(.primary)) {
                            ActivityRow(activity: activity, timeFormatter: timeFormatter)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(dateFormatter.string(from: date))
                            .font(.subheadline) // Smaller font size for the title
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchActivities(for: date)
        }
    }
}


struct ActivityRow: View {
    let activity: GroupEvent
    let timeFormatter: DateFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activity.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ForEach(activity.tasks) { task in
                Text(task.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(Color("CustomBlue"))
                Text("\(timeFormatter.string(from: activity.startDate.dateValue())) - \(timeFormatter.string(from: activity.endDate.dateValue()))")
                    .font(.caption)
            }
            
            ForEach(activity.locations, id: \.name) { location in
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.red)
                    Text(location.name)
                        .font(.caption)
                }
            }
            
            if !activity.participants.isEmpty {
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.green)
                    Text("\(activity.participants.count) participants")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}


struct MonthPickerView: View {
    @Binding var currentMonth: Date
    @Binding var showingMonthPicker: Bool
    
    var body: some View {
        NavigationView {
            DatePicker(
                "Select Month",
                selection: $currentMonth,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            .navigationTitle("Select Month")
            .navigationBarItems(
                trailing: Button("Done") {
                    showingMonthPicker = false
                }
            )
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
