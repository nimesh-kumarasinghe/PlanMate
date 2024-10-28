//
//  VotingProposeActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct VotingProposeActivityView: View {
    @State private var fromDate = Date()
    @State private var toDate = Date()
    @State private var comment = ""
    @State private var selectedLocation = "Seethawaka Miracle Nature Resort"
    
    let locations = [
        "Seethawaka Miracle Nature Resort",
        "Pearl Grand By Rathna",
        "Leaf Olu Ella",
        "Kithul Kanda Mountain Resort",
        "Me Colombo Day Outing"
    ]
    
    struct SubmittedMember: Identifiable {
        let id = UUID()
        let name: String
        let availability: String
        let location: String
        let fromDate: Date
        let toDate: Date
    }
    
    let submittedMembers = [
        SubmittedMember(
            name: "Dilanjana",
            availability: "I am free in the next two weeks",
            location: "Seethawaka Miracle Nature Resort",
            fromDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 10))!,
            toDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 24))!
        ),
        SubmittedMember(
            name: "Lakshan",
            availability: "I am free in the next three weeks",
            location: "Seethawaka Miracle Nature Resort",
            fromDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 10))!,
            toDate: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 31))!
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Select your availability")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("From")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker("", selection: $fromDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }
                        HStack {
                            Text("To")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker("", selection: $toDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    TextField("Write a comment (Optional)", text: $comment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 4)
                    
                    Text("Select your favorite place")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(locations, id: \.self) { location in
                            HStack {
                                Image(systemName: selectedLocation == location ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedLocation == location ? .blue : .gray)
                                Text(location)
                                    .font(.subheadline)
                            }
                            .onTapGesture {
                                selectedLocation = location
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Button(action: {
                        // Handle submit action
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Text("Submitted members")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(submittedMembers) { member in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.gray)
                                    Text(member.name)
                                        .font(.headline)
                                }
                                Text(member.availability)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.gray)
                                    Text(member.location)
                                        .font(.subheadline)
                                }
                                Text("Available From: \(member.fromDate.formatted(date: .numeric, time: .omitted)) to: \(member.toDate.formatted(date: .numeric, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Campus Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VotingProposeActivityView()
}
