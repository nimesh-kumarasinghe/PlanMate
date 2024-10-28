//
//  AvailabilityListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct AvailabilityListView: View {
    // Model for member data
    struct Member: Identifiable {
        let id = UUID()
        let name: String
        let availability: String
        let location: String
        let dateFrom: String
        let dateTo: String
    }
    
    // Sample data
    let members = [
        Member(name: "Nimesh",
               availability: "I am free in the next 10 days",
               location: "Seethawaka Miracle Nature Resort",
               dateFrom: "10 Oct 2024",
               dateTo: "20 Oct 2024"),
        Member(name: "Dilanjana",
               availability: "I am free in the next two weeks",
               location: "Seethawaka Miracle Nature Resort",
               dateFrom: "10 Oct 2024",
               dateTo: "24 Oct 2024"),
        Member(name: "Lakshan",
               availability: "I am free in the next three weeks",
               location: "Seethawaka Miracle Nature Resort",
               dateFrom: "10 Oct 2024",
               dateTo: "31 Oct 2024")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Button(action: {
                    // Add back action here
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("October day out")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .bottom
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your availability")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Member cards
                    ForEach(members) { member in
                        MemberCard(member: member)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
    }
}

struct MemberCard: View {
    let member: AvailabilityListView.Member
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with avatar and name
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(member.name)
                    .font(.system(.body, design: .default))
                
                Spacer()
                
                Button(action: {
                    // Add edit action here
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.blue)
                }
            }
            
            // Availability text
            Text(member.availability)
                .foregroundColor(.secondary)
            
            // Location
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text(member.location)
            }
            .foregroundColor(.secondary)
            
            // Date range
            Text("Available From: \(member.dateFrom) to: \(member.dateTo)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// Preview provider for SwiftUI canvas
struct AvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        AvailabilityListView()
    }
}
