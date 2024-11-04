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
                    .padding(.horizontal, 10)
                    
                    TextField("Write a comment (Optional)", text: $comment)
                        .padding()
                        .cornerRadius(10)
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 2)
                            )
                        .padding(.horizontal,10)
                    
                    Text("Select your favorite place")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 15) {
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
                    .padding(.horizontal,10)
                    
                    Button(action: {
                        // Handle submit action
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("CustomBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(50)
                            .padding(.horizontal,30)
                    }
                    
                    Text("Submitted members")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(submittedMembers) { member in
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.gray)
                                    Text(member.name)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                HStack(spacing: 10) {
                                    Image(systemName: "message.fill")
                                        .foregroundColor(Color("CustomBlue"))
                                    Text(member.availability)
                                        .font(.system(size: 17))
                                        .foregroundColor(Color("CustomBlue"))
                                        .fontWeight(.medium)
                                }
                                HStack(spacing: 10) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(Color("CustomBlue"))
                                    Text(member.location)
                                        .font(.system(size: 17))
                                }
                                Text("Available From: \(member.fromDate.formatted(date: .numeric, time: .omitted)) to: \(member.toDate.formatted(date: .numeric, time: .omitted))")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(.black))
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
