//
//  AvailabilityListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct AvailabilityView: View {
    @Environment(\.dismiss) private var dismiss
    
    struct MemberAvailability: Identifiable {
        let id = UUID()
        let name: String
        let availability: String
        let location: String
        let startDate: Date
        let endDate: Date
    }
    
    let members: [MemberAvailability] = [
        MemberAvailability(
            name: "Nimesh",
            availability: "I am free in the next 10 days",
            location: "Seethawaka Miracle Nature Resort",
            startDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 10))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 20))!
        ),
        MemberAvailability(
            name: "Dilanjana",
            availability: "I am free in the next two weeks",
            location: "Seethawaka Miracle Nature Resort",
            startDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 10))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 24))!
        ),
        MemberAvailability(
            name: "Lakshan",
            availability: "I am free in the next three weeks",
            location: "Seethawaka Miracle Nature Resort",
            startDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 10))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 31))!
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Your availability section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your availability")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal)
                        
                        ForEach([members[0]], id: \.id) { member in
                            MemberCard(member: member, isEditable: true)
                        }
                    }
                    Spacer()
                    
                    // Submitted members section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Submitted members")
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.horizontal)
                        
                        ForEach(members.dropFirst(), id: \.id) { member in
                            MemberCard(member: member, isEditable: false)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("October day out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .regular))
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct MemberCard: View {
    let member: AvailabilityView.MemberAvailability
    let isEditable: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(member.name.prefix(1).uppercased())
                            .foregroundColor(.gray)
                    )
                
                Text(member.name)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isEditable {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(Color("CustomBlue"))
                    Text(member.availability)
                        .font(.system(size: 17))
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Color("CustomBlue"))
                    Text(member.location)
                        .font(.system(size: 17))
                }
                
                Text("Available From: \(formattedDate(member.startDate)) to: \(formattedDate(member.endDate))")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

// Preview provider
struct AvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        AvailabilityView()
    }
}
